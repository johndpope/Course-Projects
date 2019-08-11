#include"ast.hh"
#include<typeinfo>
#include<iostream>
#include<fstream>
#include"procedure.hh"
#include"program.hh"
#include"symbol-table.hh"
#include"stdlib.h"
#include"icode.hh"
#include"reg-alloc.hh"
using namespace std;
template class Number_Ast<double>;
template class Number_Ast<int>;

Code_For_Ast & Ast::create_store_stmt(Register_Descriptor * store_register){}

Code_For_Ast & Assignment_Ast::compile(){
	
	Code_For_Ast & right_stmt = rhs->compile();
	Register_Descriptor * rhs_reg = right_stmt.get_reg();
	Code_For_Ast * return_ast;

	list<Icode_Stmt *> & new_ic_list = *new list<Icode_Stmt *>;
	new_ic_list = right_stmt.get_icode_list();
	
	rhs_reg->set_use_for_expr_result();
	Code_For_Ast & lhs_store_stmt = lhs->create_store_stmt(rhs_reg);
	rhs_reg->reset_use_for_expr_result();
	new_ic_list.insert(new_ic_list.end(), lhs_store_stmt.get_icode_list().begin(), lhs_store_stmt.get_icode_list().end());

	return_ast = new Code_For_Ast(new_ic_list, rhs_reg);
	return *return_ast;
}

Code_For_Ast & Name_Ast::compile(){
	Register_Descriptor * reg_new;
	Icode_Stmt * current_stmt;
	Mem_Addr_Opd * memory_addr_opd = new Mem_Addr_Opd(*variable_symbol_entry);
	Code_For_Ast *name_stmt = new Code_For_Ast();

	if(get_data_type() == double_data_type){
		reg_new =  machine_desc_object.get_new_register<float_reg>();
		Register_Addr_Opd * result_opd = new Register_Addr_Opd(reg_new);
		current_stmt = new Move_IC_Stmt(load_d, memory_addr_opd, result_opd);
	} 
	else if(get_data_type() == int_data_type){
		reg_new =  machine_desc_object.get_new_register<int_reg>();
		Register_Addr_Opd * result_opd = new Register_Addr_Opd(reg_new);
		current_stmt = new Move_IC_Stmt(load, memory_addr_opd, result_opd);
	}
	
	name_stmt->append_ics(*current_stmt);
	name_stmt->set_reg(reg_new);
	return *name_stmt;
}

Code_For_Ast & Name_Ast::create_store_stmt(Register_Descriptor * store_register){
	Icode_Stmt * current_stmt;
	Mem_Addr_Opd * memory_addr_opd = new Mem_Addr_Opd(*variable_symbol_entry);
	Register_Addr_Opd * store_opd = new Register_Addr_Opd(store_register);
	Code_For_Ast *store_stmt = new Code_For_Ast();

	if(get_data_type() == double_data_type) current_stmt = new Move_IC_Stmt(store_d, store_opd, memory_addr_opd);
	else if(get_data_type() == int_data_type) current_stmt = new Move_IC_Stmt(store, store_opd, memory_addr_opd);
	
	store_stmt->append_ics(*current_stmt);
	store_stmt->set_reg(store_register);
	return *store_stmt;
}

template <class T> Code_For_Ast & Number_Ast<T>::compile(){
	Register_Descriptor * reg_new;
	Icode_Stmt * current_stmt;
	Code_For_Ast *number_stmt = new Code_For_Ast();

	if(get_data_type() == double_data_type){
		reg_new =  machine_desc_object.get_new_register<float_reg>();
		Register_Addr_Opd * result_opd = new Register_Addr_Opd(reg_new);
		Const_Opd<double> * num_opd = new Const_Opd<double>(constant);
		current_stmt = new Move_IC_Stmt(imm_load_d, num_opd, result_opd);
	} 
	else if(get_data_type() == int_data_type){
		reg_new =  machine_desc_object.get_new_register<int_reg>();
		Register_Addr_Opd * result_opd = new Register_Addr_Opd(reg_new);
		Const_Opd<int> * num_opd = new Const_Opd<int>(constant);
		current_stmt = new Move_IC_Stmt(imm_load, num_opd, result_opd);
	}
	
	number_stmt->append_ics(*current_stmt);
	number_stmt->set_reg(reg_new);
	return *number_stmt;
}

