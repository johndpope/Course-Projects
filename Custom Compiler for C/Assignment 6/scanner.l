%{
#include "parser.tab.h"
#include <stdio.h>
%}

ws [ \t]+
letter [A-Za-z]
digit [0-9]
operator [\+\*\-\/]
name ({letter}|_)({letter}|{digit}|_)*
integer_number {digit}+
double_number {digit}+(\.{digit}+)?(E[+\-]?{digit}+)?
meta_char [,;(){}?:]
comment \/\/.*

%%
{ws}   {/*no action, no return*/}
{comment} {/*no action, no return*/}

void  {store_token_name("VOID",yytext,yylineno); return VOID;}
int  {store_token_name("INTEGER",yytext,yylineno); return INTEGER;}
float  {store_token_name("FLOAT",yytext,yylineno); return FLOAT;}

do  {store_token_name("DO",yytext,yylineno); return DO;}
while  {store_token_name("WHILE",yytext,yylineno); return WHILE;}
if  {store_token_name("IF",yytext,yylineno); return IF;}
else  {store_token_name("ELSE",yytext,yylineno); return ELSE;}
print {store_token_name("PRINT",yytext,yylineno); return PRINT;}
return {store_token_name("RETURN",yytext,yylineno); return PRINT;}

{integer_number} {store_token_name("NUM",yytext,yylineno); yylval.integer_value = atoi(yytext); return NUM;}
{double_number}  {store_token_name("FNUM",yytext,yylineno); yylval.double_value = atof(yytext); return FNUM;}

"=="  {store_token_name("EQUAL",yytext,yylineno); return EQUAL;}
"<=" {store_token_name("LESS_THAN_EQUAL",yytext,yylineno); return LESS_THAN_EQUAL;}
">="  {store_token_name("GREATER_THAN_EQUAL",yytext,yylineno); return GREATER_THAN_EQUAL;}
"!="  {store_token_name("NOT_EQUAL",yytext,yylineno); return NOT_EQUAL;}
">"  {store_token_name("GREATER_THAN",yytext,yylineno); return GREATER_THAN;}
"<"  {store_token_name("LESS_THAN",yytext,yylineno); return LESS_THAN;}
"&&"  {store_token_name("AND",yytext,yylineno); return AND;}
"||"  {store_token_name("OR",yytext,yylineno); return OR;}
"!"  {store_token_name("NOT",yytext,yylineno); return NOT;}

"="  {store_token_name("ASSIGN_OP",yytext,yylineno); return ASSIGN;}
{operator}  {store_token_name("ARITHOP",yytext,yylineno); return yytext[0];}
{meta_char}  {store_token_name("META CHAR",yytext,yylineno); return yytext[0];}
{name}     {store_token_name("NAME",yytext,yylineno); yylval.string_value = new string(yytext); return NAME;}
\n {;}
. {printf("cs316: Error\n"); exit(0);}
%%