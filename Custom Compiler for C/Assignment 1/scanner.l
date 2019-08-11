%{
#include "parser.tab.h"
#include "storetokens.hh"
#include <stdio.h>
%}

ws [ \t]+
letter [A-Za-z]
digit [0-9]
operator [\+\*\-\/]
name {letter}({letter}|{digit})*
integer_number {digit}+
double_number {digit}+(\.{digit}+)?(E[+\-]?{digit}+)?
meta_char [,;(){}]
comment \/\/.*

%%
{ws}   {/*no action, no return*/}
{comment} {/*no action, no return*/}

void  {store_token_name("VOID",yytext,yylineno); return 266;}
return  {store_token_name("RETURN",yytext,yylineno); return 262;}
int  {store_token_name("INTEGER",yytext,yylineno); return 263;}
float  {store_token_name("FLOAT",yytext,yylineno); return 264;}
{integer_number} {store_token_name("NUM",yytext,yylineno); yylval.integer_value = atoi(yytext); return 258;}
{double_number}  {store_token_name("FNUM",yytext,yylineno); yylval.double_value = atof(yytext); return 260;}
=  {store_token_name("ASSIGN_OP",yytext,yylineno); return 265;}
{operator}  {store_token_name("ARITHOP",yytext,yylineno); return yytext[0];}
{meta_char}  {store_token_name("META CHAR",yytext,yylineno); return yytext[0];}
{name}     {store_token_name("NAME",yytext,yylineno); yylval.string_value = new string(yytext); return 261;}
\n {yylineno++;}
%%