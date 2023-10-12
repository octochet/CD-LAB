%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yyerror(char *s);
extern FILE * yyin;

int label=0;
int compilertemp=0;

char *newtemp()
{
    char *temp=(char*)malloc(sizeof(char)*100);
    sprintf(temp,"t%d",compilertemp++);
    return temp;
}
char *newlabel()
{
    char *temp=(char*)malloc(sizeof(char)*100);
    sprintf(temp,"L%d",label++);
    return temp;
}
struct Snode
{
    char True[100];
    char False[100];
    char next[100];
    char compilerTemp[100];
    char code[10000];
};



%}
%union
{
    char val[100];
    struct Snode *node;
}


%token <val> NUMBER ID COMPARISON  
%token INCREMENT DECREMENT ASSIGN MULTIPLY DIVIDE LPAREN RPAREN SEPERATOR EOFf IF ELSE LOGICAL_AND LOGICAL_OR LOGICAL_NOT PLUS MINUS
%token LBRACE RBRACE
%token WHILE
%left LOGICAL_OR
%left LOGICAL_AND
%left LOGICAL_NOT
%left PLUS MINUS 
%left MULTIPLY DIVIDE
%nonassoc RPAREN
%nonassoc COMPARISON
%nonassoc ELSE 

%type <node> Bt B S_list S EQN ASSIGNMENT EXPRESSION TERM FACTOR mID
%type <val> SIGN
%start Start

%%

Start       : S_list EOFf{ printf("\nVALID Program\n--------------------------------\n--Intermediate Code Generation--");printf("\n%s  END Program\n--------------------------------\n", $1->code); return 0;} 
            | error EOFf { printf("\nInvalid Program\n--------------------------------\n"); return 0;}
            ;

