class DataType
  attr_accessor :name
  attr_accessor :prefix
  attr_accessor :c_type
end

class Stack
  attr_accessor :name
  attr_accessor :prefix
  attr_accessor :element_type
end

class StackEntry
  attr_accessor :stack
  attr_accessor :entry_type
  attr_accessor :name
end

class Instruction
  attr_accessor :code
  attr_accessor :name
  attr_accessor :description
  attr_accessor :code
  attr_accessor :stack_before
  attr_accessor :stack_after
end

class InstructionSet
  attr_reader :stacks
  attr_reader :instructions
  
  def self.define(&block)
    is = InstructionSet.new
    is.instance_eval &block
    is
  end
  
  def initialize
    @next_instruction_code = 0
    @instructions = []
    @data_types = {}
    @stacks = {}
    @default_stack = nil
  end
  
  def stack(name,prefix,element_type_name,options = {})
    stack = Stack.new
    stack.name = name
    stack.prefix = prefix
    @data_types.each_value do |data_type| 
      stack.element_type = data_type if data_type.name == element_type_name 
    end
    raise "Unknown element_type '#{element_type_name}' for stack named '#{name}'" unless stack.element_type
    @stacks[prefix] = stack
    @default_stack = stack if (options[:default] == true)
    stack
  end
  
  def data_type(name, prefix,c_type)
    dt = DataType.new
    dt.name = name
    dt.prefix = prefix
    dt.c_type = c_type
    @data_types[prefix] = dt
    dt
  end
  
  #
  # instruction "add", ["iA","iB"], ["iC"] do |i|
  #   i.description = "Add two integers together."
  #   i.code = "iC = iA + iB"
  # end
  #
  def instruction(name,stack_before,stack_after)
    i =  Instruction.new
    i.name = name
    i.code = @next_instruction_code
    @next_instruction_code = @next_instruction_code + 1
    i.stack_before = stack_before.collect { |se| parse_stack_entry(se) }
    i.stack_after = stack_after.collect { |se| parse_stack_entry(se) }
    yield i
    @instructions << i
    i
  end

private

  def parse_stack_entry(description)
    stack = @stacks[description[0,1]]
    type_index = stack.nil? ? 0 : 1
    stack = @default_stack unless stack
    raise "Unable to determine stack for '#{description}' and no default stack specified" unless stack
    type_prefix = description[type_index,1]
    entry_type = @data_types[type_prefix]
    raise "Unknown type prefix for '#{description}'" unless entry_type
    name = description[type_index,1]
    se = StackEntry.new
    se.stack = stack
    se.entry_type = entry_type
    se.name = name
    se
  end
end

class ExecutionEngineGenerator
  def self.generate(filename,instruction_set)
    File.open(filename,"w") do |f|
      ExecutionEngineGenerator.new.generate(f,instruction_set)
    end
  end
  
  def generate(writer,instruction_set)
    instruction_set.instructions.each do |instruction|
      generate_instruction(writer,instruction_set,instruction)
    end
  end
  
  private
  
  def generate_instruction(writer,instruction_set,instruction)
    writer.write <<-GEN
  LABEL(#{instruction.name})
  {
    DBG_START_INSTRUCTION(#{instruction.name})
GEN
    instruction.stack_before.each_with_index do |stack_entry, index|
      # TODO: GET_STACK_ITEM_* has to deal with different stacks
      entry_type = stack_entry.entry_type
      stack = stack_entry.stack
      stack_type = stack.element_type.name
      converter = (entry_type.name == stack_type) ? "" : "vm_convert_#{stack_type}_to_#{entry_type.name}"
      writer.write <<-GEN
    const #{entry_type.c_type} #{stack_entry.name} = #{converter}(GET_#{stack.name}_STACK_ITEM_#{index}());
    DBG_ARG(#{stack_entry.name},#{entry_type.name})
GEN
    end

    instruction.stack_after.reverse.each do |stack_entry|
      writer.write <<-GEN
    #{stack_entry.entry_type.c_type} #{stack_entry.name};
GEN
    end

    writer.write <<-GEN
    DBG_STACK_EFFECT_SEPARATOR
GEN
    instruction_set.stacks.each_value do |stack|
      stack_diff = 
        instruction.stack_before.collect {|stack_entry| stack_entry.stack == stack}.length - 
        instruction.stack_after.collect {|stack_entry| stack_entry.stack == stack}.length
      writer.write <<-GEN
    sp_#{stack.name} += #{stack_diff}
GEN
    end

    # TODO: Should put in preprocessor directives to indicate the source
    # instruction location. i.e. 
    #   #line 44 "MyInstructions.rb" 
    #   ...code... 
    #   #line 423 "MyGeneratedEngine.c"
    writer.write <<-GEN
    {
      #{instruction.code};
    }
GEN
    instruction.stack_after.reverse.each_with_index do |stack_entry, index|
      entry_type = stack_entry.entry_type
      stack = stack_entry.stack
      stack_type = stack.element_type.name
      converter = (entry_type.name == stack_type) ? "" : "vm_convert_#{entry_type.name}_to_#{stack_type}"
      writer.write <<-GEN
    PUT_#{stack.name}_STACK_ITEM_#{index}(#{converter}(#{stack_entry.name}))
    DBG_ARG(#{stack_entry.name},#{entry_type.name})
GEN
    end

    writer.write <<-GEN
    DBG_END_INSTRUCTION
  }
GEN
  end
end
