module Magenta
  module Generator

    class Disassembler
      def self.generate(base_filename,instruction_set)
        g = self.new
        File.open("#{base_filename}disassembler.inc","w") do |f|
          g.generate_disassembler(f,instruction_set)
        end
      end
  
      def generate_disassembler(writer,instruction_set)
        instruction_set.instructions.each do |instruction|
          generate_instruction_disassembler(writer,instruction_set,instruction)
        end
      end

private  
      def generate_instruction_disassembler(writer,instruction_set,instruction)
        writer.write <<-GEN
  /* 
    #{instruction.description}
  */
  START_INSTRUCTION(#{instruction.name},#{instruction.bytecode})
  {
    fputs("#{instruction.name}", vm_out);
GEN
        instruction.stack_before.each_with_index do |stack_entry, index|
          stack = stack_entry.stack
          next unless stack.instruction_stack?
          entry_type = stack_entry.entry_type
          stack_type = stack.element_type.name
          converter = (entry_type.name == stack_type) ? "" : "vm_convert_#{stack_type}_to_#{entry_type.name}"
          writer.write <<-GEN
    MAYBE_UNUSED const #{entry_type.to_native_type} #{stack_entry.name} = #{converter}(GET_#{stack.name}_STACK_ITEM_#{index}());
    fputs(" ", vm_out);
    printarg_#{entry_type.name}(vm_out,#{stack_entry.name});
GEN
        end

        instruction_set.stacks.each_value do |stack|
          next unless stack.instruction_stack?
          stack_diff = instruction.stack_diff(stack)
          writer.write "    sp_#{stack.name} += #{stack_diff};\n" unless stack_diff == 0
        end

        writer.write <<-GEN
    fputs("\\n", vm_out);
    END_INSTRUCTION;
  }


GEN
      end
    end

  end
end