require File.join( File.dirname(__FILE__), 'magenta', 'magenta.rb' )

my_instruction_set = Magenta::InstructionSet.define do 
  
  data_type "integer", "i", "int"
  data_type "word", "w", "int"
  
  #stack "instruction", "#", "word"
  stack "instruction", "#", "integer"
  stack "data", "%", "integer", :default => true
  
  instruction "exit", [], [] do |i|
    i.description = "Exit the interpreter."
    i.code = 'exit(0);'
  end

  instruction "drop", ["iA"], [] do |i|
    i.description = "Pop a literal from data stack and discard."
    i.code = ""
  end

  instruction "literali", ["#iA"], ["iB"] do |i|
    i.description = "Push an integer literal onto data stack."
    i.code = "iB = iA"
  end
  
  instruction "addi", ["iA","iB"], ["iC"] do |i|
    i.description = "Add two integers together."
    i.code = "iC = iA + iB"
  end

  instruction "subi", ["iA","iB"], ["iC"] do |i|
    i.description = "Subtract one integer from another."
    i.code = "iC = iA - iB"
  end

  instruction "divi", ["iA","iB"], ["iC"] do |i|
    i.description = "Divide one integer by another."
    i.code = "iC = iA / iB"
  end

  instruction "modi", ["iA","iB"], ["iC"] do |i|
    i.description = "Modulus one integer by another."
    i.code = "iC = iA % iB"
  end
  
  instruction "negi", ["iA"], ["iB"] do |i|
    i.description = "Negate an integer."
    i.code = "iB = -iA"
  end
  
  instruction "printi", ["iA"], [] do |i|
    i.description = "Print an integer."
    i.code = 'printf("%d\n",iA)'
  end
  
end

Magenta::Generator::Common.generate("generated/",my_instruction_set)
Magenta::Generator::ExecutionEngine.generate("generated/",my_instruction_set)