%option noyywrap

%x COMMENT
%x MULSTRING
%x COMMENT2
%x SSTR

%{
#include<iostream>
#include<fstream>
#include<string>

using namespace std;

int line_count = 1;
int error_count = 0;
int inner_line_count = 0;

#include "1905105.h"

symbolTable A(10);
FILE* in;
ofstream outlog;
ofstream outl;
ofstream outtoken;
ofstream outt;
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
			outtoken << "<IF, " << yytext << ">" << endl;
			outlog << "Line# " << line_count << ": Token <IF> Lexeme "<< yytext << " found" << endl;
		}

"for"	{
			outtoken << "<FOR, " << yytext << ">" << endl;
			outlog << "Line# " << line_count << ": Token <FOR> Lexeme "<< yytext << " found" << endl;
		}

"do"	{
			outtoken << "<DO, " << yytext << ">" << endl;
			outlog << "Line# " << line_count << ": Token <DO> Lexeme "<< yytext << " found" << endl;
		}

"int"	{
			outtoken << "<INT, " << yytext << ">" << endl;
			outlog << "Line# " << line_count << ": Token <INT> Lexeme "<< yytext << " found" << endl;
		}

"float"	{
			outtoken << "<FLOAT, " << yytext << ">" << endl;
			outlog << "Line# " << line_count << ": Token <FLOAT> Lexeme "<< yytext << " found" << endl;
		}

"void"	{
			outtoken << "<VOID, " << yytext << ">" << endl;
			outlog << "Line# " << line_count << ": Token <VOID> Lexeme "<< yytext << " found" << endl;
		}

"switch"	{
			outtoken << "<SWITCH, " << yytext << ">" << endl;
			outlog << "Line# " << line_count << ": Token <SWITCH> Lexeme "<< yytext << " found" << endl;
		}

"default"	{
			outtoken << "<DEFAULT, " << yytext << ">" << endl;
			outlog << "Line# " << line_count << ": Token <DEFAULT> Lexeme "<< yytext << " found" << endl;
		}		

"else"	{
			outtoken << "<ELSE, " << yytext << ">" << endl;
			outlog << "Line# " << line_count << ": Token <ELSE> Lexeme "<< yytext << " found" << endl;
		}

"while"	{
			outtoken << "<WHILE, " << yytext << ">" << endl;
			outlog << "Line# " << line_count << ": Token <WHILE> Lexeme "<< yytext << " found" << endl;
		}

"break"	{
			outtoken << "<BREAK, " << yytext << ">" << endl;
			outlog << "Line# " << line_count << ": Token <BREAK> Lexeme "<< yytext << " found" << endl;
		}

"char"	{
			outtoken << "<CHAR, " << yytext << ">" << endl;
			outlog << "Line# " << line_count << ": Token <CHAR> Lexeme "<< yytext << " found" << endl;
		}

"double"	{
			outtoken << "<DOUBLE, " << yytext << ">" << endl;
			outlog << "Line# " << line_count << ": Token <DOUBLE> Lexeme "<< yytext << " found" << endl;
		}

"return"	{
			outtoken << "<RETURN, " << yytext << ">" << endl;
			outlog << "Line# " << line_count << ": Token <RETURN> Lexeme "<< yytext << " found" << endl;
		}

"case"	{
			outtoken << "<CASE, " << yytext << ">" << endl;
			outlog << "Line# " << line_count << ": Token <CASE> Lexeme "<< yytext << " found" << endl;
		}

"continue"	{
			outtoken << "<CONTINUE, " << yytext << ">" << endl;
			outlog << "Line# " << line_count << ": Token <CONTINUE> Lexeme "<< yytext << " found" << endl;
		}

"+"		|
"-"		{
			outtoken << "<ADDOP, " << yytext <<">" << endl;
			outlog << "Line# " << line_count << ": Token <ADDOP> Lexeme "<< yytext << " found" << endl;
			// There is a '|' in "+"'s rule, this means match execute the action for following rule
		}

"*"		|
"/"		|
"%"		{
			outtoken << "<MULOP, " << yytext <<">" << endl;
			outlog << "Line# " << line_count << ": Token <MULOP> Lexeme "<< yytext << " found" << endl;
		}

"++"	|
"--"	{
			outtoken << "<INCOP, " << yytext <<">" << endl;
			outlog << "Line# " << line_count << ": Token <INCOP> Lexeme "<< yytext << " found" << endl;
		}		

