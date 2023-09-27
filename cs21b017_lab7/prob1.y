%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex();
int yyerror(char*);
extern FILE * yyin;

//node structure for syntax tree
struct node{
    char* type;
    char lexeme[100];
    int dval;
    float fval;
    struct node *left;
    struct node *right;
};

//function declarations
struct node* create_node(char*, char*, int, float, struct node*, struct node*);
void inorder(struct node*);
void levelorder(struct node*);
void preorder(struct node*);
void postorder(struct node*);
void free_tree(struct node*);
%}

%union {
    int dval;
    float fval;
    char lexeme[100];
    struct node *node;
}
%start expr_list

%token SEMICOLON PLUS MINUS MUL DIV ASSIGN LEFT_PAREN RIGHT_PAREN INC DEC

%token <lexeme> IDENTIFIER
%token <dval> INT_CONST
%token <fval> FLOAT_CONST

%left PLUS MINUS
%left MUL DIV
%right UMINUS UPLUS
%right ASSIGN
%left INC DEC

%type <node> assign_stmt arithmetic_expression primary_exp

%%
expr_list					: assign_stmt SEMICOLON {
                                printf("Accepted EXPR"); 
                                // printf("\nInorder: ");
                                // inorder($1); 
                                printf("\nPreorder: ");
                                preorder($1); 
                                printf("\nPostorder: ");
                                postorder($1); 
                                // printf("\nLevelorder: \n");
                                // levelorder($1);
                                printf("\n\n");
                                free_tree($1);
                            }expr_list
                            | error SEMICOLON {
                                printf("Rejected EXPR\n\n");
                            } expr_list
                            | {
                                printf("Completed\n");
                            }
                            ;
assign_stmt                 : IDENTIFIER ASSIGN assign_stmt {
                                $$ = create_node("ASSIGN", "=", 0, 0, create_node("IDENTIFIER",$1,0,0,NULL,NULL), $3);
                            }
                            | arithmetic_expression { $$ = $1; }
                            ;
arithmetic_expression		: primary_exp { 
                                $$ = $1;
                            }
                            | arithmetic_expression PLUS arithmetic_expression {
                                $$ = create_node("PLUS", "+", 0, 0, $1, $3);
                            }
                            | arithmetic_expression MINUS arithmetic_expression {
                                $$ = create_node("MINUS", "-", 0, 0, $1, $3);
                            }
                            | arithmetic_expression MUL arithmetic_expression {
                                $$ = create_node("MUL", "*", 0, 0, $1, $3);
                            }
                            | arithmetic_expression DIV arithmetic_expression {
                                $$ = create_node("DIV", "/", 0, 0, $1, $3);
                            }
                            | MINUS arithmetic_expression %prec UMINUS {
                                $$ = create_node("UMINUS", "-", 0, 0, $2, NULL);
                            }
                            | PLUS arithmetic_expression %prec UPLUS {
                                $$ = create_node("UPLUS", "+", 0, 0, $2, NULL);
                            }
                            ;
primary_exp					: INT_CONST { 
                                $$ = create_node("INT_CONST", "", $1, 0, NULL, NULL); 
                            }
                            | FLOAT_CONST { 
                                $$ = create_node("FLOAT_CONST", "", 0, $1, NULL, NULL);
                            }
                            | IDENTIFIER { 
                                $$ = create_node("IDENTIFIER", "", 0, 0, create_node("IDENTIFIER",$1,0,0,NULL,NULL), NULL);
                            }
                            | LEFT_PAREN arithmetic_expression RIGHT_PAREN { 
                                $$ = $2;
                            }
                            | INC IDENTIFIER {
                                char temp[] = "++";
                                strcat(temp,$2);
                                strcpy($2, temp);
                                $$ = create_node("INC", $2, 0, 0, NULL, NULL);
                            }
                            | DEC IDENTIFIER { 
                                char temp[] = "--";
                                strcat(temp,$2);
                                strcpy($2, temp);
                                $$ = create_node("DEC", $2, 0, 0, NULL, NULL);
                            }
                            | IDENTIFIER INC { 
                                strcat($1, "++");$$ = create_node("INC", $1, 0, 0, NULL, NULL);
                            }
                            | IDENTIFIER DEC { 
                                strcat($1, "--");$$ = create_node("DEC", $1, 0, 0, NULL, NULL);
                            }
                            ;
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

