%{
    #include "common.h"
    #include "syn_gv.tab.h"
    #define MAXBUFFER 10000
    char string_buffer[MAXBUFFER]={0};
    extern size_t line_number;
%}

/* Definitions */
%x COMMENT
%x MULTI_COMMENT
%x STRINGS
%option noyywrap
%option yylineno

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
<STRINGS>(\\n)          { strcat(string_buffer, "\\x0a"); }
<STRINGS>(\\t)          { strcat(string_buffer, "\\x09"); }
<STRINGS>(\\\?)         { strcat(string_buffer, "\\x3f"); }
<STRINGS>(\\\\)         { strcat(string_buffer, "\\x5c"); }
<STRINGS>(\\\")         { strcat(string_buffer, "\\x22"); }
<STRINGS>(\\\')         { strcat(string_buffer, "'"); }
<STRINGS>(\\{PRINTABLE}) { yywarning("Invalid Escape Char, skipping"); 
                            strcat(string_buffer, &(yytext[1])); }
<STRINGS>(\")           { BEGIN(INITIAL); strcat(string_buffer, "\"\0"); yylval.string = strdup(string_buffer); return TER_STRING;}
<STRINGS>(\n)           { yyerror("Missing Terminating Char \""); yyterminate(); }
<STRINGS>{PRINTABLE}    { strcat(string_buffer, yytext); }
["]                     { string_buffer[0] = '\"'; string_buffer[1] = '\0'; BEGIN(STRINGS); }


<COMMENT>[^\n]*         { ; }
<COMMENT>\n             { BEGIN 0; /*printf("\n");*/ line_number++; }
"//"                    { BEGIN COMMENT; /*printf("<INLINE COMMENT>");*/  }

<MULTI_COMMENT><<EOF>>  { yyerror("missing */"); yyterminate(); }
<MULTI_COMMENT>(\n)     { line_number++; printf("\n"); }
<MULTI_COMMENT>"*/"     { /*printf("<COMMENT END>");*/ BEGIN 0; }
<MULTI_COMMENT>(.)      { ; }
"/*"                    { BEGIN MULTI_COMMENT; /*printf("<MULTI LINE COMMENT>");*/ }

"var"       { yylval.string = strdup(yytext); return TER_VAR; }
"val"       { yylval.string = strdup(yytext); return TER_VAL; }
"bool"      { yylval.string = strdup(yytext); return TER_TYPE; }
"char"      { yylval.string = strdup(yytext); return TER_TYPE; }
"int"       { yylval.string = strdup(yytext); return TER_TYPE; }
"real"      { yylval.string = strdup("double"); return TER_TYPE; }
"class"     { yylval.string = strdup(yytext); return TER_CLASS; }
"if"        { yylval.string = strdup(yytext); return TER_IF; }
"else"      { yylval.string = strdup(yytext); return TER_ELSE; }
"for"       { yylval.string = strdup(yytext); return TER_FOR; }
"while"     { yylval.string = strdup(yytext); return TER_WHILE; }
"do"        { yylval.string = strdup(yytext); return TER_DO; }
"switch"    { yylval.string = strdup(yytext); return TER_SWITCH; }
"case"      { yylval.string = strdup(yytext); return TER_CASE; }
"fun"       { yylval.string = strdup(yytext); return TER_FUN; }
"ret"       { yylval.string = strdup(yytext); return TER_RET; }
"("         { yylval.string = strdup(yytext); return '('; } //return TER_LPAREN; }
")"         { yylval.string = strdup(yytext); return ')'; } //return TER_RPAREN; }
"["         { yylval.string = strdup(yytext); return '['; } //return TER_LBRACKET; }
"]"         { yylval.string = strdup(yytext); return ']'; } //return TER_RBRACKET; }
"{"         { yylval.string = strdup(yytext); return '{'; } //return TER_LBRACE; }
"}"         { yylval.string = strdup(yytext); return '}'; } //return TER_RBRACE; }
","         { yylval.string = strdup(yytext); return ','; } //return TER_COMMA; }
";"         { yylval.string = strdup(yytext); return ';'; } //return TER_SEMICOLON; }   
":"         { yylval.string = strdup(yytext); return ':'; } //return TER_COLON; }
"+"         { yylval.string = strdup(yytext); return '+'; } //TER_OPS_ADD; }
"-"         { yylval.string = strdup(yytext); return '-'; } //TER_OPS_SUB; }
"*"         { yylval.string = strdup(yytext); return '*'; } //TER_OPS_MUL; }
"/"         { yylval.string = strdup(yytext); return '/'; } //TER_OPS_DIV; }
"="         { yylval.string = strdup(yytext); return '='; } //TER_OPS_ASSIGN; }
"=="        { yylval.string = strdup(yytext); return TER_OPS_RELATION; }
"!="        { yylval.string = strdup(yytext); return TER_OPS_RELATION; }
">"         { yylval.string = strdup(yytext); return TER_OPS_RELATION; }
"<"         { yylval.string = strdup(yytext); return TER_OPS_RELATION; }
">="        { yylval.string = strdup(yytext); return TER_OPS_RELATION; }
"<="        { yylval.string = strdup(yytext); return TER_OPS_RELATION; }
"true"      { yylval.string = strdup(yytext); return TER_CONST_BOOL; }
"false"     { yylval.string = strdup(yytext); return TER_CONST_BOOL; }
{BININTEGER}   { yylval.number_type._str_value = strdup(yytext); 
                 yylval.number_type._type = int_B;
                 return TER_CONST_NUMBER; 
                 }
{OCTINTEGER}   { yylval.number_type._str_value = strdup(yytext); 
                 yylval.number_type._type = int_O;
                 return TER_CONST_NUMBER; 
                 }
{DECINTEGER}   { yylval.number_type._str_value = strdup(yytext); 
                 yylval.number_type._type = int_D;
                 return TER_CONST_NUMBER; 
                 }
{HEXINTEGER}   { yylval.number_type._str_value = strdup(yytext); 
                 yylval.number_type._type = int_H;
                 return TER_CONST_NUMBER; 
                 }
{REAL}      { yylval.number_type._str_value = strdup(yytext); 
              yylval.number_type._type = real;
              return TER_CONST_NUMBER; }

{IDENT}     { yylval.string = strdup(yytext); return TER_IDENT; }

'\\{ESCAPE_SEQ}'  { yylval.number_type._str_value = strdup(yytext); 
                    yylval.number_type._type = char_esp;
                    yylval.number_type._char_value = escape_seq_val(yytext);
                    return TER_CONST_NUMBER; }
'.'         { yylval.number_type._str_value = strdup(yytext); 
              yylval.number_type._type = char_one;
              yylval.number_type._char_value = yytext[1];
              return TER_CONST_NUMBER; }
'\\[^ -~]'  { yywarning("Invalid Escape Char, skipping"); 
              yylval.number_type._str_value = strdup(yytext); 
              yylval.number_type._type = char_unesp;
              yylval.number_type._char_value = yytext[2];
              return TER_CONST_NUMBER; }

''          { yyerror("Empty Char Constant"); yyterminate(); }
\n          { line_number++; /*printf("\n");*/ }
[ \t]+      { /* Ignore whitespace */ }
.           { yyerror("Invalid Token"); yyterminate(); }  
%%

/*
*/