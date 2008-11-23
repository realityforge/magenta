#include "support.h"

#if MG_DISPATCH_SCHEME == MG_SWITCH_DISPATCH

#  define START_DISASSEMBLER switch(*sp_instruction) {
#  define END_DISASSEMBLER }
#  define DISASSEMBLER_ERROR(x) default: {x;}
#  define START_INSTRUCTION(name,bytecode) case bytecode: //#name bytecode:
#  define END_INSTRUCTION break;

#else

#  define START_DISASSEMBLER
#  define END_DISASSEMBLER
#  define DISASSEMBLER_ERROR(x) {x;}
#  define START_INSTRUCTION(name,bytecode) if (*sp_instruction == INSTRUCTION_CODE(bytecode)) { //#name bytecode:
#  define END_INSTRUCTION } else 

#endif

#define PRINT_INSTRUCTION(name) fprintf(vm_out, "%p: %-20s ", sp_instruction, #name);
#define PRINT_IMMEDIATE(name,type) {fputs( #name "=", vm_out); printarg_##type(vm_out,name); fputc(' ', vm_out);}
#define PRINT_INSTRUCTION_END {fputc('\n', vm_out);}

void mgDisassembler( FILE *vm_out, instruction_stack_t *instruction_stack )
{
	int *sp_instruction = instruction_stack;
	
#ifdef MG_DEBUG
	if (vm_debug) {fprintf(vm_out,"Entering disassembler(instruction_stack=%p)\n", sp_instruction );}
#endif

	while(*sp_instruction != INSTRUCTION_CODE(0))
	{
		START_DISASSEMBLER
		#include "stack-accessors.inc"
		#include "disassembler.inc"
		DISASSEMBLER_ERROR(panic("Unknown instruction %d at %p\n", sp_instruction[ 0 ], sp_instruction ))
		END_DISASSEMBLER
	}
}

