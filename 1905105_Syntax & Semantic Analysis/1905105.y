%{
#include<iostream>
#include<fstream>
#include<string>
#include<vector>
#include <list>
#include "1905105.h"

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
ofstream outlog;
ofstream outl;
ofstream outerror;
ofstream oute;
ofstream parseTree;
ofstream pT;
string name_, name_f;
string type_, type_f;
int line_count = 1;
int starting_line;
int error_count = 0;
symbolTable table(11);
vector<symbolinfo> varlist;
vector<par> parlist;
vector<string> alist;

void printTree(symbolinfo *head, int depth){
	for(int i=0; i<depth; i++){
		parseTree << " ";  
	}
	if(head->getLeaf()){
		parseTree << head->getType()  << " : " << head->getName() << "\t<Line: " << head->getSLine() << ">" << endl;
	}
	else{
		parseTree << head->getName() << " : " << head->getType() << " \t<Line: " << head->getSLine() << "-" << head->getELine() << ">" << endl;
	}
	for(int h=0; h < head->childlist.size(); h++){
		printTree(head->childlist[h],depth+1);
	}
}

void deleteTree(symbolinfo* head){
	for(int i=0; i < head->childlist.size(); i++){
		deleteTree(head->childlist[i]);
	}
	delete head;
}

void yyerror(char *s)
{
	//write your code
}


%}

%union{
	symbolinfo *symbol;
}

%token<symbol> IF FOR ELSE LOWER_THAN_ELSE WHILE DO INT FLOAT VOID SWITCH DEFAULT BREAK CHAR DOUBLE RETURN CASE CONTINUE PRINTLN
%token<symbol> ADDOP MULOP INCOP RELOP ASSIGNOP LOGICOP BITOP NOT DECOP 
%token<symbol> LPAREN RPAREN LCURL RCURL LSQUARE RSQUARE COMMA SEMICOLON 
%token<symbol> ID CONST_INT CONST_FLOAT CONST_CHAR

%type<symbol> start program unit var_declaration func_declaration type_specifier parameter_list func_definition
%type<symbol> compound_statement statements declaration_list statement expression_statement expression variable
%type<symbol> logic_expression rel_expression simple_expression term factor  unary_expression argument_list arguments
%type<symbol> e_in e e_out

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

start : program
	{
		outlog << "start : program " << endl;
		$$ = new symbolinfo("start","program");
		$$->childlist.push_back($1);
		$$->setSLine($1->getSLine());
		$$->setELine($1->getELine());
		printTree($$, 0);
		deleteTree($$);
		//write your code in this block in all the similar blocks below
	}
	;

program : program unit 
	{
		outlog << "program : program unit " << endl;
		$$ = new symbolinfo("program","program unit");
		$$->childlist.push_back($1);
		$$->childlist.push_back($2);
		$$->setSLine($1->getSLine());
		$$->setELine($2->getELine());
	}
	| unit
	{
		outlog << "program : unit " << endl;
		$$ = new symbolinfo("program","unit");
		$$->childlist.push_back($1);
		$$->setSLine($1->getSLine());
		$$->setELine($1->getELine());
	}
	;
	
unit : var_declaration
		{
			outlog << "unit : var_declaration " << endl;
			$$ = new symbolinfo("unit","var_declaration");
			$$->childlist.push_back($1);
			$$->setSLine($1->getSLine());
			$$->setELine($1->getELine());
		}
     | func_declaration
	 {
		outlog << "unit : func_declaration " << endl;
		$$ = new symbolinfo("unit","func_declaration");
		$$->childlist.push_back($1);
		$$->setSLine($1->getSLine());
		$$->setELine($1->getELine());
	 }
     | func_definition
	 {
		outlog << "unit : func_definition " << endl;
		$$ = new symbolinfo("unit","func_definition");
		$$->childlist.push_back($1);
		$$->setSLine($1->getSLine());
		$$->setELine($1->getELine());
	 }
     ;
     
