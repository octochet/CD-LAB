CFLAGS=-g -DDEBUG -ll
CC=gcc

all: lexer

lexer: lex.yy.c
	$(CC) lex.yy.c -o lexer

lex.yy.c:${fname}
	flex ${fname}

clean:
	rm -f lexer lex.yy.c symbol_table.txt