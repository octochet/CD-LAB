%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "SymbolTable.h"
int yyerror(char *s);
extern FILE * yyin;

int label=0;
int TempVar=0;
int staticvariable_labels=0;

void initializeEnvironment() {
    env = (struct Environment *)malloc(sizeof(struct Environment));
    env->levelOfCurrentScope = 0;

    return ;
}

char *newtemp()
{
    char *temp=(char*)malloc(sizeof(char)*100);
    sprintf(temp,"t%d",TempVar++);
    return temp;
}

char *newVarlabel(){
    char *temp=(char*)malloc(sizeof(char)*100);
    sprintf(temp,"var%d",staticvariable_labels++);
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
    char TempVar[100];
    char code[10000];
};
struct BreakContinueElement{
    char Type[100];
    char Breaklabel[100];
    char Continuelabel[100];
};
struct caseel{
    char code[10000];
    bool isDefault;
    char caseValuecode[1000];
    char caseValuetemp[100];
    struct caseel *next;
};

struct Indices {
char *indexList[MAX_DIMENSION];
char code[1000];
int noOfIndices;
};

struct BreakContinueElement BreakContinueStack[100];
int BreakContinueStackPointer=-1;
void  BreakContinueStackPush(struct BreakContinueElement a){
    BreakContinueStack[++BreakContinueStackPointer]=a;
    return BreakContinueStackPointer;
}
struct BreakContinueElement BreakContinueStackPop(){
    return BreakContinueStack[BreakContinueStackPointer--];
}
bool BreakContinueStackEmpty(){
    return BreakContinueStackPointer==-1;
}
%}

%union
{
    char val[1000];
    struct Snode *node;
    struct caseel *cases;
    struct VariableNode *var;
    struct Indices *indices;
}


%token <val> NUMBER ID COMPARISON STRING INT_NUM
%token INCREMENT DECREMENT ASSIGN MULTIPLY DIVIDE 
%token LPAREN RPAREN SEPERATOR EOFf 
%token IF ELSE LOGICAL_AND LOGICAL_OR LOGICAL_NOT 
%token PLUS MINUS CASE DEFAULT CONTINUE BREAK SWITCH 
%token LBRACE RBRACE WHILE COLON COMMA
%token <val> INT CHAR LONG FLOAT DOUBLE 
%token LSQUAREBR RSQUAREBR
%left LOGICAL_OR
%left LOGICAL_AND
%left LOGICAL_NOT
%left PLUS MINUS 
%left MULTIPLY DIVIDE
%nonassoc RPAREN
%nonassoc COMPARISON
%nonassoc ELSE 
%type <indices> INDEXLIST
%type <val> TYPE
%type <node> Bt B S_list S EQN ASSIGNMENT EXPRESSION EXPRESSION1
%type <node> TERM FACTOR mID SWITCH_CASE_STMNT 
%type <cases> CASE_LIST 
%type <var> IDdecl DECLARATION
%type <val> SIGN
%start Start

%%

Start       : S_list EOFf{ 
                printf("\n**************************************************************************************************************\n");
                printf("\n\t\t\t\t\tVALID Programe\n\n");
                printf("******************************************** Symbol Table ******************************************************\n");
                PrintSymbolTable();
                printf("**************************************** Three Address Codes ***************************************************\n");
                printf("%s  END\n", $1->code); 
                return 0;
                } 
            | error EOFf { printf("\nSyntax Invalid Program: Terminated\n"); return 0;}
            ;