Code_For_Ast & Plus_Ast::compile(){
	Code_For_Ast * left_stmt = &(lhs->compile());
	Code_For_Ast * right_stmt = &(rhs->compile());
	Register_Addr_Opd * left_addr_opd = new Register_Addr_Opd(left_stmt->get_reg());
	Register_Addr_Opd * right_addr_opd = new Register_Addr_Opd(right_stmt->get_reg());
	Register_Descriptor * reg_new;
	Icode_Stmt * current_stmt;

	list<Icode_Stmt *> & icode_list = *new list<Icode_Stmt *>;
	icode_list = left_stmt->get_icode_list();
	icode_list.insert(icode_list.end(), right_stmt->get_icode_list().begin(), right_stmt->get_icode_list().end());

	if(get_data_type() == double_data_type){
		reg_new =  machine_desc_object.get_new_register<float_reg>();
		Register_Addr_Opd * result_opd = new Register_Addr_Opd(reg_new);
		current_stmt = new Compute_IC_Stmt(add_d, left_addr_opd, right_addr_opd, result_opd);
	} 
	else if(get_data_type() == int_data_type){
		reg_new =  machine_desc_object.get_new_register<int_reg>();
		Register_Addr_Opd * result_opd = new Register_Addr_Opd(reg_new);
		current_stmt = new Compute_IC_Stmt(add, left_addr_opd, right_addr_opd, result_opd);
	}

	Code_For_Ast *plus_stmt = new Code_For_Ast(icode_list, reg_new);
	plus_stmt->append_ics(*current_stmt);
	plus_stmt->set_reg(reg_new);
	
	left_stmt->get_reg()->reset_register_occupied();
	right_stmt->get_reg()->reset_register_occupied();

	return *plus_stmt;
}

Code_For_Ast & Minus_Ast::compile(){
	Code_For_Ast * left_stmt = &(lhs->compile());
	Code_For_Ast * right_stmt = &(rhs->compile());
	Register_Addr_Opd * left_addr_opd = new Register_Addr_Opd(left_stmt->get_reg());
	Register_Addr_Opd * right_addr_opd = new Register_Addr_Opd(right_stmt->get_reg());
	Register_Descriptor * reg_new;
	Icode_Stmt * current_stmt;

	list<Icode_Stmt *> & icode_list = *new list<Icode_Stmt *>;
	icode_list = left_stmt->get_icode_list();
	icode_list.insert(icode_list.end(), right_stmt->get_icode_list().begin(), right_stmt->get_icode_list().end());

	if(get_data_type() == double_data_type){
		reg_new =  machine_desc_object.get_new_register<float_reg>();
		Register_Addr_Opd * result_opd = new Register_Addr_Opd(reg_new);
		current_stmt = new Compute_IC_Stmt(sub_d, left_addr_opd, right_addr_opd, result_opd);
	} 
	else if(get_data_type() == int_data_type){
		reg_new =  machine_desc_object.get_new_register<int_reg>();
		Register_Addr_Opd * result_opd = new Register_Addr_Opd(reg_new);
		current_stmt = new Compute_IC_Stmt(sub, left_addr_opd, right_addr_opd, result_opd);
	}

	Code_For_Ast *minus_stmt = new Code_For_Ast(icode_list, reg_new);
	minus_stmt->append_ics(*current_stmt);
	minus_stmt->set_reg(reg_new);
	
	left_stmt->get_reg()->reset_register_occupied();
	right_stmt->get_reg()->reset_register_occupied();

	return *minus_stmt;
}

