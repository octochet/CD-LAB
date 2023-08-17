%option noyywrap
%{
#include <stdio.h>
%}

ALPHABET [abcd]
z [^abcd]
%%
{ALPHABET}+{ALPHABET}{z}{ALPHABET}+{ALPHABET}$ {printf("Valid string: %s",yytext);}
.* {printf("Invalid string: %s",yytext);}
\n {printf("\n"); }
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