//function definitions
struct node* create_node(char* type, char* lexeme, int dval, float fval, struct node* left, struct node* right){
    struct node* temp = (struct node*)malloc(sizeof(struct node));
    temp->type = type;
    strcpy(temp->lexeme, lexeme);
    temp->dval = dval;
    temp->fval = fval;
    temp->left = left;
    temp->right = right;
    return temp;
}

void inorder(struct node* root){
    if(root == NULL)
        return;
    inorder(root->left);
    if(strcmp(root->type, "INT_CONST") ==0) {
        printf("%d ", root->dval);
    }
    else if(strcmp(root->type, "FLOAT_CONST")==0) {
        //do not print trailing zeros
        char str[100];
        sprintf(str, "%f", root->fval);
        int i = strlen(str)-1;
        while(str[i] == '0')
            i--;
        if(str[i] == '.')

            str[i] = '\0';
        else
            str[i+1] = '\0';
        printf("%s ", str);
    }
    else {
        printf("%s ", root->lexeme);
    }
    inorder(root->right);
}

//level order traversal each level in new line
void levelorder(struct node* root){
    if(root == NULL)
        return;
    struct node* queue[100];
    int front = 0, rear = 0;
    queue[rear++] = root;
    int current_level_count = 1;
    int next_level_count = 0;
    while(front < rear){
        struct node* temp = queue[front++];
        current_level_count--;
        if(strcmp(temp->type, "INT_CONST") ==0)
            printf("%d ", temp->dval);
        else if(strcmp(temp->type, "FLOAT_CONST")==0)
            printf("%f ",temp->fval);
        else
            printf("%s ", temp->lexeme);
        if(temp->left != NULL){
            queue[rear++] = temp->left;
            next_level_count++;
        }
        if(temp->right != NULL){
            queue[rear++] = temp->right;
            next_level_count++;
        }
        if(current_level_count == 0){
            printf("\n");
            current_level_count = next_level_count;
            next_level_count = 0;
        }
    }
}

void preorder(struct node* root){
    if(root == NULL)
        return;
    if(strcmp(root->type, "INT_CONST") ==0) {
        printf("%d ", root->dval);
    }
    else if(strcmp(root->type, "FLOAT_CONST")==0) {
        //do not print trailing zeros
        char str[100];
        sprintf(str, "%f", root->fval);
        int i = strlen(str)-1;
        while(str[i] == '0')
            i--;
        if(str[i] == '.')

            str[i] = '\0';
        else
            str[i+1] = '\0';
        printf("%s ", str);
    }
    else {
        printf("%s ", root->lexeme);
    }
    preorder(root->left);
    preorder(root->right);
}

void postorder(struct node* root){
    if(root == NULL)
        return;
    postorder(root->left);
    postorder(root->right);
    if(strcmp(root->type, "INT_CONST") ==0) {
        printf("%d ", root->dval);
    }
    else if(strcmp(root->type, "FLOAT_CONST")==0) {
        //do not print trailing zeros
        char str[100];
        sprintf(str, "%f", root->fval);
        int i = strlen(str)-1;
        while(str[i] == '0')
            i--;
        if(str[i] == '.')

            str[i] = '\0';
        else
            str[i+1] = '\0';
        printf("%s ", str);
    }
    else {
        printf("%s ", root->lexeme);
    }
}

void free_tree(struct node* root){
    if(root == NULL)
        return;
    free_tree(root->left);
    free_tree(root->right);
    free(root);
}

int yyerror(char *s){
    //printf("\tINVALID\n");
    //yyparse();
    return 0;
}