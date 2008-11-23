module Magenta
  module Generator

    class Driver
      def self.generate(base_filename, instruction_set, options = {})
        params = {
          :assembler => true,
          :disassembler => true,
          :interpreter => true,
        }.update(options)

        Common.generate(base_filename, instruction_set)
        Assembler.generate(base_filename, instruction_set) if params[:assembler]
        Disassembler.generate(base_filename, instruction_set) if params[:disassembler]
        Interpreter.generate(base_filename, instruction_set) if params[:interpreter]          
      end
    end

  end
end