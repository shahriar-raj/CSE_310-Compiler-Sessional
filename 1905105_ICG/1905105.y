%{
#include<iostream>
#include<fstream>
#include<string>
#include<vector>
#include <list>
#include <sstream>
#include "1905105.h"

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
//ofstream outlog;
//ofstream outl;
ofstream outerror;
ofstream oute;
ofstream parseTree;
ofstream pT;
fstream code;
ofstream code_f;
string name_, name_f;
string type_, type_f;
string label;
int line_count = 1;
int starting_line;
int error_count = 0;
int stack_offset = 0;
int tempCount = 0;
int labelcount = 0;
map<int, string> Globalhash;
symbolTable table(11);
vector<symbolinfo> varlist;
vector<par> parlist;
vector<string> alist;
vector<string> global_list;

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

void optimization(){
	ofstream OC;
	fstream C_;
	string tmp1,tmp2;
	string s1;
	string s2;
	string token;
	vector<string> tokens1;
	vector<string> tokens2;
	OC.open("optimized_code.asm",ios::out);
	C_.open("code.asm",ios::in);
	while(getline(C_,tmp1)){
    	stringstream ss(tmp1);
    	while (getline(ss, token, ' ')) {
			tokens1.push_back(token);
    	}
    	if(tokens1[0] == "	PUSH"){
			s1 = tokens1[1];
			getline(C_,tmp2);
			tmp2.erase(0, tmp2.find_first_not_of(" "));
    		stringstream ss(tmp2);
			while (getline(ss, token, ' ')) {
        		tokens2.push_back(token);
    		}
			if(tokens2[0] == "	POP"){
				s2 = tokens2[1];
				if(s1==s2){
				}
				else{
					OC << tmp1 <<endl;
					OC << tmp2 <<endl;
				}
			}
			else{
				OC << tmp1 <<endl;
				OC << tmp2 <<endl;
			}
		}
		else if(tokens1[0] == "	ADD"){
			s1 = tokens1[2];
			if(s1=="0"){
			}
			else{
				OC << tmp1 <<endl;
			}
		}
		else if(tokens1[0] == "	MUL"){
			s1 = tokens1[2];
			if(s1=="1"){
			}
			else{
				OC << tmp1 <<endl;
			}
		}
		else{
			OC << tmp1 << endl;
		}
		tokens1.clear();
		tokens2.clear();
		
	}
	C_.close();
	OC.close();
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
%type<symbol> e_in e e_out M

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

start : program
	{
		//outlog << "start : program " << endl;
		$$ = new symbolinfo("start","program");
		$$->childlist.push_back($1);
		$$->setSLine($1->getSLine());
		$$->setELine($1->getELine());
		//printTree($$, 0);
		//deleteTree($$);
		code << "new_line proc" << endl;
		code << "push ax" << endl;
		code << "push dx" << endl;
		code << "mov ah,2" << endl;
		code << "mov dl,cr" << endl;
		code << "int 21h" << endl;
		code << "mov ah,2" << endl;
		code << "mov dl,lf" << endl;
		code << "int 21h" << endl;
		code << "pop dx" << endl;
		code << "pop ax" << endl;
		code << "ret" << endl;
		code << "new_line endp\n" << endl;

		code << "print_output proc  ;print what is in ax" << endl;
		code << "push ax" << endl;
		code << "push bx" << endl;
		code << "push cx" << endl;
		code << "push dx" << endl;
		code << "push si" << endl;
		code << "lea si,number" << endl;
		code << "mov bx,10" << endl;
		code << "add si,4" << endl;
		code << "cmp ax,0" << endl;
		code << "jnge negate" << endl;
		code << "print:" << endl;
		code << "xor dx,dx" << endl;
		code << "div bx" << endl;
		code << "mov [si],dl" << endl;
		code << "add [si],'0'" << endl;
		code << "dec si" << endl;
		code << "cmp ax,0" << endl;
		code << "jne print" << endl;
		code << "inc si" << endl;
		code << "lea dx,si" << endl;
		code << "mov ah,9" << endl;
		code << "int 21h" << endl;
		code << "pop si" << endl;
		code << "pop dx" << endl;
		code << "pop cx" << endl;
		code << "pop bx" << endl;
		code << "pop ax" << endl;
		code << "ret" << endl;
		code << "negate:" << endl;
		code << "push ax" << endl;
		code << "mov ah,2" << endl;
		code << "mov dl,'-'" << endl;
		code << "int 21h" << endl;
		code << "pop ax" << endl;
		code << "neg ax" << endl;
		code << "jmp print" << endl;
		code << "print_output endp\n" << endl;
		code << "END main" << endl;
		//write your code in this block in all the similar blocks below
	}
	;

program : program unit 
	{
		//outlog << "program : program unit " << endl;
		$$ = new symbolinfo("program","program unit");
		$$->childlist.push_back($1);
		$$->childlist.push_back($2);
		$$->setSLine($1->getSLine());
		$$->setELine($2->getELine());
	}
	| unit
	{
		//outlog << "program : unit " << endl;
		$$ = new symbolinfo("program","unit");
		$$->childlist.push_back($1);
		$$->setSLine($1->getSLine());
		$$->setELine($1->getELine());
	}
	;
	
unit : var_declaration
		{
			//outlog << "unit : var_declaration " << endl;
			$$ = new symbolinfo("unit","var_declaration");
			$$->childlist.push_back($1);
			$$->setSLine($1->getSLine());
			$$->setELine($1->getELine());
		}
     | func_declaration
	 {
		//outlog << "unit : func_declaration " << endl;
		$$ = new symbolinfo("unit","func_declaration");
		$$->childlist.push_back($1);
		$$->setSLine($1->getSLine());
		$$->setELine($1->getELine());
	 }
     | func_definition
	 {
		//outlog << "unit : func_definition " << endl;
		$$ = new symbolinfo("unit","func_definition");
		$$->childlist.push_back($1);
		$$->setSLine($1->getSLine());
		$$->setELine($1->getELine());
	 }
     ;
     
func_declaration : type_specifier ID e LPAREN parameter_list RPAREN SEMICOLON
		{
			//outlog << "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON " << endl;
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
						if(parlist[j].name==parlist[i].name && parlist[j].name!=""){
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
			$$->setdataType($1->getdataType());
			parlist.clear();
	 	}
		| type_specifier ID e LPAREN RPAREN SEMICOLON
		{
			//outlog << "func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON " << endl;
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
			$$->setdataType($1->getdataType());
			table.Insert(func);
		}
		;
		 
func_definition : type_specifier ID e LPAREN parameter_list RPAREN e_out compound_statement
		{
			//outlog << "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement " << endl;
			$$ = new symbolinfo("func_definition","type_specifier ID LPAREN parameter_list RPAREN compound_statement");
			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($4);
			$$->childlist.push_back($5);
			$$->childlist.push_back($6);
			$$->childlist.push_back($8);
			$$->setSLine($1->getSLine());
			$$->setELine($8->getELine());
			$$->setdataType($1->getdataType());
			parlist.clear();
		}
		| type_specifier ID e LPAREN RPAREN e_out compound_statement
		{
			//outlog << "func_definition : type_specifier ID LPAREN RPAREN compound_statement " << endl;
			$$ = new symbolinfo("func_definition","type_specifier ID LPAREN RPAREN compound_statement");
			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($4);
			$$->childlist.push_back($5);
			$$->childlist.push_back($7);
			$$->setSLine($1->getSLine());
			$$->setELine($7->getELine());
			$$->setdataType($1->getdataType());
			code << "	ADD SP, " << stack_offset << endl;
			tempCount++;
			code << "	POP BP" << endl;
			tempCount++;
			if($2->getName()=="main"){
				code << "	MOV AX,4CH" << endl; 
				tempCount++;
				code << "	INT 21H" << endl;
				tempCount++;
			}
			else{
					code << "	RET" <<endl;
			}
			code << $2->getName() << " ENDP\n" <<endl;
			tempCount++;
		}
 		;				

e : {
		stack_offset = 0;
		name_f = name_;
		type_f = type_;
		code << name_f << " PROC" <<endl;
		tempCount++;
		if(name_f=="main"){
			code << "	MOV AX, @DATA" << endl;
			tempCount++;
			code<< "	MOV DS, AX" << endl;
			tempCount++;
		}
		code << "	PUSH BP" << endl;
			tempCount++;
		code << "	MOV BP, SP" << endl;
			tempCount++;
	}
	;

e_out : {
			symbolinfo *temp = table.LookUp(name_f);
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
				cout <<temp->getName() << "D: " << temp->getdataType() << " + C: " << type_f << endl;
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
			//outlog << "parameter_list : parameter_list COMMA type_specifier ID " << endl;
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
			//outlog << "parameter_list : parameter_list COMMA type_specifier " << endl;
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
			//outlog << "parameter_list : type_specifier ID " << endl;
			$$ = new symbolinfo("parameter_list","type_specifier ID");
			parlist.push_back(par($2->getName(),$1->getdataType()));
			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->setSLine($1->getSLine());
			$$->setELine($2->getELine());
		}
		| type_specifier
		{
			//outlog << "parameter_list : type_specifier " << endl;
			$$ = new symbolinfo("parameter_list","type_specifier");
			parlist.push_back(par("",$1->getdataType()));
			$$->childlist.push_back($1);
			$$->setSLine($1->getSLine());
			$$->setELine($1->getELine());
		}
 		;

 		
compound_statement : LCURL e_in statements RCURL
			{
				//outlog << "compound_statement : LCURL statements RCURL " << endl;
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
				//outlog << "compound_statement : LCURL RCURL " << endl;
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
			else{
				symbolinfo sym(parlist[0].name, parlist[0].type);
				sym.setdataType(parlist[0].type);
				sym.setvarsize(-1); 
				table.Insert(sym);
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
				//outlog << "var_declaration : type_specifier declaration_list SEMICOLON " << endl;
				
				$$ = new symbolinfo("var_declaration","type_specifier declaration_list SEMICOLON");
				$$->childlist.push_back($1);
				$$->childlist.push_back($2);
				$$->childlist.push_back($3);
				$$->setSLine($1->getSLine());
				$$->setELine($3->getELine());
				for(int i=0; i<varlist.size(); i++){
					varlist[i].setType($1->getdataType());
					varlist[i].setdataType($1->getdataType());
					if(table.LookUp(varlist[i].getName())==NULL){
						if(table.getID()!=1){
							varlist[i].setGlobal(false);
							if(varlist[i].getvarType()=="array"){
								varlist[i].sets_off(stack_offset+2);
								stack_offset += 2*varlist[i].getvarsize();
								code << "	SUB SP, " <<2*varlist[i].getvarsize() <<  endl;
								tempCount++;
							}
							else{
								stack_offset += 2;
								code << "	SUB SP, 2" << endl;
								tempCount++;
								varlist[i].sets_off(stack_offset);
							}
						}
						else{
							varlist[i].setGlobal(true);
							global_list.push_back(varlist[i].getName());
						}
					}
					bool insert_ = table.Insert(varlist[i]);
				}
				table.PrintA();
				varlist.clear();
			}
 		 ;
 		 
type_specifier	: INT
		{
			//outlog << "type_specifier	: INT "<< endl;
			$$ = new symbolinfo("type_specifier","INT");
			$$->setdataType($1->getType());
			$$->childlist.push_back($1);
			$$->setSLine($1->getSLine());
			$$->setELine($1->getELine());
		}
 		| FLOAT
		{
			//outlog << "type_specifier	: FLOAT "<< endl;
			$$ = new symbolinfo("type_specifier","FLOAT");
			$$->setdataType($1->getType());
			$$->childlist.push_back($1);
			$$->setSLine($1->getSLine());
			$$->setELine($1->getELine());
		}
 		| VOID
		{
			//outlog << "type_specifier	: VOID "<< endl;
			$$ = new symbolinfo("type_specifier","VOID");
			$$->setdataType($1->getType());
			$$->childlist.push_back($1);
			$$->setSLine($1->getSLine());
			$$->setELine($1->getELine());
		}
 		;
 		
declaration_list : declaration_list COMMA ID
			{
				//outlog << "declaration_list : declaration_list COMMA ID "<< endl;
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
			//outlog << "declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE "<< endl;
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
			//outlog << "declaration_list : ID "<< endl;
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
			//outlog << "declaration_list : ID LSQUARE CONST_INT RSQUARE "<< endl;
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
			//outlog << "statements : statement "<< endl;
			$$ = new symbolinfo("statements","statement");
			$$->childlist.push_back($1);
			$$->setSLine($1->getSLine());
			$$->setELine($1->getELine());
			code << "L" << ++labelcount <<":" << endl;tempCount++;
			$$->label = "L" + to_string(labelcount);
		}
	   | statements statement
	   {
			//outlog << "statements : statements statement "<< endl;
			$$ = new symbolinfo("statements","statements statement");
			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->setSLine($1->getSLine());
			$$->setELine($2->getELine());
			code << "L" << ++labelcount <<":" << endl;tempCount++;
			$$->label = "L" + to_string(labelcount);
	   }
	   ;

statement : var_declaration
		{
			//outlog << "statement : var_declaration "<< endl;
			$$ = new symbolinfo("statement","var_declaration");
			$$->childlist.push_back($1);
			$$->setSLine($1->getSLine());
			$$->setELine($1->getELine());
		}
	  | expression_statement
	  {
		//outlog << "statement : expression_statement "<< endl;
		$$ = new symbolinfo("statement","expression_statement");
		$$->childlist.push_back($1);
		$$->setSLine($1->getSLine());
		$$->setELine($1->getELine());
	  }
	  | compound_statement
	  {
		//outlog << "statement : compound_statement "<< endl;
		$$ = new symbolinfo("statement","compound_statement");
		$$->childlist.push_back($1);
		$$->setSLine($1->getSLine());
		$$->setELine($1->getELine());
	  }
	  | FOR LPAREN expression_statement{
			string jlabel = "L" + to_string(++labelcount);
			code << jlabel << ":" <<endl; tempCount++;
			$3->label = jlabel;
	  } 
	  expression_statement{
			string slabel = "L" + to_string(++labelcount);
			string flabel = "L" + to_string(++labelcount);
			string elabel = "L" + to_string(++labelcount);
			code << "	POP AX" << endl; tempCount++;
			code <<	"	CMP AX, 0" << endl; tempCount++;
			code << "	JE " << flabel << endl; tempCount++;
			code << "	JMP " << slabel << endl; tempCount++;
			code << elabel << ":" << endl; tempCount++;
			$5->label = slabel;
			$2->label = flabel;
			$1->label = elabel;
 	  } 
	  expression{
		   code << "	JMP " << $3->label << endl; tempCount++;
		   code << $5->label << ":" << endl; tempCount++;
	  } 
	  RPAREN statement
	  {
		//outlog << "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement "<< endl;
		$$ = new symbolinfo("statement","FOR LPAREN expression_statement expression_statement expression RPAREN statement");
		$$->childlist.push_back($1);
		$$->childlist.push_back($2);
		$$->childlist.push_back($3);
		$$->childlist.push_back($5);
		$$->childlist.push_back($7);
		$$->childlist.push_back($9);
		$$->childlist.push_back($10);
		$$->setSLine($1->getSLine());
		$$->setELine($10->getELine());
		code << "	JMP " << $1->label <<endl; tempCount++;
		code << $2->label <<":" <<endl; tempCount++;
	  }
	  | M %prec LOWER_THAN_ELSE
	  {
		//outlog << "statement : IF LPAREN expression RPAREN statement "<< endl;
		$$ = new symbolinfo("statement","IF LPAREN expression RPAREN statement");
		/*$$->childlist.push_back($1);
		$$->childlist.push_back($2);
		$$->setSLine($1->getSLine());
		$$->setELine($2->getELine());*/
		code << $1->label << ":" <<endl; tempCount++;
		
	  }
	  |M ELSE
	  {
		string jlabel = "L" + to_string(++labelcount);
		code << "	JMP " << jlabel <<endl; tempCount++;
		code << $1->label << ":" <<endl; tempCount++;
		$1->label = jlabel;
	  } 
	  statement
	  {
		//outlog << "statement : IF LPAREN expression RPAREN statement ELSE statement "<< endl;
		$$ = new symbolinfo("statement","IF LPAREN expression RPAREN statement ELSE statement");
		/*$$->childlist.push_back($1);
		$$->childlist.push_back($2);
		$$->childlist.push_back($3);
		$$->childlist.push_back($4);
		$$->childlist.push_back($6);
		$$->childlist.push_back($7);
		$$->childlist.push_back($9);
		$$->setSLine($1->getSLine());
		$$->setELine($9->getELine());*/
		code << $1->label << ":" <<endl; tempCount++;
	  }
	  | WHILE
	  {	
		string jlabel = "L" + to_string(++labelcount);
		code << jlabel << ":" << endl; tempCount++;
		$1->label = jlabel ;
	  }
	   LPAREN expression{
		code << "	POP AX" <<endl; tempCount++;
		code << "	CMP AX,0" <<endl;
		string flabel = "L" + to_string(++labelcount);
		code << "	JE " << flabel << endl; tempCount++;
		$4->label = flabel;
	   } 
	   RPAREN statement
	  {
		//outlog << "statement : WHILE LPAREN expression RPAREN statement "<< endl;
		$$ = new symbolinfo("statement","WHILE LPAREN expression RPAREN statement");
		$$->childlist.push_back($1);
		$$->childlist.push_back($3);
		$$->childlist.push_back($4);
		$$->childlist.push_back($6);
		$$->childlist.push_back($7);
		$$->setSLine($1->getSLine());
		$$->setELine($7->getELine());
		code << "	JMP " << $1->label << endl; tempCount++;
		code << $4->label << ":" <<endl; tempCount++;
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  {
		//outlog << "statement : PRINTLN LPAREN ID RPAREN SEMICOLON "<< endl;
		$$ = new symbolinfo("statement","PRINTLN LPAREN ID RPAREN SEMICOLON");
		symbolinfo* find = table.LookUp($3->getName());
		$$->childlist.push_back($1);
		$$->childlist.push_back($2);
		$$->childlist.push_back($3);
		$$->childlist.push_back($4);
		$$->childlist.push_back($5);
		$$->setSLine($1->getSLine());
		$$->setELine($5->getELine());
		if(find->getGlobal()){
			code << "	MOV AX, " <<find->getName() << endl;
			tempCount++;
		}
		else{
			code << "	MOV AX, [BP-" <<find->gets_off() <<"]" << endl;
			tempCount++;
		} 
		code << "	CALL print_output" << endl;
		tempCount++;
		code << "	CALL new_line" << endl;
		tempCount++;
	  }
	  | RETURN expression SEMICOLON
	  {
		//outlog << "statement : RETURN expression SEMICOLON "<< endl;
		$$ = new symbolinfo("statement","RETURN expression SEMICOLON");
		$$->childlist.push_back($1);
		$$->childlist.push_back($2);
		$$->childlist.push_back($3);
		$$->setSLine($1->getSLine());
		$$->setELine($3->getELine());
	  }
	  ;

M: IF LPAREN expression RPAREN{
		string flabel = "L" + to_string(++labelcount);
		code << "	POP AX" << endl;
		code << "	CMP AX, 0" << endl;
		code << "	JE " << flabel <<endl;
		$3->label = flabel;
	  }
	   statement
	   {
			$$ = new symbolinfo();
			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);
			$$->childlist.push_back($4);
			$$->childlist.push_back($6);
			$$->setSLine($1->getSLine());
			$$->setELine($6->getELine());
			$$->label = $3->label; 
	   }	 

expression_statement 	: SEMICOLON
				{
					//outlog << "expression_statement 	: SEMICOLON "<< endl;
					$$ = new symbolinfo("expression_statement","SEMICOLON");
					$$->setdataType("INT");
					$$->childlist.push_back($1);
					$$->setSLine($1->getSLine());
					$$->setELine($1->getELine());
				}			
			| expression SEMICOLON 
			{
				//outlog << "expression_statement 	: expression SEMICOLON "<< endl;
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
				//outlog << "variable : ID "<< endl;
				$$ = new symbolinfo(*$1);
				symbolinfo *temp = table.LookUp($1->getName());
				$1->setdataType(temp->getdataType());
				$$->setdataType($1->getdataType());
				$$->childlist.push_back($1);
				$$->setSLine($1->getSLine());
				$$->setELine($1->getELine());
			}	
	 | ID LSQUARE expression RSQUARE 
	 {
		//outlog << "variable : ID LSQUARE expression RSQUARE "<< endl;
		$$ = new symbolinfo(*$1);
		symbolinfo *temp = table.LookUp($1->getName());
		$1->setdataType(temp->getdataType());
		$$->setdataType($1->getdataType());
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
				//outlog << "expression : logic_expression "<< endl;
				$$ = new symbolinfo(*$1);
				$$->setdataType($1->getdataType());
				$$->childlist.push_back($1);
				$$->setSLine($1->getSLine());
				$$->setELine($1->getELine());
			}
	   | variable ASSIGNOP logic_expression 	
	   {
		//outlog << "expression : variable ASSIGNOP logic_expression "<< endl;
		$$ = new symbolinfo(*$1);
		if($1->getdataType()=="INT" && $3->getdataType()=="FLOAT"){
			outerror <<"Line# "<< line_count <<  ": Warning: possible loss of data in assignment of FLOAT to INT" << endl;
			error_count++;
		}
		$$->setdataType($1->getdataType());
		$$->childlist.push_back($1);
		$$->childlist.push_back($2);
		$$->childlist.push_back($3);
		$$->setSLine($1->getSLine());
		$$->setELine($3->getELine());
		symbolinfo* find = table.LookUp($1->getName());
		if(find->getGlobal()==true){
			code << "	POP AX" <<endl;
			tempCount++;
			code << "	MOV "<< $1->getName() << ", AX" << endl;
			tempCount++;
		}
		else{
			code << "	POP AX" <<endl;
			tempCount++;
			code << "	MOV [BP-"<< find->gets_off() << "], AX" << endl;
			tempCount++;
		}
		code << "	PUSH AX" <<endl;
		tempCount++;
		code << "	POP AX" <<endl;
		tempCount++;
	   }
	   ;
			
logic_expression : rel_expression 	
			{
				//outlog << "logic_expression : rel_expression "<< endl;
				$$ = new symbolinfo(*$1);
				$$->setdataType($1->getdataType());
				$$->childlist.push_back($1);
				$$->setSLine($1->getSLine());
				$$->setELine($1->getELine());
			}
		 | rel_expression LOGICOP
		 {
			code << "	POP AX" << endl; tempCount++;
			string label1 = "L" + to_string(++labelcount);
			if($2->getName()=="&&"){
				code << "	CMP AX, 1"  << endl; tempCount++;
			}
			else{
				code << "	CMP AX, 0"  << endl; tempCount++;
			}
			code << "	JNE " << label1 << endl; tempCount++;
			$1->label = label1;
		 }
		  rel_expression 
		 {

			//outlog << "logic_expression : rel_expression LOGICOP rel_expression "<< endl;
			$$ = new symbolinfo(*$1);
			$$->setdataType("INT");
			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($4);
			$$->setSLine($1->getSLine());
			$$->setELine($4->getELine());
			code << "	POP AX" << endl; tempCount++;
			if($2->getName()=="&&"){
				code << "	CMP AX, 1"  << endl; tempCount++;
			}
			else{
				code << "	CMP AX, 0"  << endl; tempCount++;
			}
			code << "	JNE " << $1->label << endl; tempCount++;
			if($2->getName()=="&&"){
				code << "	PUSH 1"  << endl; tempCount++;
			}
			else{
				code << "	PUSH 0"  << endl; tempCount++;
			}
			string label2 = "L" + to_string(++labelcount);
			code << "	JMP " << label2 << endl; tempCount++;
			code << $1->label << ":" <<endl;
			if($2->getName()=="&&"){
				code << "	PUSH 0"  << endl; tempCount++;
			}
			else{
				code << "	PUSH 1"  << endl; tempCount++;
			}
			code << label2 << ":" <<endl;
		 }	
		 ;
			
rel_expression	: simple_expression 
			{
				//outlog << "rel_expression	: simple_expression "<< endl;
				$$ = new symbolinfo(*$1);
				$$->setdataType($1->getdataType());
				$$->childlist.push_back($1);
				$$->setSLine($1->getSLine());
				$$->setELine($1->getELine());
			}
		| simple_expression RELOP simple_expression	
		{
			//outlog << "rel_expression	: simple_expression RELOP simple_expression "<< endl;
			$$ = new symbolinfo(*$1);
			$$->setdataType("INT");
			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);
			$$->setSLine($1->getSLine());
			$$->setELine($3->getELine());
			string label1 = "L" + to_string(++labelcount);
			string label2 = "L" + to_string(++labelcount);
			code << "	POP BX" <<endl; tempCount++;
			code << "	POP AX" <<endl; tempCount++;
			code << "	CMP AX, BX" << endl; tempCount++;
			if($2->getName()=="<"){
				code <<"	JL " << label1 << endl; tempCount++;
			}
			else if($2->getName()=="<="){
				code <<"	JLE " << label1 << endl; tempCount++;
			}
			else if($2->getName()==">"){
				code <<"	JG " << label1 << endl; tempCount++;
			}
			else if($2->getName()==">="){
				code <<"	JGE " << label1 << endl; tempCount++;
			}
			else if($2->getName()=="=="){
				code <<"	JE " << label1 << endl; tempCount++;
			}
			else {
				code <<"	JNE " << label1 << endl; tempCount++;
			}

			code << "	PUSH 0" <<	endl; tempCount++;
			code << "	JMP " << label2 <<endl; tempCount++;
			code << label1 << ":" << endl; tempCount++;
			code << "	PUSH 1" <<endl; tempCount++;
			code << label2 << ":" << endl; tempCount++;
		}
		;
				
simple_expression : term 
			{
				//outlog << "simple_expression : term "<< endl;
				$$ = new symbolinfo(*$1);
				$$->setdataType($1->getdataType());
				$$->childlist.push_back($1);
				$$->setSLine($1->getSLine());
				$$->setELine($1->getELine());
			}
		  | simple_expression ADDOP term 
		  {
			//outlog << "simple_expression : simple_expression ADDOP term "<< endl;
			$$ = new symbolinfo("simple_expression","simple_expression ADDOP term");
			$$->setdataType("INT");
			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->childlist.push_back($3);
			$$->setSLine($1->getSLine());
			$$->setELine($3->getELine());
			code << "	POP BX" <<endl;
			tempCount++;
			code << "	POP AX" <<endl;
			tempCount++;
			if($2->getName()=="+"){
				code << "	ADD AX, BX" << endl;
				tempCount++;
			}
			else{
				code << "	SUB AX, BX" << endl;
				tempCount++;
			}
			code << "	PUSH AX" << endl;
			tempCount++;
		  }
		  ;
	

term :	unary_expression
			{
				//outlog << "term :	unary_expression "<< endl;
				$$ = new symbolinfo(*$1);
				$$->setdataType($1->getdataType());
				$$->childlist.push_back($1);
				$$->setSLine($1->getSLine());
				$$->setELine($1->getELine());
			}
     |  term MULOP unary_expression
	 {
		//outlog << "term :	term MULOP unary_expression "<< endl;
		$$ = new symbolinfo(*$1);
		$$->setdataType("INT");
		$$->childlist.push_back($1);
		$$->childlist.push_back($2);
		$$->childlist.push_back($3);
		$$->setSLine($1->getSLine());
		$$->setELine($3->getELine());
		code << "	CWD" << endl;
		tempCount++;
		code << "	POP CX" << endl;
		tempCount++;
		code << "	POP AX" << endl;
		tempCount++;
		if($2->getName()=="*"){
			code << "	MUL CX" <<endl;
			tempCount++;
			code << "	PUSH AX" <<endl;
			tempCount++;
		}
		else{
			code <<"	DIV CX" << endl;
			tempCount++;
			if($2->getName()=="/"){
				code << "	PUSH AX" <<endl;
				tempCount++;
			}
			else{
				code << "	PUSH DX" <<endl;
				tempCount++;
			}
		}
	 }
     ;


unary_expression : ADDOP unary_expression  
			{
				//outlog << "unary_expression : ADDOP unary_expression "<< endl;
				$$ = new symbolinfo(*$2);
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
				if($1->getName()=="-"){
					code << "	POP AX" << endl;tempCount++;
					code << "	NEG AX" << endl;tempCount++;
					code << "	PUSH AX" << endl;tempCount++;
				}
			}
		 | NOT unary_expression 
		 {
			//outlog << "unary_expression : NOT unary_expression "<< endl;
			$$ = new symbolinfo(*$2);
			$$->setdataType($2->getdataType());
			$$->childlist.push_back($1);
			$$->childlist.push_back($2);
			$$->setSLine($1->getSLine());
			$$->setELine($2->getELine());
			string label1 = "L" + to_string(++labelcount);
			string label2 = "L" + to_string(++labelcount);
			code << "	POP AX" << endl;tempCount++;
			code << "	CMP AX, 0" << endl;tempCount++;
			code << "	JE " << label1 << endl;tempCount++;
			code << "	PUSH 0" << endl;tempCount++;
			code << "	JMP " << label2 <<endl;tempCount++;
			code << label1 << ":" << endl;tempCount++;
			code << "	PUSH 1" << endl;tempCount++;
			code << label2 << ":" <<endl;tempCount++;

		 }
		 | factor 
		 {
			//outlog << "unary_expression : factor "<< endl;
			$$ = new symbolinfo(*$1);
			$$->setdataType($1->getdataType());
			$$->zeroflag = $1->zeroflag;
			$$->childlist.push_back($1);
			$$->setSLine($1->getSLine());
			$$->setELine($1->getELine());
		 }
		 ;
	
factor	: variable 
		{
			//outlog << "factor	: variable "<< endl;
			$$ = new symbolinfo(*$1);
			symbolinfo* find = table.LookUp($1->getName());
			$$->setdataType($1->getdataType());
			$$->childlist.push_back($1);
			$$->setSLine($1->getSLine());
			$$->setELine($1->getELine());
			if(find->getGlobal()){
				code << "	MOV AX, " << find->getName() << endl;
				tempCount++;
				code << "	PUSH AX" <<endl;
				tempCount++;
			}
			else{
				if(find->getvarType()=="array"){
					code << "	MOV AX, [BP-" << (find->gets_off()+2*$1->getArrInd())<<"]" << endl;
					tempCount++;
					code << "	PUSH AX" <<endl;
					tempCount++;
				}
				else{
					code << "	MOV AX, [BP-" << find->gets_off() <<"]" << endl;
					tempCount++;
					code << "	PUSH AX" <<endl;
					tempCount++;
				}
			}
		}
	| ID LPAREN argument_list RPAREN
	{
		//outlog << "factor	: ID LPAREN argument_list RPAREN "<< endl;
		$$ = new symbolinfo(*$1);
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
		code << "	CALL " << $1->getName() << endl;
		alist.clear();
	}
	| LPAREN expression RPAREN
	{
		//outlog << "factor	: PAREN expression RPAREN "<< endl;
		$$ = new symbolinfo(*$2);
		$$->setdataType($2->getdataType());
		$$->childlist.push_back($1);
		$$->childlist.push_back($2);
		$$->childlist.push_back($3);
		$$->setSLine($1->getSLine());
		$$->setELine($3->getELine());
	}
	| CONST_INT 
	{
		//outlog << "factor : CONST_INT "<< endl;
		$$ = new symbolinfo(*$1);
		$1->setdataType("INT");
		if($1->getName()=="0"){
			$$->zeroflag = true;
		}
		$$->setdataType($1->getdataType());
		$$->childlist.push_back($1);
		$$->setSLine($1->getSLine());
		$$->setELine($1->getELine());
		code << "	MOV AX, " << $1->getName() << endl;
		tempCount++;
		code << "	PUSH AX" << endl;
		tempCount++;
	}
	| CONST_FLOAT
	{
		//outlog << "factor : CONST_FLOAT "<< endl;
		$$ = new symbolinfo("factor","CONST_FLOAT");
		$1->setdataType("FLOAT");
		$$->setdataType($1->getdataType());
		$$->childlist.push_back($1);
		$$->setSLine($1->getSLine());
		$$->setELine($1->getELine());
	}
	| variable INCOP 
	{
		//outlog << "factor : variable INCOP  "<< endl;
		$$ = new symbolinfo(*$1);
		symbolinfo* find = table.LookUp($1->getName());
		$$->setdataType($1->getdataType());
		$$->childlist.push_back($1);
		$$->childlist.push_back($2);
		$$->setSLine($1->getSLine());
		$$->setELine($2->getELine());
		if(find->getGlobal()){
				code << "	MOV AX, " << find->getName() << endl;
				tempCount++;
				code << "	PUSH AX" <<endl;
				tempCount++;
				code << "	INC AX" << endl;
				tempCount++;
				code << "	MOV " << find->getName() <<", AX" << endl;
				tempCount++;
			}
		else{
				if(find->getvarType()=="array"){
					code << "	MOV AX, [BP-" << (find->gets_off()+2*$1->getArrInd())<<"]" << endl;
					tempCount++;
					code << "	PUSH AX" <<endl;
					tempCount++;
					code << "	INC AX" << endl;
					tempCount++;
					code << "	MOV, [BP-" << find->gets_off()+2*$1->getArrInd() <<"], AX" << endl;
					tempCount++;
				}
				else{
					code << "	MOV AX, [BP-" << find->gets_off() <<"]" << endl;
					tempCount++;
					code << "	PUSH AX" <<endl;
					tempCount++;
					code << "	INC AX" << endl;
					tempCount++;
					code << "	MOV [BP-" << find->gets_off() <<"], AX" << endl;
					tempCount++;
				}
		}
	}
	| variable DECOP
	{
		//outlog << "factor : variable DECOP "<< endl;
		$$ = new symbolinfo(*$1);
		symbolinfo* find = table.LookUp($1->getName());
		$$->setdataType($1->getdataType());
		$$->childlist.push_back($1);
		$$->childlist.push_back($2);
		$$->setSLine($1->getSLine());
		$$->setELine($2->getELine());
		if(find->getGlobal()){
				code << "	MOV AX, " << find->getName() << endl;
				tempCount++;
				code << "	PUSH AX" <<endl;
				tempCount++;
				code << "	DEC AX" << endl;
				tempCount++;
				code << "	MOV " << find->getName() <<", AX" << endl;
				tempCount++;
			}
		else{
				if(find->getvarType()=="array"){
					code << "	MOV AX, [BP-" << (find->gets_off()+2*$1->getArrInd())<<"]" << endl;
					tempCount++;
					code << "	PUSH AX" <<endl;
					tempCount++;
					code << "	DEC AX" << endl;
					tempCount++;
					code << "	MOV, [BP-" << find->gets_off()+2*$1->getArrInd() <<"], AX" << endl;
					tempCount++;
				}
				else{
					code << "	MOV AX, [BP-" << find->gets_off() <<"]" << endl;
					tempCount++;
					code << "	PUSH AX" <<endl;
					tempCount++;
					code << "	DEC AX" << endl;
					tempCount++;
					code << "	MOV [BP-" << find->gets_off() <<"], AX" << endl;
					tempCount++;
				}
		}
	}
	;
	
argument_list : arguments
				{
					//outlog << "argument_list : arguments "<< endl;
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
				//outlog << "arguments : arguments COMMA logic_expression "<< endl;
				$$ = new symbolinfo("arguments","arguments COMMA logic_expression");
				$$->childlist.push_back($1);
				$$->childlist.push_back($2);
				$$->childlist.push_back($3);
				$$->setSLine($1->getSLine());
				$$->setELine($3->getELine());
				alist.push_back($3->getdataType());
			}
	      | logic_expression
		  {
			//outlog << "arguments : logic_expression "<< endl;
			$$ = new symbolinfo("arguments","logic_expression");
			$$->childlist.push_back($1);
			$$->setSLine($1->getSLine());
			$$->setELine($1->getELine());
			alist.push_back($1->getdataType());
		  }
	      ;
 

%%

int main(int argc,char *argv[])
{
	string temp;
	code.open("code.asm",ios::out);
	code_f.open("code_f.asm",ios::out);
	//outl.open("output_log.txt");
	//outl.close();
	//oute.open("output_error.txt");
	//oute.close();
	//outerror.open("output_error.txt",ios::app);
	//outlog.open("output_log.txt",ios::app);
	yyin=fopen(argv[1],"r");;
	table.EnterScope();
	yyparse();
	code_f << ";-------" << endl;
	code_f << ";" << endl;
	code_f << ";-------" << endl;
	code_f << ".MODEL SMALL" << endl;
	code_f << ".STACK 1000H" << endl;
	code_f << ".Data" << endl;
	code_f << "	CR EQU 0DH" << endl;
	code_f << "	LF EQU 0AH" << endl;
	code_f << "	number DB \"00000$\""  << endl;
	for(int i=0; i<global_list.size(); i++){
		code_f <<"	"<< global_list[i] << " DW 1 DUP (0000H)" << endl;
	}
	code_f << ".CODE" << endl;
	//outlog << "Total Lines: " << line_count << endl;
	//outlog << "Total Errors: "<< error_count;
	//outlog.close();
	code.close();
	code.open("code.asm",ios::in);
	while(getline(code, temp)){
		code_f << temp << endl;
	}
	code.close();
	code_f.close();
	remove("code.asm");
	rename("code_f.asm","code.asm");
	//outerror.close();
	optimization();
	return 0;
}
