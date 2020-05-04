%{
	#include <string.h>
	#include <stdio.h>
	#define BUFF_SIZE 1024
	char A[BUFF_SIZE], B[BUFF_SIZE];
	int count = 0;
%}

space [ \t]
letter [a-zA-Z]

%%

{space} {count++;printf("%s\n", A);}
{letter}+ {cmp();}

%%


void cmp()
{
	if (count == 0)
	{
		strcpy(A, yytext);
	}
	else
	{
		strcpy(B, yytext);
		if (strncmp(A, B, strlen(A)) == 0)
		{
			printf("SAME\n");
		}
		else
		{
			printf("NOT SAME\n");
		}
		count = 0;
		memset(A, '\0', BUFF_SIZE);
		memset(B, '\0', BUFF_SIZE);
	}
}

int main(){
	yylex();
	return 0;
}
