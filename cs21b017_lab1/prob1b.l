%option noyywrap
%{
#include <stdio.h>
#include <stdbool.h>
int x_cnt =0;
int y_cnt =0;
bool valid = true;
%}

%%
x {x_cnt++; putchar('x');}
y {y_cnt++; putchar('y');}
z { putchar('z');}
. { valid = false;putchar(yytext[0]);}

\n {
    if(x_cnt%2 == y_cnt%3 && valid) {
        printf(": valid string\n");
    } else {
        printf(": invalid string\n");
    }
    x_cnt = 0;
    y_cnt = 0;
}

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
