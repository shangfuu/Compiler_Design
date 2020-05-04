%{
	int yylineno;
%}

%%
^(.*)\n {printf("%4d\t%s", ++yylineno, yytext);}
%%

int main(void){
	
	yyin = fopen("test.txt", "r");
	yylineno = 0;
	yylex();

	fclose(yyin);
	return 0;
}
