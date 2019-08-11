#include "ast.hh"
#include <stdlib.h>
template class Number_Ast<double>;
template class Number_Ast<int>;

Eval_Result & Ast::get_value_of_evaluation(Local_Environment & eval_env){}
void Ast::set_value_of_evaluation(Local_Environment & eval_env, Eval_Result & result){}
void Ast::print_value(Local_Environment & eval_env, ostream & file_buffer){}

Eval_Result & Assignment_Ast::evaluate(Local_Environment & eval_env, ostream & file_buffer){
	Eval_Result * right = &(rhs->evaluate(eval_env, file_buffer));
	lhs->set_value_of_evaluation(eval_env, *right);
	this->print(file_buffer);
	string var_name = lhs->get_symbol_entry().get_variable_name();
	if(!right->is_variable_defined()) 
		file_buffer <<"\n"<<VAR_SPACE <<var_name <<" : undefined\n\n";
	else if(right->get_result_enum() == int_result) 
		file_buffer <<"\n"<<VAR_SPACE <<var_name <<" : "<<right->get_int_value() <<"\n\n";
	else if(right->get_result_enum() == double_result) 
		file_buffer <<"\n"<<VAR_SPACE <<var_name <<" : "<<right->get_double_value() <<"\n\n";
	else printf("cs316: Error, variable not found");
}

Eval_Result & Name_Ast::evaluate(Local_Environment & eval_env, ostream & file_buffer){
	string name = variable_symbol_entry->get_variable_name();
	if (eval_env.does_variable_exist(name)){
		if(eval_env.is_variable_defined(name)) return *eval_env.get_variable_value(name);  
	}
	else if (interpreter_global_table.does_variable_exist(name)){
		return *interpreter_global_table.get_variable_value(name);
	}
	else printf("cs 316: Error, variable not found");
}

void Name_Ast:: print_value(Local_Environment & eval_env, ostream & file_buffer){}

Eval_Result & Name_Ast:: get_value_of_evaluation(Local_Environment & eval_env)
{
	string name = variable_symbol_entry->get_variable_name();
	if (eval_env.does_variable_exist(name)){
		if(eval_env.is_variable_defined(name)) return *eval_env.get_variable_value(name);  
	}
	else if (interpreter_global_table.does_variable_exist(name)){
		return *interpreter_global_table.get_variable_value(name);
	}
	else printf("cs 316: Error, variable not found");
}

void Name_Ast::set_value_of_evaluation(Local_Environment & eval_env, Eval_Result & result)
{
	string name = variable_symbol_entry->get_variable_name();
	if (eval_env.does_variable_exist(name)){
		eval_env.put_variable_value(result, name);  
	}
	else if (interpreter_global_table.does_variable_exist(name)){
		interpreter_global_table.put_variable_value(result, name);
	}
	else printf("cs 316: Error, variable not found");
}

template <typename T>
Eval_Result & Number_Ast<T>::evaluate(Local_Environment & eval_env, ostream & file_buffer){
	if(this->node_data_type == int_data_type){
		Eval_Result_Value_Int * result = new Eval_Result_Value_Int();
		result->set_variable_status(true);
		result->set_result_enum(int_result);
		result->set_value(constant);
		return *result;
	}
	if(this->node_data_type == double_data_type){
		Eval_Result_Value_Double * result = new Eval_Result_Value_Double();
		result->set_variable_status(true);
		result->set_result_enum(double_result);
		result->set_value(constant);
		return *result;
	}	
}

