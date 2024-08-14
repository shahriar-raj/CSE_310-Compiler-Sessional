%option noyywrap

%x COMMENT
%x MULSTRING
%x COMMENT2
%x SSTR

%{
#include<iostream>
#include<fstream>
#include<string>
#include <list>
#include "1905105.h"
#include "y.tab.h"

using namespace std;

extern int line_count;
extern int error_count;
int inner_line_count = 0;
extern YYSTYPE yylval; 

FILE* in;
//extern ofstream outlog;
extern ofstream outerror;
extern string name_;
extern string type_;
char c;
int i;
string comment="";
string mulstring="";
string token_str ="";
bool inserted;

char char_return(char t){
	switch (t){
		case '\'':return('\'');
		case '\"':return('\"');
		case '\\':return('\\');
		case 'n':return('\n');
		case 't':return('\t');
		case 'a':return('\a');
		case 'f':return('\f');
		case 'r':return('\r');
		case 'b':return('\b');
		case 'v':return('\v');
		case '0':return('\0');
		default :return('\0');
	} 
}
%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n
UNDERSCORE _

%%
{WHITESPACE} {;}
{NEWLINE} {line_count++;}

"if"	{
			//outlog << "Line# " << line_count << ": Token <IF> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"IF");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return IF;
		}

"for"	{
			//outlog << "Line# " << line_count << ": Token <FOR> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"FOR");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return FOR;
		}

"do"	{
			//outlog << "Line# " << line_count << ": Token <DO> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"DO");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return DO;
		}

"int"	{
			//outlog << "Line# " << line_count << ": Token <INT> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"INT");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			type_="INT";
			return INT;
		}

"float"	{
			//outlog << "Line# " << line_count << ": Token <FLOAT> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"FLOAT");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			type_="FLOAT";
			return FLOAT;
		}

"void"	{
			//outlog << "Line# " << line_count << ": Token <VOID> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"VOID");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			type_="VOID";
			return VOID;
		}

"switch"	{
			//outlog << "Line# " << line_count << ": Token <SWITCH> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"SWITCH");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return SWITCH;
		}

"default"	{
			//outlog << "Line# " << line_count << ": Token <DEFAULT> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"DEFAULT");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return DEFAULT;
		}		

"else"	{
			//outlog << "Line# " << line_count << ": Token <ELSE> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"ELSE");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return ELSE;
		}

"while"	{
			//outlog << "Line# " << line_count << ": Token <WHILE> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"WHILE");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return WHILE;
		}

"break"	{
			//outlog << "Line# " << line_count << ": Token <BREAK> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"BREAK");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return BREAK;
		}

"char"	{
			//outlog << "Line# " << line_count << ": Token <CHAR> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"CHAR");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return CHAR;
		}

"double"	{
			//outlog << "Line# " << line_count << ": Token <DOUBLE> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"DOUBLE");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return DOUBLE;
		}

"return"	{
			//outlog << "Line# " << line_count << ": Token <RETURN> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"RETURN");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return RETURN;
		}

"case"	{
			//outlog << "Line# " << line_count << ": Token <CASE> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"CASE");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return CASE;
		}

"println"	{
				//outlog << "Line# " << line_count << ": Token <PRINTLN> Lexeme "<< yytext << " found" << endl;
				yylval.symbol = new symbolinfo(yytext,"PRINTLN");
				yylval.symbol->setLeaf(true);
				yylval.symbol->setSLine(line_count);
				yylval.symbol->setELine(line_count);
				return PRINTLN;	
			}

"continue"	{
			//outlog << "Line# " << line_count << ": Token <CONTINUE> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"CONTINUE");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return CONTINUE;
		}

"+"		|
"-"		{
			//outlog << "Line# " << line_count << ": Token <ADDOP> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"ADDOP");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return ADDOP;
			// There is a '|' in "+"'s rule, this means match execute the action for following rule
		}

"*"		|
"/"		|
"%"		{
			//outlog << "Line# " << line_count << ": Token <MULOP> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"MULOP");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return MULOP;
		}

"++"	{
			//outlog << "Line# " << line_count << ": Token <INCOP> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"INCOP");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return INCOP;
		}	

"--"	{
			//outlog << "Line# " << line_count << ": Token <INCOP> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"DECOP");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return DECOP;
		}	

"<"		|
"<="	|
">"		|
">="	|
"=="	|
"!="	{
			//outlog << "Line# " << line_count << ": Token <RELOP> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"RELOP");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return RELOP;
		}	

"="		{
			//outlog << "Line# " << line_count << ": Token <ASSIGNOP> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"ASSIGNOP");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return ASSIGNOP;
		}	

"&&"	|
"||"	{
			//outlog << "Line# " << line_count << ": Token <LOGICOP> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"LOGICOP");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return LOGICOP;
		}

"&"		|
"|"		|
"^"		|
"<<"	|
">>"	{
			//outlog << "Line# " << line_count << ": Token <BITOP> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"BITOP");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return BITOP;
		}

"!"		{
			//outlog << "Line# " << line_count << ": Token <NOT> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"NOT");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return NOT;
		}

"("		{
			//outlog << "Line# " << line_count << ": Token <LPAREN> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"LPAREN");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return LPAREN;
		}

")"		{
			//outlog << "Line# " << line_count << ": Token <RPAREN> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"RPAREN");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return RPAREN;
		}

"{"		{
			//outlog << "Line# " << line_count << ": Token <LCURL> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"LCURL");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return LCURL;
		}

"}"		{
			//outlog << "Line# " << line_count << ": Token <RCURL> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"RCURL");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return RCURL;
		}

"["		{
			//outlog << "Line# " << line_count << ": Token <LSQUARE> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"LSQUARE");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return LSQUARE;
		}

"]"		{
			//outlog << "Line# " << line_count << ": Token <RSQUARE> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"RSQUARE");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return RSQUARE;
		}

","		{
			//outlog << "Line# " << line_count << ": Token <COMMA> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"COMMA");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return COMMA;
		}

";"		{
			//outlog << "Line# " << line_count << ": Token <SEMICOLON> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"SEMICOLON");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return SEMICOLON;
		}

\'([^'\\]|\\['"\\ntafrbv0])\' {
		 if(yytext[1]!='\\'){
			c = yytext[1]; 
		 } 
		 else{
			c = char_return(yytext[2]);
		 }
		 //outlog << "Line# " << line_count << ": Token <CONST_CHAR> Lexeme "<< c << " found" << endl;
		 yylval.symbol = new symbolinfo(string(1,c),"CONST_CHAR");
		 yylval.symbol->setLeaf(true);
		 yylval.symbol->setSLine(line_count);
		 yylval.symbol->setELine(line_count);
		 return CONST_CHAR;
}