Code_For_Ast & Divide_Ast::compile(){
	Code_For_Ast * left_stmt = &(lhs->compile());
	Code_For_Ast * right_stmt = &(rhs->compile());
	Register_Addr_Opd * left_addr_opd = new Register_Addr_Opd(left_stmt->get_reg());
	Register_Addr_Opd * right_addr_opd = new Register_Addr_Opd(right_stmt->get_reg());
	Register_Descriptor * reg_new;
	Icode_Stmt * current_stmt;

	list<Icode_Stmt *> & icode_list = *new list<Icode_Stmt *>;
	icode_list = left_stmt->get_icode_list();
	icode_list.insert(icode_list.end(), right_stmt->get_icode_list().begin(), right_stmt->get_icode_list().end());

	if(get_data_type() == double_data_type){
		reg_new =  machine_desc_object.get_new_register<float_reg>();
		Register_Addr_Opd * result_opd = new Register_Addr_Opd(reg_new);
		current_stmt = new Compute_IC_Stmt(div_d, left_addr_opd, right_addr_opd, result_opd);
	} 
	else if(get_data_type() == int_data_type){
		reg_new =  machine_desc_object.get_new_register<int_reg>();
		Register_Addr_Opd * result_opd = new Register_Addr_Opd(reg_new);
		current_stmt = new Compute_IC_Stmt(divd, left_addr_opd, right_addr_opd, result_opd);
	}

	Code_For_Ast *divide_stmt = new Code_For_Ast(icode_list, reg_new);
	divide_stmt->append_ics(*current_stmt);
	divide_stmt->set_reg(reg_new);
	
	left_stmt->get_reg()->reset_register_occupied();
	right_stmt->get_reg()->reset_register_occupied();

	return *divide_stmt;
}

Code_For_Ast & Mult_Ast::compile(){
	Code_For_Ast * left_stmt = &(lhs->compile());
	Code_For_Ast * right_stmt = &(rhs->compile());
	Register_Addr_Opd * left_addr_opd = new Register_Addr_Opd(left_stmt->get_reg());
	Register_Addr_Opd * right_addr_opd = new Register_Addr_Opd(right_stmt->get_reg());
	Register_Descriptor * reg_new;
	Icode_Stmt * current_stmt;

	list<Icode_Stmt *> & icode_list = *new list<Icode_Stmt *>;
	icode_list = left_stmt->get_icode_list();
	icode_list.insert(icode_list.end(), right_stmt->get_icode_list().begin(), right_stmt->get_icode_list().end());

	if(get_data_type() == double_data_type){
		reg_new =  machine_desc_object.get_new_register<float_reg>();
		Register_Addr_Opd * result_opd = new Register_Addr_Opd(reg_new);
		current_stmt = new Compute_IC_Stmt(mult_d, left_addr_opd, right_addr_opd, result_opd);
	} 
	else if(get_data_type() == int_data_type){
		reg_new =  machine_desc_object.get_new_register<int_reg>();
		Register_Addr_Opd * result_opd = new Register_Addr_Opd(reg_new);
		current_stmt = new Compute_IC_Stmt(mult, left_addr_opd, right_addr_opd, result_opd);
	}

	Code_For_Ast *mult_stmt = new Code_For_Ast(icode_list, reg_new);
	mult_stmt->append_ics(*current_stmt);
	mult_stmt->set_reg(reg_new);
	
	left_stmt->get_reg()->reset_register_occupied();
	right_stmt->get_reg()->reset_register_occupied();

	return *mult_stmt;
}

