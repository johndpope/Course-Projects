#include<typeinfo>
#include<iostream>
#include<fstream>
#include"procedure.hh"
#include"program.hh"
#include"ast.hh"
#include"symbol-table.hh"
#include"stdlib.h"
using namespace std;

template class Number_Ast<double>;
template class Number_Ast<int>;
int Ast::labelCounter;

Ast::Ast(){}
Ast::~Ast(){}
Data_Type Ast::get_data_type(){}
void Ast::set_data_type(Data_Type dt){}
bool Ast::is_value_zero(){}
bool Ast::check_ast(){}
Symbol_Table_Entry & Ast::get_symbol_entry(){}

Assignment_Ast::Assignment_Ast(Ast * temp_lhs, Ast * temp_rhs, int line){
	lhs = temp_lhs;
	rhs = temp_rhs;
	this->lineno = line;
	this->ast_num_child = binary_arity;
	this->node_data_type = lhs->get_data_type();	
}

Assignment_Ast::~Assignment_Ast(){
	if(rhs != NULL) delete rhs;
	if(lhs != NULL) delete lhs;
}

bool Assignment_Ast::check_ast(){
	if( lhs->get_data_type() != rhs->get_data_type() ) {
		printf("cs316: Error, Data Type in assignment is not compatible!\n") ;
		exit(0);
		return false;
	}

	if( this->ast_num_child != binary_arity ) {
		printf("cs316: Error, wrong arity value!\n") ;
		exit(0);
		return false;
	}

	if( lhs == NULL ) {
		printf("cs316: Error, left side is null!\n") ;
		exit(0);
		return false;
	}

	if( lhs == NULL ) {
		printf("cs316: Error, right side is null!\n") ;
		exit(0);
		return false;
	}

	return true;
}
void Assignment_Ast::print(ostream & file_buffer){
	file_buffer <<"\n" <<AST_SPACE <<"Asgn:" <<"\n" <<AST_NODE_SPACE <<"LHS (";
	lhs->print(file_buffer);
	file_buffer <<")\n" <<AST_NODE_SPACE <<"RHS (";
	rhs->print(file_buffer);
	file_buffer << ")";
}

Name_Ast::Name_Ast(string & name, Symbol_Table_Entry & var_entry, int line)
{
	if( name!=var_entry.get_variable_name() ) printf("cs316: Error, name is different from symbol table entry\n");
	variable_symbol_entry = &var_entry;
	this->lineno = line;
	this->ast_num_child = zero_arity;
	this->node_data_type = variable_symbol_entry->get_data_type();
}
Name_Ast::~Name_Ast(){}

Data_Type Name_Ast::get_data_type(){
	return this->node_data_type;
}

Symbol_Table_Entry & Name_Ast::get_symbol_entry(){
	return *variable_symbol_entry;
}

void Name_Ast::set_data_type(Data_Type dt){
	this->node_data_type = dt;
}

void Name_Ast::print(ostream & file_buffer){
	file_buffer << "Name : " <<variable_symbol_entry->get_variable_name();
}

template <class DATA_TYPE> Number_Ast<DATA_TYPE>::Number_Ast(DATA_TYPE number, Data_Type constant_data_type, int line){
	constant = number;
	this->lineno = line;
	this->ast_num_child = zero_arity;
	this->node_data_type = constant_data_type;
}

template <class DATA_TYPE> Number_Ast<DATA_TYPE>::~Number_Ast(){}

template <class DATA_TYPE> 
Data_Type Number_Ast<DATA_TYPE>::get_data_type(){
	return this->node_data_type;
}

template <class DATA_TYPE> 
void Number_Ast<DATA_TYPE>::set_data_type(Data_Type dt){
	this->node_data_type = dt;
}

template <class DATA_TYPE>
bool Number_Ast<DATA_TYPE>::is_value_zero(){
	if (this->constant==0) return true;
	else return false;
}

template <class DATA_TYPE>
void Number_Ast<DATA_TYPE>::print(ostream & file_buffer){
	file_buffer << "Num : " <<this->constant;
}

Data_Type Arithmetic_Expr_Ast::get_data_type(){
	return this->node_data_type;
}

void Arithmetic_Expr_Ast::set_data_type(Data_Type dt){
	this->node_data_type = dt;
}

bool Arithmetic_Expr_Ast::check_ast(){
	if( (this->ast_num_child == binary_arity) && (lhs->get_data_type() != rhs->get_data_type()) )
	{
			printf("cs316: Error, Incompatible data type!\n");
			exit(0);
			return false;
	}
	
	else return true;
}

Plus_Ast::Plus_Ast(Ast * l, Ast * r, int line){
	this->lhs = l;
	this->rhs = r;
	this->ast_num_child = binary_arity;
}

