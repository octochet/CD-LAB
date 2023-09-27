%option noyywrap
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
This is a recursive descent parser for the Grammar:-
E -> TE'
E' -> +TE' | epsilon
T -> FT'
T' -> *FT' | epsilon
F -> (E) | id | num
id -> (letter|_)(letter|digit|_)*
num -> [digit]+
*/

// Token definitions
#define NUM 257
#define ID 258
#define PLUS 259
#define TIMES 260
#define LPAREN 261
#define RPAREN 262
#define NL 263

// Global variables
int lookahead;
int ValidOrNot = 1;

// Function prototypes Declarations
void E();
void E_prime();
void T();
void T_prime();
void F();
void match(int expectedToken);
%}

DIGIT       [0-9]
LETTER      [a-zA-Z]
ID          ({LETTER}|_)({LETTER}|{DIGIT}|_)*
NUM         {DIGIT}+
NL          \n

%%
{NUM}       { printf("%s",yytext); return NUM; }
{ID}        { printf("%s",yytext); return ID; }
"+"         { printf("%s",yytext); return PLUS; }
"*"         { printf("%s",yytext); return TIMES; }
"("         { printf("%s",yytext); return LPAREN; }
")"         { printf("%s",yytext); return RPAREN; }
{NL}        { return NL; }
<<EOF>>     { return EOF; }
%%

int main(int argc, char *argv[]) {
    FILE *input_file;
    if (argc != 2) {
        fprintf(stderr, "Usage: %s input_file\n", argv[0]);
        return 1;
    }
    input_file = fopen(argv[1], "r");
    if (input_file == NULL) {
        fprintf(stderr, "Error: could not open input file '%s'\n", argv[1]);
        return 1;
    }
    yyin = input_file;
    //run for whole input file
    while (1) {
        lookahead = yylex();
        if(lookahead == EOF)
            break;
        ValidOrNot = 1;
        E();
        if (ValidOrNot==1)
            printf(": VALID\n");
        else
            printf(": INVALID\n");
    }
    return 0;
}

// E -> TE'
void E() {
    T();
    E_prime();
}

// E' -> +TE' | epsilon
void E_prime() {
    if (lookahead == PLUS) {
        match(PLUS);
        T();
        E_prime();
    }
}

// T -> FT'
void T() {
    F();
    T_prime();
}

// T' -> *FT' | epsilon
void T_prime() {
    if (lookahead == TIMES) {
        match(TIMES);
        F();
        T_prime();
    }
}

// F -> (E) | id | num
// id -> (letter|_)(letter|digit|_)*
// num -> [digit]+
void F() {
    if (lookahead == NUM)
        match(NUM);
    else if (lookahead == ID)
        match(ID);
    else if (lookahead == LPAREN) {
        match(LPAREN);
        E();
        match(RPAREN);
    }
    else if (lookahead != NL) { // check that lookahead is not NL
        //printf("Error: Invalid token.\n");
        //exit(1);
        ValidOrNot=0;
        while(lookahead != NL)
            lookahead = yylex();
    }
    else {
        //printf("Error: Empty string not allowed.\n");
        //exit(1);
        ValidOrNot=0;
        while(lookahead != NL)
            lookahead = yylex();
    }
}

void match(int expectedToken) {
    if (lookahead == expectedToken)
        lookahead = yylex();
    else {
        printf("Error: Unexpected token. Expected token code: %d, Actual token code: %d\n", expectedToken, lookahead);
        exit(1);
    }
}