func_declaration : type_specifier ID e LPAREN parameter_list RPAREN SEMICOLON
		{
			outlog << "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON " << endl;
			$$ = new symbolinfo("func_declaration","type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($4);
			$$->childlist.push_back($5);
			$$->childlist.push_back($6);
			$$->childlist.push_back($7);
			$$->setSLine($1->getSLine());
			$$->setELine($7->getELine());
			if(table.LookUp($2->getName())!=NULL){
				error_count++;
				outerror <<"Line# "<<line_count<< ": Redeclaration of function \'" << $2->getName() <<"\' "<< endl;
			}
			else{
				symbolinfo func($2->getName(),"FUNCTION, "+$1->getdataType()); 
				func.setdataType($1->getdataType());
				func.setvarType("FUNCTION DECLARATION");
				func.setvarsize(-2);
				for(int j=0; j<parlist.size(); j++){
					bool err = false;
					for(int i=0; i<j; i++){ 
						if(parlist[j].name==parlist[i].name){
							err = true;
							error_count++;
							outerror <<"Line# "<<line_count<< ": Redefinition of parameter \'" << parlist[i].name <<"\' "<< endl;
							break;
						}
					}
					if(!err){
						func.addpar(parlist[j].name,parlist[j].type);
					}
				}
				table.Insert(func);
			}
			parlist.clear();
	 	}
		| type_specifier ID e LPAREN RPAREN SEMICOLON
		{
			outlog << "func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON " << endl;
			$$ = new symbolinfo("func_declaration","type_specifier ID LPAREN RPAREN SEMICOLON");
			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($4);
			$$->childlist.push_back($5);
			$$->childlist.push_back($6);
			$$->setSLine($1->getSLine());
			$$->setELine($6->getELine());
			symbolinfo func($2->getName(),"FUNCTION, "+$1->getdataType());
			func.setdataType($1->getdataType());
			func.setvarType("FUNCTION DECLARATION");
			func.setvarsize(-2);
			table.Insert(func);
		}
		;
		 
func_definition : type_specifier ID e LPAREN parameter_list RPAREN e_out compound_statement
		{
			outlog << "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement " << endl;
			$$ = new symbolinfo("func_definition","type_specifier ID LPAREN parameter_list RPAREN compound_statement");
			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($4);
			$$->childlist.push_back($5);
			$$->childlist.push_back($6);
			$$->childlist.push_back($8);
			$$->setSLine($1->getSLine());
			$$->setELine($8->getELine());
			parlist.clear();
		}
		| type_specifier ID e LPAREN RPAREN e_out compound_statement
		{
			outlog << "func_definition : type_specifier ID LPAREN RPAREN compound_statement " << endl;
			$$ = new symbolinfo("func_definition","type_specifier ID LPAREN RPAREN compound_statement");
			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($4);
			$$->childlist.push_back($5);
			$$->childlist.push_back($7);
			$$->setSLine($1->getSLine());
			$$->setELine($7->getELine());
		}
 		;				

e : {
		name_f = name_;
		type_f = type_;
	}
	;

e_out : {
			symbolinfo *temp = table.LookUp(name_f);
			//cout << name_f << endl;
			if(temp==NULL){
				symbolinfo func(name_f,"FUNCTION, "+type_f); 
				func.setdataType(type_f);
				func.setvarType("FUNCTION DEFINITION");
				func.setvarsize(-3);
				for(int j=0; j<parlist.size(); j++){
					bool err = false;
					for(int i=0; i<j; i++){ 
						if(parlist[j].name==parlist[i].name){
							err = true;
							error_count++;
							outerror <<"Line# "<<line_count<< ": Redefinition of parameter \'" << parlist[i].name <<"\' "<< endl;
							break;
						}
					}
					if(!err){
						func.addpar(parlist[j].name,parlist[j].type);
					}
				}
				table.Insert(func);
			}
			else if(temp->getvarsize()==-2){
				if(temp->getdataType()!=type_f){
					error_count++;
					outerror <<"Line# "<<line_count<< ": Conflicting types for \'" << name_f<<"\' "<< endl;
				}
				else if(temp->parlist.size()!=parlist.size()){
					error_count++;
					outerror <<"Line# "<<line_count<< ": Conflicting types for \'" << name_f <<"\' "<< endl;
				}
				else{
					for(int l=0; l<parlist.size(); l++){
						if(parlist[l].type != temp->parlist[l].type){
							error_count++;
							outerror <<"Line# "<<line_count<< ": Conflicting types for \'" << name_f <<"\' "<< endl;
							break;
						}
					}
				}
				temp->setvarsize(-3);
				temp->setvarType("FUNCTION DEFINITION");
			}
			else if(temp!=NULL && temp->getvarsize()==-1){
				error_count++;
				outerror <<"Line# "<<line_count<< ": \'" << name_f <<"\' redeclared as different kind of symbol"<< endl;
			}
			else if(temp!=NULL && temp->getvarsize()==-3){
				error_count++;
				outerror <<"Line# "<< line_count<< ": Redifinition of \'" << name_f <<"\' "<< endl;
			}
		}
		;

parameter_list  : parameter_list COMMA type_specifier ID
		{
			outlog << "parameter_list : parameter_list COMMA type_specifier ID " << endl;
			$$ = new symbolinfo("parameter_list","parameter_list COMMA type_specifier ID");
			parlist.push_back(par($4->getName(),$3->getdataType()));
			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);
			$$->childlist.push_back($4);
			$$->setSLine($1->getSLine());
			$$->setELine($4->getELine());
		}
		| parameter_list COMMA type_specifier
		{
			outlog << "parameter_list : parameter_list COMMA type_specifier " << endl;
			$$ = new symbolinfo("parameter_list","parameter_list COMMA type_specifier ID");
			parlist.push_back(par("",$3->getdataType()));
			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);
			$$->setSLine($1->getSLine());
			$$->setELine($3->getELine());
		}
 		| type_specifier ID
		{
			outlog << "parameter_list : type_specifier ID " << endl;
			$$ = new symbolinfo("parameter_list","type_specifier ID");
			parlist.push_back(par($2->getName(),$1->getdataType()));
			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->setSLine($1->getSLine());
			$$->setELine($2->getELine());
		}
		| type_specifier
		{
			outlog << "parameter_list : type_specifier " << endl;
			$$ = new symbolinfo("parameter_list","type_specifier");
			parlist.push_back(par("",$1->getdataType()));
			$$->childlist.push_back($1);
			$$->setSLine($1->getSLine());
			$$->setELine($1->getELine());
		}
 		;

 		
