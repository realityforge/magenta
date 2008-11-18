RUBY_DIR=src/main/ruby
C_DIR=src/main/c

RUBY=ruby
LEX=flex -l
YACC=bison -y
GCC=gcc

DEBUG=0
ASSEMBLER=0

# -pedantic -pedantic-errors -Wextra 
STRICTNESS_DEFINES=-Wall -Wextra
DEFINES=-std=c99 -Wfatal-errors

ifeq ($(ASSEMBLER),1)
DEFINES+=-DMG_DISASSEMBLER
endif

ifeq ($(DEBUG),1)
DEFINES+=-DMG_DEBUG -g
else
#DEFINES+= -no-integrated-cpp -O3 -fomit-frame-pointer -fstrict-aliasing -momit-leaf-frame-pointer -fno-tree-pre -falign-loops
DEFINES+= -fast -fno-fast-math
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
	
generated/interpreter.inc: $(RUBY_DIR)/*.rb $(RUBY_DIR)/magenta/*.rb  $(RUBY_DIR)/magenta/generator/*.rb generated
	$(RUBY) $(RUBY_DIR)/example.rb
	
generated/scanner.inc: $(C_DIR)/example.l generated
	$(LEX) -o generated/scanner.inc $(C_DIR)/example.l 

generated/parser.c: $(C_DIR)/example.y
	$(YACC) -o generated/parser.c $(C_DIR)/example.y

target/magenta: target generated/interpreter.inc $(C_DIR)/driver.c  $(C_DIR)/interpreter.c  $(C_DIR)/support.h $(C_DIR)/disassembler.c generated/scanner.inc generated/parser.c
	$(COMPILE) -o target/parser.o generated/parser.c -c
ifeq ($(ASSEMBLER),1)
	$(COMPILE) -o target/disassembler.o $(C_DIR)/disassembler.c -c
endif
	$(COMPILE) -o target/magenta  $(C_DIR)/interpreter.c $(C_DIR)/driver.c $(STRICTNESS_DEFINES) target/*.o