'' {
	outerror <<"Line# "<< line_count <<  ": EMPTY_CONST_CHAR " << yytext << endl;
	error_count++;
}

\'([^'\\]|\\['"\\ntafrbv0]) {
		outerror <<"Line# "<< line_count <<  ": UNFINISHED_CONST_CHAR " << yytext << endl;
		error_count++;
}

\'([^'\\]|\\['"\\ntafrbv0])([^'\n])+\' {
		outerror <<"Line# "<< line_count <<  ": MULTICHAR_CONST_CHAR " << yytext << endl;
		error_count++;
}

\" {
		mulstring = "";
		token_str = "";
		mulstring.append(yytext);
		token_str.append(yytext);
		inner_line_count = 0;
		BEGIN(MULSTRING);
	}

<MULSTRING>\\\" {
		mulstring.append(yytext);
		token_str.append(yytext);
}

<MULSTRING>\" {
					mulstring.append(yytext);
					token_str.append(yytext);
					if(inner_line_count==0){
						//outlog <<"Line# " << line_count << ": Token <SINGLE LINE STRING> Lexeme "<< mulstring << " found" << endl;
						i=1;
						while(token_str[i]!='\"'){
							if(token_str[i]!='\\'){
								c = token_str[i++]; 
		 					}			 
		 					else{
								i++;
								c = char_return(token_str[i++]);
		 					}
						}
						BEGIN(INITIAL);
					}
					else{
						//outlog <<"Line# " << line_count << ": Token <MULTI LINE STRING> Lexeme "<< mulstring << " found" << endl;
						line_count+=inner_line_count;
						i=1;
						 while(token_str[i]!='\"'){
					 		if(token_str[i]!='\\'){
					 			c = token_str[i++]; 
		 			 		}
					 		else{
					 			i++;
					 			c = char_return(token_str[i++]);
		 			 		}
					 	}		
						BEGIN(INITIAL);
					}
				}