Eval_Result & Plus_Ast::evaluate(Local_Environment & eval_env, ostream & file_buffer){
	Eval_Result * left = &(lhs->evaluate(eval_env, file_buffer));
	Eval_Result * right = &(rhs->evaluate(eval_env, file_buffer));
	Result_Enum left_type = left->get_result_enum();
	Result_Enum right_type = right->get_result_enum();

	if (left_type != right_type){
		printf("cs316: Error, data types incompatible for addition\n");
	}
	if (left_type == int_result)
	{
		Eval_Result_Value_Int * result = new Eval_Result_Value_Int();
		result->set_value(left->get_int_value() + right->get_int_value());
		return *result;
	}
	if (left_type == double_result)
	{
		Eval_Result_Value_Double * result = new Eval_Result_Value_Double();
		result->set_value(left->get_double_value() + right->get_double_value());
		return *result;
	}
}
Eval_Result & Minus_Ast::evaluate(Local_Environment & eval_env, ostream & file_buffer){
	Eval_Result * left = &(lhs->evaluate(eval_env, file_buffer));
	Eval_Result * right = &(rhs->evaluate(eval_env, file_buffer));
	Result_Enum left_type = left->get_result_enum();
	Result_Enum right_type = right->get_result_enum();

	if (left_type != right_type){
		printf("cs316: Error, data types incompatible for subtraction\n");
	}
	if (left_type == int_result)
	{
		Eval_Result_Value_Int * result = new Eval_Result_Value_Int();
		result->set_value(left->get_int_value() - right->get_int_value());
		return *result;
	}
	if (left_type == double_result)
	{
		Eval_Result_Value_Double * result = new Eval_Result_Value_Double();
		result->set_value(left->get_double_value() - right->get_double_value());
		return *result;
	}	
}

Eval_Result & Divide_Ast::evaluate(Local_Environment & eval_env, ostream & file_buffer){
	Eval_Result * left = &(lhs->evaluate(eval_env, file_buffer));
	Eval_Result * right = &(rhs->evaluate(eval_env, file_buffer));
	Result_Enum left_type = left->get_result_enum();
	Result_Enum right_type = right->get_result_enum();

	if (left_type != right_type){
		printf("cs316: Error, data types incompatible for division\n");
	}
	if (left_type == int_result)
	{
		Eval_Result_Value_Int * result = new Eval_Result_Value_Int();
		if(right->get_int_value() == 0) {printf("cs 316: Error, division by 0"); exit(0);}
		result->set_value(left->get_int_value() / right->get_int_value());
		return *result;
	}
	if (left_type == double_result)
	{
		Eval_Result_Value_Double * result = new Eval_Result_Value_Double();
		if(right->get_double_value() == 0.0) {printf("cs 316: Error, division by 0"); exit(0);}
		result->set_value(left->get_double_value() / right->get_double_value());
		return *result;
	}	
}
Eval_Result & Mult_Ast::evaluate(Local_Environment & eval_env, ostream & file_buffer){
	Eval_Result * left = &(lhs->evaluate(eval_env, file_buffer));
	Eval_Result * right = &(rhs->evaluate(eval_env, file_buffer));
	Result_Enum left_type = left->get_result_enum();
	Result_Enum right_type = right->get_result_enum();

	if (left_type != right_type){
		printf("cs316: Error, data types incompatible for multiplication\n");
	}
	if (left_type == int_result)
	{
		Eval_Result_Value_Int * result = new Eval_Result_Value_Int();
		result->set_value(left->get_int_value() * right->get_int_value());
		return *result;
	}
	if (left_type == double_result)
	{
		Eval_Result_Value_Double * result = new Eval_Result_Value_Double();
		result->set_value(left->get_double_value() * right->get_double_value());
		return *result;
	}	
}
Eval_Result & UMinus_Ast::evaluate(Local_Environment & eval_env, ostream & file_buffer){
	Eval_Result * left = &(lhs->evaluate(eval_env, file_buffer));
	Result_Enum left_type = left->get_result_enum();

	if (left_type == int_result)
	{
		Eval_Result_Value_Int * result = new Eval_Result_Value_Int();
		result->set_value(- left->get_int_value());
		return *result;
	}
	if (left_type == double_result)
	{
		Eval_Result_Value_Double * result = new Eval_Result_Value_Double();
		result->set_value(- left->get_double_value());
		return *result;
	}	
}


Eval_Result & Conditional_Expression_Ast::evaluate(Local_Environment & eval_env, ostream & file_buffer){
	Eval_Result * condition = &(cond->evaluate(eval_env, file_buffer));
	if(condition->get_int_value() == 1)  return lhs->evaluate(eval_env, file_buffer);
	else return rhs->evaluate(eval_env, file_buffer);
}

