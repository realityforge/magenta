module Magenta
  module Generator

    class Assembler
      def self.generate(base_filename,instruction_set)
        g = self.new
        File.open("#{base_filename}assembler.inc","w") do |f|
          g.generate_builder(f,instruction_set)
        end
        File.open("#{base_filename}instruction-table.inc","w") do |f|
          g.generate_instruction_table(f,instruction_set)
        end
      end
  
      def generate_builder(writer,instruction_set)
        instruction_set.instructions.each do |instruction|
          generate_instruction_builder(writer,instruction_set,instruction)
        end
      end

      def generate_instruction_table(writer,instruction_set)
        instruction_set.instructions.each do |instruction|
          writer.write <<-GEN
INSTRUCTION(#{instruction.name},#{instruction.bytecode})
GEN
        end
      end

private  
      def generate_instruction_builder(writer,instruction_set,instruction)
        writer.write "IB_API void mgGen_#{instruction.name}(instruction_stack_t **instructions, int *remaining"
        inline = instruction.stack_before.find_all {|se| se.stack.instruction_stack?}
        instruction_size = 1 
        inline.each do |stack_entry|
          writer.write ", const #{stack_entry.entry_type.to_native_type} #{stack_entry.name}"
          instruction_size = instruction_size + 1
        end

        writer.write <<-GEN
)        
{
  if( *remaining < #{instruction_size} ) { panic("Instruction #{instruction.name} requires more bytes in code buffer than are remaining"); }
  mgInstructionAppend(instructions,INSTRUCTION_CODE(#{instruction.bytecode}));
GEN

inline.each do |stack_entry|
  writer.write "  mgInstructionAppend(instructions,#{stack_entry.name});\n"
end

        writer.write <<-GEN
}


GEN
      end
    end

  end
end