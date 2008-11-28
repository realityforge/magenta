#include <stdlib.h>
#include <stdio.h>

#include "magenta.h"
#include "magenta/types.h"

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

#ifdef __GNUC__
#  define MAYBE_UNUSED __attribute__((unused))
#  define LIKELY(x) __builtin_expect(!!(x), 1)
#  define UNLIKELY(x) __builtin_expect(!!(x), 0)
#  ifndef ARCH_HAS_PREFETCH
// rw => prefetch for read or write?, locality => left in cache or purged?
// void __builtin_prefetch( const void *addr, int rw, int locality );
#    define PREFETCH(x) __builtin_prefetch(x)
#  endif

#else
#  define MAYBE_UNUSED
#  define LIKELY(x)
#  define UNLIKELY(x)
#endif

#ifndef PREFETCH
#  define PREFETCH(x)
#endif


extern char *program_name;
extern FILE *yyin;
extern instruction_stack_t *vmcodep;
extern int vmCodeRemaining;
extern int yyparse();

extern void panic(const char * format, ...);

extern void mgInterpreterExecute(instruction_stack_t *instruction_stack, data_stack_t *data_stack);
extern void mgInterpreterInit(void **instruction_table);
#ifdef MG_DISASSEMBLER
extern void mgDisassembler( FILE *vm_out, instruction_stack_t *instruction_stack );
#endif

#if MG_DISPATCH_SCHEME == MG_SWITCH_DISPATCH

#  define INSTRUCTION_CODE(bytecode) bytecode

#else // Assume direct

extern void *mg_instruction_table[];
#  define INSTRUCTION_CODE(bytecode) ((integer_data_type_t)mg_instruction_table[bytecode])

#endif