"<"		|
"<="	|
">"		|
">="	|
"=="	|
"!="	{
			outtoken << "<RELOP, " << yytext <<">" << endl;
			outlog << "Line# " << line_count << ": Token <RELOP> Lexeme "<< yytext << " found" << endl;
		}	

"="		{
			outtoken << "<ASSIGNOP, " << yytext <<">" << endl;
			outlog << "Line# " << line_count << ": Token <ASSIGNOP> Lexeme "<< yytext << " found" << endl;
		}	

"&&"	|
"||"	{
			outtoken << "<LOGICOP, " << yytext <<">" << endl;
			outlog << "Line# " << line_count << ": Token <LOGICOP> Lexeme "<< yytext << " found" << endl;
		}

"&"		|
"|"		|
"^"		|
"<<"	|
">>"	{
			outtoken << "<BITOP, " << yytext <<">" << endl;
			outlog << "Line# " << line_count << ": Token <BITOP> Lexeme "<< yytext << " found" << endl;
		}

"!"		{
			outtoken << "<NOT, " << yytext <<">" << endl;
			outlog << "Line# " << line_count << ": Token <NOT> Lexeme "<< yytext << " found" << endl;
		}

"("		{
			outtoken << "<LPAREN, " << yytext <<">" << endl;
			outlog << "Line# " << line_count << ": Token <LPAREN> Lexeme "<< yytext << " found" << endl;
		}

")"		{
			outtoken << "<RPAREN, " << yytext <<">" << endl;
			outlog << "Line# " << line_count << ": Token <RPAREN> Lexeme "<< yytext << " found" << endl;
		}

"{"		{
			A.EnterScope();
			outtoken << "<LCURL, " << yytext <<">" << endl;
			outlog << "Line# " << line_count << ": Token <LCURL> Lexeme "<< yytext << " found" << endl;
		}

"}"		{
			A.ExitScope();
			outtoken << "<RCURL, " << yytext <<">" << endl;
			outlog << "Line# " << line_count << ": Token <RCURL> Lexeme "<< yytext << " found" << endl;
		}

"["		{
			outtoken << "<LSQUARE, " << yytext <<">" << endl;
			outlog << "Line# " << line_count << ": Token <LSQUARE> Lexeme "<< yytext << " found" << endl;
		}

"]"		{
			outtoken << "<RSQUARE, " << yytext <<">" << endl;
			outlog << "Line# " << line_count << ": Token <RSQUARE> Lexeme "<< yytext << " found" << endl;
		}

","		{
			outtoken << "<COMMA, " << yytext <<">" << endl;
			outlog << "Line# " << line_count << ": Token <COMMA> Lexeme "<< yytext << " found" << endl;
		}

";"		{
			outtoken << "<SEMICOLON, " << yytext <<">" << endl;
			outlog << "Line# " << line_count << ": Token <SEMICOLON> Lexeme "<< yytext << " found" << endl;
		}

\'([^'\\]|\\['"\\ntafrbv0])\' {
		 outtoken << "<CONST_CHAR, ";
		 
		 if(yytext[1]!='\\'){
			c = yytext[1]; 
		 } 
		 else{
			c = char_return(yytext[2]);
		 }
		 outtoken << c <<">" << endl;
		 outlog << "Line# " << line_count << ": Token <CONST_CHAR> Lexeme "<< c << " found" << endl;
}


'' {
	outlog <<"Error at line# "<< line_count <<  ": EMPTY_CONST_CHAR " << yytext << endl;
	error_count++;
}

\'([^'\\]|\\['"\\ntafrbv0]) {
		outlog <<"Error at line# "<< line_count <<  ": UNFINISHED_CONST_CHAR " << yytext << endl;
		error_count++;
}

