#include "local-environment.hh"
#include <stdlib.h>
// Eval_Result::
void Symbol_Table:: create(Local_Environment & local_global_variables_table){
	list<Symbol_Table_Entry *> symbol_table_entries = this->variable_table;
	if (this->scope == global)
		for(list<Symbol_Table_Entry *>::iterator it = symbol_table_entries.begin(); it!=symbol_table_entries.end(); it++)
		{
			if((*it)->get_data_type() == int_data_type)
			{
				Eval_Result_Value_Int * result = new Eval_Result_Value_Int();
				result->set_result_enum(int_result);
				result->set_value((int)0);
				local_global_variables_table.put_variable_value(*result, (*it)->get_variable_name());
			}
			if((*it)->get_data_type() == double_data_type)
			{
				Eval_Result_Value_Double * result = new Eval_Result_Value_Double();
				result->set_result_enum(double_result);
				result->set_value((double)0.0);
				local_global_variables_table.put_variable_value(*result, (*it)->get_variable_name());
			}	
		}
	else
		for(list<Symbol_Table_Entry *>::iterator it = symbol_table_entries.begin(); it!=symbol_table_entries.end(); it++)
		{
			if((*it)->get_data_type() == int_data_type)
			{
				Eval_Result_Value_Int * result = new Eval_Result_Value_Int();
				result->set_result_enum(int_result);
				local_global_variables_table.put_variable_value(*result, (*it)->get_variable_name());
			}
			if((*it)->get_data_type() == double_data_type)
			{
				Eval_Result_Value_Double * result = new Eval_Result_Value_Double();
				result->set_result_enum(double_result);
				local_global_variables_table.put_variable_value(*result, (*it)->get_variable_name());
			}	
		}
}

Local_Environment::Local_Environment(){variable_table.clear();}
Local_Environment::~Local_Environment(){}

int Eval_Result::get_int_value(){}
void Eval_Result::set_value(int value){}
double Eval_Result::get_double_value(){}
void Eval_Result::set_value(double value){}
bool Eval_Result::is_variable_defined(){}
void Eval_Result::set_variable_status(bool def){}

void Eval_Result_Value::set_value(int number){}
void Eval_Result_Value::set_value(double number){}
int Eval_Result_Value::get_int_value(){}
double Eval_Result_Value::get_double_value(){}


Eval_Result_Value_Int::Eval_Result_Value_Int(){defined = false;}
void Eval_Result_Value_Int::set_value(int number){
	defined = true;
	result_type = int_result;
	value = number;
}
void Eval_Result_Value_Int::set_value(double number){return;}
int Eval_Result_Value_Int::get_int_value(){return value;}
void Eval_Result_Value_Int::set_variable_status(bool def){defined = def;}
bool Eval_Result_Value_Int::is_variable_defined(){return defined;}
void Eval_Result_Value_Int::set_result_enum(Result_Enum res){result_type = res;}
Result_Enum Eval_Result_Value_Int::get_result_enum(){return result_type;}


Eval_Result_Value_Double::Eval_Result_Value_Double(){defined = false;}
void Eval_Result_Value_Double::set_value(int number){return;}
void Eval_Result_Value_Double::set_value(double number){
	defined = true;
	result_type = double_result;
	value = number;
}
double Eval_Result_Value_Double::get_double_value(){return value;}
void Eval_Result_Value_Double::set_variable_status(bool def){defined = def;}
bool Eval_Result_Value_Double::is_variable_defined(){return defined;}
void Eval_Result_Value_Double::set_result_enum(Result_Enum res){result_type = res;}
Result_Enum Eval_Result_Value_Double::get_result_enum(){return result_type;}

void Local_Environment::print(ostream & file_buffer){
	for(map<string, Eval_Result *>::iterator it = variable_table.begin(); it!=variable_table.end(); it++)
	{
		if(it->second->is_variable_defined()){
			if(it->second->get_result_enum() == int_result) file_buffer << VAR_SPACE << it->first <<" : " << it->second->get_int_value();
			if(it->second->get_result_enum() == double_result) file_buffer << VAR_SPACE << it->first <<" : " << it->second->get_double_value();
		}
		else file_buffer << VAR_SPACE <<it->first <<" : " << "undefined";
		file_buffer <<"\n";
	}
}
bool Local_Environment::is_variable_defined(string name){
	return variable_table[name]->is_variable_defined();
}
Eval_Result * Local_Environment::get_variable_value(string name){
	return variable_table[name];
}
void Local_Environment::put_variable_value(Eval_Result & value, string name){
	variable_table[name] = &value;
}
bool Local_Environment::does_variable_exist(string name){
	return variable_table.find(name)!= variable_table.end();
}