compound_statement : LCURL e_in statements RCURL
			{
				outlog << "compound_statement : LCURL statements RCURL " << endl;
				$$ = new symbolinfo("compound_statement","LCURL statements RCURL");
				$$->childlist.push_back($1);
				$$->childlist.push_back($3);
				$$->childlist.push_back($4);
				$$->setSLine($1->getSLine());
				$$->setELine($4->getELine());
				table.PrintA();
				table.ExitScope();
			}
 		    | LCURL e_in RCURL
			{
				outlog << "compound_statement : LCURL RCURL " << endl;
				$$ = new symbolinfo("compound_statement","LCURL RCURL");
				$$->childlist.push_back($1);
				$$->childlist.push_back($3);
				$$->setSLine($1->getSLine());
				$$->setELine($3->getELine());
				table.PrintA();
				table.ExitScope();
			}
 		    ;

e_in: {
		table.EnterScope();
		if(parlist.size()==1){
			if(parlist[0].type == "VOID"){

			}
		}
		else{
			for(int p=0; p<parlist.size(); p++){
				symbolinfo sym(parlist[p].name, parlist[p].type);
				sym.setdataType(parlist[p].type);
				sym.setvarsize(-1); 
				table.Insert(sym);
			}
		}
	}
	;	

var_declaration : type_specifier declaration_list SEMICOLON
			{
				outlog << "var_declaration : type_specifier declaration_list SEMICOLON " << endl;
				$$ = new symbolinfo("var_declaration","type_specifier declaration_list SEMICOLON");
				$$->childlist.push_back($1);
				$$->childlist.push_back($2);
				$$->childlist.push_back($3);
				$$->setSLine($1->getSLine());
				$$->setELine($3->getELine());
				for(int i=0; i<varlist.size(); i++){
					varlist[i].setType($1->getdataType());
					varlist[i].setdataType($1->getdataType());
					bool insert_ = table.Insert(varlist[i]);
					if(insert_== false && table.LookUp(varlist[i].getName())->getdataType()==$1->getdataType()){
						error_count++;
						outerror <<"Line# "<<line_count<< ": Redeclaration of variable \'" << varlist[i].getName() <<"\' "<< endl;
					}
					else if(insert_== false && table.LookUp(varlist[i].getName())->getdataType()!=$1->getdataType()){
						error_count++;
						outerror <<"Line# "<<line_count<< ": Conflicting types for \'" << varlist[i].getName() <<"\' "<< endl;
					}
					else if($2->getdataType()=="VOID"){
						error_count++;
						outerror <<"Line# "<<line_count<< ": Variable or field \'" << varlist[i].getName() <<"\' declared void " << endl;
					}
					else{
						
					}
				}
				varlist.clear();
			}
 		 ;
 		 
type_specifier	: INT
		{
			outlog << "type_specifier	: INT "<< endl;
			$$ = new symbolinfo("type_specifier","INT");
			$$->setdataType($1->getType());
			$$->childlist.push_back($1);
			$$->setSLine($1->getSLine());
			$$->setELine($1->getELine());
			type_ = "INT";
		}
 		| FLOAT
		{
			outlog << "type_specifier	: FLOAT "<< endl;
			$$ = new symbolinfo("type_specifier","FLOAT");
			$$->setdataType($1->getType());
			$$->childlist.push_back($1);
			$$->setSLine($1->getSLine());
			$$->setELine($1->getELine());
			type_ = "FLOAT";
		}
 		| VOID
		{
			outlog << "type_specifier	: VOID "<< endl;
			$$ = new symbolinfo("type_specifier","VOID");
			$$->setdataType($1->getType());
			$$->childlist.push_back($1);
			$$->setSLine($1->getSLine());
			$$->setELine($1->getELine());
			type_ = "VOID";
		}
 		;
 		
