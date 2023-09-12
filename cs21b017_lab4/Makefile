parser: y.tab.c lex.yy.c y.tab.h
	gcc -w y.tab.c lex.yy.c  -ll -o parser
lex.yy.c: $(fname).l
	lex $(fname).l
y.tab.c: $(fname).y
	yacc -v -d -t $(fname).y
clean:
	rm -f parser y.tab.c lex.yy.c y.tab.h y.output
test:
	lex $(fname).l
	yacc -v -d -t $(fname).y
	gcc -w y.tab.c lex.yy.c  -ll -o parser
	./parser $(inf).txt
	rm -f parser y.tab.c lex.yy.c y.tab.h y.output