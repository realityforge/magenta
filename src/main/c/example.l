%option yylineno
%%
[+-\/\%;()=] return yytext[0];
print	return PRINT;
def	return DEF;
[0-9]+			{ yylval.number = strtol(yytext,NULL,10); return NUMBER; }
[a-zA-Z\_][a-zA-Z0-9\_]*	{ yylval.string=strdup(yytext); return IDENTIFIER; }

[ \t\n]	; // Ignore whitespace
[/][/].* ; // Ignore comments
.		yyerror("Illegal character"); exit(1);
%%
