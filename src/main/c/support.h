
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


#define GET_STACK_ITEM_0() sp[0]
#define GET_STACK_ITEM_1() sp[1]
#define GET_STACK_ITEM_2() sp[2]
#define GET_STACK_ITEM_3() sp[3]
#define GET_STACK_ITEM_4() sp[4]
#define GET_STACK_ITEM_5() sp[5]

#define PUT_STACK_ITEM_0(value) sp[0] = value
#define PUT_STACK_ITEM_1(value) sp[1] = value
#define PUT_STACK_ITEM_2(value) sp[2] = value
#define PUT_STACK_ITEM_3(value) sp[3] = value
#define PUT_STACK_ITEM_4(value) sp[4] = value
#define PUT_STACK_ITEM_5(value) sp[5] = value