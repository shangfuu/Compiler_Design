%{
#include "stdio.h"
int i = 0;
%}

digit [0-9]
letter [a-zA-Z]

%%

({digit})+"."?({digit})+ {i++;}

{letter}({letter}|{digit})* {i++;}

\n {printf("%d\n", i); i=0;}
. ;

%%

int yywrap(){
	return 1;
}

int main(int argc, char* const argv[]){
	
	yylex();

	return 0;
}
