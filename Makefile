RUBY_DIR=src/main/ruby
C_DIR=src/main/c

RUBY=ruby
LEX=flex -l
YACC=bison -y
CC=gcc

DEBUG=0
ASSEMBLER=0

STRICTNESS_CFLAGS=-Wall -Wextra
CFLAGS=-std=c99 -Wfatal-errors
DEFINES=

ifeq ($(ASSEMBLER),1)
DEFINES+=-DMG_DISASSEMBLER
endif

ifeq ($(DEBUG),1)
DEFINES+=-DMG_DEBUG -g
else
CFLAGS+= -fast -fno-fast-math
endif

INCLUDES=-I generated -I $(C_DIR) 

GENERATED_SRC=generated/interpreter.inc generated/scanner.inc generated/parser.c

SRCS = $(C_DIR)/interpreter.c $(C_DIR)/driver.c $(C_DIR)/disassembler.c

COMPILE=$(CC) $(INCLUDES) $(DEFINES) $(CFLAGS)

.PHONY: all
all: target/magenta

.PHONY: clean
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

generated/parser.c: $(C_DIR)/example.y generated/scanner.inc
	$(YACC) -o generated/parser.c $(C_DIR)/example.y

%.d : %.c $(GENERATED_SRC)
	@dirname $* | xargs echo generated/deps | tr ' ' '/' | xargs mkdir -p
	@makedepend  $(INCLUDES) $(DEFINES) -f - $< | sed 's, \($*\.o\)[ :]*\(.*\), $@ : $$\(wildcard \2\)\n\1 : \2,g' > generated/deps/$*.d

-include $(SRCS:.c=generated/deps/$*.d)

target/magenta: target generated/interpreter.inc generated/scanner.inc generated/parser.c $(SRCS:.c=.d)
	$(COMPILE) -o target/parser.o generated/parser.c -c
ifeq ($(ASSEMBLER),1)
	$(COMPILE) -o target/disassembler.o $(C_DIR)/disassembler.c -c
endif
	$(COMPILE) -o target/magenta  $(C_DIR)/interpreter.c $(C_DIR)/driver.c $(STRICTNESS_CFLAGS) target/*.o
