%option yylineno
%%
[+-\/\%;] return yytext[0];
print	return PRINT;
[0-9]+			{ yylval.number = strtol(yytext,NULL,10); return NUMBER; }
[ \t\n]	; // Ignore whitespace
[/][/].* ; // Ignore comments
.		yyerror("Illegal character"); exit(1);
%%
