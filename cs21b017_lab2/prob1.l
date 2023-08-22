%option noyywrap
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "uthash.h"

#define MAX_SYMBOLS 1000

typedef struct {
    char name[50];
    char type[50];
    UT_hash_handle hh;
} symbol_table_entry;

symbol_table_entry *symbol_table = NULL;
int symbol_count = 0;

void insert_symbol(char *type, char *name) {
    symbol_table_entry *entry;
    HASH_FIND_STR(symbol_table, name, entry);
    if (entry == NULL) {
        entry = (symbol_table_entry *)malloc(sizeof(symbol_table_entry));
        strcpy(entry->name, name);
        strcpy(entry->type, type);
        HASH_ADD_STR(symbol_table, name, entry);
        symbol_count++;
    }
}

void print_symbol_table_to_file(FILE *fp) {
    symbol_table_entry *entry, *tmp;
    fprintf(fp, "%12s    |    %12s\n", "Name", "Type");
    fprintf(fp, "--------------------------------\n");
    HASH_ITER(hh, symbol_table, entry, tmp) {
        fprintf(fp, "%12s    |    %12s\n", entry->name, entry->type);
    }
}
/*
lex program which takes c code as input and prints the tokens. stores the tokens in a file named tokens.txt
*/
%}

Preprocessor_Directive	"#include"|"#define"|"#undef"
KEYWORD    "auto"|"break"|"case"|"char"|"const"|"continue"|"default"|"do"|"double"|"else"|"enum"|"extern"|"float"|"for"|"goto"|"if"|"int"|"long"|"register"|"return"|"short"|"signed"|"sizeof"|"static"|"struct"|"switch"|"typedef"|"union"|"unsigned"|"void"|"volatile"|"while"
IDENTIFIER     [a-zA-Z_][a-zA-Z0-9_]*
OPERATOR     "+"|"-"|"*"|"/"|"%"|"++"|"--"|"="|"=="|"!="|"<"|">"|"<="|">="|"&&"|"||"|"!"|"&"|"|"|"^"|"<<"|">>"|"~"|"->"|"?"
STRING  \"(\\.|[^"\\])*\"

%%
"/*"(.|\n)*?"*/" {}
"//".* {}
{STRING} { printf("String: %s\n",yytext);}
[ \t\r\n]+ {}
{Preprocessor_Directive}.* {}
{KEYWORD} {printf("Keyword: %s\n", yytext); }
{OPERATOR} {printf("Operator: %s\n", yytext); }
{IDENTIFIER} {printf("Identifier: %s\n", yytext); insert_symbol("Identifier",yytext);}
"("|")"|";"|","|":"|"."|"->"|"?"|"'"|"'"|\"|"{"|"}" {printf("Punctuation: %s\n", yytext);}
-?[0-9]+ {printf("Integer: %s\n", yytext);}
-?[0-9]+"."[0-9]* {printf("Float: %s\n", yytext);}
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

    extern FILE *yyin, *yyout;
    yyin = fp;
    yyout = fopen("symbol_table.txt", "w");
    // fprintf("Symbol Table\n");
    // fprintf("------------\n");
    // fprintf("----Name----|----Type----\n");

    yylex();
    print_symbol_table_to_file(yyout);
    fclose(fp);
    return 0;
}
