# include <bits/stdc++.h>

using namespace std;

//-------------------------------------------------- SymbolInfo -----------------------------------------------------------------//

class symbolinfo{
    string name, type;
public:
    symbolinfo* next_;
    symbolinfo();
    symbolinfo(string, string);
    symbolinfo(const symbolinfo& sym);
    string getName(void);
    void setName(string);
    string getType(void);
    void setType(string);
};

symbolinfo :: symbolinfo(void){
    name = "";
    type = "";
    next_  = NULL;
};

symbolinfo :: symbolinfo(string name, string type){
    this->name = name;
    this->type = type;
    next_  = NULL;
}

symbolinfo :: symbolinfo(const symbolinfo& sym){
    name = sym.name;
    type = sym.type;
    next_ = sym.next_;
}

string symbolinfo::getName(void){
    return name;
}

void symbolinfo::setName(string name_){
    name = name_;
}

string symbolinfo::getType(void){
    return type;
}

void symbolinfo::setType(string type_){
    type = type_;
}

//-------------------------------------------------- ScopeTable -----------------------------------------------------------------//

class scopeTable{
    int N, id;
    symbolinfo* b_list;
    symbolinfo** head;
    symbolinfo** tail;
    int* pos;
public:
    scopeTable* parent = NULL;
    scopeTable(int,int);
    long long int SDBM_hash(string);
    bool Insert(symbolinfo sym1);
    bool Delete(string);
    symbolinfo* LookUp(string, bool);
    void Print(void);
    int getId(void);
    ~scopeTable(void);
};

scopeTable :: scopeTable(int N, int id){
    this->N = N;
    this->id = id;
    b_list = new symbolinfo[N];
    head = new symbolinfo*[N];
    for(int i=0; i<N; i++)
        head[i] = NULL;
    tail = new symbolinfo*[N];
    for(int i=0; i<N; i++)
        tail[i] = NULL;
    pos = new int[N];
    for(int i=0; i<N; i++)
        pos[i] = 1;
}

scopeTable :: ~scopeTable(void){
    delete[] b_list;
}

long long int scopeTable :: SDBM_hash(string str){
    long long int hash = 0;
	long long int i = 0;
	long long int len = str.length();

	for (i = 0; i < len; i++)
	{
		hash = (str[i]) + (hash << 6) + (hash << 16) - hash;
	}

	return hash;
}

bool scopeTable :: Insert(symbolinfo sym1){
    bool inserted = false;
    long long int h = SDBM_hash(sym1.getName())%N;
    symbolinfo *tmp = new symbolinfo;
    tmp->setName(sym1.getName());
    tmp->setType(sym1.getType());
    tmp->next_ = NULL;
    ofstream out("output.txt", ios::app);
    if(LookUp(sym1.getName(),false)!=NULL){
        inserted = false;
        out << "\t'" << sym1.getName() << "' already exists in the current ScopeTable" << endl;
        return inserted;
    }
    if(head[h] == NULL){
        //cout << " IN scopeTable 2 " <<sym1.getName() << endl;
        head[h] = tmp;
        tail[h] = tmp;
        inserted = true;
        out << "\tInserted in ScopeTable# "<< id << " at position " << h+1 << ", " << pos[h] << endl;
    }
    else{
        tail[h]->next_ = tmp;
        tail[h] = tail[h]->next_;
        pos[h]++;
        inserted = true;
        out << "\tInserted in ScopeTable# "<< id << " at position " << h+1 << ", " << pos[h] << endl;
    }
    //out.close();
    return inserted;
}

void scopeTable :: Print(){
    ofstream out("output.txt", ios::app);
    for(int i=0; i<N; i++){
        symbolinfo* cur = head[i];
        out <<"\t"<< i+1 << "--> ";
        while(true){
            if(cur==NULL){
                out << endl;
                break;
            }
            else{
                out << "<" << cur->getName() << "," << cur->getType() << "> " ;
                cur = cur->next_;
            }
        }
    }
    //out.close();
}