Eval_Result & Return_Ast::evaluate(Local_Environment & eval_env, ostream & file_buffer){}

Eval_Result & Relational_Expr_Ast::evaluate(Local_Environment & eval_env, ostream & file_buffer){
	Eval_Result * left = &(lhs_condition->evaluate(eval_env, file_buffer));
	Eval_Result * right = &(rhs_condition->evaluate(eval_env, file_buffer));
	Result_Enum left_type = left->get_result_enum();
	Result_Enum right_type = right->get_result_enum();

	if (left_type != right_type){
		printf("cs316: Error, data types incompatible for comparision\n");
		exit(0);
	}

	Eval_Result_Value_Int * result = new Eval_Result_Value_Int();
	if (left->get_result_enum() == int_result)
	{
		if (rel_op == less_equalto) result->set_value( (int) (left->get_int_value() <= right->get_int_value())) ;
		else if (rel_op == less_than) result->set_value( (int) (left->get_int_value() < right->get_int_value()) );
		else if (rel_op == greater_than) result->set_value( (int) (left->get_int_value() > right->get_int_value())) ;
		else if (rel_op == greater_equalto) result->set_value( (int) (left->get_int_value() >= right->get_int_value())) ;
		else if (rel_op == equalto) result->set_value( (int) (left->get_int_value() == right->get_int_value())) ;
		else if (rel_op == not_equalto) result->set_value( (int) (left->get_int_value() != right->get_int_value())) ;
	}
	else if (left->get_result_enum() == double_result)
	{
		if (rel_op == less_equalto) result->set_value( (int) (left->get_double_value() <= right->get_double_value()) );
		else if (rel_op == less_than) result->set_value( (int) (left->get_double_value() < right->get_double_value()) );
		else if (rel_op == greater_than) result->set_value( (int) (left->get_double_value() > right->get_double_value()) );
		else if (rel_op == greater_equalto) result->set_value( (int) (left->get_double_value() >= right->get_double_value()) );
		else if (rel_op == equalto) result->set_value( (int) (left->get_double_value() == right->get_double_value()) );
		else if (rel_op == not_equalto) result->set_value( (int) (left->get_double_value() != right->get_double_value()) );
	}
	return *result;
}

Eval_Result & Logical_Expr_Ast::evaluate(Local_Environment & eval_env, ostream & file_buffer){
	Eval_Result * left = &(lhs_op->evaluate(eval_env, file_buffer));
	Eval_Result * right = &(rhs_op->evaluate(eval_env, file_buffer));
	Eval_Result_Value_Int * result = new Eval_Result_Value_Int();

	if (bool_op == _logical_and) result->set_value( (int) (left->get_int_value() && right->get_int_value()) );
	else if (bool_op == _logical_or) result->set_value( (int) (left->get_int_value() || right->get_int_value()) );
	else if (bool_op == _logical_not) result->set_value( (int) (!right->get_int_value()) );

	return *result;
}

Eval_Result & Selection_Statement_Ast::evaluate(Local_Environment & eval_env, ostream & file_buffer){
	Eval_Result * condition = &(cond->evaluate(eval_env, file_buffer));
	if(condition->get_int_value())  then_part->evaluate(eval_env, file_buffer);
	else if (else_part != NULL) else_part->evaluate(eval_env, file_buffer);
}

Eval_Result & Iteration_Statement_Ast::evaluate(Local_Environment & eval_env, ostream & file_buffer){//in doubt
	Eval_Result_Value_Int * result = new Eval_Result_Value_Int();
	while( (cond->evaluate(eval_env, file_buffer)).get_int_value() == 1 ) body->evaluate(eval_env, file_buffer);
}

Eval_Result & Sequence_Ast::evaluate(Local_Environment & eval_env, ostream & file_buffer){
	for(list<Ast*>::iterator it = statement_list.begin(); it!=statement_list.end(); it++)
		(*it)->evaluate(eval_env, file_buffer);
}

Eval_Result & Call_Ast::evaluate(Local_Environment & eval_env, ostream & file_buffer){}
