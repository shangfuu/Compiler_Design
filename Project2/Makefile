CC = g++
CFLAG = -ll -std=c++11 

LEX_FILE = scanner.l
YACC_FILE = parser.y
SYM_TABLE_FILE = hash_table.h

all: compile

compile: y.tab.cpp lex.yy.cpp $(SYM_TABLE_FILE)
	$(CC) y.tab.cpp lex.yy.cpp -o proj2.o $(CFLAG)

y.tab.cpp: $(YACC_FILE)
	yacc -d $(YACC_FILE) -o y.tab.cpp

lex.yy.cpp: $(LEX_FILE) y.tab.hpp $(SYM_TABLE_FILE)
	lex -o lex.yy.cpp $(LEX_FILE)


PHONY: clean

clean:
	-rm y.tab.*
	-rm *.o
	-rm lex.yy.*