<MULSTRING>\\[\r]?\n {
						mulstring.append(yytext);
						inner_line_count++;
					}

<MULSTRING>(.) {
					mulstring.append(yytext);
					token_str.append(yytext);
				}

<MULSTRING>[\r]?\n {
						inner_line_count++;
						error_count++;
						line_count+=inner_line_count;
						outerror <<"Line# "<< line_count-1 <<  ": UNFINISHED_STRING " << mulstring << endl;
						BEGIN(INITIAL);
					}

<MULSTRING><<EOF>> {
						error_count++;
						line_count+=inner_line_count;
						outerror <<"Line# "<< line_count-1 <<  ": UNFINISHED_STRING " << mulstring << endl;
						BEGIN(INITIAL);
					}	

"/*" {
			comment = "";
			comment.append(yytext);
			inner_line_count=0;
			BEGIN(COMMENT);
	}

<COMMENT>"*/" {		
					comment.append(yytext); 
					//outlog <<"Line# " << line_count << ": Token <MULTI LINE COMMENT> Lexeme "<< comment << " found" << endl;
					line_count += inner_line_count;	
					BEGIN(INITIAL);
			}

<COMMENT>[\r]?\n {
				comment.append(yytext);
				inner_line_count++;
			}

<COMMENT>(.) {
				comment.append(yytext);
			}

<COMMENT><<EOF>> {	
					error_count++;
					line_count+=inner_line_count;
					outerror <<"Line# "<< line_count++ <<  ": UNFINISHED_COMMENT " << comment << endl;
					BEGIN(INITIAL);
				}
		
\/\/ {
		comment = "";
		comment.append(yytext);
		inner_line_count = 0;
		BEGIN(COMMENT2);
	}

<COMMENT2>\\[\r]?\n {
						comment.append(yytext);
						inner_line_count++;
					}

<COMMENT2>[\r]?\n {
				//outlog <<"Line# " << line_count << ": Token <SINGLE LINE COMMENT> Lexeme "<< comment << " found" << endl;	
				inner_line_count++;
				line_count += inner_line_count;
				BEGIN(INITIAL);
			}

<COMMENT2>(.) {
				comment.append(yytext);
			}

<COMMENT2><<EOF>> {
					//outlog <<"Line# " << line_count << ": Token <SINGLE LINE COMMENT> Lexeme "<< comment << " found" << endl;	
					line_count++;
				}

({UNDERSCORE}|{LETTER})+({DIGIT}|{LETTER}|{UNDERSCORE})* {
			//outlog << "Line# " << line_count << ": Token <ID> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"ID");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			name_ = yytext;
			return ID;
		}

{DIGIT}+({UNDERSCORE}|{LETTER})+({DIGIT}|{LETTER}|{UNDERSCORE})* {
			outerror <<"Line# "<< line_count <<  ": INVALID_ID_SUFFIX_NUM_PREFIX " << yytext << endl;
			error_count++;
		}

{DIGIT}+ {
			//outlog << "Line# " << line_count << ": Token <CONST_INT> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"CONST_INT");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return CONST_INT;
		}

(({DIGIT}*\.{DIGIT}+)|{DIGIT}+)([Ee][+-]?{DIGIT}+)? {
			//outlog << "Line# " << line_count << ": Token <CONST_FLOAT> Lexeme "<< yytext << " found" << endl;
			yylval.symbol = new symbolinfo(yytext,"CONST_FLOAT");
			yylval.symbol->setLeaf(true);
			yylval.symbol->setSLine(line_count);
			yylval.symbol->setELine(line_count);
			return CONST_FLOAT;
		}

({DIGIT}*\.{DIGIT}*)+ {
			outerror <<"Line# "<< line_count <<  ": TOO_MANY_DECIMAL_POINTS " << yytext << endl;
			error_count++;
}		

({DIGIT}+([Ee][+-]?{DIGIT}*\.{DIGIT}*)) {
			outerror <<"Line# "<< line_count <<  ": ILLFORMED_NUMBER " << yytext << endl;
			error_count++;
}

. {
	outerror <<"Line# "<< line_count <<  ": UNRECOGNIZED_CHAR " << yytext << endl;
			error_count++;
}

