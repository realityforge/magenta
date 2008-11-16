#include <stdlib.h>
#include <stdio.h>

#include "support.h"

#include "declarations.h"

int vm_debug;
FILE* vm_out;

#define START_INSTRUCTION(name,bytecode) case bytecode: //#name bytecode:
#define PREFETCH_NEXT_INSTRUCTION
#define END_INSTRUCTION

void engine( instruction_stack_t *instruction_stack, data_stack_t *data_stack )
{
	int *sp_instruction = instruction_stack;
	int *sp_data = data_stack;
	
	switch(*sp_instruction++)
	{
#      include "stack-accessors.c"
#      include "execution-engine.c"
	default:
	    panic("Unknown instruction %d at %p\n", sp_instruction[ -1 ], sp_instruction - 1);
	}
}

