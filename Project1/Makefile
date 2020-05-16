lex_file = proj1.l
Hfile = hash_table.h

all: lex
lex: $(lex_file) $(Hfile)
	$(LEX) $(lex_file)
	cc -o scanner -O lex.yy.c -ll

.PHONT: DEBUG

DEBUG: $(lex_file)
	$(LEX) -d $(lex_file)
	cc -o scanner -O lex.yy.c -ll

