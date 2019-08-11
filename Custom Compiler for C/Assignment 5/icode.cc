#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include <list>
#include <map>
#include "symbol-table.hh"
#include "icode.hh"
#include "reg-alloc.hh"
#include "ast.hh"
#include "program.hh"
using namespace std;
template class Const_Opd<double>;
template class Const_Opd<int>;

//instruction descriptor
Instruction_Descriptor::Instruction_Descriptor(Tgt_Op op , string name , string mnn , string ics , Icode_Format icf , Assembly_Format af){
	inst_op = op;
	mnemonic = mnn;
	ic_symbol = ics;
	this->name = name;
	ic_format = icf;
	assem_format = af;
}

Instruction_Descriptor::Instruction_Descriptor(){
	inst_op = nop;
	mnemonic = "";
	ic_symbol = "";
	this->name = "";
	ic_format = i_nsy;
	assem_format = a_nsy;
}
Tgt_Op Instruction_Descriptor::get_op(){
	return inst_op;
}
string Instruction_Descriptor::get_name(){
	return name;
}
string Instruction_Descriptor::get_mnemonic(){
	return mnemonic;
}
string Instruction_Descriptor::get_ic_symbol(){
	return ic_symbol;
}
Icode_Format Instruction_Descriptor::get_ic_format(){
	return ic_format;
}
Assembly_Format Instruction_Descriptor::get_assembly_format(){
	return assem_format;
}

//icode statement

Register_Descriptor * Ics_Opd::get_reg(){
	return NULL;
}
Mem_Addr_Opd::Mem_Addr_Opd(Symbol_Table_Entry &se){
	symbol_entry = &se;
}
void Mem_Addr_Opd::print_ics_opd(ostream &file_buffer){
	file_buffer<<symbol_entry->get_variable_name();
}
void Mem_Addr_Opd::print_asm_opd(ostream &file_buffer){
	//CHECK THIS!//
	if (symbol_entry->get_symbol_scope() != global) file_buffer << symbol_entry->get_start_offset() << "($fp)";
	else file_buffer << symbol_entry->get_variable_name();
}
Mem_Addr_Opd &Mem_Addr_Opd::operator=(const Mem_Addr_Opd &rhs){
	symbol_entry = rhs.symbol_entry;
}
Register_Addr_Opd::Register_Addr_Opd(Register_Descriptor *rd){
	register_description = rd;
}
Register_Descriptor *Register_Addr_Opd::get_reg(){
	return register_description;
}

Register_Addr_Opd & Register_Addr_Opd::operator=(const Register_Addr_Opd & rhs){
	this->register_description = rhs.register_description;
}

void Register_Addr_Opd::print_ics_opd(ostream &file_buffer){
	file_buffer<<register_description->get_name();
}
void Register_Addr_Opd::print_asm_opd(ostream &file_buffer){
	file_buffer<<"$"<<register_description->get_name();
}

//const opd
template<class T>
Const_Opd<T>::Const_Opd(T num){
	this->num = num;
}
template<class T>
void Const_Opd<T>::print_ics_opd(ostream &file_buffer){
	file_buffer<<num;
}
template<class T>
void Const_Opd<T>::print_asm_opd(ostream &file_buffer){
	file_buffer<<num;
}
template<class T>
Const_Opd<T> & Const_Opd<T>::operator=(const Const_Opd &rhs){
	this->num = rhs.num;
}

//Icode_Stmt
//These are virtual, no need to define
Instruction_Descriptor & Icode_Stmt::get_op(){
	return op_desc;
}
Ics_Opd *Icode_Stmt::get_opd1(){
	//J
}
Ics_Opd *Icode_Stmt::get_opd2(){
	//A
}
Ics_Opd *Icode_Stmt::get_result(){
	//I
}
void Icode_Stmt::Icode_Stmt::set_opd1(Ics_Opd *io){
	//H
}
void Icode_Stmt::set_opd2(Ics_Opd *io){
	//I
}
void Icode_Stmt::set_result(Ics_Opd *io){
	//N
}
	//D
