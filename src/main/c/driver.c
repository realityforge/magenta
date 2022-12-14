#include <stdarg.h>

#include "support.h"

#ifdef MG_DEBUG

int vm_debug;
FILE* vm_out;

#endif

#if (MG_DEBUG || MG_DISASSEMBLER)

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

#define CODE_SIZE 65536
#define STACK_SIZE 65536

int main(int argc, char **argv)
{
  if( 2 != argc )
  {
    panic("Expected filename parameter to command missing.\n");
  }
  program_name = argv[1];
  yyin = fopen( program_name,"r" );
  if( NULL == yyin ) 
  {
    perror(program_name);
    exit(1);
  }
	
  mgInterpreterInit( mg_instruction_table );

  instruction_stack_t *instruction_stack = 
    (instruction_stack_t *)calloc( CODE_SIZE, sizeof(instruction_stack_t) );
  data_stack_t *data_stack = (data_stack_t *)calloc( STACK_SIZE, sizeof(data_stack_t) );

#ifdef MG_DEBUG
  vm_debug = 1;
  vm_out = stderr;
#endif

  vmcodep = instruction_stack;
  vmCodeRemaining = CODE_SIZE;
  
  if ( yyparse() ) exit(1);

  *(vmcodep++) = INSTRUCTION_CODE(0);

#ifdef MG_DISASSEMBLER
	mgDisassembler( stderr, instruction_stack );
#endif

  mgInterpreterExecute(instruction_stack, data_stack + STACK_SIZE - 1);
  return 0;
}
