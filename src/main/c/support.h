#include <stdlib.h>
#include <stdio.h>

#include "magenta.h"

#include "declarations.inc"

#ifdef MG_DEBUG

extern int vm_debug;
extern FILE* vm_out;

#  define DBG_START_INSTRUCTION(name) if (vm_debug) {fprintf(vm_out, "%p: %-20s ", sp_instruction, #name);}
#  define DBG_STACK_POINTER(name) if (vm_debug) {fprintf(vm_out, #name "=%p ", sp_##name);}
#  define DBG_ARG(name,type) if (vm_debug) {fputs(#name "=", vm_out); printarg_##type(vm_out,name); fputc(' ', vm_out);}
#  define DBG_STACK_EFFECT_SEPARATOR if (vm_debug) {fputs("-- ", vm_out);}
#  define DBG_END_INSTRUCTION if (vm_debug) {fputc('\n', vm_out);}

#else

#  define DBG_START_INSTRUCTION(name)
#  define DBG_STACK_POINTER(name)
#  define DBG_ARG(name,type)
#  define DBG_STACK_EFFECT_SEPARATOR
#  define DBG_END_INSTRUCTION

#endif

#if defined(__GNUC__) && ((__GNUC__==2 && defined(__GNUC_MINOR__) && __GNUC_MINOR__>=7)||(__GNUC__>2))
#define MAYBE_UNUSED __attribute__((unused))
#else
#define MAYBE_UNUSED
#endif

extern char *program_name;
extern FILE *yyin;
extern instruction_stack_t *vmcodep;
extern int yyparse();

extern void panic(const char * format, ...);
//extern void engine( instruction_stack_t *instruction_stack, data_stack_t *data_stack );
extern void engine( instruction_stack_t *instruction_stack, data_stack_t *data_stack, void **instruction_table );

#ifdef VM_DISASSEMBLER
extern void disassembler( FILE *vm_out, instruction_stack_t *instruction_stack );
#endif

#if MG_DISPATCH_SCHEME == MG_SWITCH_DISPATCH

#  define INSTRUCTION_CODE(bytecode) bytecode

#else // Assume direct

extern void *mg_instruction_table[];
#  define INSTRUCTION_CODE(bytecode) ((integer_data_type_t)mg_instruction_table[bytecode])

#endif