declaration_list : declaration_list COMMA ID
			{
				outlog << "declaration_list : declaration_list COMMA ID "<< endl;
				$$ = new symbolinfo("declaration_list","declaration_list COMMA ID");
				symbolinfo si($3->getName(),$3->getType());
				si.setvarType("variable");
				si.setvarsize(-1);
				varlist.push_back(si);
				$$->childlist.push_back($1);
				$$->childlist.push_back($2);
				$$->childlist.push_back($3);
				$$->setSLine($1->getSLine());
				$$->setELine($3->getELine());
			}
 		  | declaration_list COMMA ID LSQUARE CONST_INT RSQUARE
		  {
			outlog << "declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE "<< endl;
			$$ = new symbolinfo("declaration_list","declaration_list COMMA ID LSQUARE CONST_INT RSQUARE");
			symbolinfo si($3->getName(),$3->getType());
			si.setvarType("array");
			si.setvarsize(stoi($5->getName()));
			varlist.push_back(si);
			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);
			$$->childlist.push_back($4);
			$$->childlist.push_back($5);
			$$->childlist.push_back($6);
			$$->setSLine($1->getSLine());
			$$->setELine($6->getELine());
		  }
 		  | ID
		  {
			outlog << "declaration_list : ID "<< endl;
			$$ = new symbolinfo("declaration_list","ID");
			symbolinfo si($1->getName(),$1->getType());
			si.setvarType("variable");
			si.setvarsize(-1);
			varlist.push_back(si);
			$$->childlist.push_back($1);
			$$->setSLine($1->getSLine());
			$$->setELine($1->getELine());
		  }
 		  | ID LSQUARE CONST_INT RSQUARE
		  {
			outlog << "declaration_list : ID LSQUARE CONST_INT RSQUARE "<< endl;
			$$ = new symbolinfo("declaration_list","ID LSQUARE CONST_INT RSQUARE");
			symbolinfo si($1->getName(),$1->getType());
			si.setvarType("array");
			si.setvarsize(stoi($3->getName()));
			varlist.push_back(si);
			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);
			$$->childlist.push_back($4);
			$$->setSLine($1->getSLine());
			$$->setELine($4->getELine());
		  }
 		  ;
 		  
statements : statement
		{
			outlog << "statements : statement "<< endl;
			$$ = new symbolinfo("statements","statement");
			$$->childlist.push_back($1);
			$$->setSLine($1->getSLine());
			$$->setELine($1->getELine());
		}
	   | statements statement
	   {
			outlog << "statements : statements statement "<< endl;
			$$ = new symbolinfo("statements","statements statement");
			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->setSLine($1->getSLine());
			$$->setELine($2->getELine());
	   }
	   ;
	   
