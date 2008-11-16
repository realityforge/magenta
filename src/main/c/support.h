
#ifdef VM_DEBUG

extern int vm_debug;
extern FILE* vm_out;

#  define DBG_START_INSTRUCTION(name) if (vm_debug) {fprintf(vm_out, "%p: %-20s", sp_instruction-1, #name);}
#  define DBG_STACK_POINTER(name) if (vm_debug) {fprintf(vm_out, #name "=%p ", sp_##name - 1);}
#  define DBG_ARG(name,type) if (vm_debug) {fputs(" " #name "=", vm_out); printarg_##type(vm_out,name);}
#  define DBG_STACK_EFFECT_SEPARATOR if (vm_debug) {fputs(" --", vm_out);}
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

extern void panic(const char * format, ...);
extern void engine( instruction_stack_t *instruction_stack, data_stack_t *data_stack );