#include <stdlib.h>
#include <stdio.h>

#include "support.h"

#include "declarations.h"

int vm_debug;
FILE* vm_out;

#define START_INSTRUCTION(name,bytecode) case bytecode: //#name bytecode:
#define PREFETCH_NEXT_INSTRUCTION
#define END_INSTRUCTION

void engine( instruction_stack_t *instruction_stack, data_stack_t *data_stack )
{
	int *sp_instruction = instruction_stack;
	int *sp_data = data_stack;
	
	switch(*sp_instruction++)
	{
#      include "stack-accessors.c"
#      include "execution-engine.c"
	default:
		fprintf(stderr,"unknown instruction %d at %p\n", sp_instruction[ -1 ], sp_instruction - 1);
		exit(1);
	}
}

#define CODE_SIZE 65536
#define STACK_SIZE 65536

int main(int argc, char **argv)
{
  instruction_stack_t *instruction_stack = 
    (instruction_stack_t *)calloc( CODE_SIZE, sizeof(instruction_stack_t) );
  data_stack_t *data_stack = (data_stack_t *)calloc( CODE_SIZE, sizeof(data_stack_t) );

instruction_stack[0] = 0;
  engine(instruction_stack,data_stack);
  return 0;
}

/*
#define CODE_SIZE 65536
#define STACK_SIZE 65536

int main(int argc, char **argv)
{
  Inst *vm_code=(Inst *)calloc(CODE_SIZE,sizeof(Inst));
  Inst *start;
  Cell *stack=(Cell *)calloc(STACK_SIZE,sizeof(Cell));
  engine_t runvm=engine;

  while ((c = getopt(argc, argv, "hdpt")) != -1) {
    switch (c) {
    default:
    case 'h':
    help:
      fprintf(stderr, "Usage: %s [options] file\nOptions:\n-h	Print this message and exit\n-d	disassemble VM program before execution\n-p	profile VM code sequences (output on stderr)\n-t	trace VM code execution (output on stderr)\n",
	      argv[0]);
      exit(1);
    case 'd':
      disassembling=1;
      break;
    case 'p':
      profiling=1;
      runvm = engine_debug;
      break;
    case 't':
      vm_debug=1;
      runvm = engine_debug;
      break;
    }
  }
  if (optind+1 != argc) 
    goto help;
  program_name = argv[optind];
  if ((yyin=fopen(program_name,"r"))==NULL) {
    perror(argv[optind]);
    exit(1);
  }

  vmcodep = vm_code;
  vm_out = stderr;
  (void)runvm(NULL,NULL,NULL); 
  init_peeptable();
  
  if (yyparse())
    exit(1);

  start=vmcodep;
  gen_main_end();
  vmcode_end=vmcodep;

  if (disassembling)
    vm_disassemble(vm_code, vmcodep, vm_prim);

  printf("result = %ld\n",runvm(start, stack+STACK_SIZE-1, NULL));

  if (profiling)
    vm_print_profile(vm_out);

  return 0;
}*/