S_list      : S S_list
            {
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                strcat(temp->code,$1->code);
                strcat(temp->code,$2->code);
                strcpy(temp->TempVar,"");
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
                strcpy(temp->TempVar,"");
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
            ;

S           : DECLARATION SEPERATOR{
                $$=(struct Snode*)malloc(sizeof(struct Snode));
                strcpy($$->code,$1->codeAtInitialization);
            }
            |
            EQN SEPERATOR
            {  $$ = $1;  }
            | IF LPAREN Bt RPAREN S ELSE S  {
                  struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                char *End_Of_If=newlabel();
                char *Else=newlabel();
                strcat(temp->code,$3->code);
                strcat(temp->code,"  if ");
                strcat(temp->code,$3->TempVar);
                strcat(temp->code," isFalse");
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
                strcpy(temp->TempVar,"");
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
                strcat(temp->code,"  if ");
                strcat(temp->code,$3->TempVar);
                strcat(temp->code," isFalse");
                strcat(temp->code," goto ");
                strcat(temp->code,End_Of_If);
                strcat(temp->code,"\n");
                strcat(temp->code,$5->code);
                strcat(temp->code,End_Of_If);
                strcat(temp->code," :");
                strcat(temp->code,"\n");
                strcpy(temp->TempVar,"");
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
            | WHILE {
                struct BreakContinueElement a;
                strcpy(a.Type,"while");
                strcpy(a.Breaklabel,newlabel());
                strcpy(a.Continuelabel,newlabel());
                BreakContinueStackPush(a);
            } 
            LPAREN Bt RPAREN S {
                 struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                struct BreakContinueElement a;
                if(BreakContinueStackEmpty()){
                    printf("\nError continue statement not in loop or switch\n");printf("\nInvalid Program\n---------------\n");
                    return 0;
                }
                a=BreakContinueStackPop();
                char *whilelabel = a.Continuelabel;
                char *endlabel = a.Breaklabel;
                strcat(temp->code,whilelabel);
                strcat(temp->code,":\n");
                strcat(temp->code,$4->code);
                strcat(temp->code,"  if isFalse ");
                strcat(temp->code,$4->TempVar);
                strcat(temp->code,"  goto ");
                strcat(temp->code,endlabel);
                strcat(temp->code,"\n");
                strcat(temp->code,$6->code);
                strcat(temp->code,"  goto ");
                strcat(temp->code,whilelabel);
                strcat(temp->code,"\n");
                strcat(temp->code,endlabel);
                strcat(temp->code," :\n");
                strcpy(temp->TempVar,"");
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }

            | LBRACE {
                enterScope();
            }S_list RBRACE{
                $$ = $3;
                 exitScope();
            } 

            | LPAREN Bt RPAREN S {
                $$=$4;
            }

            | BREAK SEPERATOR
            {
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                strcat(temp->code,"  goto ");
                struct BreakContinueElement a;
                if(BreakContinueStackEmpty()){
                    printf("\nError break statement not in loop or switch\n");printf("\nInvalid Program\n---------------\n");
                    return 0;
                }
                a=BreakContinueStackPop();
                BreakContinueStackPush(a);
                strcat(temp->code,a.Breaklabel);
                strcat(temp->code,"\n");
                strcpy(temp->TempVar,"break label");
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$=temp;
            }
            | CONTINUE SEPERATOR{
                  struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                strcat(temp->code,"  goto ");
                if(BreakContinueStackEmpty()){
                    printf("\nError continue statement not in loop or switch\n");
                    return  0;
                }
                //what is required is to see if there is a while in the stack if so jump to its continue label else throw error
                struct BreakContinueElement whileNodeinStack;
                struct BreakContinueElement tempstack[100];
                int tempstackpointer=0;
                bool isWhilefound=false;
                while(!BreakContinueStackEmpty()){
                    struct BreakContinueElement temp=BreakContinueStackPop();
                    tempstack[tempstackpointer++]=temp;
                    if(strcmp(temp.Type,"while")==0){
                        whileNodeinStack=temp;
                        //printf("\nfound while :%s\n",whileNodeinStack.Continuelabel);
                        isWhilefound=true;
                        break;
                    }
                }
                while(tempstackpointer>0){
                    BreakContinueStackPush(tempstack[--tempstackpointer]);
                }
                if(!isWhilefound){
                    printf("\nError continue statement not in loop or switch\n");printf("\nInvalid Program\n---------------\n");
                    return 0;
                }
                strcat(temp->code,whileNodeinStack.Continuelabel);
                strcat(temp->code,"\n");
                strcpy(temp->TempVar,"continue label");
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$=temp;
            }
            | SWITCH_CASE_STMNT {
                $$=$1;
            }
            ;
DECLARATION : 
            TYPE IDdecl {
                struct VariableNode *temp = $2;
                strcpy(temp->type,$1);
                strcpy(temp->addressLabel,newVarlabel());
                strcpy(temp->codeAtInitialization,"");
                addVariableToCurrentScope(temp);
                $$=temp;
            }
            | TYPE IDdecl ASSIGN EXPRESSION1 {
                struct VariableNode *temp = $2;
                strcpy(temp->type,$1);
                strcpy(temp->addressLabel,newVarlabel());
                strcpy(temp->codeAtInitialization,$4->code);
                strcat(temp->codeAtInitialization,"  ");
                strcat(temp->codeAtInitialization,temp->addressLabel);
                strcat(temp->codeAtInitialization," = ");
                strcat(temp->codeAtInitialization,$4->TempVar);
                strcat(temp->codeAtInitialization,"\n");
                addVariableToCurrentScope(temp);
                $$=temp;
            }
            | DECLARATION COMMA IDdecl {
                struct VariableNode *temp = $3;
                strcpy(temp->type,$1->type);
                strcpy(temp->addressLabel,newVarlabel());
                strcpy(temp->codeAtInitialization,"");
                addVariableToCurrentScope(temp);
                $$=temp;
            }
            | DECLARATION COMMA IDdecl ASSIGN EXPRESSION1 {
                struct VariableNode *temp = $3;
                strcpy(temp->type,$1->type);
                strcpy(temp->addressLabel,newVarlabel());
                strcpy(temp->codeAtInitialization,"");
                strcat(temp->codeAtInitialization,$5->code);
                strcat(temp->codeAtInitialization,"  ");
                strcat(temp->codeAtInitialization,temp->addressLabel);
                strcat(temp->codeAtInitialization," = ");
                strcat(temp->codeAtInitialization,$5->TempVar);
                strcat(temp->codeAtInitialization,"\n");
                addVariableToCurrentScope(temp);
                $$=temp;
            }
            ;
IDdecl      : IDdecl LSQUAREBR INT_NUM RSQUAREBR {
                struct VariableNode *temp = $1;
                temp->noOfDimensions++;
                temp->dimensions[temp->noOfDimensions-1]=atoi($3);
                $$=temp;
            }
            | ID {
                char varname[100];
                strcpy(varname,$1);
                //printf("\nvarname:%s\n",varname);
                //check if already declared using symbol table
                if(checkInCurrentScope(varname)){
                    printf("\nError variable %s already declared in current scope\n", $1);
                    //return 0;
                }

                struct VariableNode *temp = (struct VariableNode*)malloc(sizeof(struct VariableNode));
                temp->noOfDimensions=0;
                strcpy(temp->name,$1);
                $$=temp;
            }   
            ;
TYPE        : INT   {  strcpy($$, "int"); }
            | LONG  { strcpy($$, "long"); }
            | FLOAT {  strcpy($$, "float"); }
            | DOUBLE{  strcpy($$, "double"); }
            | CHAR  {  strcpy($$, "char"); }
            ;

SWITCH_CASE_STMNT :
            SWITCH {
              struct BreakContinueElement a;
                strcpy(a.Type,"switch");
                strcpy(a.Breaklabel,newlabel());
                strcpy(a.Continuelabel,"None");
                BreakContinueStackPush(a);                  
            }LPAREN EXPRESSION1 RPAREN LBRACE CASE_LIST RBRACE {
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                struct BreakContinueElement a;
                if(BreakContinueStackEmpty()){
                    printf("\nError break statement not in loop or switch\n");printf("\nInvalid Program\n---------------\n");
                    return 0;
                }
                a=BreakContinueStackPop();
                char *endlabel = a.Breaklabel;
               
                struct caseel *tempcaselist=$7;
                char trailingcode[10000];
                struct caseel *defaultcase;
                struct caseel *temp1=$7;
                bool defaultcasepresent=false;
                while(temp1!=NULL){
                    if(temp1->isDefault&&!defaultcasepresent){
                        defaultcasepresent=true;
                        defaultcase=temp1;
                    }
                    else if(temp1->isDefault&&defaultcasepresent){
                        printf("\nError multiple default cases\n");printf("\nInvalid Program\n---------------\n");
                        return 0;
                    }
                    temp1=temp1->next;
                }
                
                char *defaultlabel=newlabel();
                strcat(temp->code,$4->code);
                while(tempcaselist!=NULL){
                    if(tempcaselist->isDefault){
                        defaultcase=tempcaselist;
                        strcat(trailingcode,defaultlabel);
                        strcat(trailingcode," :\n");
                        strcat(trailingcode,tempcaselist->code);
                    }
                    else{
                        char *caselabel=newlabel();
                        strcat(temp->code,tempcaselist->caseValuecode);
                        strcat(temp->code,"  if ");
                        strcat(temp->code,$4->TempVar);
                        strcat(temp->code," == ");
                        strcat(temp->code,tempcaselist->caseValuetemp);
                        strcat(temp->code," goto ");
                        strcat(temp->code,caselabel);
                        strcat(temp->code,"\n");
                        //to add to trailing code
                        strcat(trailingcode,caselabel);
                        strcat(trailingcode," :\n");
                        strcat(trailingcode,tempcaselist->code);
                    }

                    tempcaselist=tempcaselist->next;
                }
                if(defaultcasepresent){
                    strcat(temp->code,"  goto ");
                    strcat(temp->code,defaultlabel);
                    strcat(temp->code,"\n");
                }
                else{
                    strcat(temp->code,"  goto ");
                    strcat(temp->code,endlabel);
                    strcat(temp->code,"\n");
                }
                strcat(temp->code,trailingcode);
                strcat(temp->code,endlabel);
                strcat(temp->code," :\n");
                strcpy(temp->TempVar,"");
                $$ = temp;
            }
            ;


CASE_LIST   : CASE EXPRESSION1 COLON S_list CASE_LIST {
                struct caseel *temp = (struct caseel*)malloc(sizeof(struct caseel));
                strcpy(temp->code,$4->code);
                temp->isDefault=false;
                strcpy(temp->caseValuecode,$2->code);
                strcpy(temp->caseValuetemp,$2->TempVar);                
                temp->next=$5;
                $$=temp;
            }
            | CASE EXPRESSION1 COLON S_list {
                struct caseel *temp = (struct caseel*)malloc(sizeof(struct caseel));
                strcpy(temp->code,$4->code);
                temp->isDefault=false;
                strcpy(temp->caseValuecode,$2->code);
                strcpy(temp->caseValuetemp,$2->TempVar);
                temp->next=NULL;
                $$=temp;
            }
            | DEFAULT COLON S_list {
                struct caseel *temp = (struct caseel*)malloc(sizeof(struct caseel));
                strcpy(temp->code,$3->code);
                temp->isDefault=true;
                temp->next=NULL;
                $$=temp;
            }
            | DEFAULT COLON S_list CASE_LIST {
                struct caseel *temp = (struct caseel*)malloc(sizeof(struct caseel));
                strcpy(temp->code,$3->code);
                temp->isDefault=true;
                temp->next=$4;
                $$=temp;
            }
            | DEFAULT COLON CASE_LIST {
                struct caseel *temp = (struct caseel*)malloc(sizeof(struct caseel));
                strcpy(temp->code,"");
                temp->isDefault=true;
                temp->next=NULL;
                $$=temp;
            }
            | CASE EXPRESSION1 COLON CASE_LIST {
                struct caseel *temp = (struct caseel*)malloc(sizeof(struct caseel));
                strcpy(temp->code,"");
                temp->isDefault=false;
                strcpy(temp->caseValuecode,$2->code);
                strcpy(temp->caseValuetemp,$2->TempVar);
                temp->next=$4;
                $$=temp;
            }
            ;


Bt          :ASSIGNMENT{
                $$=$1;}
            | B {
                $$=$1;} ;


B           : B LOGICAL_OR B 
            {
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                // a||b run a check a value if true go to end and assign a's value to it else run b 
                char *End_Of_Or=newlabel();
                char *TempVar=newtemp();
                strcat(temp->code,$1->code);


                strcat(temp->code,"  ");
                strcat(temp->code,TempVar);
                strcat(temp->code," = ");
                strcat(temp->code,$1->TempVar);
                strcat(temp->code,"\n");
                
                
                strcat(temp->code,"  if ");
                strcat(temp->code,TempVar);
                strcat(temp->code," isTrue");
                strcat(temp->code," then ");
                strcat(temp->code,"goto ");
                strcat(temp->code,End_Of_Or);
                strcat(temp->code,"\n");
                //if pass happened
                strcat(temp->code,$3->code);
                strcat(temp->code,"  ");
                strcat(temp->code,TempVar);
                strcat(temp->code," = ");
                strcat(temp->code,$3->TempVar);
                strcat(temp->code,"\n");

                strcat(temp->code,End_Of_Or);
                strcat(temp->code," :");
                strcat(temp->code,"\n");
                strcpy(temp->TempVar,TempVar);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
            | B LOGICAL_AND B {
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                //a && b if a is false go to end else run b and check b's value
                char *End_Of_And=newlabel();
                char *TempVar=newtemp();
                strcat(temp->code,$1->code);

                
                strcat(temp->code,"  ");
                strcat(temp->code,TempVar);
                strcat(temp->code," = ");
                strcat(temp->code,$1->TempVar);
                strcat(temp->code,"\n");
                

                strcat(temp->code,"  if ");
                strcat(temp->code,TempVar);
                strcat(temp->code," isFalse");
                strcat(temp->code," then ");
                strcat(temp->code,"goto ");
                strcat(temp->code,End_Of_And);
                strcat(temp->code,"\n");
                
                //if pass happened
                strcat(temp->code,$3->code);
                strcat(temp->code,"  ");
                strcat(temp->code,TempVar);
                strcat(temp->code," = ");
                strcat(temp->code,$3->TempVar);
                strcat(temp->code,"\n");


                strcat(temp->code,End_Of_And);
                strcat(temp->code," :");
                strcat(temp->code,"\n");
                strcpy(temp->TempVar,TempVar);
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
                strcat(temp->code,$2->TempVar);
                strcat(temp->code,"\n");
                strcpy(temp->TempVar,temp1);
                strcpy(temp->next,"");
                strcpy(temp->True,$2->False);
                strcpy(temp->False,$2->True);
                $$ = temp;
            }
            | EXPRESSION1 COMPARISON EXPRESSION1 {
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                char *temp1=newtemp();
                strcat(temp->code,$1->code);
                strcat(temp->code,$3->code);
                strcat(temp->code,"  ");
                strcat(temp->code,temp1);
                strcat(temp->code," = ");
                strcat(temp->code,$1->TempVar);
                strcat(temp->code," ");
                strcat(temp->code,$2);
                strcat(temp->code," ");
                strcat(temp->code,$3->TempVar);
                strcat(temp->code,"\n");
                strcpy(temp->TempVar,temp1);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$=temp;                
            }
            | EXPRESSION1{
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
                strcat(temp->code,$2->TempVar);
                strcat(temp->code," = ");
                strcat(temp->code,$2->TempVar);
                strcat(temp->code, " + 1");
                strcat(temp->code,"\n");
                strcat(temp->code,"  ");
                strcat(temp->code,temp1);
                strcat(temp->code," = ");
                strcat(temp->code,$2->TempVar);
                strcat(temp->code,"\n");
                strcpy(temp->TempVar,temp1);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
            | DECREMENT mID  {
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                char *temp1=newtemp();
                strcat(temp->code,"  ");
                strcat(temp->code,$2->TempVar);
                strcat(temp->code," = ");
                strcat(temp->code,$2->TempVar);
                strcat(temp->code, " - 1 ");
                strcat(temp->code,"\n");
                strcat(temp->code,"  ");
                strcat(temp->code,temp1);
                strcat(temp->code," = ");
                strcat(temp->code,$2->TempVar);
                strcat(temp->code,"\n");
                strcpy(temp->TempVar,temp1);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
            | mID INCREMENT {
                struct Snode *temp = (struct Snode*)malloc(sizeof(struct Snode));
                char *temp1=newtemp();
                strcat(temp->code,"  ");
                strcat(temp->code,$1->TempVar);
                strcat(temp->code," = " );
                strcat(temp->code,$1->TempVar);
                strcat(temp->code, " + 1 ");
                strcat(temp->code,"\n");
                strcat(temp->code,"  ");
                strcat(temp->code,temp1);
                strcat(temp->code," = ");
                strcat(temp->code,$1->TempVar);
                strcat(temp->code,"\n");
                strcpy(temp->TempVar,temp1);
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
                strcat(temp->code,$1->TempVar);
                strcat(temp->code,"\n");
                strcat(temp->code,"  ");
                strcat(temp->code,$1->TempVar);
                strcat(temp->code," = ");
                strcat(temp->code,$1->TempVar);
                strcat(temp->code, " - 1 ");
                strcat(temp->code,"\n");
                strcpy(temp->TempVar,temp1);
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
                strcat(temp->code,$1->code);
                strcat(temp->code,$3->code);
                strcat(temp->code,"  ");
                strcat(temp->code,$1->TempVar);
                strcat(temp->code," = ");
                strcat(temp->code,$3->TempVar);
                strcat(temp->code,"\n");
                strcpy(temp->TempVar,$1->TempVar);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
	        | mID ASSIGN EXPRESSION1 {
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                strcat(temp->code,$1->code);
                strcat(temp->code,$3->code);
                strcat(temp->code,"  ");
                strcat(temp->code,$1->TempVar);
                strcat(temp->code," = ");
                strcat(temp->code,$3->TempVar);
                strcat(temp->code,"\n");
                strcpy(temp->TempVar,$1->TempVar);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
	        ;     
EXPRESSION1 :STRING {
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                strcpy(temp->TempVar,$1);
                $$ = temp;
            } 
            | EXPRESSION{
                $$=$1;}
            ;
EXPRESSION  :
            EXPRESSION PLUS TERM
            {
                    struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                char *temp1=newtemp();
                strcat(temp->code,$1->code);
                strcat(temp->code,$3->code);
                strcat(temp->code,"  ");
                strcat(temp->code,temp1);
                strcat(temp->code," = ");
                strcat(temp->code,$1->TempVar);
                strcat(temp->code," + ");
                strcat(temp->code,$3->TempVar);
                strcat(temp->code,"\n");
                strcpy(temp->TempVar,temp1);
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
                strcat(temp->code,$1->TempVar);
                strcat(temp->code," - ");
                strcat(temp->code,$3->TempVar);
                strcat(temp->code,"\n");
                strcpy(temp->TempVar,temp1);
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
                strcat(temp->code,$1->TempVar);
                strcat(temp->code," * ");
                strcat(temp->code,$3->TempVar);
                strcat(temp->code,"\n");
                strcpy(temp->TempVar,temp1);
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
                strcat(temp->code,$1->TempVar);
                strcat(temp->code," / ");
                strcat(temp->code,$3->TempVar);
                strcat(temp->code,"\n");
                strcpy(temp->TempVar,temp1);
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
                strcpy(temp->TempVar,$1);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
            |INT_NUM{
                 struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                strcpy(temp->code,"");
                strcpy(temp->TempVar,$1);
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
                strcat(temp->code,$2->TempVar);
                strcat(temp->code," = ");
                strcat(temp->code,$2->TempVar);
                strcat(temp->code, " + 1");
                strcat(temp->code,"\n");
                strcat(temp->code,"  ");
                strcat(temp->code,temp1);
                strcat(temp->code," = ");
                strcat(temp->code,$2->TempVar);
                strcat(temp->code,"\n");
                strcpy(temp->TempVar,temp1);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
            | DECREMENT mID{
               struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                char *temp1=newtemp();
                strcat(temp->code,"  ");
                strcat(temp->code,$2->TempVar);
                strcat(temp->code," = ");
                strcat(temp->code,$2->TempVar);
                strcat(temp->code, " - 1 ");
                strcat(temp->code,"\n");
                strcat(temp->code,"  ");
                strcat(temp->code,temp1);
                strcat(temp->code," = ");
                strcat(temp->code,$2->TempVar);
                strcat(temp->code,"\n");
                strcpy(temp->TempVar,temp1);
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
                strcat(temp->code,$1->TempVar);
                strcat(temp->code,"\n");
                strcat(temp->code,"  ");
                strcat(temp->code,$1->TempVar);
                strcat(temp->code," = ");
                strcat(temp->code,$1->TempVar);
                strcat(temp->code, "+1 ");
                strcat(temp->code,"\n");
                strcpy(temp->TempVar,temp1);
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
                strcat(temp->code,$1->TempVar);
                strcat(temp->code,"\n");
                strcat(temp->code,"  ");
                strcat(temp->code,$1->TempVar);
                strcat(temp->code," = ");
                strcat(temp->code,$1->TempVar);
                strcat(temp->code, "-1");
                strcat(temp->code,"\n");
                strcpy(temp->TempVar,temp1);
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
                strcat(temp->code,$2->TempVar);
                strcat(temp->code,"\n");
                strcpy(temp->TempVar,temp1);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            }
            ;

            ;
SIGN        : PLUS
        {
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
INDEXLIST :   LSQUAREBR EXPRESSION RSQUAREBR INDEXLIST{
                struct Indices* temp = $4;
                char *TempVar = $2->TempVar;
                strcat(temp->code,$2->code);
                
                if (temp->noOfIndices < 100) {
                    temp->indexList[temp->noOfIndices++] = strdup(TempVar);
                }
                else
                {
                    printf("\nError: Array index out of bounds\n");
                }
                $$=temp;
            }
            |LSQUAREBR EXPRESSION RSQUAREBR {
                $$=(struct Indices*)malloc(sizeof(struct Indices));
                $$->noOfIndices=0;
                // printf("\nInside [ Exp ]\n");
                char *TempVar = $2->TempVar;
                // printf("\nTempVar:%s\n",TempVar);
                if ($$->noOfIndices < 100) {
                    // printf("\nINSIDE IF\n");
                    $$->indexList[$$->noOfIndices++] = strdup(TempVar);
                    // printf("\n$$->indexList[0]:%s\n",$$->indexList[0]);
                }
                else
                {
                    printf("\nError: Array index out of bounds\n");
                }
            };
mID	        : mID INDEXLIST {
                //compute for array references based on index list 
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                struct Indices* temp1 = $2;
                strcpy(temp->code,"");
                strcat(temp->code,$2->code);
                struct VariableNode* temp2 = getNodeDetailsUsingAddressLabel($1->TempVar);
                if(temp2->noOfDimensions != temp1->noOfIndices)
                {
                    printf("\nError: Array index out of bounds\n");
                }
                else
                {
                    char *temp3 = newtemp();
                    // printf("\nArray index computation\n");
                    for (int i = 0; i < temp1->noOfIndices; ++i)
                    {
                        if(i==0){
                            strcat(temp->code,"  ");
                            strcat(temp->code,temp3);
                            strcat(temp->code," = ");
                            strcat(temp->code,temp1->indexList[temp1->noOfIndices-i-1]);
                            strcat(temp->code,"\n");
                            continue;
                        }
                        char *temp4 = newtemp();
                        strcat(temp->code,"  ");
                        strcat(temp->code,temp4);
                        strcat(temp->code," = ");
                        strcat(temp->code,temp3);
                        strcat(temp->code," * ");
                        int num = temp2->dimensions[i];
                        char str[100];
                        sprintf(str,"%d",num);
                        strcat(temp->code,str);
                        strcat(temp->code,"\n");
                        strcat(temp->code,"  ");
                        strcat(temp->code,temp4);
                        strcat(temp->code," = ");
                        strcat(temp->code,temp4);
                        strcat(temp->code," + ");
                        strcat(temp->code,temp1->indexList[temp1->noOfIndices-i-1]);
                        strcat(temp->code,"\n");
                        temp3 = temp4;
                    }
                    strcat(temp->code,"  ");
                    strcat(temp->code,temp3);
                    strcat(temp->code," = ");
                    strcat(temp->code,temp3);
                    strcat(temp->code," * ");
                    int width = getWidth(temp2->type);
                    char str[100];
                    sprintf(str,"%d",width);

                    strcat(temp->code,str);
                    strcat(temp->code,"\n");
                    //make compiler temp as offset(temp3)
                    strcpy(temp->TempVar,temp2->name);
                    strcat(temp->TempVar,"[");
                    strcat(temp->TempVar,temp3);
                    strcat(temp->TempVar,"]");
                }

                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$ = temp;
            } 
            |
            ID{
                char varname[100];
                strcpy(varname,$1);
                char reqAddLabel[100];
                strcpy(reqAddLabel,$1);
                if(checkInAllScope(varname))
                {
                    // printf("\nVariable %s declared\n");

                    strcpy(reqAddLabel,getNodeDetails(varname)->addressLabel);
                }
                else{
                    printf("\t\t\t------->Error variable %s not declared\n", varname);
                }
                struct Snode* temp = (struct Snode*)malloc(sizeof(struct Snode));
                strcpy(temp->code,"");
                strcpy(temp->TempVar,reqAddLabel);
                strcpy(temp->next,"");
                strcpy(temp->True,"");
                strcpy(temp->False,"");
                $$=temp;
                
            }
            ;

%%
int yyerror(char *s)
{
    printf("\t\tError\t\t ");
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
    initializeEnvironment();
    enterScope();

    if(fp == NULL)
    {
        printf("Error opening file %s\n", argv[1]);
        printf("taking input from stdin\n");
        yyin = stdin;
    }

    else { yyin = fp; }
    printf("**************************************************************************************************************\n");
    printf("\t\t\t\t\tInput File: %s\n", argv[1]);
    printf("**************************************************************************************************************\n");
    yyparse();
    exitScope();
    printf("**************************************************************************************************************\n");
    return 0;
}
int yyterminate()
{
    return 1;
}