%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "common.h"
    #define MAXBUFFER 10000
    char string_buffer[MAXBUFFER]={0};
    size_t line_number = 1;
%}

/* Definitions */
%x COMMENT
%x MULTI_COMMENT
%x STRINGS
%option noyywrap

/* Regular expressions */
BINDIGIT    ([01])
OCTDIGIT    ([0-7])
DECDIGIT    ([0-9])
HEXDIGIT    ([0-9a-fA-F])
DIGIT       ({DECDIGIT})
ALPHAB      ([a-zA-Z])  
IDENT       ((_|{ALPHAB})(_|{ALPHAB}|{DIGIT})*)
BININTEGER  (0b{BINDIGIT}+)
OCTINTEGER  (0{OCTDIGIT}+)
DECINTEGER  (0|([1-9]{DECDIGIT}*))
HEXINTEGER  (0x{HEXDIGIT}+)
REAL        ({DECDIGIT}+"."{DECDIGIT}+)
PRINTABLE   ([ -~])
ESCAPE_SEQ  ([nt\\\'\"\?])

/* Rules */
%%
<STRINGS><<EOF>>        { yyerror("missing terminating char \""); yyterminate(); }
<STRINGS>(\\\n)         { line_number++; } // match a \ and newline
<STRINGS>(\\n)          { strcat(string_buffer, "\n"); }
<STRINGS>(\\t)          { strcat(string_buffer, "\t"); }
<STRINGS>(\\\?)         { strcat(string_buffer, "\?"); }
<STRINGS>(\\\\)         { strcat(string_buffer, "\\"); }
<STRINGS>(\\\")         { strcat(string_buffer, "\""); }
<STRINGS>(\\\')         { strcat(string_buffer, "'"); }
<STRINGS>(\\{PRINTABLE}) { yywarning("Invalid Escape Char, skipping"); 
                            strcat(string_buffer, &(yytext[1])); }
<STRINGS>(\")           { printf("\"%s\"<END STR>",string_buffer); BEGIN 0; }
<STRINGS>(\n)           { yyerror("Missing Terminating Char \""); yyterminate(); }
<STRINGS>{PRINTABLE}    { strcat(string_buffer, yytext); }
["]                     { string_buffer[0] = '\0'; printf("<START STR>"); BEGIN(STRINGS); }

<COMMENT>[^\n]*         { ; }
<COMMENT>\n             { BEGIN 0; printf("\n"); line_number++; }
"//"                    { BEGIN COMMENT; printf("<INLINE COMMENT>");  }

<MULTI_COMMENT><<EOF>>  { yyerror("missing */"); yyterminate(); }
<MULTI_COMMENT>(\n)     { line_number++; printf("\n"); }
<MULTI_COMMENT>"*/"     { printf("<COMMENT END>"); BEGIN 0; }
<MULTI_COMMENT>(.)      { ; }
"/*"                    { BEGIN MULTI_COMMENT; printf("<MULTI LINE COMMENT>"); }

"var"       { printf("<VAR>"); }
"val"       { printf("<VAL>"); }
"bool"      { printf("<BOOL>"); }
"char"      { printf("<CHAR>"); }
"int"       { printf("<INT>"); }
"real"      { printf("<REAL>"); }
"true"      { printf("<TRUE>"); }
"false"     { printf("<FALSE>"); }
"class"     { printf("<CLASS>"); }
"if"        { printf("<IF>"); }
"else"      { printf("<ELSE>"); }
"for"       { printf("<FOR>"); }
"while"     { printf("<WHILE>"); }
"do"        { printf("<DO>"); }
"switch"    { printf("<SWITCH>"); }
"case"      { printf("<CASE>"); }
"fun"       { printf("<FUN>"); }
"ret"       { printf("<RET>"); }
"("         { printf("<LEFT_PAREN>"); }
")"         { printf("<RIGHT_PAREN>"); }
"["         { printf("<LEFT_BRACKET>"); }
"]"         { printf("<RIGHT_BRACKET>"); }
"{"         { printf("<LEFT_BRACE>"); }
"}"         { printf("<RIGHT_BRACE>"); }
","         { printf("<COMMA>"); }
";"         { printf("<SEMICOLON>"); }
":"         { printf("<COLON>"); }
"+"         { printf("<PLUS>"); }
"-"         { printf("<MINUS>"); }
"*"         { printf("<MULTIPLY>"); }
"/"         { printf("<DIVIDE>"); }
"="         { printf("<ASSIGN>"); }
"=="        { printf("<EQUAL>"); }
"!="        { printf("<NOT_EQUAL>"); }
">"         { printf("<GREATER_THAN>"); }
"<"         { printf("<LESS_THAN>"); }
">="        { printf("<GREATER_THAN_EQUAL>"); }
"<="        { printf("<LESS_THAN_EQUAL>"); }
{BININTEGER}   { printf("<BIN_INTEGER_LITERAL>"); }
{OCTINTEGER}   { printf("<OCT_INTEGER_LITERAL>"); }
{DECINTEGER}   { printf("<DEC_INTEGER_LITERAL>"); }
{HEXINTEGER}   { printf("<HEX_INTEGER_LITERAL>"); }
{REAL}      { printf("<REAL_LITERAL>"); }
{IDENT}     { printf("<IDENTIFIER>"); }
'\\{ESCAPE_SEQ}'  { printf("<CHARACTER_ESCAPE_SEQUENCE>"); }
'.'         { printf("<CHARACTER_LITERAL>"); }
\n          { line_number++; printf("\n"); }
''          { yyerror("Empty Char Constant"); yyterminate(); }
[ \t]+      { /* Ignore whitespace */ }
.           { yyerror("Invalid Token"); yyterminate(); }  
%%

void yywarning(const char *msg) {
    printf("\nWARNING Line %d: %s %s\n", line_number, msg, yytext);
}

void yyerror(const char *msg) {
    printf("\nERROR Line %d: %s %s\n", line_number, msg, yytext);
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        printf("Usage: %s <filename>\n", argv[0]);
        return -1;
    }
    char sFile[100];
    sprintf(sFile, "%s.result", argv[1]);
    redirect_stdout(sFile);
    FILE* fp = NULL;
    if (NULL == (fp = fopen(argv[1], "r"))) {
        printf("cannot open %s\n", argv[1]);
        return -1;
    }
    yyin = fp;
    yylex();
    restore_stdout();
    return 0;
}