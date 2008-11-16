
#ifdef VM_DEBUG

extern int vm_debug;
extern FILE* vm_out;

#  define DBG_START_INSTRUCTION(name) if (vm_debug) {fprintf(vm_out, "%p: %-20s", ip-1, #name);}
#  define DBG_STACK_POINTER(name) if (vm_debug) {fprintf(vm_out, #name "=%p", sp_##name);}
#  define DBG_ARG(name,type) if (vm_debug) {fputs(" " #name "=", vm_out); printarg_##type(vm_out,name);}
#  define DBG_STACK_EFFECT_SEPARATOR {fputs(" -- ", vm_out);}
#  define DBG_END_INSTRUCTION {fputc('\n', vm_out);}

#else

#  define DBG_START_INSTRUCTION(name)
#  define DBG_STACK_POINTER(name)
#  define DBG_ARG(name,type)
#  define DBG_STACK_EFFECT_SEPARATOR
#  define DBG_END_INSTRUCTION

#endif

extern void panic(const char * format, ...);