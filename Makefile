RUBY=ruby
DEFINES=-DVM_DEBUG -DVM_DISASSEMBLER

RUBY_DIR=src/main/ruby
C_DIR=src/main/c

main: target/magenta

clean:
	rm -rf target generated

generated: 
	mkdir -p generated

target: 
	mkdir -p target
	
$(RUBY_DIR)/example.rb: $(RUBY_DIR)/magenta/magenta.rb $(RUBY_DIR)/magenta/model.rb $(RUBY_DIR)/magenta/generator/assembler.rb $(RUBY_DIR)/magenta/generator/common.rb $(RUBY_DIR)/magenta/generator/interpreter.rb $(RUBY_DIR)/magenta/generator/disassembler.rb
	touch $(RUBY_DIR)/example.rb

generated/execution-engine.c: $(RUBY_DIR)/example.rb generated
	$(RUBY) $(RUBY_DIR)/example.rb
	
generated/stack-accessors.c: $(RUBY_DIR)/example.rb generated
	$(RUBY) $(RUBY_DIR)/example.rb

generated/declarations.h: $(RUBY_DIR)/example.rb generated
	$(RUBY) $(RUBY_DIR)/example.rb
	
target/magenta: target generated/declarations.h generated/stack-accessors.c generated/execution-engine.c $(C_DIR)/driver.c  $(C_DIR)/engine.c  $(C_DIR)/support.h $(C_DIR)/disassembler.c 
	gcc $(DEFINES) -o target/magenta $(C_DIR)/engine.c $(C_DIR)/driver.c $(C_DIR)/disassembler.c -Wall -Werror -I generated