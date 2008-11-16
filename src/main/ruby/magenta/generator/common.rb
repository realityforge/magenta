module Magenta
  module Generator

    class Common
      def self.generate(base_filename,instruction_set)
        g = self.new
        File.open("#{base_filename}declarations.h","w") do |f|
          g.generate_declarations(f,instruction_set)
        end
      end

      def generate_declarations(writer,instruction_set)
        instruction_set.data_types.each_value do |stack|
          generate_data_type_declaration(writer,stack)
        end
        instruction_set.stacks.each_value do |stack|
          generate_stack_declaration(writer,stack)
        end
        writer.write "#ifdef VM_DEBUG\n"
        instruction_set.data_types.each_value do |stack|
          generate_data_type_debug(writer,stack)
        end
        writer.write "#endif //VM_DEBUG\n"
      end

private
      def generate_data_type_declaration(writer,data_type)
          writer.write <<-GEN
typedef #{data_type.c_type} #{data_type.to_native_type};          
GEN
      end

      def generate_stack_declaration(writer,stack)
          writer.write <<-GEN
typedef #{stack.element_type.to_native_type} #{stack.name}_stack_t;          
GEN
      end

      def generate_data_type_debug(writer,data_type)
          writer.write <<-GEN
extern void printarg_#{data_type.name}(FILE *vm_out, const #{data_type.to_native_type} value );
GEN
      end

    end
  end
end