statement : var_declaration
		{
			outlog << "statement : var_declaration "<< endl;
			$$ = new symbolinfo("statement","var_declaration");
			$$->childlist.push_back($1);
			$$->setSLine($1->getSLine());
			$$->setELine($1->getELine());
		}
	  | expression_statement
	  {
		outlog << "statement : expression_statement "<< endl;
		$$ = new symbolinfo("statement","expression_statement");
		$$->childlist.push_back($1);
		$$->setSLine($1->getSLine());
		$$->setELine($1->getELine());
	  }
	  | compound_statement
	  {
		outlog << "statement : compound_statement "<< endl;
		$$ = new symbolinfo("statement","compound_statement");
		$$->childlist.push_back($1);
		$$->setSLine($1->getSLine());
		$$->setELine($1->getELine());
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  {
		outlog << "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement "<< endl;
		$$ = new symbolinfo("statement","FOR LPAREN expression_statement expression_statement expression RPAREN statement");
		$$->childlist.push_back($1);
		$$->childlist.push_back($2);
		$$->childlist.push_back($3);
		$$->childlist.push_back($4);
		$$->childlist.push_back($5);
		$$->childlist.push_back($6);
		$$->childlist.push_back($7);
		$$->setSLine($1->getSLine());
		$$->setELine($7->getELine());
	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
	  {
		outlog << "statement : IF LPAREN expression RPAREN statement "<< endl;
		$$ = new symbolinfo("statement","IF LPAREN expression RPAREN statement");
		$$->childlist.push_back($1);
		$$->childlist.push_back($2);
		$$->childlist.push_back($3);
		$$->childlist.push_back($4);
		$$->childlist.push_back($5);
		$$->setSLine($1->getSLine());
		$$->setELine($5->getELine());
	  }
	  | IF LPAREN expression RPAREN statement ELSE statement
	  {
		outlog << "statement : IF LPAREN expression RPAREN statement ELSE statement "<< endl;
		$$ = new symbolinfo("statement","IF LPAREN expression RPAREN statement ELSE statement");
		$$->childlist.push_back($1);
		$$->childlist.push_back($2);
		$$->childlist.push_back($3);
		$$->childlist.push_back($4);
		$$->childlist.push_back($5);
		$$->childlist.push_back($6);
		$$->childlist.push_back($7);
		$$->setSLine($1->getSLine());
		$$->setELine($7->getELine());
	  }
	  | WHILE LPAREN expression RPAREN statement
	  {
		outlog << "statement : WHILE LPAREN expression RPAREN statement "<< endl;
		$$ = new symbolinfo("statement","WHILE LPAREN expression RPAREN statement");
		$$->childlist.push_back($1);
		$$->childlist.push_back($2);
		$$->childlist.push_back($3);
		$$->childlist.push_back($4);
		$$->childlist.push_back($5);
		$$->setSLine($1->getSLine());
		$$->setELine($5->getELine());
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  {
		outlog << "statement : PRINTLN LPAREN ID RPAREN SEMICOLON "<< endl;
		$$ = new symbolinfo("statement","PRINTLN LPAREN ID RPAREN SEMICOLON");
		$$->setdataType($2->getdataType());
		$$->childlist.push_back($1);
		$$->childlist.push_back($2);
		$$->childlist.push_back($3);
		$$->childlist.push_back($4);
		$$->childlist.push_back($5);
		$$->setSLine($1->getSLine());
		$$->setELine($5->getELine());
	  }
	  | RETURN expression SEMICOLON
	  {
		outlog << "statement : RETURN expression SEMICOLON "<< endl;
		$$ = new symbolinfo("statement","RETURN expression SEMICOLON");
		$$->childlist.push_back($1);
		$$->childlist.push_back($2);
		$$->childlist.push_back($3);
		$$->setSLine($1->getSLine());
		$$->setELine($3->getELine());
	  }
	  ;
	  
expression_statement 	: SEMICOLON
				{
					outlog << "expression_statement 	: SEMICOLON "<< endl;
					$$ = new symbolinfo("expression_statement","SEMICOLON");
					$$->setdataType("INT");
					$$->childlist.push_back($1);
					$$->setSLine($1->getSLine());
					$$->setELine($1->getELine());
				}			
			| expression SEMICOLON 
			{
				outlog << "expression_statement 	: expression SEMICOLON "<< endl;
				$$ = new symbolinfo("expression_statement","expression SEMICOLON");
				$$->setdataType($1->getdataType());
				$$->childlist.push_back($1);
				$$->childlist.push_back($2);
				$$->setSLine($1->getSLine());
				$$->setELine($2->getELine());
			}
			;
	  
variable : ID 	
			{
				outlog << "variable : ID "<< endl;
				$$ = new symbolinfo("variable","ID");
				symbolinfo *temp = table.LookUp($1->getName());
				if(temp==NULL){
					outerror <<"Line# "<< line_count <<  ": Undeclared variable \'" << $1->getName() << "\' " << endl;
					error_count++;
					$$->setdataType("FLOAT");
				}
				else if($1->getdataType()=="VOID"){
					outerror <<"Line# "<< line_count << ": Void cannot be used in expression " << endl;
					error_count++;
					$$->setdataType("FLOAT");
				}
				else{
					$$->setdataType($1->getdataType());
				}

				$$->childlist.push_back($1);
				$$->setSLine($1->getSLine());
				$$->setELine($1->getELine());
			}	
	 | ID LSQUARE expression RSQUARE 
	 {
		outlog << "variable : ID LSQUARE expression RSQUARE "<< endl;
		$$ = new symbolinfo("variable","ID LSQUARE expression RSQUARE");
		symbolinfo *temp = table.LookUp($1->getName());
		if(temp==NULL){
			outerror <<"Line# "<< line_count <<  ": Undeclared array \'" << $1->getName() << "\' " << endl;
			error_count++;
			$$->setdataType("FLOAT");
		}
		else if(temp->getdataType()=="VOID"){
			outerror <<"Line# "<< line_count <<  ": Void cannot be used in expression " << endl;
			error_count++;
			$$->setdataType("FLOAT");
		}
		else{
			$$->setdataType($1->getdataType());
		}

		if(temp!=NULL && temp->getvarsize()<0){
			outerror <<"Line# "<< line_count <<  ": \'" << $1->getName() << "\' is not an array " << endl;
			error_count++;
		}
		else if($3->getdataType()=="VOID"){
			outerror <<"Line# "<< line_count <<  ": Void cannot be used in expression " << endl;
			error_count++;
			$$->setdataType("FLOAT");
		}
		else if($3->getdataType()!="INT"){
			outerror <<"Line# "<< line_count <<  ": Array subscript is not an integer " << endl;
			error_count++;
		}
		
		$$->childlist.push_back($1);
		$$->childlist.push_back($2);
		$$->childlist.push_back($3);
		$$->childlist.push_back($4);
		$$->setSLine($1->getSLine());
		$$->setELine($4->getELine());
	 }
	 ;
	 
 expression : logic_expression	
			{
				outlog << "expression : logic_expression "<< endl;
				$$ = new symbolinfo("expression","logic_expression");
				$$->setdataType($1->getdataType());
				$$->childlist.push_back($1);
				$$->setSLine($1->getSLine());
				$$->setELine($1->getELine());
			}
	   | variable ASSIGNOP logic_expression 	
	   {
		outlog << "expression : variable ASSIGNOP logic_expression "<< endl;
		$$ = new symbolinfo("expression","variable ASSIGNOP logic_expression");
		if($1->getdataType()=="INT" && $3->getdataType()=="FLOAT"){
			outerror <<"Line# "<< line_count <<  ":  Warning: possible loss of data in assignment of FLOAT to INT" << endl;
			error_count++;
		}
		$$->setdataType($1->getdataType());
		$$->childlist.push_back($1);
		$$->childlist.push_back($2);
		$$->childlist.push_back($3);
		$$->setSLine($1->getSLine());
		$$->setELine($3->getELine());
	   }
	   ;
			
logic_expression : rel_expression 	
			{
				outlog << "logic_expression : rel_expression "<< endl;
				$$ = new symbolinfo("logic_expression","rel_expression");
				$$->setdataType($1->getdataType());
				$$->childlist.push_back($1);
				$$->setSLine($1->getSLine());
				$$->setELine($1->getELine());
			}
		 | rel_expression LOGICOP rel_expression 
		 {

			outlog << "logic_expression : rel_expression LOGICOP rel_expression "<< endl;
			$$ = new symbolinfo("logic_expression","rel_expression LOGICOP rel_expression");
			$$->setdataType("INT");
			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);
			$$->setSLine($1->getSLine());
			$$->setELine($3->getELine());
		 }	
		 ;
			
rel_expression	: simple_expression 
			{
				outlog << "rel_expression	: simple_expression "<< endl;
				$$ = new symbolinfo("rel_expression","simple_expression");
				$$->setdataType($1->getdataType());
				$$->childlist.push_back($1);
				$$->setSLine($1->getSLine());
				$$->setELine($1->getELine());
			}
		| simple_expression RELOP simple_expression	
		{
			outlog << "rel_expression	: simple_expression RELOP simple_expression "<< endl;
			$$ = new symbolinfo("rel_expression","simple_expression RELOP simple_expression");
			$$->setdataType("INT");
			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);
			$$->setSLine($1->getSLine());
			$$->setELine($3->getELine());
		}
		;
				
simple_expression : term 
			{
				outlog << "simple_expression : term "<< endl;
				$$ = new symbolinfo("simple_expression","term");
				$$->setdataType($1->getdataType());
				$$->childlist.push_back($1);
				$$->setSLine($1->getSLine());
				$$->setELine($1->getELine());
			}
		  | simple_expression ADDOP term 
		  {
			outlog << "simple_expression : simple_expression ADDOP term "<< endl;
			$$ = new symbolinfo("simple_expression","simple_expression ADDOP term");
			if($1->getdataType()=="FLOAT" || $3->getdataType()=="FLOAT"){
				$$->setdataType("FLOAT");
			}
			else{
				$$->setdataType("INT");
			}
			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);
			$$->setSLine($1->getSLine());
			$$->setELine($3->getELine());
		  }
		  ;
					
