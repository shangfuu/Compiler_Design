%{
	#include <stdio.h>
	#include <math.h>
	enum {ADD, SUB, DIV, MUL, POW, NONE} op = NONE;
	double a = 0, b = 0, ans = 0;
%}

digit [0-9]+|[0-9]+"."[0-9]+
add "+"
sub "-"
mul "*"
div "/"
pow "^"

%%

{add} {op = ADD;}
{sub} {op = SUB;}
{mul} {op = MUL;}
{div} {op = DIV;}
{pow} {op = POW;}

{digit} {cal();}

"\n" {printf("answer is: %.3f\n", ans);} 
. ;
%%

void cal(){

	if (op == NONE) 
	{
		a = atof(yytext);
	}
	else
	{
		b = atof(yytext);
	
		switch (op)
		{
			case ADD:
				ans = a + b;
				break;
			case SUB:
				ans = a - b;
				break;
			case DIV:
				ans = a / b;
				break;
			case MUL:
				ans = a * b;
				break;
			case POW:
				ans = pow(a, b);
				break;
		}
		op = NONE;
	}
}


int main(){
	
	yylex();
	return 0;
}
