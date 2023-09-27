%{
#include <stdio.h>
#include <string.h>
int yylex();
void yyerror(const char* s);
extern FILE * yyin;
%}

%union {
    char *str;
    int day;
    int year;
}

%token <day> DAY
%token <str> MONTH
%token <year> YEAR
%token SCOL
%token DASH

%%
date_list : date date_list
          | error SCOL { printf("\tINVALID\n"); } date_list
          |
          ;
date: DAY DASH MONTH DASH YEAR SCOL
    {   int isValid=0;
        if($5%400 ==0 || ($5%4==0 && $5%100!=0)) {
            if(strcmp("Feb",$3)==0) {
                if($1 <= 29 && $1 >= 1) {
                    printf("\tVALID\n");
                } else {
                    printf("\tINVALID\n");
                }
            } else if(strcmp("Jan",$3)==0 ||strcmp("Mar",$3)==0 ||strcmp("May",$3)==0 ||strcmp("Jul",$3)==0 ||strcmp("Aug",$3)==0 ||strcmp("Oct",$3)==0 ||strcmp("Dec",$3)==0) {
                if($1<=31 && $1>=1) {
                    printf("\tVALID\n");
                } else {
                    printf("\tINVALID\n");
                }
            } else {
                if($1<=30 && $1>=1) {
                    printf("\tVALID\n");
                } else {
                    printf("\tINVALID\n");
                }
            }
        } else {
            if(strcmp("Feb",$3)==0) {
                if($1 <= 28 && $1 >= 1) {
                    printf("\tVALID\n");
                } else {
                    printf("\tINVALID\n");
                }
            } else if(strcmp("Jan",$3)==0 ||strcmp("Mar",$3)==0 ||strcmp("May",$3)==0 ||strcmp("Jul",$3)==0 ||strcmp("Aug",$3)==0 ||strcmp("Oct",$3)==0 ||strcmp("Dec",$3)==0) {
                if($1<=31 && $1>=1) {
                    printf("\tVALID\n");
                } else {
                    printf("\tINVALID\n");
                }
            } else {
                if($1<=30 && $1>=1) {
                    printf("\tVALID\n");
                } else {
                    printf("\tINVALID\n");
                }
            }
        }
    }
%%

void yyerror(const char* s) {
    //fprintf(stderr, "Error: %s\n", s);
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

