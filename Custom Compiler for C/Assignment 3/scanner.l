%{
#include "parser.tab.h"
#include <stdio.h>
%}

ws [ \t]+
letter [A-Za-z]
digit [0-9]
operator [\+\*\-\/]
name {letter}({letter}|{digit}|_)*
integer_number {digit}+
double_number {digit}+(\.{digit}+)?(E[+\-]?{digit}+)?
meta_char [,;(){}]
comment \/\/.*

%%
{ws}   {/*no action, no return*/}
{comment} {/*no action, no return*/}

void  {store_token_name("VOID",yytext,yylineno); return VOID;}
int  {store_token_name("INTEGER",yytext,yylineno); return INTEGER;}
float  {store_token_name("FLOAT",yytext,yylineno); return FLOAT;}
{integer_number} {store_token_name("NUM",yytext,yylineno); yylval.integer_value = atoi(yytext); return NUM;}
{double_number}  {store_token_name("FNUM",yytext,yylineno); yylval.double_value = atof(yytext); return FNUM;}
=  {store_token_name("ASSIGN",yytext,yylineno); return ASSIGN;}
{operator}  {store_token_name("ARITHOP",yytext,yylineno); return yytext[0];}
{meta_char}  {store_token_name("META CHAR",yytext,yylineno); return yytext[0];}
{name}     {store_token_name("NAME",yytext,yylineno); yylval.string_value = new string(yytext); return NAME;}
\n {;}
. {printf("cs316 Error"); exit(0);}
%%