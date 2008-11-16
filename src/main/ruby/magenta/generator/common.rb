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
      end

private
      def generate_data_type_declaration(writer,data_type)
          writer.write <<-GEN
typedef #{data_type.c_type} #{data_type.name}_data_type_t;          
GEN
      end

      def generate_stack_declaration(writer,stack)
          writer.write <<-GEN
typedef #{stack.element_type.name}_data_type_t #{stack.name}_stack_t;          
GEN
      end

    end
  end
end