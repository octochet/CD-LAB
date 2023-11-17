parser: lex.yy.c y.tab.c y.tab.h
	gcc -w y.tab.c lex.yy.c  -ll -o parser
lex.yy.c: $(fname).l
	lex $(fname).l
y.tab.c: $(fname).y
	yacc -v -Wno -d -t $(fname).y
clean:
	rm -f parser y.tab.c lex.yy.c y.tab.h y.output