\'([^'\\]|\\['"\\ntafrbv0])([^'\n])+\' {
		outlog <<"Error at line# "<< line_count <<  ": MULTICHAR_CONST_CHAR " << yytext << endl;
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
						outlog <<"Line# " << line_count << ": Token <SINGLE LINE STRING> Lexeme "<< mulstring << " found" << endl;
						outtoken << "<SINGLE LINE STRING, ";
						i=1;
						while(token_str[i]!='\"'){
							if(token_str[i]!='\\'){
								c = token_str[i++]; 
		 					}			 
		 					else{
								i++;
								c = char_return(token_str[i++]);
		 					}
							outtoken << c;
						}
		 				outtoken << ">" << endl;
						BEGIN(INITIAL);
					}
					else{
						outlog <<"Line# " << line_count << ": Token <MULTI LINE STRING> Lexeme "<< mulstring << " found" << endl;
						line_count+=inner_line_count;
						outtoken << "<MULTI LINE STRING, ";
						i=1;
						 while(token_str[i]!='\"'){
					 		if(token_str[i]!='\\'){
					 			c = token_str[i++]; 
		 			 		}
					 		else{
					 			i++;
					 			c = char_return(token_str[i++]);
		 			 		}
							outtoken << c; 
					 	}
		 				outtoken << ">" << endl;			
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
						outlog <<"Error at line# "<< line_count-1 <<  ": UNFINISHED_STRING " << mulstring << endl;
						BEGIN(INITIAL);
					}

<MULSTRING><<EOF>> {
						error_count++;
						line_count+=inner_line_count;
						outlog <<"Error at line# "<< line_count-1 <<  ": UNFINISHED_STRING " << mulstring << endl;
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
					outlog <<"Line# " << line_count << ": Token <MULTI LINE COMMENT> Lexeme "<< comment << " found" << endl;
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
					outlog <<"Error at line# "<< line_count++ <<  ": UNFINISHED_COMMENT " << comment << endl;
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
				outlog <<"Line# " << line_count << ": Token <SINGLE LINE COMMENT> Lexeme "<< comment << " found" << endl;	
				inner_line_count++;
				line_count += inner_line_count;
				BEGIN(INITIAL);
			}

<COMMENT2>(.) {
				comment.append(yytext);
			}

<COMMENT2><<EOF>> {
					outlog <<"Line# " << line_count << ": Token <SINGLE LINE COMMENT> Lexeme "<< comment << " found" << endl;	
					line_count++;
				}

({UNDERSCORE}|{LETTER})+({DIGIT}|{LETTER}|{UNDERSCORE})* {
			outtoken << "<ID, " << yytext <<">" << endl;
			outlog << "Line# " << line_count << ": Token <ID> Lexeme "<< yytext << " found" << endl;
			symbolinfo sym(yytext,"ID");
			inserted = A.Insert(sym);
			if(inserted){
				A.PrintA();
			}
		}

{DIGIT}+({UNDERSCORE}|{LETTER})+({DIGIT}|{LETTER}|{UNDERSCORE})* {
			outlog <<"Error at line# "<< line_count <<  ": INVALID_ID_SUFFIX_NUM_PREFIX " << yytext << endl;
			error_count++;
		}

{DIGIT}+ {
			outtoken << "<CONST_INT, " << yytext <<">" << endl;
			outlog << "Line# " << line_count << ": Token <CONST_INT> Lexeme "<< yytext << " found" << endl;
		}

(({DIGIT}*\.{DIGIT}+)|{DIGIT}+)([Ee][+-]?{DIGIT}+)? {
			outtoken << "<CONST_FLOAT, " << yytext <<">" << endl;
			outlog << "Line# " << line_count << ": Token <CONST_FLOAT> Lexeme "<< yytext << " found" << endl;
		}

({DIGIT}*\.{DIGIT}*)+ {
			outlog <<"Error at line# "<< line_count <<  ": TOO_MANY_DECIMAL_POINTS " << yytext << endl;
			error_count++;
}		

({DIGIT}+([Ee][+-]?{DIGIT}*\.{DIGIT}*)) {
			outlog <<"Error at line# "<< line_count <<  ": ILLFORMED_NUMBER " << yytext << endl;
			error_count++;
}

. {
	outlog <<"Error at line# "<< line_count <<  ": UNRECOGNIZED_CHAR " << yytext << endl;
			error_count++;
}


%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		cout << "Please provide input file name and try again" << endl;
		return 0;
	}
	
	in = fopen(argv[1],"r");
	if(in==NULL){
		cout << "Cannot open specified file" << endl;
		return 0;
	}
	
	yyin= in;
	outl.open("output_log.txt");
	outl.close();
	outlog.open("output_log.txt",ios::app);
	outt.open("output_token.txt");
	outt.close();
	outtoken.open("output_token.txt",ios::app);
	A.EnterScope();
	yylex();
	A.PrintA();
	outlog << "Total lines: " << line_count-1 << endl;
	outlog << "Total errors: " << error_count << endl;
	fclose(yyin);
	outtoken.close();
	outlog.close();
	return 0;
}
