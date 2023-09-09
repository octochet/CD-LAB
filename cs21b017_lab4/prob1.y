%{
#include <stdio.h>
#include <stdbool.h>
int yylex();
int yyerror(char*);
extern FILE * yyin;
%}

%token NUMBER PLUS MINUS IOTA SCOL ERROR

%%

complex_list:
    complex_number SCOL{printf("\tVALID\n");} complex_list | 
    error SCOL {printf("\tINVALID\n");}complex_list |
    ERROR SCOL {printf("\tINVALID\n");}complex_list |

    ;
complex_number:
    sign NUMBER |
    sign NUMBER IOTA |
    sign IOTA |
    sign IOTA operator NUMBER |
    sign NUMBER operator IOTA |
    sign NUMBER operator NUMBER IOTA |
    sign NUMBER operator IOTA NUMBER |
    sign NUMBER IOTA operator NUMBER |
    sign IOTA NUMBER operator NUMBER |
    sign IOTA NUMBER
    ;
sign:
    PLUS | MINUS |
    ;
operator:
    PLUS|MINUS
    ;
%%

int yyerror(char *s){
    //printf("\tINVALID\n");
    //yyparse();
    return 0;
}

int main(int argc, char* argv[])
{
	if(argc > 1)
	{
		FILE *fp = fopen(argv[1], "r");
		if(fp)
			yyin = fp;
	}
    yyparse();
	return 0;
}