term :	unary_expression
			{
				outlog << "term :	unary_expression "<< endl;
				$$ = new symbolinfo("term","unary_expression");
				$$->setdataType($1->getdataType());
				$$->childlist.push_back($1);
				$$->setSLine($1->getSLine());
				$$->setELine($1->getELine());
			}
     |  term MULOP unary_expression
	 {
		outlog << "term :	term MULOP unary_expression "<< endl;
		$$ = new symbolinfo("term","term MULOP unary_expression");
		if($2->getName()=="%" && ($1->getdataType()!="INT" || $3->getdataType()!="INT")){
			outerror <<"Line# "<< line_count <<  ": Operands of modulus must be integers " << endl;
			error_count++;
			$$->setdataType("INT");
		}
		else if(($2->getName()=="%"||$2->getName()=="/") && $3->zeroflag==true){
			outerror <<"Line# "<< line_count <<  ": Warning: division by zero i=0f=1Const=0" << endl;
			error_count++;
			$$->setdataType($1->getdataType());
		}
		else if($1->getdataType()=="FLOAT" || $3->getdataType()=="FLOAT"){
			$$->setdataType("FLOAT");
		}
		else{
			$$->setdataType("INT");
		}
		$$->childlist.push_back($1);
		$$->childlist.push_back($2);
		$$->childlist.push_back($3);
		$$->setSLine($1->getSLine());
		$$->setELine($3->getELine());
	 }
     ;

