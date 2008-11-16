
class ExecutionEngineGenerator
  def self.generate(filename,instruction_set)
    File.open(filename,"w") do |f|
      ExecutionEngineGenerator.new.generate(f,instruction_set)
    end
  end
  
  def generate(writer,instruction_set)
    instruction_set.instructions.each do |instruction|
      generate_instruction(writer,instruction_set,instruction)
    end
  end
  
  private
  
  def generate_instruction(writer,instruction_set,instruction)
    writer.write <<-GEN
  LABEL(#{instruction.name})
  {
    DBG_START_INSTRUCTION(#{instruction.name})
GEN
    instruction.stack_before.each_with_index do |stack_entry, index|
      # TODO: GET_STACK_ITEM_* has to deal with different stacks
      entry_type = stack_entry.entry_type
      stack = stack_entry.stack
      stack_type = stack.element_type.name
      converter = (entry_type.name == stack_type) ? "" : "vm_convert_#{stack_type}_to_#{entry_type.name}"
      writer.write <<-GEN
    const #{entry_type.c_type} #{stack_entry.name} = #{converter}(GET_#{stack.name}_STACK_ITEM_#{index}());
    DBG_ARG(#{stack_entry.name},#{entry_type.name})
GEN
    end

    instruction.stack_after.reverse.each do |stack_entry|
      writer.write <<-GEN
    #{stack_entry.entry_type.c_type} #{stack_entry.name};
GEN
    end

    writer.write <<-GEN
    DBG_STACK_EFFECT_SEPARATOR
GEN
    instruction_set.stacks.each_value do |stack|
      stack_diff = instruction.stack_diff(stack)
      writer.write "    sp_#{stack.name} += #{stack_diff}\n" unless stack_diff == 0
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
GEN
    instruction.stack_after.reverse.each_with_index do |stack_entry, index|
      entry_type = stack_entry.entry_type
      stack = stack_entry.stack
      stack_type = stack.element_type.name
      converter = (entry_type.name == stack_type) ? "" : "vm_convert_#{entry_type.name}_to_#{stack_type}"
      writer.write <<-GEN
    PUT_#{stack.name}_STACK_ITEM_#{index}(#{converter}(#{stack_entry.name}))
    DBG_ARG(#{stack_entry.name},#{entry_type.name})
GEN
    end

    writer.write <<-GEN
    DBG_END_INSTRUCTION
  }
GEN
  end
end
