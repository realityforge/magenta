#include "support.h"

#define START_INSTRUCTION(name,bytecode) case bytecode: //#name bytecode:
#define PREFETCH_NEXT_INSTRUCTION
#define END_INSTRUCTION break;

void disassembler( FILE *vm_out, instruction_stack_t *instruction_stack )
{
	int *sp_instruction = instruction_stack;
	
#ifdef VM_DEBUG
	if (vm_debug) {fprintf(vm_out,"Entering disassembler(instruction_stack=%p)\n", sp_instruction );}
#endif

	while(*sp_instruction != 0)
	{
		switch(*sp_instruction++)
		{
#			include "stack-accessors.inc"
#			include "disassembler.inc"
		default:
		    panic("Unknown instruction %d at %p\n", sp_instruction[ -1 ], sp_instruction - 1);
		}
	}
}

