%option noyywrap
%{
#include <stdio.h>
%}


%%

.*00.*  { printf("%s: Invalid string\n",yytext); }
.*111.* { printf("%s: Valid string\n",yytext); }
.*      { printf("%s: Invalid string\n",yytext); }

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
