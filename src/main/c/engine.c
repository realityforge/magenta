#include <stdlib.h>
#include <stdio.h>

#include "support.h"

int vm_debug;
FILE* vm_out;

#define START_INSTRUCTION(name) name##_bytecode:
#define PREFETCH_NEXT_INSTRUCTION
#define END_INSTRUCTION

void engine( int *instruction_stack,
             int *data_stack )
{
	int *sp_instruction = instruction_stack;
	int *sp_data = data_stack;
	
	switch(*sp_instruction++)
	{
#      include "stack_accessors.c"
#      include "execution-engine.c"
	default:
		fprintf(stderr,"unknown instruction %d at %p\n", sp_instruction[ -1 ], sp_instruction - 1);
		exit(1);
	}
}