symbolinfo* scopeTable :: LookUp(string symName, bool p){
    ofstream out("output.txt", ios::app);
    symbolinfo *found = NULL;
    long long int h = SDBM_hash(symName)%N;
    //cout << head[h] << endl;
    symbolinfo* cur = head[h];
    int count_m = 1;
    while(true){
        if(cur == NULL){
            return found;
        }
        if(cur->getName()==symName){
            found = cur;
            if(p)
                out << "\t'" << symName << "' " << "found in ScopeTable# " << id << " at position "<<h+1 << ", " << count_m << endl;
            return found;
        }
        cur = cur->next_;
        count_m++;
    }
    //out.close();
}

bool scopeTable :: Delete(string s_name){
    ofstream out("output.txt", ios::app);
    bool deleted = false;
    long long int h = SDBM_hash(s_name)%N;
    int count_m = 1;
    symbolinfo *prev = NULL;
    symbolinfo *cur = head[h];
    symbolinfo *temp = new symbolinfo;
    if(head[h] == NULL){
       out << "\tNot found in the current ScopeTable" << endl;
       delete temp;
       return deleted;
    }
    while(count_m<=pos[h]){
        //cout << " HERE OUT " << endl;
        if(cur->getName() == s_name){
            //cout << " HERE IN " <<endl;
            if(cur == head[h] && cur == tail[h]){
               head[h] = NULL;
               tail[h] = NULL;
               out << "\tDeleted '" << s_name << "' from ScopeTable# " << id <<" at position " << h+1 << ", " <<count_m << endl;
               //cout << "YES 1" <<endl;
            }
            else if(cur == head[h]){
               head[h] = cur->next_;
               out << "\tDeleted '" << s_name << "' from ScopeTable# " << id <<" at position " << h+1 << ", " <<count_m << endl;
               //cout << "YES 2" <<endl;
            }
            else if(cur == tail[h]){
               tail[h] = prev;
               tail[h]->next_ = NULL;
               out << "\tDeleted '" << s_name << "' from ScopeTable# " << id <<" at position " << h+1 << ", " <<count_m << endl;
               //cout << "YES 3" <<endl;
            }
            else{
                out << "\tDeleted '" << s_name << "' from ScopeTable# " << id <<" at position " << h+1 << ", " <<count_m << endl;
                temp = cur;
                prev->next_ = cur->next_;
                //cout << "YES 4" <<endl;
            }
            pos[h] -- ;
            delete temp;
            deleted = true;
            //out.close();
            return deleted;
        }
        prev = cur;
        cur = cur->next_;
        count_m++;
    }
    if(!deleted){
        ofstream out("output.txt", ios::app);
        out << "\tNot found in the current ScopeTable" << endl;
        //out.close();
        delete temp;
    }
    return deleted;
}

int scopeTable :: getId(void){
    return id;
}

//-------------------------------------------------- SymbolTable -----------------------------------------------------------------//

class symbolTable{
    int N;
    int count_scope = 0;
    scopeTable* head;
    scopeTable* tail;
public:
    symbolTable(int);
    void EnterScope(void);
    void ExitScope(void);
    bool Insert(symbolinfo);
    bool Remove(string);
    symbolinfo* LookUp(string);
    void PrintC(void);
    void PrintA(void);
    void Quit(void);
};

symbolTable :: symbolTable(int N){
    this->N = N;
    head = NULL;
    tail = NULL;
}

void symbolTable :: EnterScope(void){
    scopeTable ab(N,count_scope+1);
    count_scope+=1;
    ofstream out("output.txt", ios::app);
    out << "\tScopeTable# "<< count_scope <<" created"<<endl;
    scopeTable* temp = new scopeTable(N,count_scope);
    ab.parent = head;
    if(tail == NULL){
        head = temp;
        tail = temp;
    }
    else{
        temp->parent = head;
        head = temp;
    }
    //out.close();
}

void symbolTable :: ExitScope(void){
    ofstream out("output.txt", ios::app);
    if(head->parent!=NULL){
        scopeTable* temp = head;
        head= head->parent;
        out << "\tScopeTable# " << temp->getId()<< " removed" << endl;
        delete temp;
    }
    else{
        out << "\tScopeTable# " << head->getId()<< " cannot be removed" << endl;
    }
    //out.close();
}