Code_For_Ast & UMinus_Ast::compile(){
	Code_For_Ast * left_stmt = &(lhs->compile());
	Register_Addr_Opd * left_addr_opd = new Register_Addr_Opd(left_stmt->get_reg());
	Register_Descriptor * reg_new;
	Icode_Stmt * current_stmt;

	list<Icode_Stmt *> & icode_list = *new list<Icode_Stmt *>;
	icode_list = left_stmt->get_icode_list();

	if(get_data_type() == double_data_type){
		reg_new =  machine_desc_object.get_new_register<float_reg>();
		Register_Addr_Opd * result_opd = new Register_Addr_Opd(reg_new);
		current_stmt = new Compute_IC_Stmt(uminus_d, left_addr_opd, NULL, result_opd);
	} 
	else if(get_data_type() == int_data_type){
		reg_new =  machine_desc_object.get_new_register<int_reg>();
		Register_Addr_Opd * result_opd = new Register_Addr_Opd(reg_new);
		current_stmt = new Compute_IC_Stmt(uminus, left_addr_opd, NULL, result_opd);
	}
	
	Code_For_Ast *uminus_stmt = new Code_For_Ast(icode_list, reg_new);
	uminus_stmt->append_ics(*current_stmt);
	uminus_stmt->set_reg(reg_new);

	left_stmt->get_reg()->reset_register_occupied();

	return *uminus_stmt;
}

Code_For_Ast & Conditional_Expression_Ast::compile(){
	//Not done
}

Code_For_Ast & Relational_Expr_Ast::compile(){
	Code_For_Ast * left_stmt = &(lhs_condition->compile());
	Code_For_Ast * right_stmt = &(rhs_condition->compile());
	Register_Addr_Opd * left_addr_opd = new Register_Addr_Opd(left_stmt->get_reg());
	Register_Addr_Opd * right_addr_opd = new Register_Addr_Opd(right_stmt->get_reg());
	Register_Descriptor * reg_new;
	Icode_Stmt * current_stmt;

	list<Icode_Stmt *> & icode_list = *new list<Icode_Stmt *>;
	icode_list = left_stmt->get_icode_list();
	icode_list.insert(icode_list.end(), right_stmt->get_icode_list().begin(), right_stmt->get_icode_list().end());

	reg_new =  machine_desc_object.get_new_register<int_reg>();
	Register_Addr_Opd * result_opd = new Register_Addr_Opd(reg_new);

	Tgt_Op operand;
	if (lhs_condition->get_data_type() == double_data_type){
		if (this->rel_op == less_equalto) operand = sle_d;
		else if (this->rel_op == less_than) operand = slt_d;
		else if (this->rel_op == greater_than) operand = sgt_d;
		else if (this->rel_op == greater_equalto) operand = sge_d;
		else if (this->rel_op == equalto) operand = seq_d;
		else if (this->rel_op == not_equalto) operand = sne_d;
	}
	else if (lhs_condition->get_data_type() == int_data_type){
		if (this->rel_op == less_equalto) operand = sle;
		else if (this->rel_op == less_than) operand = slt;
		else if (this->rel_op == greater_than) operand = sgt;
		else if (this->rel_op == greater_equalto) operand = sge;
		else if (this->rel_op == equalto) operand = seq;
		else if (this->rel_op == not_equalto) operand = sne;
	}
	current_stmt = new Compute_IC_Stmt(operand, left_addr_opd, right_addr_opd, result_opd);

	Code_For_Ast *plus_stmt = new Code_For_Ast(icode_list, reg_new);
	plus_stmt->append_ics(*current_stmt);
	plus_stmt->set_reg(reg_new);
	
	left_stmt->get_reg()->reset_register_occupied();
	right_stmt->get_reg()->reset_register_occupied();

	return *plus_stmt;
}

Code_For_Ast & Logical_Expr_Ast::compile(){
	Code_For_Ast * left_stmt = &(lhs_op->compile());
	Code_For_Ast * right_stmt = &(rhs_op->compile());
	Register_Addr_Opd * left_addr_opd = new Register_Addr_Opd(left_stmt->get_reg());
	Register_Addr_Opd * right_addr_opd = new Register_Addr_Opd(right_stmt->get_reg());
	Register_Descriptor * reg_new;
	Icode_Stmt * current_stmt;

	list<Icode_Stmt *> & icode_list = *new list<Icode_Stmt *>;
	icode_list = left_stmt->get_icode_list();

	reg_new =  machine_desc_object.get_new_register<int_reg>();
	Register_Addr_Opd * result_opd = new Register_Addr_Opd(reg_new);

	if (this->bool_op == _logical_and) current_stmt = new Compute_IC_Stmt(and_t, left_addr_opd, right_addr_opd, result_opd);
	else if (this->bool_op == _logical_or) current_stmt = new Compute_IC_Stmt(or_t, left_addr_opd, right_addr_opd, result_opd);
	else if (this->bool_op == _logical_not) current_stmt = new Compute_IC_Stmt(not_t, NULL, right_addr_opd, result_opd);

	Code_For_Ast *logical_stmt = new Code_For_Ast(icode_list, reg_new);
	logical_stmt->append_ics(*current_stmt);
	logical_stmt->set_reg(reg_new);
	
	left_stmt->get_reg()->reset_register_occupied();
	right_stmt->get_reg()->reset_register_occupied();

	return *logical_stmt;
}

