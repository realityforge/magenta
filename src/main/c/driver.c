#include <stdarg.h>

#include "support.h"

#ifdef VM_DEBUG

int vm_debug;
FILE* vm_out;

#endif

#if (VM_DEBUG || VM_DISASSEMBLER)

void printarg_integer(FILE *vm_out, const integer_data_type_t value )
{
	fprintf(vm_out, "%d", value );
}

#endif


void panic(const char * format, ...) 
{
  va_list ap;
  va_start(ap, format); 
  vfprintf(stderr, format, ap);
  va_end(ap);
  exit(1);
}

#define INSTRUCTION(name,bytecode)
#include "instruction-table.inc"
#undef INSTRUCTION

static inline void instruction_append(instruction_stack_t **instructions, const integer_data_type_t value)
{
	**instructions = value;
#ifdef VM_DEBUG
	if (vm_debug) {fprintf(vm_out,"%p: %d\n",*instructions, **instructions);}
#endif
	(*instructions)++;
}

#define IB_API static inline
#define INSTRUCTION_CODE(bytecode) bytecode
#include "assembler.inc"

#define CODE_SIZE 65536
#define STACK_SIZE 65536

int main(int argc, char **argv)
{
  instruction_stack_t *instruction_stack = 
    (instruction_stack_t *)calloc( CODE_SIZE, sizeof(instruction_stack_t) );
  data_stack_t *data_stack = (data_stack_t *)calloc( STACK_SIZE, sizeof(data_stack_t) );

#ifdef VM_DEBUG
 vm_debug = 1;
vm_out = stderr;
#endif

  instruction_stack[0] = 0;
    instruction_stack_t *instructions = instruction_stack;
  
    gen_literali(&instructions,1);
	gen_literali(&instructions,3);
	gen_addi(&instructions);
	gen_printi(&instructions);
	gen_exit(&instructions);

#ifdef VM_DISASSEMBLER
	disassembler( stderr, instruction_stack );
#endif

  engine(instruction_stack, data_stack + STACK_SIZE - 1);
  return 0;
}
