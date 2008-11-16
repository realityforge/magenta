module Magenta

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
    attr_accessor :bytecode
    attr_accessor :name
    attr_accessor :description
    attr_accessor :code
    attr_accessor :stack_before
    attr_accessor :stack_after
  
    def stack_diff(stack)
        before = self.stack_before.find_all {|stack_entry| stack_entry.stack == stack}.length 
        after = self.stack_after.find_all {|stack_entry| stack_entry.stack == stack}.length
        before - after
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
      @next_instruction_bytecode = 0
      @instructions = []
      @data_types = {}
      @stacks = {}
      @default_stack = nil
    end
  
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
    def data_type(name, prefix,c_type)
      dt = DataType.new
      dt.name = name
      dt.prefix = prefix
      dt.c_type = c_type
      @data_types[prefix] = dt
      dt
    end

    #  
    # i.e
    #
    # instruction "add", ["iA","iB"], ["iC"] do |i|
    #   i.description = "Add two integers together."
    #   i.code = "iC = iA + iB"
    # end
    #
    def instruction(name,stack_before,stack_after)
      i =  Instruction.new
      i.name = name
      i.bytecode = @next_instruction_bytecode
      @next_instruction_bytecode = @next_instruction_bytecode + 1
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
      name = description[type_index,description.length - type_index]
      se = StackEntry.new
      se.stack = stack
      se.entry_type = entry_type
      se.name = name
      se
    end
  end

end