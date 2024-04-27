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
OCTDIGIT    ([0-7])
DECDIGIT    ([0-9])
HEXDIGIT    ([0-9a-fA-F])
DIGIT       ({DECDIGIT})
ALPHAB      ([a-zA-Z])  
IDENT       ((_|{ALPHAB})(_|{ALPHAB}|{DIGIT})*)
OCTINTEGER  (0[1-7]{OCTDIGIT}*)
DECINTEGER  ([1-9]{DECDIGIT}*)
HEXINTEGER  (0x[1-9a-fA-F]{HEXDIGIT}*)
INTEGER     ((-)?(0|{DIGIT}))
REAL        ({INTEGER}"."{DIGIT}+)
PRINTABLE   ([ -~])
ESCAPE_SEQ  ([nt\\\'\"\?])

/* Rules */
%%
<STRINGS><<EOF>>          { yyerror("Invalid character"); yyterminate();}
<STRINGS>\\$              { strcat(string_buffer, yytext); line_number++; } // match a \ and newline
<STRINGS>[\\][n]          { strcat(string_buffer, "\n"); }
<STRINGS>[\\][t]          { strcat(string_buffer, "\t"); }
<STRINGS>[\\][?]          { strcat(string_buffer, "\?"); }
<STRINGS>[\\][\\]         { strcat(string_buffer, "\\"); }
<STRINGS>[\\]["]          { strcat(string_buffer, "\""); }
<STRINGS>[\\]{PRINTABLE}  { strcat(string_buffer, yytext); }
<STRINGS>["]              { printf("\"%s\"\n",string_buffer); BEGIN 0; }
<STRINGS>{PRINTABLE}      { strcat(string_buffer, yytext); }

"//"                    { BEGIN COMMENT; }
<COMMENT>[^\n]*         { ; }
<COMMENT>\n             { BEGIN 0; }

"/*"                    { BEGIN MULTI_COMMENT; }
<MULTI_COMMENT>"*/"     { BEGIN 0; }
<MULTI_COMMENT>(.|\n)   { ; }
<MULTI_COMMENT><<EOF>>  {yyerror("Invalid character"); yyterminate();}

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
";"         { printf("<SEMICOLON>\n"); }
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
{INTEGER}   { printf("<INTEGER_LITERAL>"); }
{REAL}      { printf("<REAL_LITERAL>"); }
{IDENT}     { printf("<IDENTIFIER>"); }
'\\{ESCAPE_SEQ}'  { printf("<ESCAPE_SEQUENCE>"); }
'.'         { printf("<CHARACTER_LITERAL>"); }
["]         { string_buffer[0] = '\0'; printf("<STRING>"); BEGIN(STRINGS); }
\n          { /* Ignore newlines */ line_number++; }
[ \t]+      { /* Ignore whitespace */ }
.           { yyerror("Invalid Token"); yyterminate(); }  
%%

void yyerror(const char *msg) {
    printf("Line %d: %s %s\n", line_number, msg, yytext);
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