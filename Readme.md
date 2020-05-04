# Sample Makefile
1. Name the file with ".l"
2. lex {name.l}
3. cc -o {scanner} -O lex.yy.c -ll -lm

# When running lex
<code>EOF: ctrl + D</code> to stop yylex input in linux. 