bool symbolTable :: Insert(symbolinfo sym){
    bool inserted = head->Insert(sym);
    return inserted;
}

bool symbolTable :: Remove(string s){
    bool inserted = head->Delete(s);
    return inserted;
}

symbolinfo* symbolTable :: LookUp(string symb1){
    scopeTable* current = head;
    symbolinfo* found = NULL;
    while(current!=NULL){
        found = current->LookUp(symb1,true);
        if(found!=NULL)
            break;
        current = current->parent;
    }
    if(found == NULL){
       ofstream out("output.txt", ios::app);
       out << "\t'" << symb1 << "' not found in any of the ScopeTables"<< endl;
       //out.close();
    }
    return found;
}

void symbolTable :: PrintC(void){
    ofstream out("output.txt", ios::app);
    out << "\tScopeTable# " << head->getId() << endl;
    head->Print();
    //out.close();
}

void symbolTable :: PrintA(void){
    ofstream out("output.txt", ios::app);
    scopeTable* current = head;
    while(current!=NULL){
        out << "\tScopeTable# " << current->getId() << endl;
        current->Print();
        current = current->parent;
    }
    //out.close();
}

void symbolTable :: Quit(void){
     ofstream out("output.txt", ios::app);
     while(true){
        if(head->parent!=NULL){
            scopeTable* temp = head;
            head= head->parent;
            out << "\tScopeTable# " << temp->getId()<< " removed" << endl;
            delete temp;
        }
        else{
            scopeTable* temp = head;
            out << "\tScopeTable# " << temp->getId()<< " removed" << endl;
            head = NULL;
            tail = NULL;
            //out.close();
            break;
        }
     }
}

int main(){
    string s1;
    int bs;
    ifstream in("sample_input.txt");
    ofstream out1("output.txt");
    out1.close();
    ofstream out("output.txt",ios::app);
    getline(in, s1);
    bs = stoi(s1);
    symbolTable A(bs);
    int cmd_n = 1;
    A.EnterScope();
    while(true){
        getline(in,s1);
        out << "Cmd " << cmd_n << ": " << s1 << endl;
        string cmd_1;
        string *params = new string[6];
        int j=0;
        for(int i=0;s1[i]!='\0'&&j<6;i++){
            if(s1[i] != ' '){
                params[j] = params[j] + s1[i];
            }
            else{
                j++;
            }
        }
        if(params[0] == "I") {
                if(j!=2){
                    out << "\tNumber of parameters mismatch for the command I" <<endl;
                }
                else{
                    symbolinfo sample(params[1],params[2]);
                    A.Insert(sample);
                }
        }
        else if(params[0] == "L") {
                if(j!=1){
                    out << "\tNumber of parameters mismatch for the command L" <<endl;
                }
                else{
                    A.LookUp(params[1]);
                }
        }
        else if(params[0] == "D") {
                if(j!=1){
                    out << "\tNumber of parameters mismatch for the command D" <<endl;
                }
                else{
                    A.Remove(params[1]);
                }
        }
        else if(params[0] == "S") {
                if(j!=0){
                    out << "\tNumber of parameters mismatch for the command S" <<endl;
                }
                else{
                    A.EnterScope();
                }
        }
        else if(params[0] == "E") {
                if(j!=0){
                    out << "\tNumber of parameters mismatch for the command E" <<endl;
                }
                else{
                    A.ExitScope();
                }
        }
        else if(params[0] == "P") {
                if(j!=1){
                    out << "\tNumber of parameters mismatch for the command P" <<endl;
                }
                else if(params[1]=="C"){
                    A.PrintC();
                }
                else if(params[1]=="A"){
                    A.PrintA();
                }
        }
        else if(params[0] == "Q") {
                if(j!=0){
                    out << "\tNumber of parameters mismatch for the command Q" <<endl;
                }
                else{
                    A.Quit();
                }
                break;
        }
        else{
            out << "No Such Command" << endl;
        }
        cmd_n++;
    }
    out.close();
    return 0;
}