unary_expression : ADDOP unary_expression  
			{
				outlog << "unary_expression : ADDOP unary_expression "<< endl;
				$$ = new symbolinfo("unary_expression","ADDOP unary_expression");
				if($2->getdataType()=="VOID"){
					outerror <<"Line# "<< line_count <<  ": Void cannot be used in unary_expression " << endl;
					error_count++;
				}
				else{
					$$->setdataType($2->getdataType());
				}
				$$->childlist.push_back($1);
				$$->childlist.push_back($2);
				$$->setSLine($1->getSLine());
				$$->setELine($2->getELine());
			}
		 | NOT unary_expression 
		 {
			outlog << "unary_expression : NOT unary_expression "<< endl;
			$$ = new symbolinfo("unary_expression","NOT unary_expression");
			if($2->getdataType()=="VOID"){
				outerror <<"Line# "<< line_count <<  ": Void cannot be used in unary_expression " << endl;
				error_count++;
			}
			else{
				$$->setdataType($2->getdataType());
			}
			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->setSLine($1->getSLine());
			$$->setELine($2->getELine());
		 }
		 | factor 
		 {
			outlog << "unary_expression : factor "<< endl;
			$$ = new symbolinfo("unary_expression","factor");
			$$->setdataType($1->getdataType());
			$$->zeroflag = $1->zeroflag;
			$$->childlist.push_back($1);
			$$->setSLine($1->getSLine());
			$$->setELine($1->getELine());
		 }
		 ;
	
factor	: variable 
		{
			outlog << "factor	: variable "<< endl;
			$$ = new symbolinfo("factor","variable");
			$$->setdataType($1->getdataType());
			$$->childlist.push_back($1);
			$$->setSLine($1->getSLine());
			$$->setELine($1->getELine());
		}
	| ID LPAREN argument_list RPAREN
	{
		outlog << "factor	: ID LPAREN argument_list RPAREN "<< endl;
		$$ = new symbolinfo("factor","ID LPAREN argument_list RPAREN");
		$$->setdataType($1->getdataType());
		$$->childlist.push_back($1);
		$$->childlist.push_back($2);
		$$->childlist.push_back($3);
		$$->childlist.push_back($4);
		$$->setSLine($1->getSLine());
		$$->setELine($4->getELine());
		symbolinfo *found = table.LookUp($1->getName());

		if(found == NULL){
			outerror <<"Line# "<< line_count << ": Undeclared function \'"<< $1->getName() <<"\'"<< endl;
			error_count++;
			$$->setdataType("FLOAT");
		}
		else if(found->getvarsize()!=-3){
			outerror <<"Line# "<< line_count << ": Function definition of \'"<< $1->getName() <<"\' not found"<< endl;
			error_count++;
		}
		else {
			if(alist.size()==0 && (found->parlist.size())==1 && $1->parlist[0].type == "VOID"){
			}
			else if(alist.size()<found->parlist.size()){
				outerror <<"Line# "<< line_count << ": Too few arguments to function \'"<< $1->getName() <<"\'"<< endl;
				error_count++;
			}
			else if(alist.size()>found->parlist.size()){
				outerror <<"Line# "<< line_count << ": Too many arguments to function \'"<< $1->getName() <<"\'"<< endl;
				error_count++;
			}
			else{
				for(int i=0; i<alist.size(); i++){
					if(alist[i]!=found->parlist[i].type){
						cout << found->getName() <<endl;
						cout << alist[i] << "    +     " << found->parlist[i].type << endl;
						outerror <<"Line# "<< line_count << ": Type mismatch for argument "<<(i+1)<<" of \'"<< $1->getName() <<"\'"<< endl;
						error_count++;
					}
				}
			}
		}
		alist.clear();
	}
	| LPAREN expression RPAREN
	{
		outlog << "factor	: PAREN expression RPAREN "<< endl;
		$$ = new symbolinfo("factor","LPAREN expression RPAREN");
		if($2->getdataType()=="VOID"){
			outerror <<"Line# "<< line_count << ": Void cannot be used in expression " << endl;
			error_count++;
			$2->setdataType("FLOAT");
		}
		else{
			$$->setdataType($2->getdataType());
		}
		$$->childlist.push_back($1);
		$$->childlist.push_back($2);
		$$->childlist.push_back($3);
		$$->setSLine($1->getSLine());
		$$->setELine($3->getELine());
	}
	| CONST_INT 
	{
		outlog << "factor : CONST_INT "<< endl;
		$$ = new symbolinfo("factor","CONST_INT");
		$1->setdataType("INT");
		if($1->getName()=="0"){
			$$->zeroflag = true;
		}
		$$->setdataType($1->getdataType());
		$$->childlist.push_back($1);
		$$->setSLine($1->getSLine());
		$$->setELine($1->getELine());
	}
	| CONST_FLOAT
	{
		outlog << "factor : CONST_FLOAT "<< endl;
		$$ = new symbolinfo("factor","CONST_FLOAT");
		$1->setdataType("FLOAT");
		$$->setdataType($1->getdataType());
		$$->childlist.push_back($1);
		$$->setSLine($1->getSLine());
		$$->setELine($1->getELine());
	}
	| variable INCOP 
	{
		outlog << "factor : variable INCOP  "<< endl;
		$$ = new symbolinfo("factor","variable INCOP");
		$$->setdataType($1->getdataType());
		$$->childlist.push_back($1);
		$$->childlist.push_back($2);
		$$->setSLine($1->getSLine());
		$$->setELine($2->getELine());
	}
	| variable DECOP
	{
		outlog << "factor : variable DECOP "<< endl;
		$$ = new symbolinfo("factor","variable DECOP");
		$$->setdataType($1->getdataType());
		$$->childlist.push_back($1);
		$$->childlist.push_back($2);
		$$->setSLine($1->getSLine());
		$$->setELine($2->getELine());
}
	;
	
