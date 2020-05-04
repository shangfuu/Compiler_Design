/* Declaration section */
%{
%}

%%
"<"[^>]*> {printf("%s\n", yytext);}
. ;
%%

int yywrap(){
	return 1;
}

int main(){
	yyin = fopen("index.html","r");
	printf("Hello lex\n");	
	// The function to start the analysis
	yylex();

	fclose(yyin);
	return 0;
}
