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
		printf("cs316: Error, Data Type in statement is not compatible!") ;
		return false;
	}

	if( this->ast_num_child != binary_arity ) {
		printf("cs316: Error, wrong arity value!") ;
		return false;
	}

	if( lhs == NULL ) {
		printf("cs316: Error, left side is null!") ;
		return false;
	}

	if( lhs == NULL ) {
		printf("cs316: Error, right side is null!") ;
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
	if( name!=var_entry.get_variable_name() ) printf("cs316: Error, name is different from symbol table entry");
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

template <class DATA_TYPE>
Number_Ast<DATA_TYPE>::Number_Ast(DATA_TYPE number, Data_Type constant_data_type, int line){
	constant = number;
	this->lineno = line;
	this->ast_num_child = zero_arity;
	this->node_data_type = constant_data_type;
}

template <class DATA_TYPE>
Number_Ast<DATA_TYPE>::~Number_Ast(){}

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
	file_buffer << "Num : " << this->constant;
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
			printf("cs316: Error, Incompatible data type!");
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