void Plus_Ast::print(ostream & file_buffer){
	file_buffer <<"\n"<<AST_NODE_SPACE <<"Arith: PLUS" <<"\n" <<AST_SUB_NODE_SPACE <<"LHS (";
	lhs->print(file_buffer);
	file_buffer <<")\n" <<AST_SUB_NODE_SPACE <<"RHS (";
	rhs->print(file_buffer);
	file_buffer <<")";
}

Minus_Ast::Minus_Ast(Ast * l, Ast * r, int line){
	this->lhs = l;
	this->rhs = r;
	this->ast_num_child = binary_arity;
}

void Minus_Ast::print(ostream & file_buffer){
	file_buffer <<"\n"<<AST_NODE_SPACE <<"Arith: MINUS" <<"\n" <<AST_SUB_NODE_SPACE <<"LHS (";
	lhs->print(file_buffer);
	file_buffer <<")\n" <<AST_SUB_NODE_SPACE <<"RHS (";
	rhs->print(file_buffer);
	file_buffer <<")";
}

Divide_Ast::Divide_Ast(Ast * l, Ast * r, int line){
	this->lhs = l;
	this->rhs = r;
	this->ast_num_child = binary_arity;
}

void Divide_Ast::print(ostream & file_buffer){
	file_buffer <<"\n"<<AST_NODE_SPACE <<"Arith: DIV" <<"\n" <<AST_SUB_NODE_SPACE <<"LHS (";
	lhs->print(file_buffer);
	file_buffer <<")\n" <<AST_SUB_NODE_SPACE <<"RHS (";
	rhs->print(file_buffer);
	file_buffer <<")";
}

Mult_Ast::Mult_Ast(Ast * l, Ast * r, int line){
	this->lhs = l;
	this->rhs = r;
	this->ast_num_child = binary_arity;
}

void Mult_Ast::print(ostream & file_buffer){
	file_buffer <<"\n"<<AST_NODE_SPACE <<"Arith: MULT" <<"\n" <<AST_SUB_NODE_SPACE <<"LHS (";
	lhs->print(file_buffer);
	file_buffer <<")\n" <<AST_SUB_NODE_SPACE <<"RHS (";
	rhs->print(file_buffer);
	file_buffer <<")";
}

UMinus_Ast::UMinus_Ast(Ast * l, Ast * r, int line){
	this->lhs = l;
	this->rhs = NULL;
	this->ast_num_child = unary_arity;
}

void UMinus_Ast::print(ostream & file_buffer){
	file_buffer <<"\n" <<AST_NODE_SPACE <<"Arith: UMINUS" <<"\n" <<AST_SUB_NODE_SPACE << "LHS (";
	lhs->print(file_buffer);
	file_buffer <<")";
}

Return_Ast::Return_Ast(int line){
		this->lineno = line;	
}

Return_Ast::~Return_Ast(){}

void Return_Ast::print(ostream & file_buffer){
	file_buffer <<"\n" <<AST_NODE_SPACE <<"Return AST\n";	
}

Conditional_Expression_Ast::Conditional_Expression_Ast(Ast* cond, Ast* l, Ast* r, int line){
	this->cond = cond;
	this->lhs = l;
	this->rhs = r;
	this->ast_num_child = ternary_arity;
}

void Conditional_Expression_Ast::print(ostream & file_buffer){
	file_buffer <<"\n" <<AST_SPACE <<"Cond:\n" <<AST_NODE_SPACE <<"IF_ELSE";
	cond->print(file_buffer);
	file_buffer <<"\n" <<AST_NODE_SPACE <<"LHS (";
	lhs->print(file_buffer);
	file_buffer <<")\n" <<AST_NODE_SPACE <<"RHS (";
	rhs->print(file_buffer);
	file_buffer <<")";
}

Relational_Expr_Ast::Relational_Expr_Ast(Ast * lhs, Relational_Op rop, Ast * rhs, int line){
	this->lhs_condition = lhs;
	this->rhs_condition = rhs;
	this->rel_op = rop;
	this->ast_num_child = binary_arity;
}

bool Relational_Expr_Ast::check_ast()
{
	if(this->lhs_condition->get_data_type() != this->rhs_condition->get_data_type()) {
		printf("cs316: Error, relation data types incompatible\n");
		exit(0);
		return false;
	}
	else return true;
}

void Relational_Expr_Ast::print(ostream & file_buffer){
	char* relation;
	if (this->rel_op == less_equalto) relation = (char*)"LE";
	else if (this->rel_op == less_than) relation = (char*)"LT";
	else if (this->rel_op == greater_than) relation = (char*)"GT";
	else if (this->rel_op == greater_equalto) relation = (char*)"GE";
	else if (this->rel_op == equalto) relation = (char*)"EQ";
	else if (this->rel_op == not_equalto) relation = (char*)"NE";
	else printf("cs316: Error, unknown relation symbol\n");

	file_buffer <<"\n" <<AST_NODE_SPACE <<"Condition: " <<relation;
	file_buffer <<"\n" <<AST_SUB_NODE_SPACE << "LHS (";
	lhs_condition->print(file_buffer);
	file_buffer <<")\n" <<AST_SUB_NODE_SPACE <<"RHS (";
	rhs_condition->print(file_buffer);
	file_buffer <<")";
}

