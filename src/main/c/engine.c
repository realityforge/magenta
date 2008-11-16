#include <stdlib.h>
#include <stdio.h>

#include "declarations.h"
#include "support.h"

#define START_INSTRUCTION(name,bytecode) case bytecode: //#name bytecode:
#define PREFETCH_NEXT_INSTRUCTION
#define END_INSTRUCTION break;

void engine( instruction_stack_t *instruction_stack, data_stack_t *data_stack )
{
	int *sp_instruction = instruction_stack;
	int *sp_data = data_stack;
	
#ifdef VM_DEBUG
	if (vm_debug) {fprintf(vm_out,"Entering engine(instruction_stack=%p,data_stack=%p)\n",sp_instruction,data_stack);}
#endif

	while(*sp_instruction != 0)
	{
		switch(*sp_instruction++)
		{
#			include "stack-accessors.c"
#			include "execution-engine.c"
		default:
		    panic("Unknown instruction %d at %p\n", sp_instruction[ -1 ], sp_instruction - 1);
		}
	}
}

