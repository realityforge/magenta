#include <stdarg.h>

#include "support.h"

#ifdef MG_DEBUG

int vm_debug;
FILE* vm_out;

#endif

#if (MG_DEBUG || VM_DISASSEMBLER)

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

void * mg_instruction_table[256];

char *program_name;
FILE *yyin;

#define CODE_SIZE 65536
#define STACK_SIZE 65536

int main(int argc, char **argv)
{
	if( argc != 2 )
	{
		panic("Expected filename parameter to command missing.");
	}
    program_name = argv[1];
  if ((yyin=fopen(program_name,"r"))==NULL) {
    perror(program_name);
    exit(1);
  }
	
  engine(NULL, NULL, mg_instruction_table);

  instruction_stack_t *instruction_stack = 
    (instruction_stack_t *)calloc( CODE_SIZE, sizeof(instruction_stack_t) );
  data_stack_t *data_stack = (data_stack_t *)calloc( STACK_SIZE, sizeof(data_stack_t) );

#ifdef MG_DEBUG
 vm_debug = 1;
vm_out = stderr;
#endif

  vmcodep = instruction_stack;
  
  if ( yyparse() ) exit(1);

  *(vmcodep++) = INSTRUCTION_CODE(0);

#ifdef VM_DISASSEMBLER
	disassembler( stderr, instruction_stack );
#endif

  engine(instruction_stack, data_stack + STACK_SIZE - 1, mg_instruction_table);
  return 0;
}
