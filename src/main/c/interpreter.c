#include "support.h"

#if MG_DISPATCH_SCHEME == MG_SWITCH_DISPATCH
#  define INTERPRETER_START while(*sp_instruction != INSTRUCTION_CODE(0)) switch(*sp_instruction) {
#  define INTERPRETER_END default: panic("Unknown instruction %d at %p\n", sp_instruction[ 0 ], sp_instruction); }
#  define START_INSTRUCTION(name,bytecode) case bytecode: //#name bytecode
#  define PREFETCH_NEXT_INSTRUCTION
#  define END_INSTRUCTION break;
#elif MG_DISPATCH_SCHEME == MG_DIRECT_DISPATCH
#  define INTERPRETER_START {END_INSTRUCTION;
#  define INTERPRETER_END }
#  define START_INSTRUCTION(name,bytecode) instruction_##name: //#name bytecode
#  define PREFETCH_NEXT_INSTRUCTION
#  define END_INSTRUCTION {goto *(*sp_instruction);}
#  define NEED_INSTRUCTION_TABLE 1
#else
#  error "Unknown value of MG_DISPATCH_SCHEME"
#endif

static void mgEngine(instruction_stack_t *instruction_stack, data_stack_t *data_stack, void **instruction_table )
{
	//instruction_stack is NULL when initializing the engine for non switched dispatch
#ifdef NEED_INSTRUCTION_TABLE
	if (NULL == instruction_stack) goto INSTRUCTION_TABLE_SETUP; 
#endif //NEED_INSTRUCTION_TABLE

	int *sp_instruction = instruction_stack;
	int *sp_data = data_stack;
	

#ifdef MG_DEBUG
	if (vm_debug) {fprintf(vm_out,"Entering engine(instruction_stack=%p,data_stack=%p)\n",sp_instruction,data_stack);}
#endif

	INTERPRETER_START;
	# include "stack-accessors.inc"
	# include "interpreter.inc"
	INTERPRETER_END;

#ifdef NEED_INSTRUCTION_TABLE
EndInterpretation:
	return;
	
INSTRUCTION_TABLE_SETUP:	
#if MG_DISPATCH_SCHEME != MG_SWITCH_DISPATCH
instruction_table[0] = &&EndInterpretation;
#  define INSTRUCTION(name,bytecode) instruction_table[bytecode] = &&instruction_##name;
#  include "instruction-table.inc"
#endif
	return;

#endif //NEED_INSTRUCTION_TABLE
}

void mgInterpreterExecute(instruction_stack_t *instruction_stack, data_stack_t *data_stack)
{
	mgEngine(instruction_stack,data_stack,NULL);
}

void mgInterpreterInit(void **instruction_table)
{
#ifdef NEED_INSTRUCTION_TABLE
	mgEngine(NULL,NULL,instruction_table);
#endif //NEED_INSTRUCTION_TABLE
}

