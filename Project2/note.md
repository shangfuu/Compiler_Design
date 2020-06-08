# Modified in Project2 lex: 

1. Not including hash_table.h
2. Add return at #define token(t). 
3. Include y.tab.hpp.
4. Change NULL to NIL, because of c keyword problem.
5. Add KEYWORDS read.
6. Take off main function.
7. Rewrite operator:
    Rewrite assign operator.
    Rewrite relational operator.
    Rewrite logical operator.
8. Add #define tokenFloat(t,f)
9. Add char constatns rule.
10. Delete the define as follow:
    #define IDENTIFIER "id"
    #define INTEGER "int"
    #define STRING "string"
11. True False return Token(CONST_BOOL), because they are both bool value in yacc.
12. Change #define into C++ like. Using cout instead of printf().
13. Add yylval if tha rule has a value.

