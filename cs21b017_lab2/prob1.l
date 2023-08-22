%option noyywrap
%{
#include <stdio.h>
/*
lex program which takes c code as input and prints the tokens. stores the tokens in a file named tokens.txt
*/
%}

Preprocessor_Directive	"#include"|"#define"|"#undef"
KEYWORD    "auto"|"break"|"case"|"char"|"const"|"continue"|"default"|"do"|"double"|"else"|"enum"|"extern"|"float"|"for"|"goto"|"if"|"int"|"long"|"register"|"return"|"short"|"signed"|"sizeof"|"static"|"struct"|"switch"|"typedef"|"union"|"unsigned"|"void"|"volatile"|"while"
IDENTIFIER     [a-zA-Z_][a-zA-Z0-9_]*
OPERATOR     "+"|"-"|"*"|"/"|"%"|"++"|"--"|"="|"=="|"!="|"<"|">"|"<="|">="|"&&"|"||"|"!"|"&"|"|"|"^"|"<<"|">>"|"~"|"->"|"?"
%%

"/*"(.|\n)*?"*/" {}

"//".* {}

[ \t\r\n]+ {}

{Preprocessor_Directive} {printf("Preprocessor_Directive: %s\n", yytext);}
"<"[^\n]*">"     { printf("Header File: %s\n", yytext); }
{KEYWORD} {printf("Keyword: %s\n", yytext);}
{OPERATOR} {printf("Operator: %s\n", yytext);}
{IDENTIFIER} {printf("Identifier: %s\n", yytext);}
"("|")"|";"|","|":"|"."|"->"|"?"|"'"|"'"|\"|"{"|"}" {printf("Special Character: %s\n", yytext);}
[0-9]+ {printf("Integer: %s\n", yytext);}
[0-9]+"."[0-9]* {printf("Float: %s\n", yytext);}
%%

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    FILE *fp = fopen(argv[1], "r");
    if (fp == NULL) {
        printf("Error opening file\n");
        return 1;
    }

    yyin = fp;
    yylex();

    fclose(fp);
    return 0;
}
