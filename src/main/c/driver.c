#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>

#include "support.h"

#include "declarations.h"

#ifdef VM_DEBUG

int vm_debug;
FILE* vm_out;

#endif

void panic(const char * format, ...) 
{
  va_list ap;
  va_start(ap, format); 
  vfprintf(stderr, format, ap);
  va_end(ap);
  exit(1);
}


#define CODE_SIZE 65536
#define STACK_SIZE 65536

int main(int argc, char **argv)
{
  instruction_stack_t *instruction_stack = 
    (instruction_stack_t *)calloc( CODE_SIZE, sizeof(instruction_stack_t) );
  data_stack_t *data_stack = (data_stack_t *)calloc( CODE_SIZE, sizeof(data_stack_t) );

  instruction_stack[0] = 0;
  engine(instruction_stack,data_stack);
  return 0;
}
