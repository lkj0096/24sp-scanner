%{
  #include "common.h"

  void yyerror(const char *s);
  extern int yylex();
  extern int yyparse();
%}


%union {
    number_t number_type;
    int int_type;
    double real_type;
    char char_type;
    char* string;
}

//keywords
%token <number_type> TER_CONST_NUMBER

%token <string> TER_VAR TER_VAL 
%token <string> TER_TYPE TER_CLASS 
%token <string> TER_IF TER_ELSE TER_FOR TER_WHILE TER_DO TER_SWITCH TER_CASE TER_CONST_BOOL
%token <string> TER_FUN TER_RET 
/* %token <string> TER_OPS_ASSIGN TER_OPS_ADD TER_OPS_SUB TER_OPS_MUL TER_OPS_DIV  */
%token <string> TER_OPS_RELATION 
%token <string> TER_IDENT TER_STRING
%type <string> L_VALUE_EXPR SUBSCRIPT_OP
%type <string> ARGUMENT ARGU_LIST

/* %type <number_type> R_VALUE_EXPRESSION OPERATION OPERATION_MUL_DIV OPERATION_FACTOR */

%%

program : 
    HEADER FUN_LIST ;

HEADER : ;

FUN_LIST : 
    FUNCTION FUN_LIST
  | PROCEDURE FUN_LIST
  | FUNCTION
  | PROCEDURE 
  ;

PROCEDURE : 
    TER_FUN TER_IDENT '(' ARGU_LIST ')' '{' { printf("void %s(){\n", $2); } STMT_LIST '}' { printf("}\n"); }
  ;

FUNCTION : 
    TER_FUN TER_IDENT '(' ARGU_LIST ')' ':' TER_TYPE '{' { printf("%s %s(%s) {\n", $7, $2, $4); } STMT_LIST TER_RET { printf("return "); } R_VALUE_EXPRESSION ';' '}' { printf(";\n}\n"); }
  ;

ARGU_LIST : 
    ARGUMENT ',' ARGU_LIST { sprintf($$, "%s, %s", $1, $3); }
  | ARGUMENT { $$ = strdup($1); }
  | /*empty*/ { $$ = ""; }
  ;

ARGUMENT :  
    TER_IDENT ':' TER_TYPE { $$ = strdup($3); sprintf($$, "%s %s", $$, $1); }
  ;

STMT_LIST : 
    STMT STMT_LIST
  | /*empty*/
  ;

STMT :
    TER_VAL L_VALUE_EXPR ':' TER_TYPE { printf("const %s %s",  $4, $2); } '=' {printf("=");} ASSIGNED_VALUE ';' {printf(";\n");}
  | TER_VAR L_VALUE_EXPR ':' TER_TYPE { printf("%s %s",  $4, $2); } '=' {printf("=");} ASSIGNED_VALUE ';' {printf(";\n");}
  | TER_VAR L_VALUE_EXPR ':' TER_TYPE { printf("%s %s",  $4, $2); } ';' {printf(";\n");}
  | L_VALUE_EXPR { printf("%s ", $1); } '=' {printf("= ");} ASSIGNED_VALUE ';'{printf(";\n");}        // a = 1;
  | TER_IDENT { printf("%s ", strncmp($1, "print", 5) ? $1 : "std::cout <<" ); } '(' {printf("(");} EXPR_LIST ')' {printf(")");} { printf("%s", strncmp($1, "println", 7) ? "" : "<< std::endl"); } ';' { printf(";\n"); } // function call
  ;

L_VALUE_EXPR :
    TER_IDENT SUBSCRIPT_OP { sprintf($$, "%s%s", $1, $2); }
  ;

SUBSCRIPT_OP : 
    '[' TER_CONST_NUMBER ']' SUBSCRIPT_OP { sprintf($$, "[%s]", $2._str_value); }
  | /*empty*/ { $$ = strdup(""); }
  ;

INIT_LIST :
    '{' { printf("{ "); } EXPR_LIST '}' { printf("} "); }
  ;

ASSIGNED_VALUE :
    R_VALUE_EXPRESSION
  | INIT_LIST
  ;

EXPR_LIST : 
    R_VALUE_EXPRESSION ','{ printf(", "); } EXPR_LIST
  | R_VALUE_EXPRESSION
  | /*empty*/
  ;

R_VALUE_EXPRESSION : 
    OPERATION
  | TER_STRING { printf("%s ", $1); }
  | TER_IDENT { printf("%s ", $1); } '=' { printf("= "); } OPERATION
  | TER_IDENT { printf("%s ", strncmp($1, "print", 5) ? $1 : "std::cout <<" ); } '(' {printf("(");} EXPR_LIST ')' {printf(")");} { printf("%s", strncmp($1, "println", 7) ? "" : "<< std::endl"); } // function call
  ;

OPERATION :
    OPERATION '+' { printf("+ "); } OPERATION_MUL_DIV
  | OPERATION '-' { printf("- "); } OPERATION_MUL_DIV 
  | OPERATION_MUL_DIV
  ;


OPERATION_MUL_DIV :
    OPERATION_MUL_DIV '*' { printf("* "); } OPERATION_FACTOR
  | OPERATION_MUL_DIV '/' { printf("/ "); } OPERATION_FACTOR
  | OPERATION_FACTOR
  ;

OPERATION_FACTOR :
    '(' { printf("( "); } OPERATION ')' { printf(") "); }
  | L_VALUE_EXPR { printf("%s ", $1); }
  | '-' L_VALUE_EXPR { printf("(-%s) ", $2); }
  | TER_CONST_NUMBER       { printf("%s ", $1._str_value); }
  | '-' TER_CONST_NUMBER   { printf("(-%s) ", $2._str_value); }
  ;

%%

void yywarning(const char *msg) {
    printf("\nWARNING Line %lu: %s\n", line_number, msg);
}

void yyerror(const char *msg) {
    printf("\nERROR Line %lu: %s\n", line_number, msg);
}