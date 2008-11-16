module Magenta
  module Generator

    class Common
      def self.generate(base_filename,instruction_set)
        g = self.new
        File.open("#{base_filename}declarations.inc","w") do |f|
          g.generate_declarations(f,instruction_set)
        end
        File.open("#{base_filename}stack-accessors.inc","w") do |f|
          g.generate_stack_accessors(f,instruction_set)
        end
      end

      def generate_declarations(writer,instruction_set)

        # generate typedefs for data_types
        instruction_set.data_types.each_value do |data_type|
          generate_data_type_declaration(writer,data_type)
        end
        
        # generate typedefs for stacks
        instruction_set.stacks.each_value do |stack|
          generate_stack_declaration(writer,stack)
        end
        
        # generate converter macros between types
        instruction_set.data_types.each_value do |source|
          instruction_set.data_types.each_value do |destination|
            generate_data_type_converter(writer,source,destination)
          end
        end
        
        # generate printing prototypes for debugging/disassembling
        writer.write "#if (VM_DEBUG || VM_DISASSEMBLER)\n"
        instruction_set.data_types.each_value do |stack|
          generate_data_type_debug(writer,stack)
        end
        writer.write "#endif //(VM_DEBUG || VM_DISASSEMBLER)\n"
      end

      def generate_stack_accessors(writer,instruction_set)
        instruction_set.stacks.each_value do |stack|
          generate_stack_accessor(writer,stack)
        end
      end

private
      def generate_stack_accessor(writer,stack)
        # TODO: Support caching of N items (where N is 0->6) in variables rather than 
        # on stack. To avoid copying between stack and variables we can keep a state
        # variable for interpreter and duplicate the code to execute instructions for 
        # each different state (i.e. GET_X_STACK_ITEM_Y is redefined in each state).
        # This can probably only be done with the default stack to aovid code explosion
        (0..Magenta::Instruction::MAX_STACK_ENTRY_COUNT).each do |index|
          accessor = "GET_#{stack.name}_STACK_ITEM_#{index}"
          mutator = "PUT_#{stack.name}_STACK_ITEM_#{index}"
          writer.write <<-GEN
#ifdef #{accessor}
#  undef #{accessor}
#endif
#define #{accessor}() (sp_#{stack.name}[#{index}])
GEN
          unless stack.instruction_stack?
            writer.write <<-GEN
#ifdef #{mutator}
#  undef #{mutator}
#endif
#define #{mutator}(value) (sp_#{stack.name}[#{index}] = value)
GEN
          end
          
          writer.write "\n\n"
        end
      end

      def generate_data_type_converter(writer,source,destination)
        converter_code = source.converters[destination.name]
        unless converter_code
          converter_code = "source" if source.c_type == destination.c_type
        end
      
        if converter_code
          writer.write <<-GEN 
static inline #{destination.to_native_type} vm_convert_#{source.name}_to_#{destination.name}(const #{source.to_native_type} source)          
{
  return #{converter_code};
}
GEN
        end
      end

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