Code_For_Ast & Selection_Statement_Ast::compile(){
	string l0 = get_new_label();
	string l1 = get_new_label();
	Label_IC_Stmt * label_stmt0 = new Label_IC_Stmt(label, l0);
	Code_For_Ast * select_ast;
	list<Icode_Stmt *> & icode_list = *new list<Icode_Stmt *>;

	Code_For_Ast & cond_stmt = cond->compile();
	Code_For_Ast & then_stmt = then_part->compile();
	icode_list = cond_stmt.get_icode_list();

	Register_Addr_Opd * cond_reg_opd = new Register_Addr_Opd(cond_stmt.get_reg());
	Control_Flow_IC_Stmt * ctrl_stmt0 = new Control_Flow_IC_Stmt(beq, cond_reg_opd, NULL, l0);
	icode_list.push_back(ctrl_stmt0);
	icode_list.insert(icode_list.end(), then_stmt.get_icode_list().begin(), then_stmt.get_icode_list().end());

	if(else_part != NULL)
	{	
		Code_For_Ast & else_stmt = else_part->compile();
		
		Control_Flow_IC_Stmt * ctrl_stmt1 = new Control_Flow_IC_Stmt(j, NULL, NULL, l1);
		icode_list.push_back(ctrl_stmt1);
		icode_list.push_back(label_stmt0);
		icode_list.insert(icode_list.end(), else_stmt.get_icode_list().begin(), else_stmt.get_icode_list().end());

		Label_IC_Stmt * label_stmt1 = new Label_IC_Stmt(label, l1);
		icode_list.push_back(label_stmt1);
	}
	else icode_list.push_back(label_stmt0);	

	select_ast = new Code_For_Ast(icode_list, NULL);
	cond_stmt.get_reg()->reset_use_for_expr_result();
	return *select_ast;
}

Code_For_Ast & Iteration_Statement_Ast::compile(){
	string l0 = get_new_label();
	string l1 = get_new_label();
	Label_IC_Stmt * label_stmt0 = new Label_IC_Stmt(label, l0);
	Label_IC_Stmt * label_stmt1 = new Label_IC_Stmt(label, l1);
	Code_For_Ast & cond_stmt = cond->compile();
	Code_For_Ast & body_stmt = body->compile();

	list<Icode_Stmt *> & icode_list = *new list<Icode_Stmt *>;
	Code_For_Ast * iter_ast;

	if(!is_do_form){
		Control_Flow_IC_Stmt * ctrl_stmt1 = new Control_Flow_IC_Stmt(j, NULL, NULL, l1);
		icode_list.push_back(ctrl_stmt1);
	}
	icode_list.push_back(label_stmt0);
	if(body_stmt.get_icode_list().empty() != true)
		icode_list.insert(icode_list.end(), body_stmt.get_icode_list().begin(), body_stmt.get_icode_list().end());
	icode_list.push_back(label_stmt1);
	icode_list.insert(icode_list.end(), cond_stmt.get_icode_list().begin(), cond_stmt.get_icode_list().end());

	iter_ast = new Code_For_Ast(icode_list, NULL);
	Register_Addr_Opd * cond_reg_opd = new Register_Addr_Opd(cond_stmt.get_reg());
	Control_Flow_IC_Stmt * ctrl_stmt0 = new Control_Flow_IC_Stmt(bne, cond_reg_opd, NULL, l0);
	iter_ast->append_ics(*ctrl_stmt0);

	cond_stmt.get_reg()->reset_use_for_expr_result();
	return *iter_ast;
}