argument_list : arguments
				{
					outlog << "argument_list : arguments "<< endl;
					$$ = new symbolinfo("argument_list","arguments");
					$$->childlist.push_back($1);
					$$->setSLine($1->getSLine());
					$$->setELine($1->getELine());
				}
			  |{
				$$ = new symbolinfo("argument_list","");
				symbolinfo epsilon("","");
				symbolinfo *ep = &epsilon;
				ep->setSLine(line_count);
				ep->setELine(line_count);
				ep->setLeaf(true);
				$$->childlist.push_back(ep);
				$$->setSLine(ep->getSLine());
				$$->setELine(ep->getELine());
			  }
			  ;
	
arguments : arguments COMMA logic_expression
			{
				outlog << "arguments : arguments COMMA logic_expression "<< endl;
				$$ = new symbolinfo("arguments","arguments COMMA logic_expression");
				$$->childlist.push_back($1);
				$$->childlist.push_back($2);
				$$->childlist.push_back($3);
				$$->setSLine($1->getSLine());
				$$->setELine($3->getELine());
				if($3->getdataType() == "VOID"){
					outerror <<"Line# "<< line_count <<  ": Void cannot be used in expression " << endl;
					error_count++;
					$3->setdataType("FLOAT");
				}
				alist.push_back($3->getdataType());
			}
	      | logic_expression
		  {
			outlog << "arguments : logic_expression "<< endl;
			$$ = new symbolinfo("arguments","logic_expression");
			$$->childlist.push_back($1);
			$$->setSLine($1->getSLine());
			$$->setELine($1->getELine());
			if($1->getdataType() == "VOID"){
				outerror <<"Line# "<< line_count <<  ": Void cannot be used in expression " << endl;
				error_count++;
				$1->setdataType("FLOAT");
			}
			alist.push_back($1->getdataType());
		  }
	      ;
 

%%

int main(int argc,char *argv[])
{

	outl.open("output_log.txt");
	outl.close();
	oute.open("output_error.txt");
	oute.close();
	pT.open("output_parseTree.txt");
	pT.close();
	outerror.open("output_error.txt",ios::app);
	outlog.open("output_log.txt",ios::app);
	parseTree.open("output_parseTree.txt",ios::app);

	yyin=fopen(argv[1],"r");;
	table.EnterScope();
	yyparse();
	outlog << "Total Lines: " << line_count << endl;
	outlog << "Total Errors: "<< error_count;
	outlog.close();
	outerror.close();
	parseTree.close();
	return 0;
}
