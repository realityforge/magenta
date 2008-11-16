module Magenta
  module Generator

    class ExecutionEngine
      def self.generate(filename,instruction_set)
        g = self.new
        File.open("#{filename}execution-engine.c","w") do |f|
          g.generate_execution_engine(f,instruction_set)
        end
        File.open("#{filename}stack-accessors.c","w") do |f|
          g.generate_stack_accessors(f,instruction_set)
        end
        File.open("#{filename}declarations.h","w") do |f|
          g.generate_declarations(f,instruction_set)
        end
      end
  
      def generate_execution_engine(writer,instruction_set)
        instruction_set.instructions.each do |instruction|
          generate_instruction_executor(writer,instruction_set,instruction)
        end
      end

      def generate_stack_accessors(writer,instruction_set)
        instruction_set.stacks.each_value do |stack|
          generate_stack_accessor(writer,stack)
        end
      end

      def generate_declarations(writer,instruction_set)
        instruction_set.stacks.each_value do |stack|
          generate_stack_declaration(writer,stack)
        end
      end

private
      def generate_stack_declaration(writer,stack)
          writer.write <<-GEN
typedef #{stack.element_type.c_type} #{stack.name}_stack_t;          
GEN
      end

      def generate_stack_accessor(writer,stack)
        # TODO: Support caching of N items (where N is 0->6) in variables rather than 
        # on stack. To avoid copying between stack and variables we can keep a state
        # variable for interpreter and duplicate the code to execute instructions for 
        # each different state (i.e. GET_X_STACK_ITEM_Y is redefined in each state).
        # This can probably only be done with the default stack to aovid code explosion
        (0..5).each do |index|
          accessor = "GET_#{stack.name}_STACK_ITEM_#{index}"
          mutator = "PUT_#{stack.name}_STACK_ITEM_#{index}"
          writer.write <<-GEN
#ifdef #{accessor}
#  undef #{accessor}
#endif
#define #{accessor}() (sp_#{stack.name}[#{index}])

#ifdef #{mutator}
#  undef #{mutator}
#endif
#define #{mutator}(value) (sp_#{stack.name}[#{index}] = value)


GEN
        end
      end
  
      def generate_instruction_executor(writer,instruction_set,instruction)
        writer.write <<-GEN
  /* 
    #{instruction.description}
  */
  START_INSTRUCTION(#{instruction.name},#{instruction.bytecode})
  {
    DBG_START_INSTRUCTION(#{instruction.name});
GEN
        instruction_set.stacks.each_value do |stack|
          writer.write <<-GEN
    DBG_STACK_POINTER(#{stack.name});
GEN
        end

        instruction.stack_before.each_with_index do |stack_entry, index|
          entry_type = stack_entry.entry_type
          stack = stack_entry.stack
          stack_type = stack.element_type.name
          converter = (entry_type.name == stack_type) ? "" : "vm_convert_#{stack_type}_to_#{entry_type.name}"
          writer.write <<-GEN
    const #{entry_type.c_type} #{stack_entry.name} = #{converter}(GET_#{stack.name}_STACK_ITEM_#{index}());
    DBG_ARG(#{stack_entry.name},#{entry_type.name});
GEN
        end

        instruction.stack_after.reverse.each do |stack_entry|
          writer.write <<-GEN
    #{stack_entry.entry_type.c_type} #{stack_entry.name};
GEN
        end

        writer.write <<-GEN
    DBG_STACK_EFFECT_SEPARATOR;
GEN
        instruction_set.stacks.each_value do |stack|
          stack_diff = instruction.stack_diff(stack)
          writer.write "    sp_#{stack.name} += #{stack_diff};\n" unless stack_diff == 0
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
    PREFETCH_NEXT_INSTRUCTION;
GEN
        instruction.stack_after.reverse.each_with_index do |stack_entry, index|
          entry_type = stack_entry.entry_type
          stack = stack_entry.stack
          stack_type = stack.element_type.name
          converter = (entry_type.name == stack_type) ? "" : "vm_convert_#{entry_type.name}_to_#{stack_type}"
          writer.write <<-GEN
    PUT_#{stack.name}_STACK_ITEM_#{index}(#{converter}(#{stack_entry.name}));
    DBG_ARG(#{stack_entry.name},#{entry_type.name});
GEN
        end

        writer.write <<-GEN
    DBG_END_INSTRUCTION;
    END_INSTRUCTION;
  }


GEN
      end
    end

  end
end