%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex();
int yyerror(char*);
extern FILE * yyin;
%}

%token INT_CONST FLOAT_CONST IDENTIFIER SEMICOLON PLUS MINUS MUL DIV ASSIGN LEFT_PAREN RIGHT_PAREN INC DEC EoF

%left PLUS MINUS
%left MUL DIV
%right UMINUS UPLUS
%right ASSIGN
%left INC DEC

%%

program_unit				: expr_list                               
                            ;
expr_list					: assign_stmt SEMICOLON {printf("VALID\n");}expr_list
                            | error SEMICOLON {printf("INVALID!! Error: Syntax Error\n");} expr_list
                            | error EoF {printf("INVALID!! Error: Missing Semicolon\n");exit(0);}
                            | EoF {exit(0);}
                            |
                            ;
assign_stmt                 : IDENTIFIER ASSIGN assign_stmt
                            | arithmetic_expression
                            ;
arithmetic_expression		: primary_exp
                            | arithmetic_expression PLUS arithmetic_expression
                            | arithmetic_expression MINUS arithmetic_expression
                            | arithmetic_expression MUL arithmetic_expression
                            | arithmetic_expression DIV arithmetic_expression
                            | MINUS arithmetic_expression %prec UMINUS
                            | PLUS arithmetic_expression %prec UPLUS
                            ;
primary_exp					: INT_CONST
                            | FLOAT_CONST
                            | IDENTIFIER check
                            | LEFT_PAREN arithmetic_expression RIGHT_PAREN check
                            | INC IDENTIFIER
                            | DEC IDENTIFIER
                            | INC LEFT_PAREN arithmetic_expression RIGHT_PAREN
                            | DEC LEFT_PAREN arithmetic_expression RIGHT_PAREN
                            ;
check                       : INC | DEC | ;
%%

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

int yyerror(char *s){
    //printf("\tINVALID\n");
    //yyparse();
    return 0;
}