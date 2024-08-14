# include <bits/stdc++.h>

using namespace std;

//-------------------------------------------------- SymbolInfo -----------------------------------------------------------------//
class par{
public:
    string name;
    string type;
    par(string name, string type){
        this->name = name;
        this->type = type;
    }
};

class symbolinfo{
    string name, type, dataType, varType;
    int varsize, s_line, e_line, s_off, arrIndex;
    bool isLeaf = false;
    bool isglobal;
public:
    symbolinfo* next_;
    string label; 
    bool zeroflag = false;
    vector<symbolinfo*> childlist;
    vector<int> truelist;
    vector<int> falselist;
    vector<int> nextlist;
    vector<par> parlist;
    symbolinfo(void){
        name = "";
        type = "";
        next_  = NULL;
    }

    symbolinfo(string name, string type){
        this->name = name;
        this->type = type;
        next_  = NULL;
    }

    symbolinfo(const symbolinfo& sym){
        name = sym.name;
        type = sym.type;
        next_ = sym.next_;
        varsize = sym.varsize;
        dataType = sym.dataType;
        varType = sym.varType;
        parlist = sym.parlist;
        isglobal = sym.isglobal;
        isLeaf = sym.isLeaf;
        zeroflag = sym.zeroflag;
        s_off = sym.s_off;
        arrIndex = sym.arrIndex;
        label = sym.label;
        truelist = sym.truelist;
        falselist = sym.falselist;
        nextlist = sym.nextlist;
    }


    string getName(void){
        return name;
    }
    
    bool getGlobal(void){
    	return isglobal;
    }
    
    void setGlobal(bool G){
    	isglobal = G;
    }
    
    void setName(string name_){
        name = name_;
    }

    string getType(void){
        return type;
    }

    void setType(string type_){
        type = type_;
    }

    string getdataType(void){
        return dataType;
    }

    void setdataType(string datatype_){
        dataType = datatype_;
    }

    int getvarsize(){
        return varsize;
    }

    void setvarsize(int vsize){
        varsize = vsize;
    }

    string getvarType(void){
        return varType;
    }
    
    void setvarType(string var_type){
        varType = var_type;
    }
    
    void setSLine(int line_no){
        s_line = line_no;
    }

    int getSLine(void){
        return s_line;
    }

    void setELine(int line_no){
        e_line = line_no;
    }

    int getELine(void){
        return e_line;
    }

    void setLeaf(bool leaf){
        isLeaf = leaf;
    }

    bool getLeaf(void){
        return isLeaf;
    }

    void addpar(string _name, string _type){   
        parlist.push_back(par(_name, _type));
    }

    int gets_off(){
        return s_off;
    }

    void sets_off(int s_o){
        s_off = s_o;
    }

    void setArrInd(int in){
        arrIndex = in;
    }

    int getArrInd(void){
        return arrIndex;
    }
};

//-------------------------------------------------- ScopeTable -----------------------------------------------------------------//

class scopeTable{
    int N, id;
    symbolinfo* b_list;
    symbolinfo** head;
    symbolinfo** tail;
    int* pos;
public:
    scopeTable* parent = NULL;

    scopeTable(int N, int id){
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
            pos[i] = 0;
    };

    ~scopeTable(void){
        delete[] b_list;
    }

    long long int SDBM_hash(string str){
        long long int hash = 0;
        long long int i = 0;
        long long int len = str.length();

        for (i = 0; i < len; i++)
        {
            hash = (str[i]) + (hash << 6) + (hash << 16) - hash;
        }

        return hash;
    };