Logical_Expr_Ast::Logical_Expr_Ast(Ast * lhs, Logical_Op bop, Ast * rhs, int line){
	this->lhs_op = lhs;
	this->rhs_op = rhs;
	this->bool_op = bop;
	this->ast_num_child = binary_arity;
}

void Logical_Expr_Ast::print(ostream & file_buffer){
	char* logic;
	if (this->bool_op == _logical_and) logic = (char*)"AND\n";
	else if (this->bool_op == _logical_or) logic = (char*)"OR\n";
	else if (this->bool_op == _logical_not) logic = (char*)"NOT\n";
	else printf("cs316: error, unknown logical symbol\n");

	file_buffer <<"\n" <<AST_NODE_SPACE <<"Condition: " <<logic;
	if (bool_op != _logical_not){
		file_buffer <<AST_SUB_NODE_SPACE << "LHS (";
		lhs_op->print(file_buffer);
		file_buffer <<")\n";
	}
	file_buffer <<AST_SUB_NODE_SPACE <<"RHS (";
	rhs_op->print(file_buffer);
	file_buffer <<")";
}

Selection_Statement_Ast::Selection_Statement_Ast(Ast * cond,Ast* then_part, Ast* else_part, int line){
	this->cond = cond;
	this->then_part = then_part;
	this->else_part = else_part;
	this->ast_num_child = ternary_arity;
}

void Selection_Statement_Ast::print(ostream & file_buffer){
	file_buffer <<"\n" <<AST_SPACE <<"IF : \n" <<AST_SPACE <<"CONDITION (";
	cond->print(file_buffer);
	file_buffer <<")\n" <<AST_SPACE <<"THEN (";
	then_part->print(file_buffer);
	file_buffer <<")";
	if (else_part != NULL){
		file_buffer <<"\n"<<AST_SPACE <<"ELSE (";
		else_part->print(file_buffer);
		file_buffer <<")";
	}
}

Iteration_Statement_Ast::Iteration_Statement_Ast(Ast * cond, Ast* body, int line, bool do_form){
	this->cond = cond;
	this->body = body;
	this->is_do_form = do_form;
	this->ast_num_child = binary_arity;
}

void Iteration_Statement_Ast::print(ostream & file_buffer){ 
	if( !(this->is_do_form) ) {
		file_buffer <<"\n" <<AST_SPACE <<"WHILE : \n" <<AST_SPACE <<"CONDITION (";
		cond->print(file_buffer);
		file_buffer <<")\n" <<AST_SPACE <<"BODY (";
		body->print(file_buffer);
		file_buffer <<")";
	}
	else {
		file_buffer <<"\n" <<AST_SPACE <<"DO (";
		body->print(file_buffer);
		file_buffer <<")\n" <<AST_SPACE <<"WHILE CONDITION (";
		cond->print(file_buffer);
		file_buffer <<")";
	}
}

Sequence_Ast::Sequence_Ast(int line){
	this->ast_num_child = zero_arity;
}

void Sequence_Ast::ast_push_back(Ast* ast){ statement_list.push_back(ast);}

void Sequence_Ast::print(ostream & file_buffer){
	for(list<Ast *>::iterator it = statement_list.begin(); it!=statement_list.end(); it++){
		file_buffer <<"\n" <<AST_NODE_SPACE;
		(*it)->print(file_buffer);
	}
}


Data_Type Relational_Expr_Ast::get_data_type(){return this->node_data_type;}
void Relational_Expr_Ast::set_data_type(Data_Type dt){this->node_data_type = dt;}

Data_Type Logical_Expr_Ast::get_data_type(){return this->node_data_type;}
void Logical_Expr_Ast::set_data_type(Data_Type dt){this->node_data_type = dt;}
bool Logical_Expr_Ast::check_ast(){return true;}

Data_Type Selection_Statement_Ast::get_data_type(){return this->node_data_type;}
void Selection_Statement_Ast::set_data_type(Data_Type dt){this->node_data_type = dt;}
bool Selection_Statement_Ast::check_ast(){return true;}

Data_Type Iteration_Statement_Ast::get_data_type(){return this->node_data_type;}
void Iteration_Statement_Ast::set_data_type(Data_Type dt){this->node_data_type = dt;}
bool Iteration_Statement_Ast::check_ast(){return true;}