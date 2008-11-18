RUBY_DIR=src/main/ruby
C_DIR=src/main/c

RUBY=ruby
LEX=flex -l
YACC=bison -y
GCC=gcc

DEBUG=0
ASSEMBLER=0

DEFINES=

ifeq ($(ASSEMBLER),1)
DEFINES+=-DMG_DISASSEMBLER
endif

ifeq ($(DEBUG),1)
DEFINES+=-DMG_DEBUG -g
else
DEFINES+=-O3
endif

INCLUDES=-I generated -I $(C_DIR) 

COMPILE=$(GCC) $(INCLUDES) $(DEFINES)

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

generated/scanner.inc: $(C_DIR)/example.l generated
	$(LEX) -o generated/scanner.inc $(C_DIR)/example.l 

generated/parser.c: $(C_DIR)/example.y
	$(YACC) -o generated/parser.c $(C_DIR)/example.y

target/magenta: target generated/declarations.h generated/stack-accessors.c generated/execution-engine.c $(C_DIR)/driver.c  $(C_DIR)/engine.c  $(C_DIR)/support.h $(C_DIR)/disassembler.c generated/scanner.inc generated/parser.c
	$(COMPILE) -o target/parser.o generated/parser.c -c
ifeq ($(ASSEMBLER),1)
	$(COMPILE) -o target/disassembler.o $(C_DIR)/disassembler.c -c
endif
	$(COMPILE) -o target/magenta  $(C_DIR)/engine.c $(C_DIR)/driver.c -Wall target/*.o