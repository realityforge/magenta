%{
#include "support.h"

instruction_stack_t *vmcodep;
int yylineno;

void yyerror(const char *s)
{
	panic("%s: %d: %s\n", program_name, yylineno, s);
}

#include "assembler.c"

int yylex();
%}


%token PRINT NUMBER

%union {
  long number;
}

%type <number> NUMBER;

%%
program: statement_list
       | ;

statement_list: statement 
		| statement ';' statement_list
       ;

statement: PRINT expr { gen_printi(&vmcodep); }
    | expr { gen_drop(&vmcodep); }
    ;

expr: term '+' expr	 { gen_addi(&vmcodep); }
    | term '-' expr	 { gen_subi(&vmcodep); }
    | term '*' expr	 { gen_muli(&vmcodep); }
    | term '%' expr	 { gen_modi(&vmcodep); }
    | term '/' expr	 { gen_divi(&vmcodep); }
    | '-' term		 { gen_negi(&vmcodep); }
    | term
    ;

term: '(' expr ')'
    | NUMBER { gen_literali(&vmcodep, $1); }
    ;

%%
int yywrap(void)
{
  return 1;
}

#pragma GCC diagnostic ignored "-Wunused-label"
#pragma GCC diagnostic ignored "-Wunused-function"
#pragma gcc diagnostic ignored "format"

#include "scanner.inc"