//print ic:  need to be done/////////////////////////////////////////////////////////
void Print_IC_Stmt::print_icode(ostream & file_buffer)
{
	//Do this!
	
}
////////////////////////////////////////////////////////////////////////////////
void Print_IC_Stmt::print_assembly(ostream & file_buffer)
{
	//Do this!
	
}
//////////////////////////////////////////////////////////////////////////////////
//Move_IC_Stmt
Move_IC_Stmt::Move_IC_Stmt(Tgt_Op inst_op, Ics_Opd * opd1, Ics_Opd * result){
	this->op_desc = *(machine_desc_object.spim_instruction_table[inst_op]);
	this->opd1 = opd1;   
	this->result = result; 
}
Move_IC_Stmt& Move_IC_Stmt::operator=(const Move_IC_Stmt& rhs)
{
	this->result = rhs.result; 
	this->op_desc = rhs.op_desc;
	this->opd1 = rhs.opd1;
}
Ics_Opd * Move_IC_Stmt::get_opd1()
{
	return opd1;
}
Ics_Opd * Move_IC_Stmt::get_result()        
{
	return result; 
}
void Move_IC_Stmt::set_opd1(Ics_Opd * io)
{ 
	opd1 = io; 
}
void Move_IC_Stmt::set_result(Ics_Opd * io) 
{ 
	result = io;
}
void Move_IC_Stmt::print_icode(ostream & file_buffer)
{
	if(op_desc.get_ic_format() ==  i_r_op_o1){ 
		file_buffer <<"\t" <<op_desc.get_name();
		file_buffer <<":    \t";
		result->print_ics_opd(file_buffer);
		file_buffer <<" <- ";
		opd1->print_ics_opd(file_buffer);
		file_buffer << "\n";
	}
}
void Move_IC_Stmt::print_assembly(ostream & file_buffer)
{
	file_buffer << "\t" << op_desc.get_mnemonic() <<" ";
	if(op_desc.get_assembly_format() == a_op_r_o1){
		result->print_asm_opd(file_buffer);
		file_buffer <<", ";
		opd1->print_asm_opd(file_buffer);
	}
	else if(op_desc.get_assembly_format() == a_op_o1_r){
		opd1->print_asm_opd(file_buffer);
		file_buffer << ", ";
		result->print_asm_opd(file_buffer);
	}
	file_buffer << "\n";
}
Compute_IC_Stmt::Compute_IC_Stmt(Tgt_Op inst_op, Ics_Opd * opd1, Ics_Opd * opd2, Ics_Opd * result) 
{
	this->result = result; 
	this->op_desc = *(machine_desc_object.spim_instruction_table[inst_op]);
	this->opd1 = opd1;
	this->opd2 = opd2;   
}
Compute_IC_Stmt& Compute_IC_Stmt::operator=(const Compute_IC_Stmt& rhs)
{
	this->result = rhs.result; 
	this->opd1 = rhs.opd1;
	this->opd2 = rhs.opd2;
	this->op_desc = rhs.op_desc;
}
Ics_Opd * Compute_IC_Stmt::get_opd1()
{ 
	return opd1; 
}
void Compute_IC_Stmt::set_opd1(Ics_Opd * io)   
{ 
	opd1 = io; 
}
Ics_Opd * Compute_IC_Stmt::get_opd2()          
{ 
	return opd2; 
}
void Compute_IC_Stmt::set_opd2(Ics_Opd * io)   
{
 	opd2 = io; 
}
Ics_Opd * Compute_IC_Stmt::get_result()        
{ 
	return result; 
}
void Compute_IC_Stmt::set_result(Ics_Opd * io) 
{ 
	result = io; 
}
void Compute_IC_Stmt::print_icode(ostream & file_buffer)
{
	file_buffer << "\t" << op_desc.get_name() << ":    \t";
	result->print_ics_opd(file_buffer);
	file_buffer <<" <- ";
	if(op_desc.get_ic_format() == i_r_op_o1){
		opd1->print_ics_opd(file_buffer);
	}else if(op_desc.get_ic_format() == i_r_o1_op_o2){
		opd1->print_ics_opd(file_buffer);
		file_buffer <<" , ";
		opd2->print_ics_opd(file_buffer);
	}
	file_buffer << "\n";
}

