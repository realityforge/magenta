#if MG_DISPATCH_SCHEME == MG_SWITCH_DISPATCH
#  define INSTRUCTION_CODE(bytecode) bytecode
#elif MG_DISPATCH_SCHEME == MG_DIRECT_DISPATCH
extern void *mg_instruction_table[];
#  define INSTRUCTION_CODE(bytecode) ((integer_data_type_t)mg_instruction_table[bytecode])
#else 
#  error "Unknown MG_DISPATCH_SCHEME value"
#endif

#ifndef MG_NO_INLINE_GENERATOR
#  define IB_API static inline
#endif //MG_NO_INLINE_GENERATOR

IB_API void mgInstructionAppend(instruction_stack_t **instructions, const integer_data_type_t value)
{
	**instructions = value;
#ifdef MG_DEBUG > 1
	if (vm_debug) {fprintf(vm_out,"GEN %p: %p\n",*instructions, (void *)**instructions);}
#endif
	(*instructions)++;
}

#include "assembler.inc"
