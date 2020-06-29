# Modified in Project3: 

1. Fix Project2 exp bug.
2. Add JBC.h and JBC.cpp to do Java Byte Code things.
3. Add EXP % EXP
4. Change PRINT (EXP) and PRINTLN(EXP) to PRINT EXP and PRINTLN EXP.
5. Add EXP : (EXP) into rules of EXP.
6. Change all Bool value to Int.
7. Change Lex OP_arith from [-%+*/] to [\-\%\+\*\/] to avoid problem happen.
8. arg are not immutable anymore, they are all VAR
9. rewrite function declaretion
10. change grammar method and block

# How to Run

1. make
2. make run file={filename}
