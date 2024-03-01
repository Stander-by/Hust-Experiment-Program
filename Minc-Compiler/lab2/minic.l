%{
#include "string.h"
#include "def.h"

extern int yycolumn;

#define YYSTYPE yylval
extern "C"
{	
	int yywrap(void);
	int yylex(void);
}

void flexout(std::string name,std::string value){
  std::cout<<name<<"\t:"<<value<<std::endl;
}
//flex为bison提供行号信息
%}
%option yylineno 

%%

"int"        {flexout("TYPE","int");}
"float"      {flexout("TYPE","float");}
"char"      {flexout("TYPE","char");}
"if"        {flexout("IF","if");}
"else"        {flexout("ELSE","else");}
"struct"        {flexout("STRUCT","struct");}
"return"     {flexout("RETURN","return");}
"("         {flexout("LP","(");}
")"         {flexout("RP",")");}
"{"         {flexout("LC","{");}
"}"         {flexout("RC","}");}
"["      {flexout("LB","[");}
"]"      {flexout("RB","]");}
"++"     {flexout("PLUSPLUS","++");}
"--"     {flexout("MINUSMINUS","--");}
"+="     {flexout("PLUSASS","+=");}
"-="     {flexout("MINUSASS","-=");}
"="         {flexout("ASSIGNOP","=");}
"+"         {flexout("PLUS","+");}
"-"         {flexout("SUB","-");}    
"=="     {flexout("RELOP","==");}
"."       {flexout("DOT",".");}
","      {flexout("COMMA",",");}
";"         {flexout("SEMI",";");}



[A-Za-z][A-Za-z0-9]*  {flexout("ID",yytext);}

[\-]?[1-9][0-9]*|[0][0-7]*    {flexout("INT",yytext);}
[0][x][A-F1-9][A-F0-9]* {flexout("INT",yytext);}

[1-9][0-9]*[.][0-9][0-9]*[e][\-][1-9] {flexout("FLOAT",yytext);}
[1-9][0-9]*[.][0-9][0-9]* {flexout("FLOAT",yytext);}

[\n]         {yycolumn++;}


[\n]		{yycolumn=1;}
[ \r\t]		{/*printf("过滤空格等字符\n");*/}

[0][0-9]*[8-9][0-9]*    {printf("Error type A at Line %d: Illegal octal number '%s'\n", yycolumn, yytext);}
[0][x][A-F1-9]*[G-Z][A-F1-9]* {printf("Error type A at Line %d: Illegal hexadecimal number '%s'\n", yycolumn, yytext);}
[\~\!\@\#\$\%\^\&\_\\] {printf("Error type A at Line %d: Mysterious characters '%s'\n", yycolumn, yytext);}


%%

int yywrap()
{
    return 1;
}