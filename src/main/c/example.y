%{
#include "support.h"

instruction_stack_t *vmcodep;
int vmCodeRemaining;
int yylineno;

void yyerror(const char *s)
{
	panic("%s: %d: %s\n", program_name, yylineno, s);
}

#include "assembler.c"

int yylex();
%}


%token PRINT NUMBER IDENTIFIER DEF END

%union {
  long number;
  char *string;
}

%type <number> NUMBER;
%type <string> IDENTIFIER;

%%
program: statement_list
       | ;

statement_list: statement 
		| statement ';' statement_list
       ;

statement: print_statement
    | expr_statement
    ;

print_statement: PRINT expr { mgGen_printi(&vmcodep, &vmCodeRemaining); }
	;

expr_statement: expr { mgGen_drop(&vmcodep, &vmCodeRemaining); }
	;

/*
assign_statement: IDENTIFIER '=' expr { mgGen_storelocali(&vmcodep, &vmCodeRemaining, var_offset($1)); }
	;

parameter: IDENTIFIER { insert_parameter($1); }
	;
	
parameters: parameter ',' parameters 
      | parameter
      | ;

function_statement: DEF IDENTIFIER '(' parameters ')' statement_list END { XXXX }
	;
*/	

expr: term '+' expr	 { mgGen_addi(&vmcodep, &vmCodeRemaining); }
    | term '-' expr	 { mgGen_subi(&vmcodep, &vmCodeRemaining); }
    | term '*' expr	 { mgGen_muli(&vmcodep, &vmCodeRemaining); }
    | term '%' expr	 { mgGen_modi(&vmcodep, &vmCodeRemaining); }
    | term '/' expr	 { mgGen_divi(&vmcodep, &vmCodeRemaining); }
    | '-' term		 { mgGen_negi(&vmcodep, &vmCodeRemaining); }
    | term
    ;

term: '(' expr ')'
    | NUMBER { mgGen_literali(&vmcodep, &vmCodeRemaining, $1); }
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