void Compute_IC_Stmt::print_assembly(ostream & file_buffer)
{
	file_buffer << "\t" << op_desc.get_mnemonic() << " ";
	if(op_desc.get_assembly_format() == a_op_r_o1_o2){
		result->print_asm_opd(file_buffer);
		file_buffer << ", ";
		opd1->print_asm_opd(file_buffer);
		file_buffer << ", ";
		opd2->print_asm_opd(file_buffer);
	}
	else if(op_desc.get_assembly_format() == a_op_o1_o2_r){
		opd1->print_asm_opd(file_buffer);
		file_buffer << ", ";
		opd2->print_asm_opd(file_buffer);
		file_buffer << ", ";
		result->print_asm_opd(file_buffer);
	}
	else if(op_desc.get_assembly_format() == a_op_r_o1){
		result->print_asm_opd(file_buffer);
		file_buffer << ", ";
		opd1->print_asm_opd(file_buffer);
	}
	else if(op_desc.get_assembly_format() == a_op_o1_r){
		opd1->print_asm_opd(file_buffer);
		file_buffer << ", ";
		result->print_asm_opd(file_buffer);
	}
	file_buffer << "\n";
}
//control flow ic
Control_Flow_IC_Stmt::Control_Flow_IC_Stmt(Tgt_Op inst_op, Ics_Opd * opd1, string label)
{
	this->opd1 = opd1;
	this->op_desc = *(machine_desc_object.spim_instruction_table[inst_op]);
	this->label = label;
}
Control_Flow_IC_Stmt& Control_Flow_IC_Stmt::operator=(const Control_Flow_IC_Stmt& rhs)
{
	this->opd1 = rhs.opd1;
	this->op_desc = rhs.op_desc;
	this->label = rhs.label; 
}

Ics_Opd * Control_Flow_IC_Stmt::get_opd1()          
{ 
	return opd1; 
}
void Control_Flow_IC_Stmt::set_opd1(Ics_Opd * io)   
{ 
	opd1 = io; 
}
string Control_Flow_IC_Stmt::get_label()        
{ 
	return label; 
}
void Control_Flow_IC_Stmt::set_label(string label) 
{ 
	this->label = label; 
}
void Control_Flow_IC_Stmt::print_icode(ostream & file_buffer)
{
	if(op_desc.get_ic_format() == i_op_o1_o2_st){
			file_buffer << "\t" << op_desc.get_name() << ":    \t";
			opd1->print_ics_opd(file_buffer);
			file_buffer << " , zero : goto " << label << "\n";
	}
	else if(op_desc.get_ic_format() == i_op_st){
			file_buffer << "\tgoto " << label << "\n";
	}
}
void Control_Flow_IC_Stmt::print_assembly(ostream & file_buffer)
{
	if(op_desc.get_assembly_format() == a_op_o1_o2_st){
			file_buffer << "\t" << op_desc.get_mnemonic() << " ";
			opd1->print_asm_opd(file_buffer);
			file_buffer << ", $zero, " << label << " \n";

	}else if(op_desc.get_assembly_format() == a_op_st){
			file_buffer << "\t" << op_desc.get_mnemonic() << " " << label << "\n";

	}
}
//Label IC
Label_IC_Stmt::Label_IC_Stmt(Tgt_Op inst_op, string label)
{
	op_desc = *(machine_desc_object.spim_instruction_table[inst_op]);
	this->label = label;
}
Label_IC_Stmt& Label_IC_Stmt::operator=(const Label_IC_Stmt& rhs)
{
	this->op_desc = rhs.op_desc;
	this->label = rhs.label; 
}

string Label_IC_Stmt::get_label()          
{ 
	return label; 
}
void Label_IC_Stmt::set_label(string label) 
{ 
	this->label = label; 
}
void Label_IC_Stmt::print_icode(ostream & file_buffer)
{
	if(op_desc.get_ic_format() == i_op_st){
		file_buffer << "\n" << label << ":    \t\n";		
	}
}
void Label_IC_Stmt::print_assembly(ostream & file_buffer)
{
	if(op_desc.get_assembly_format() == a_op_st){
		file_buffer << "\n" << label << ":    \t\n";
	}
}
//code for ast
Code_For_Ast::Code_For_Ast(){
	ics_list = {};
	result_register = NULL;
}

Code_For_Ast::Code_For_Ast(list<Icode_Stmt *> & ic_l, Register_Descriptor * reg){
	ics_list = ic_l;
	result_register = reg;
}

void Code_For_Ast::append_ics(Icode_Stmt & ics){
	ics_list.push_back(&ics);
}

list<Icode_Stmt *> & Code_For_Ast::get_icode_list()  { 
	return ics_list;
}

Register_Descriptor * Code_For_Ast::get_reg(){
	return result_register;
}

void Code_For_Ast::set_reg(Register_Descriptor * reg){
	result_register = reg;
}

Code_For_Ast& Code_For_Ast::operator=(const Code_For_Ast& rhs){
	this->result_register = rhs.result_register;
	this->ics_list = rhs.ics_list;
}
//