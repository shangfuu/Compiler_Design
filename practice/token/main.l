%{
	int n = 0;
%}

keyword "while"|"if"|"else"|"int"|"float"

%%

 /* keyword */
{keyword} { n++;printf("keywords: %s\n", yytext); }

 /* operator. */
"=="|">="|"<="|"<"|">"|"="|"!="|"+"|"-"|"*"|"/" {n++;printf("operator: %s\n", yytext);}

[a-zA-Z]([a-zA-Z0-9])* {n++;printf("id: %s\n", yytext);}

[(){}|,;] {n++;printf("seperator: %s\n", yytext);}

[0-9]+"."[0-9]+ {n++;printf("floats: %s\n", yytext);}

[0-9]+ {n++;printf("integer: %s\n", yytext);}

. ;
\n {printf("\n");}

<<EOF>> {printf("Match EOF\n");return 0;}

%%

int main(){
	yylex();	
	printf("Number of tokens: %d\n", n);
	return 0;
}
