#include "support.h"

#define START_INSTRUCTION(name,bytecode) case bytecode: //#name bytecode:
#define END_INSTRUCTION break;

#define PRINT_INSTRUCTION(name) fprintf(vm_out, "%p: %-20s ", sp_instruction - 1, #name);
#define PRINT_IMMEDIATE(name,type) {fputs( #name "=", vm_out); printarg_##type(vm_out,name); fputc(' ', vm_out);}
#define PRINT_INSTRUCTION_END {fputc('\n', vm_out);}

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