    bool Insert(symbolinfo sym1){
        bool inserted = false;
        long long int h = SDBM_hash(sym1.getName())%N;
        symbolinfo *tmp = new symbolinfo;
        tmp->setName(sym1.getName());
        tmp->setType(sym1.getType());
        tmp->setdataType(sym1.getdataType());
        tmp->setvarsize(sym1.getvarsize());
        tmp->setvarType(sym1.getvarType());
        tmp->parlist = sym1.parlist;
        tmp->next_ = NULL;
        tmp->setGlobal(sym1.getGlobal());
        tmp->sets_off(sym1.gets_off());
        tmp->setArrInd(sym1.getArrInd());
        tmp->label = sym1.label;
        tmp->truelist = sym1.truelist;
        tmp->falselist = sym1.falselist;
        tmp->nextlist = sym1.nextlist;
        //ofstream out("output_log.txt", ios::app);
        if(LookUp(sym1.getName(),false)!=NULL){
            inserted = false;
            return inserted;
        }
        if(head[h] == NULL){
            //cout << " IN scopeTable 2 " <<sym1.getName() << endl;
            head[h] = tmp;
            tail[h] = tmp;
            //pos[h]++;
            inserted = true;
        }
        else{
            tail[h]->next_ = tmp;
            tail[h] = tail[h]->next_;
            pos[h]++;
            inserted = true;
        }
        //out.close();
        return inserted;
    };

    bool Delete(string s_name){
        bool deleted = false;
        long long int h = SDBM_hash(s_name)%N;
        int count_m = 1;
        symbolinfo *prev = NULL;
        symbolinfo *cur = head[h];
        symbolinfo *temp = new symbolinfo;
        if(head[h] == NULL){
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
                //cout << "YES 1" <<endl;
                }
                else if(cur == head[h]){
                head[h] = cur->next_;
                //cout << "YES 2" <<endl;
                }
                else if(cur == tail[h]){
                tail[h] = prev;
                tail[h]->next_ = NULL;
                //cout << "YES 3" <<endl;
                }
                else{
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
            //out.close();
            delete temp;
        }
        return deleted;
    };

    symbolinfo* LookUp(string symName, bool p){
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
                return found;
            }
            cur = cur->next_;
            count_m++;
        }
        //out.close();
    };

    void Print(){
        //ofstream out("output_log.txt", ios::app);
        for(int i=0; i<N; i++){
            symbolinfo* cur = head[i];
            if(head[i]==NULL){
                continue;
            }
            //out <<"\t"<< i+1 << "--> ";
            while(true){
                if(cur==NULL){
                    //out << endl;
                    break;
                }
                else{
                    //out << "<" << cur->getName() << ", " << cur->getType() << "> " << cur->gets_off();
                    cur = cur->next_;
                }
            }
        }
        //out.close();
    };

    int getId(void){
        return id;
    };
   
};

//-------------------------------------------------- SymbolTable -----------------------------------------------------------------//

class symbolTable{
    int N;
    int count_scope = 0;
    scopeTable* head;
    scopeTable* tail;
public:

    symbolTable(int N){
        this->N = N;
        head = NULL;
        tail = NULL;
    };

    void EnterScope(void){
        scopeTable ab(N,count_scope+1);
        count_scope+=1;
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
    };

    void ExitScope(void){
        if(head->parent!=NULL){
            scopeTable* temp = head;
            head= head->parent;
            delete temp;
        }
        //out.close();
    };

    bool Insert(symbolinfo sym){
        bool inserted = head->Insert(sym);
        return inserted;
    };

    bool Remove(string s){
        bool inserted = head->Delete(s);
        return inserted;
    };

    symbolinfo* LookUp(string symb1){
        scopeTable* current = head;
        symbolinfo* found = NULL;
        while(current!=NULL){
            found = current->LookUp(symb1,true);
            if(found!=NULL)
                break;
            current = current->parent;
        }
        if(found == NULL){
        //out.close();
        }
        return found;
    };

    void PrintC(void){
        //ofstream out("output_log.txt", ios::app);
        //out << "\tScopeTable# " << head->getId() << endl;
        head->Print();
        //out.close();
    };

    void PrintA(void){
        //ofstream out("output_log.txt", ios::app);
        scopeTable* current = head;
        while(current!=NULL){
            //out << "\tScopeTable# " << current->getId() << endl;
            current->Print();
            current = current->parent;
        }
        //out.close();
    };

    int getID(){
        return head->getId();
    }
    
    void Quit(void){
        while(true){
            if(head->parent!=NULL){
                scopeTable* temp = head;
                head= head->parent;
                delete temp;
            }
            else{
                scopeTable* temp = head;
                head = NULL;
                tail = NULL;
                //out.close();
                break;
            }
        }
    };

};
