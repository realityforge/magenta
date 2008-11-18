module Magenta

  class DataType
    attr_accessor :name
    attr_accessor :prefix
    attr_accessor :c_type
    attr_accessor :converters
    
    def initialize
      @converters = {}
    end
    
    def converter(name,code)
      @converters[name] = code
    end

    def to_native_type
      "#{name}_data_type_t"
    end
  end

  class Stack
    INSTRUCTION_STACK_NAME = "instruction"
    
    attr_accessor :name
    attr_accessor :prefix
    attr_accessor :element_type
    
    def instruction_stack?
      self.name == INSTRUCTION_STACK_NAME
    end
  end

  class StackEntry
    attr_accessor :stack
    attr_accessor :entry_type
    attr_accessor :name
  end

  class Instruction
    MAX_STACK_ENTRY_COUNT = 5
    
    # bytecodes start at 1. 0 is reserved for end of interpretation
    attr_accessor :bytecode
    attr_accessor :name
    attr_accessor :description
    attr_accessor :code
    attr_accessor :stack_before
    attr_accessor :stack_after
    attr_accessor :options
  
    def stack_diff(stack)
        before = self.stack_before.find_all {|stack_entry| stack_entry.stack == stack}.length 
        after = self.stack_after.find_all {|stack_entry| stack_entry.stack == stack}.length
        before - after
    end
    
    def terminator?
      options[:terminator] == true
    end
  
  end

  class InstructionSet
    attr_reader :data_types
    attr_reader :stacks
    attr_reader :instructions
  
    def self.define(&block)
      is = InstructionSet.new
      is.instance_eval &block
      is
    end
  
    def initialize
      @next_instruction_bytecode = 1
      @instructions = []
      @data_types = {}
      @stacks = {}
      @default_stack = nil
    end
  
    # 
    # NOTE: There MUST be an instruction stack named "instruction". There should also be
    # at least one other stack with default flag set to true.  
    # 
    # i.e
    #
    # stack "instruction", "#", "word"
    # stack "data", "%", "integer", :default => true
    #
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
  
    #  
    # i.e
    #
    # data_type "integer", "i", "int"
    #
    def data_type(name, prefix, c_type, &block)
      dt = DataType.new
      dt.name = name
      dt.prefix = prefix
      dt.c_type = c_type
      @data_types[prefix] = dt
      yield dt if block
      dt
    end

    #  
    # NOTE: The first instruction (with bytecode = 0) is considered a special 
    # instruciton that exits interpreter. 
    # 
    # i.e
    #
    # instruction "add", ["iA","iB"], ["iC"] do |i|
    #   i.description = "Add two integers together."
    #   i.code = "iC = iA + iB"
    # end
    #
    def instruction(name,stack_before,stack_after, options = {})
      i =  Instruction.new
      i.name = name
      i.options = options
      i.bytecode = @next_instruction_bytecode
      @next_instruction_bytecode = @next_instruction_bytecode + 1
      i.stack_before = stack_before.collect { |se| parse_stack_entry(se) }
      if i.stack_before.length > Instruction::MAX_STACK_ENTRY_COUNT
        raise "The number of stack elements consumed is greater than the max for instruction #{name}" 
      end
      i.stack_after = stack_after.collect { |se| parse_stack_entry(se) }
      if i.stack_after.length > Instruction::MAX_STACK_ENTRY_COUNT
        raise "The number of stack elements produced is greater than the max for instruction #{name}" 
      end
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
      name = description[type_index,description.length - type_index]
      se = StackEntry.new
      se.stack = stack
      se.entry_type = entry_type
      se.name = name
      se
    end
  end

end