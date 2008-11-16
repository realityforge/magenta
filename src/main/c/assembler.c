#define INSTRUCTION(name,bytecode)
#include "instruction-table.inc"
#undef INSTRUCTION

static inline void instruction_append(instruction_stack_t **instructions, const integer_data_type_t value)
{
	**instructions = value;
#ifdef VM_DEBUG
	if (vm_debug) {fprintf(vm_out,"%p: %d\n",*instructions, **instructions);}
#endif
	(*instructions)++;
}

#define IB_API static inline
#define INSTRUCTION_CODE(bytecode) bytecode
#include "assembler.inc"