S_list      : S S_list
            {
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                strcat(temp->code,$1->code);
                strcat(temp->code,$2->code);
                strcpy(temp->compilerTemp,"");
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }  
            | S{
                $$=$1;
            }
            | SEPERATOR{
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                strcpy(temp->code,"");
                strcpy(temp->compilerTemp,"");
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
            ;

S           : EQN SEPERATOR
            {  $$ = $1;  }
            | IF LPAREN Bt RPAREN S ELSE S  {
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                char *End_Of_If=newlabel();
                char *Else=newlabel();
                strcat(temp->code,$3->code);
                strcat(temp->code,"  if NOT ");
                strcat(temp->code,$3->compilerTemp);
                strcat(temp->code," goto ");
                strcat(temp->code,Else);
                strcat(temp->code,"\n");
                strcat(temp->code,$5->code);
                strcat(temp->code,"  goto ");
                strcat(temp->code,End_Of_If);
                strcat(temp->code,"\n");
                strcat(temp->code,Else);
                strcat(temp->code," :");
                strcat(temp->code,"\n");
                strcat(temp->code,$7->code);
                strcat(temp->code,End_Of_If);
                strcat(temp->code," :");
                strcat(temp->code,"\n");
                strcpy(temp->compilerTemp,"");
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
            | IF LPAREN Bt RPAREN S 
              {
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                char *End_Of_If=newlabel();
                strcat(temp->code,$3->code);
                strcat(temp->code,"  if NOT ");
                strcat(temp->code,$3->compilerTemp);
                strcat(temp->code," goto ");
                strcat(temp->code,End_Of_If);
                strcat(temp->code,"\n");
                strcat(temp->code,$5->code);
                strcat(temp->code,End_Of_If);
                strcat(temp->code," :");
                strcat(temp->code,"\n");
                strcpy(temp->compilerTemp,"");
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
            | WHILE LPAREN Bt RPAREN S {
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                char *whilelabel=newlabel();
                char *endlabel=newlabel();
                strcat(temp->code,whilelabel);
                strcat(temp->code,":\n");
                strcat(temp->code,$3->code);
                strcat(temp->code,"  if NOT ");
                strcat(temp->code,$3->compilerTemp);
                strcat(temp->code,"  goto ");
                strcat(temp->code,endlabel);
                strcat(temp->code,"\n");
                strcat(temp->code,$5->code);
                strcat(temp->code,"  goto ");
                strcat(temp->code,whilelabel);
                strcat(temp->code,"\n");
                strcat(temp->code,endlabel);
                strcat(temp->code," :\n");
                strcpy(temp->compilerTemp,"");
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
            | LBRACE S_list RBRACE {
                $$ = $2;
            }
            ;

Bt          :ASSIGNMENT
            {$$=$1;}
            | B {$$=$1;} ;


B           : B LOGICAL_OR B 
            {
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                // a||b run a check a value if true go to end and assign a's value to it else run b 
                char *End_Of_Or=newlabel();
                char *compilertemp=newtemp();
                strcat(temp->code,$1->code);


                strcat(temp->code,"  ");
                strcat(temp->code,compilertemp);
                strcat(temp->code," = ");
                strcat(temp->code,$1->compilerTemp);
                strcat(temp->code,"\n");
                
                
                strcat(temp->code,"  if ");
                strcat(temp->code,compilertemp);
                strcat(temp->code," then ");
                strcat(temp->code,"goto ");
                strcat(temp->code,End_Of_Or);
                strcat(temp->code,"\n");
                //if pass happened
                strcat(temp->code,$3->code);
                strcat(temp->code,"  ");
                strcat(temp->code,compilertemp);
                strcat(temp->code," = ");
                strcat(temp->code,$3->compilerTemp);
                strcat(temp->code,"\n");

                strcat(temp->code,End_Of_Or);
                strcat(temp->code," :");
                strcat(temp->code,"\n");
                strcpy(temp->compilerTemp,compilertemp);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
            | B LOGICAL_AND B {
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                //a && b if a is false go to end else run b and check b's value
                char *End_Of_And=newlabel();
                char *compilertemp=newtemp();
                strcat(temp->code,$1->code);

                
                strcat(temp->code,"  ");
                strcat(temp->code,compilertemp);
                strcat(temp->code," = ");
                strcat(temp->code,$1->compilerTemp);
                strcat(temp->code,"\n");
                

                strcat(temp->code,"  if NOT ");
                strcat(temp->code,compilertemp);
                strcat(temp->code," then ");
                strcat(temp->code,"goto ");
                strcat(temp->code,End_Of_And);
                strcat(temp->code,"\n");
                
                //if pass happened
                strcat(temp->code,$3->code);
                strcat(temp->code,"  ");
                strcat(temp->code,compilertemp);
                strcat(temp->code," = ");
                strcat(temp->code,$3->compilerTemp);
                strcat(temp->code,"\n");


                strcat(temp->code,End_Of_And);
                strcat(temp->code," :");
                strcat(temp->code,"\n");
                strcpy(temp->compilerTemp,compilertemp);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
            | LOGICAL_NOT B{
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                char *temp1=newtemp();
                strcat(temp->code,$2->code);
                strcat(temp->code,"  ");
                strcat(temp->code,temp1);
                strcat(temp->code," = ");
                strcat(temp->code," ! ");
                strcat(temp->code,$2->compilerTemp);
                strcat(temp->code,"\n");
                strcpy(temp->compilerTemp,temp1);
                strcpy(temp->next,"");
                strcpy(temp->True,$2->False);
                strcpy(temp->False,$2->True);
                $$ = temp;
            }
            | EXPRESSION COMPARISON EXPRESSION {
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                char *temp1=newtemp();
                strcat(temp->code,$1->code);
                strcat(temp->code,$3->code);
                strcat(temp->code,"  ");
                strcat(temp->code,temp1);
                strcat(temp->code," = ");
                strcat(temp->code,$1->compilerTemp);
                strcat(temp->code," ");
                strcat(temp->code,$2);
                strcat(temp->code," ");
                strcat(temp->code,$3->compilerTemp);
                strcat(temp->code,"\n");
                strcpy(temp->compilerTemp,temp1);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$=temp;                
            }
            | EXPRESSION{
                $$=$1;
            }
            | LPAREN B RPAREN {
                $$=$2;
            }
            ;

EQN         : INCREMENT mID     
            {
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                char *temp1=newtemp();
                strcat(temp->code,"  ");
                strcat(temp->code,$2->compilerTemp);
                strcat(temp->code," = ");
                strcat(temp->code,$2->compilerTemp);
                strcat(temp->code, " + 1");
                strcat(temp->code,"\n");
                strcat(temp->code,"  ");
                strcat(temp->code,temp1);
                strcat(temp->code," = ");
                strcat(temp->code,$2->compilerTemp);
                strcat(temp->code,"\n");
                strcpy(temp->compilerTemp,temp1);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
            | DECREMENT mID  {
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                char *temp1=newtemp();
                strcat(temp->code,"  ");
                strcat(temp->code,$2->compilerTemp);
                strcat(temp->code," = ");
                strcat(temp->code,$2->compilerTemp);
                strcat(temp->code, " - 1 ");
                strcat(temp->code,"\n");
                strcat(temp->code,"  ");
                strcat(temp->code,temp1);
                strcat(temp->code," = ");
                strcat(temp->code,$2->compilerTemp);
                strcat(temp->code,"\n");
                strcpy(temp->compilerTemp,temp1);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
            | mID INCREMENT {
                struct Snode *temp = (struct Snode*)malloc(sizeof(struct Snode));
                char *temp1=newtemp();
                strcat(temp->code,"  ");
                strcat(temp->code,$1->compilerTemp);
                strcat(temp->code," = " );
                strcat(temp->code,$1->compilerTemp);
                strcat(temp->code, " + 1 ");
                strcat(temp->code,"\n");
                strcat(temp->code,"  ");
                strcat(temp->code,temp1);
                strcat(temp->code," = ");
                strcat(temp->code,$1->compilerTemp);
                strcat(temp->code,"\n");
                strcpy(temp->compilerTemp,temp1);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            } 
            | mID DECREMENT{
                struct Snode *temp = (struct Snode*)malloc(sizeof(struct Snode));
                char *temp1=newtemp();
                strcat(temp->code,"  ");
                strcat(temp->code,temp1);
                strcat(temp->code," = ");
                strcat(temp->code,$1->compilerTemp);
                strcat(temp->code,"\n");
                strcat(temp->code,"  ");
                strcat(temp->code,$1->compilerTemp);
                strcat(temp->code," = ");
                strcat(temp->code,$1->compilerTemp);
                strcat(temp->code, " - 1 ");
                strcat(temp->code,"\n");
                strcpy(temp->compilerTemp,temp1);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }  
            | ASSIGNMENT  {
                $$ = $1;
            }
            ;
            
ASSIGNMENT  : mID ASSIGN ASSIGNMENT 
            {
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                strcat(temp->code,$3->code);
                strcat(temp->code,"  ");
                strcat(temp->code,$1->compilerTemp);
                strcat(temp->code," = ");
                strcat(temp->code,$3->compilerTemp);
                strcat(temp->code,"\n");
                strcpy(temp->compilerTemp,$1->compilerTemp);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
	        | mID ASSIGN EXPRESSION {
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                strcpy(temp->code,$3->code);
                strcat(temp->code,"  ");
                strcat(temp->code,$1->compilerTemp);
                strcat(temp->code," = ");
                strcat(temp->code,$3->compilerTemp);
                strcat(temp->code,"\n");
                strcpy(temp->compilerTemp,$1->compilerTemp);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
	        ;        	  
            
EXPRESSION  : EXPRESSION PLUS TERM
            {
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                char *temp1=newtemp();
                strcat(temp->code,$1->code);
                strcat(temp->code,$3->code);
                strcat(temp->code,"  ");
                strcat(temp->code,temp1);
                strcat(temp->code," = ");
                strcat(temp->code,$1->compilerTemp);
                strcat(temp->code," + ");
                strcat(temp->code,$3->compilerTemp);
                strcat(temp->code,"\n");
                strcpy(temp->compilerTemp,temp1);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
            | EXPRESSION MINUS TERM {
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                char *temp1=newtemp();
                strcat(temp->code,$1->code);
                strcat(temp->code,$3->code);
                strcat(temp->code,"  ");
                strcat(temp->code,temp1);
                strcat(temp->code," = ");
                strcat(temp->code,$1->compilerTemp);
                strcat(temp->code," - ");
                strcat(temp->code,$3->compilerTemp);
                strcat(temp->code,"\n");
                strcpy(temp->compilerTemp,temp1);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
            | TERM {
                $$=$1;
            }
            ;
TERM        : TERM MULTIPLY FACTOR 
            {
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                char *temp1=newtemp();
                strcat(temp->code,$1->code);
                strcat(temp->code,$3->code);
                strcat(temp->code,"  ");
                strcat(temp->code,temp1);
                strcat(temp->code," = ");
                strcat(temp->code,$1->compilerTemp);
                strcat(temp->code," * ");
                strcat(temp->code,$3->compilerTemp);
                strcat(temp->code,"\n");
                strcpy(temp->compilerTemp,temp1);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
            | TERM DIVIDE FACTOR{
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                char *temp1=newtemp();
                strcat(temp->code,$1->code);
                strcat(temp->code,$3->code);
                strcat(temp->code,"  ");
                strcat(temp->code,temp1);
                strcat(temp->code," = ");
                strcat(temp->code,$1->compilerTemp);
                strcat(temp->code," / ");
                strcat(temp->code,$3->compilerTemp);
                strcat(temp->code,"\n");
                strcpy(temp->compilerTemp,temp1);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
            | FACTOR {
                $$ = $1;
            }
            ;
FACTOR      : NUMBER
            {
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                strcpy(temp->code,"");
                strcpy(temp->compilerTemp,$1);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
            | mID {
                $$=$1;
            }
            | LPAREN EXPRESSION RPAREN {
                $$=$2;
            }
            | INCREMENT mID {
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                char *temp1=newtemp();
                strcat(temp->code,"  ");
                strcat(temp->code,$2->compilerTemp);
                strcat(temp->code," = ");
                strcat(temp->code,$2->compilerTemp);
                strcat(temp->code, " + 1");
                strcat(temp->code,"\n");
                strcat(temp->code,"  ");
                strcat(temp->code,temp1);
                strcat(temp->code," = ");
                strcat(temp->code,$2->compilerTemp);
                strcat(temp->code,"\n");
                strcpy(temp->compilerTemp,temp1);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
            | DECREMENT mID{
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                char *temp1=newtemp();
                strcat(temp->code,"  ");
                strcat(temp->code,$2->compilerTemp);
                strcat(temp->code," = ");
                strcat(temp->code,$2->compilerTemp);
                strcat(temp->code, " - 1 ");
                strcat(temp->code,"\n");
                strcat(temp->code,"  ");
                strcat(temp->code,temp1);
                strcat(temp->code," = ");
                strcat(temp->code,$2->compilerTemp);
                strcat(temp->code,"\n");
                strcpy(temp->compilerTemp,temp1);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$= temp;
            }
            | mID INCREMENT{
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                char *temp1=newtemp();
                strcat(temp->code,"  ");
                strcat(temp->code,temp1);
                strcat(temp->code," = ");
                strcat(temp->code,$1->compilerTemp);
                strcat(temp->code,"\n");
                strcat(temp->code,"  ");
                strcat(temp->code,$1->compilerTemp);
                strcat(temp->code," = ");
                strcat(temp->code,$1->compilerTemp);
                strcat(temp->code, "+1 ");
                strcat(temp->code,"\n");
                strcpy(temp->compilerTemp,temp1);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
            | mID DECREMENT{
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                char *temp1=newtemp();
                strcat(temp->code,"  ");
                strcat(temp->code,temp1);
                strcat(temp->code," = ");
                strcat(temp->code,$1->compilerTemp);
                strcat(temp->code,"\n");
                strcat(temp->code,"  ");
                strcat(temp->code,$1->compilerTemp);
                strcat(temp->code," = ");
                strcat(temp->code,$1->compilerTemp);
                strcat(temp->code, "-1");
                strcat(temp->code,"\n");
                strcpy(temp->compilerTemp,temp1);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
            | SIGN FACTOR{
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                char *temp1=newtemp();
                strcat(temp->code,"  ");
                strcat(temp->code,temp1);
                strcat(temp->code," = ");
                strcat(temp->code,$1);
                strcat(temp->code," ");
                strcat(temp->code,$2->compilerTemp);
                strcat(temp->code,"\n");
                strcpy(temp->compilerTemp,temp1);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
            ;
SIGN        : PLUS{
                char str[100];
                str[0]='+';str[1]='\0';
                strcpy($$ , str);
            }
            | MINUS{
                char str[100];
                str[0]='-';str[1]='\0';
                strcpy($$ , str);
            }
            ;
mID	        :  /* LPAREN mID RPAREN{
            $$=$2;
            } | */
            ID{
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                strcpy(temp->code,"");
                strcpy(temp->compilerTemp,$1);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$=temp;
            }
            ;

%%
int yyerror(char *s)
{
    printf("\t\t Error ");
    return 0;
}
int main(int argc, char **argv)
{
    if(argc < 2)
    {
        printf("Usage: %s <filename>\n", argv[0]);
        exit(1);
    }
    FILE *fp = fopen(argv[1], "r");
    if(fp == NULL)
    {
        printf("Error opening file %s\n", argv[1]);
        printf("taking input from stdin\n");
        yyin = stdin;
    }
    else { yyin = fp; }
    printf("\n--------------------------------\n");
    yyparse();
    return 0;
}
int yyterminate()
{
    return 1;
}