Code_For_Ast & Sequence_Ast::compile(){
	for(list<Ast *>::iterator it = statement_list.begin(); it!=statement_list.end(); it++) {
		Code_For_Ast & temp_stmt = (*it)->compile();
		sa_icode_list.insert(sa_icode_list.end(), temp_stmt.get_icode_list().begin(), temp_stmt.get_icode_list().end());
	}

	Code_For_Ast * sequence_stmt = new Code_For_Ast(sa_icode_list, NULL);
	return *sequence_stmt;
}

void Sequence_Ast::print_assembly(ostream & file_buffer){
	for(list<Icode_Stmt *>::iterator it = sa_icode_list.begin(); it!=sa_icode_list.end(); it++) 
		(*it)->print_assembly(file_buffer);
}

void Sequence_Ast::print_icode(ostream & file_buffer){
	for(list<Icode_Stmt *>::iterator it = sa_icode_list.begin(); it!=sa_icode_list.end(); it++) 
		(*it)->print_icode(file_buffer);
}

Code_For_Ast & Print_Ast::compile(){
	Print_IC_Stmt * print_stmt = new Print_IC_Stmt();
	Move_IC_Stmt * constant;
	Move_IC_Stmt * variable;
	list<Icode_Stmt * > & icode_list = *new list<Icode_Stmt *>;

	Register_Descriptor * reg_new;
	Register_Addr_Opd * print_opd = new Register_Addr_Opd(reg_new);

	if(var->get_symbol_entry().get_data_type() == double_data_type)
	{
		reg_new = machine_desc_object.get_new_register<int_reg>();
		constant = new Move_IC_Stmt(imm_load, new Const_Opd<int>(3), print_opd);
		icode_list.push_back(constant);
		variable = new Move_IC_Stmt(load_d, new Mem_Addr_Opd(var->get_symbol_entry()), new Register_Addr_Opd(machine_desc_object.spim_register_table[f12]));
		icode_list.push_back(variable);
	}
	else
	{
		reg_new = machine_desc_object.get_new_register<int_reg>();
		constant = new Move_IC_Stmt(imm_load, new Const_Opd<int>(1), print_opd);
		icode_list.push_back(constant);
		variable = new Move_IC_Stmt(load, new Mem_Addr_Opd(var->get_symbol_entry()), new Register_Addr_Opd(machine_desc_object.spim_register_table[a0]));
		icode_list.push_back(variable);
	}

	icode_list.push_back(print_stmt);
	Code_For_Ast * return_ast = new Code_For_Ast(icode_list, NULL);
	return *return_ast;
}

Code_For_Ast & UMinus_Ast::compile_and_optimize_ast(Lra_Outcome & lra){}
Code_For_Ast & Mult_Ast::compile_and_optimize_ast(Lra_Outcome & lra){}
Code_For_Ast & Divide_Ast::compile_and_optimize_ast(Lra_Outcome & lra){}
Code_For_Ast & Minus_Ast::compile_and_optimize_ast(Lra_Outcome & lra){}
Code_For_Ast & Plus_Ast::compile_and_optimize_ast(Lra_Outcome & lra){}
Code_For_Ast & Name_Ast::compile_and_optimize_ast(Lra_Outcome & lra){}
template<class T>Code_For_Ast & Number_Ast<T>::compile_and_optimize_ast(Lra_Outcome & lra){}
Code_For_Ast & Assignment_Ast::compile_and_optimize_ast(Lra_Outcome & lra){}

Code_For_Ast & Return_Ast::compile(){}
Code_For_Ast & Return_Ast::compile_and_optimize_ast(Lra_Outcome & lra){}
Code_For_Ast & Call_Ast::compile(){}
Code_For_Ast & Call_Ast::compile_and_optimize_ast(Lra_Outcome & lra){}