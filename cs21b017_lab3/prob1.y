%{
#include <stdio.h>

int yylex();
void yyerror(const char* msg);

int valid = 1;
%}

%token i PLUS TIMES

%%
E: T E1 { if (valid) printf("yes\n"); else printf("no\n"); valid = 1; }
  ;

E1: PLUS T E1
   | /* empty */
   ;

T: F T1
  ;

T1: TIMES F T1
   | /* empty */
   ;

F: i
  ;

%%

int main(int argc, char** argv) {
    for (int i = 1; i < argc; ++i) {
        FILE* input = fopen(argv[i], "r");
        if (input == NULL) {
            perror("Error opening file");
            return 1;
        }
        yyrestart(input);
        yyparse();
        fclose(input);
    }
    return 0;
}

void yyerror(const char* msg) {
    valid = 0;
}

int yywrap() {
    return 1;
}
