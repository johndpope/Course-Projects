%{
	#include <stdio.h>
	extern "C" void yyerror (char *);
	extern int yylex (void);
	extern int yylineno;
	Symbol_Table  * global_symbol_table;
	Symbol_Table  * local_symbol_table;
	Procedure * curr_proc;
%}
%union {
	int integer_value;
	double double_value;
	std::string * string_value;
	list<Ast *> * ast_list;
	list<Data_Type> * list_of_data_type;
	Ast * ast;
	Symbol_Table * symbol_table;
	Symbol_Table_Entry * symbol_entry;
	list<Symbol_Table_Entry *> * symbol_entry_list;
	Basic_Block * basic_block;
	Procedure * procedure;
	Program * program_object;
	pair<Data_Type,string>* arg;
	list< pair<Data_Type,string> > * arg_list;
}
%token<double_value> FNUM
%token<integer_value> NUM
%token<string_value> NAME
%token VOID INTEGER FLOAT ASSIGN DO WHILE IF ELSE PRINT RETURN
%right ASSIGN
%right '?'
%left OR 
%left AND 
%left EQUAL NOT_EQUAL 
%left LESS_THAN GREATER_THAN LESS_THAN_EQUAL GREATER_THAN_EQUAL
%left '+' '-'
%left '*' '/'
%right UMINUS
%left NOT
%type<program_object> program
%type<procedure> procedure_definition procedure_declaration
%type<symbol_table> optional_variable_declaration_list declaration_list variable_declaration_list variable_declaration variable_declaration_list_global
%type<symbol_entry_list> variable_list
%type<ast_list> statement_list parameter_list parameters
%type<ast> assignment_statement print_statement expression variable constant function
%type<ast> conditional_statement then_statement condition single_condition function_statement return_statement
%type<arg> argument
%type<arg_list> argument_list optional_argument_list
%type<list_of_data_type> optional_declaration_list optional_declarations

%%

program	:	declaration_list
			procedure_declaration_list
			{
				cout <<"cs316: Error, procedure can't be declared\n";
			}
			procedure_definition_list
			{
				global_symbol_table->set_table_scope(global);
				program_object.set_global_table(* global_symbol_table);
				cout <<"cs316: Error, procedure could not be defined\n";
			}
			;

procedure_definition_list:	procedure_definition
							|	procedure_definition_list procedure_definition
							;
procedure_declaration_list:	procedure_declaration
							|	procedure_declaration_list procedure_declaration
							;

procedure_definition:	VOID NAME '(' optional_argument_list ')'
              	   		'{'
						optional_variable_declaration_list
                        statement_list
    	           		'}'
    	           		{
    	           			$7->set_table_scope(local);
    	           			Procedure * proc = new Procedure(void_data_type, * $2, yylineno);

    	           			Symbol_Table * opt_arg_list = new Symbol_Table();
    	           			list<pair<Data_Type,string> >* optional_list  = $4;
							for(list<pair<Data_Type,string>>::iterator it = optional_list->begin(); it!=optional_list->end(); it++)
							{
								Symbol_Table_Entry * st_var = new Symbol_Table_Entry(it->second, it->first, yylineno);
								opt_arg_list->push_symbol(st_var);
							}

    	           			proc->set_formal_param_list(*opt_arg_list);
    	           			proc->set_local_list(*$7);
    	           			proc->set_ast_list(*$8);
    	           			curr_proc = proc;
    	           			program_object.set_proc_to_map(*$2, proc);
    	           			$$ = proc;
    	           		}
    	           		|	INTEGER NAME '(' optional_argument_list ')'
              	   		'{'
						optional_variable_declaration_list
                        statement_list
    	           		'}'
    	           		{
    	           			$7->set_table_scope(local);
    	           			Procedure * proc = new Procedure(int_data_type, * $2, yylineno);

    	           			Symbol_Table * opt_arg_list = new Symbol_Table();
    	           			list<pair<Data_Type,string> >* optional_list  = $4;
							for(list<pair<Data_Type,string>>::iterator it = optional_list->begin(); it!=optional_list->end(); it++)
							{
								Symbol_Table_Entry * st_var = new Symbol_Table_Entry(it->second, it->first, yylineno);
								opt_arg_list->push_symbol(st_var);
							}

    	           			proc->set_formal_param_list(*opt_arg_list);
    	           			proc->set_local_list(*$7);
    	           			proc->set_ast_list(*$8);
    	           			curr_proc = proc;
    	           			program_object.set_proc_to_map(*$2, proc);
    	           			$$ = proc;
    	           		}
    	           		|	FLOAT NAME '(' optional_argument_list ')'
              	   		'{'
						optional_variable_declaration_list
                        statement_list
    	           		'}'
    	           		{
    	           			$7->set_table_scope(local);
    	           			Procedure * proc = new Procedure(double_data_type, * $2, yylineno);

    	           			Symbol_Table * opt_arg_list = new Symbol_Table();
    	           			list<pair<Data_Type,string> >* optional_list  = $4;
							for(list<pair<Data_Type,string>>::iterator it = optional_list->begin(); it!=optional_list->end(); it++)
							{
								Symbol_Table_Entry * st_var = new Symbol_Table_Entry(it->second, it->first, yylineno);
								opt_arg_list->push_symbol(st_var);
							}

    	           			proc->set_formal_param_list(*opt_arg_list);
    	           			proc->set_local_list(*$7);
    	           			proc->set_ast_list(*$8);
    	           			curr_proc = proc;
    	           			program_object.set_proc_to_map(*$2, proc);
    	           			$$ = proc;
    	           		}
    	           		;

declaration_list:	//empty
					{
						Symbol_Table * gl_table = new Symbol_Table();
						program_object.set_global_table(* gl_table);
						gl_table->set_table_scope(global);
						$$ = gl_table;
						exit(0);
					}
					|	variable_declaration_list_global
					{
						program_object.set_global_table(*$1);
						$1->set_table_scope(global);
						global_symbol_table = $1;
						$$ = $1;
						exit(0);
					}
					; 

procedure_declaration:	VOID NAME '(' optional_declaration_list ')' ';'
    	           		{
    	           			Procedure * proc = new Procedure(void_data_type, * $2, yylineno);

    	           			Symbol_Table * opt_arg_list = new Symbol_Table();
    	           			list<Data_Type>* optional_list  = $4;
    	           			int dummy_count = 0;
							for(list<Data_Type>::iterator it = optional_list->begin(); it!=optional_list->end(); it++)
							{
								string name = "dummy"+to_string(dummy_count);
								Symbol_Table_Entry * st_var = new Symbol_Table_Entry(name, (*it), yylineno);
								opt_arg_list->push_symbol(st_var);
								dummy_count++;
							}

    	           			proc->set_formal_param_list(*opt_arg_list);
    	           			curr_proc = proc;
    	           			program_object.set_proc_to_map(*$2, proc);
    	           			$$ = proc;
    	           		}
    	           		|	VOID NAME '(' optional_argument_list ')' ';'
    	           		{
    	           			Procedure * proc = new Procedure(void_data_type, * $2, yylineno);

    	           			int dummy_count = 0;
    	           			Symbol_Table * opt_arg_list = new Symbol_Table();
    	           			list<pair<Data_Type,string> >* optional_list  = $4;
							for(list<pair<Data_Type,string>>::iterator it = optional_list->begin(); it!=optional_list->end(); it++)
							{
								string name = "dummy"+to_string(dummy_count);
								Symbol_Table_Entry * st_var = new Symbol_Table_Entry(name, it->first, yylineno);
								opt_arg_list->push_symbol(st_var);
								dummy_count++;
							}

    	           			proc->set_formal_param_list(*opt_arg_list);
    	           			curr_proc = proc;
    	           			program_object.set_proc_to_map(*$2, proc);
    	           			$$ = proc;
    	           		}
    	           		|	INTEGER NAME '(' optional_declaration_list ')' ';'
    	           		{
    	           			Procedure * proc = new Procedure(int_data_type, * $2, yylineno);

    	           			Symbol_Table * opt_arg_list = new Symbol_Table();
    	           			list<Data_Type>* optional_list  = $4;
    	           			int dummy_count = 0;
							for(list<Data_Type>::iterator it = optional_list->begin(); it!=optional_list->end(); it++)
							{
								string name = "dummy"+to_string(dummy_count);
								Symbol_Table_Entry * st_var = new Symbol_Table_Entry(name, (*it), yylineno);
								opt_arg_list->push_symbol(st_var);
								dummy_count++;
							}

    	           			proc->set_formal_param_list(*opt_arg_list);
    	           			curr_proc = proc;
    	           			program_object.set_proc_to_map(*$2, proc);
    	           			$$ = proc;
    	           		}
    	           		|	INTEGER NAME '(' optional_argument_list ')' ';'
    	           		{
    	           			Procedure * proc = new Procedure(int_data_type, * $2, yylineno);

    	           			int dummy_count = 0;
    	           			Symbol_Table * opt_arg_list = new Symbol_Table();
    	           			list<pair<Data_Type,string> >* optional_list  = $4;
							for(list<pair<Data_Type,string>>::iterator it = optional_list->begin(); it!=optional_list->end(); it++)
							{
								string name = "dummy"+to_string(dummy_count);
								Symbol_Table_Entry * st_var = new Symbol_Table_Entry(name, it->first, yylineno);
								opt_arg_list->push_symbol(st_var);
								dummy_count++;
							}

    	           			proc->set_formal_param_list(*opt_arg_list);
    	           			curr_proc = proc;
    	           			program_object.set_proc_to_map(*$2, proc);
    	           			$$ = proc;
    	           		}
    	           		|	FLOAT NAME '(' optional_declaration_list ')' ';'
    	           		{
    	           			Procedure * proc = new Procedure(double_data_type, * $2, yylineno);

    	           			Symbol_Table * opt_arg_list = new Symbol_Table();
    	           			list<Data_Type>* optional_list  = $4;
    	           			int dummy_count = 0;
							for(list<Data_Type>::iterator it = optional_list->begin(); it!=optional_list->end(); it++)
							{
								string name = "dummy"+to_string(dummy_count);
								Symbol_Table_Entry * st_var = new Symbol_Table_Entry(name, (*it), yylineno);
								opt_arg_list->push_symbol(st_var);
								dummy_count++;
							}

    	           			proc->set_formal_param_list(*opt_arg_list);
    	           			curr_proc = proc;
    	           			program_object.set_proc_to_map(*$2, proc);
    	           			$$ = proc;
    	           		}
    	           		|	FLOAT NAME '(' optional_argument_list ')' ';'
    	           		{
    	           			Procedure * proc = new Procedure(double_data_type, * $2, yylineno);

    	           			int dummy_count = 0;
    	           			Symbol_Table * opt_arg_list = new Symbol_Table();
    	           			list<pair<Data_Type,string> >* optional_list  = $4;
							for(list<pair<Data_Type,string>>::iterator it = optional_list->begin(); it!=optional_list->end(); it++)
							{
								string name = "dummy"+to_string(dummy_count);
								Symbol_Table_Entry * st_var = new Symbol_Table_Entry(name, it->first, yylineno);
								opt_arg_list->push_symbol(st_var);
								dummy_count++;
							}

    	           			proc->set_formal_param_list(*opt_arg_list);
    	           			curr_proc = proc;
    	           			program_object.set_proc_to_map(*$2, proc);
    	           			$$ = proc;
    	           		}
    	           		;

optional_declaration_list:	// empty
						{
							list<Data_Type>* optional_list = new list<Data_Type>;
							$$ = optional_list;
						}
						|	optional_declarations
						{
						}
						;

optional_declarations:	INTEGER
						{
							list<Data_Type>* arg = new list<Data_Type>;
							arg->push_back(int_data_type);
							$$ = arg;
						}
						|	FLOAT
						{
							list<Data_Type>* arg = new list<Data_Type>;
							arg->push_back(double_data_type);
							$$ = arg;
						}
						|	optional_declarations ',' INTEGER
						{
							list<Data_Type>* list_of_args = $1;
							list_of_args->push_back(int_data_type);
							$$ = list_of_args;
						}
						|	optional_declarations ',' FLOAT
						{
							list<Data_Type>* list_of_args = $1;
							list_of_args->push_back(double_data_type);
							$$ = list_of_args;
						}
						;

optional_argument_list:	// empty
						{
							list<pair<Data_Type,string> >* optional_list = new list<pair<Data_Type,string> >;
							$$ = optional_list;
						}
						|	argument_list
						{
						}
						;

argument_list:	argument
				{
					list<pair<Data_Type,string> >* arg = new list<pair<Data_Type,string> >;
					arg->push_back(*$1);
					$$ = arg;
				}
				|	argument_list ',' argument
				{
					list<pair<Data_Type,string> >* list_of_args = $1;
					list_of_args->push_back(*$3);
					$$ = list_of_args;
				}
				;

argument:	INTEGER	NAME
			{
				pair<Data_Type,string>* arg = new pair<Data_Type,string>;
				arg->first = int_data_type;
				arg->second = *$2;
				$$ = arg;
			}
			|	FLOAT NAME
			{
				pair<Data_Type,string>* arg = new pair<Data_Type,string>;
				arg->first = double_data_type;
				arg->second = *$2;
				$$ = arg;
			}
			;

optional_variable_declaration_list	:	//empty
										{
											Symbol_Table * op_list = new Symbol_Table();
											op_list->set_table_scope(local);
											local_symbol_table = op_list;
											$$ = op_list;
										}
										|	variable_declaration_list
										{
											$1->set_table_scope(local);
											local_symbol_table = $1;
											$$ = $1;
										}
										;

variable_declaration_list:	variable_declaration
							{
								Symbol_Table * var_st = new Symbol_Table();
								var_st->append_list(*$1, yylineno);
								$$ = var_st;
							}
							|	variable_declaration_list
							variable_declaration
							{
								$1->append_list(*$2, yylineno);
								$$ = $1;
							}
							;

variable_declaration_list_global:	variable_declaration
							{
								Symbol_Table * var_st = new Symbol_Table();
								var_st->append_list(*$1, yylineno);
								$$ = var_st;
							}
							|	variable_declaration_list_global
							variable_declaration
							{
								$1->append_list(*$2, yylineno);
								$$ = $1;
							}
							;

variable_declaration:	INTEGER variable_list ';'
						{
							list<Symbol_Table_Entry *> * var_list = $2;
							var_list->reverse();
							Symbol_Table * var_dec_ast = new Symbol_Table();
							for(list<Symbol_Table_Entry *>::iterator it = var_list->begin(); it!=var_list->end(); it++)
							{
								(*it)->set_data_type(int_data_type);
								var_dec_ast->push_symbol(*it);
							}
							$$ = var_dec_ast;
						}
						|	FLOAT variable_list ';'
						{
							list<Symbol_Table_Entry *> * var_list = $2;
							var_list->reverse();
							Symbol_Table * var_dec_ast = new Symbol_Table();
							for(list<Symbol_Table_Entry *>::iterator it = var_list->begin(); it!=var_list->end(); it++)
							{
								(*it)->set_data_type(double_data_type);
								var_dec_ast->push_symbol(*it);
							}
							$$ = var_dec_ast;
						}
						;

variable_list   :       NAME
						{
								Symbol_Table_Entry * st_var = new Symbol_Table_Entry(* $1, void_data_type, yylineno);
								list<Symbol_Table_Entry *> * var_list = new list<Symbol_Table_Entry *>();
								var_list->push_back(st_var);
								$$ = var_list;
						}
                 		|        NAME ',' variable_list
                 		{
								Symbol_Table_Entry * st_var = new Symbol_Table_Entry(* $1, void_data_type, yylineno);
								list<Symbol_Table_Entry *> * var_list = $3;
								var_list->push_back(st_var);
								$$ = var_list;	
						}
						;

statement_list:	/* empty */
				{
					list<Ast*> * st_list = new list<Ast*>();
					$$ = st_list;
				}
				|	statement_list assignment_statement
				{
					$1->push_back($2);
					$$ = $1;
				}
				|	statement_list conditional_statement
				{
					$1->push_back($2);
					$$ = $1;
				}
				|	'{' '}'
				{
					printf("cs 316: Error, block of statements cannot be empty\n");
					exit(0);
				}
				|	statement_list print_statement
				{
					$1->push_back($2);
					$$ = $1;
				}
				|	statement_list function_statement
				{
					$1->push_back($2);
					$$ = $1;
				}
				|	statement_list return_statement
				{
					$1->push_back($2);
					$$ = $1;
				}
				;

assignment_statement:	variable ASSIGN expression ';'
						{
							Assignment_Ast * ast_assign = new Assignment_Ast($1, $3, yylineno);
							$$ = ast_assign;
							if( !( $$->check_ast() ) ) yyerror((char *)"cs316: Error; Data type not compatible");
						}
						|	variable ASSIGN function ';'
						{
							Assignment_Ast * ast_assign = new Assignment_Ast($1, $3, yylineno);
							$$ = ast_assign;
							if( !( $$->check_ast() ) ) yyerror((char *)"cs316: Error; Data type not compatible");
						}
						;

function:	NAME '(' parameters ')'
				{
					string func_name = *$1;
					Call_Ast* function_ast = new Call_Ast(func_name, yylineno);
					function_ast->set_actual_param_list(*$3);
					$$ = function_ast;
				}
				;

parameters:	//empty
			{
				$$ = new list<Ast*>;
			}
			|	parameter_list
			{
			}
			;

parameter_list:	expression
				{
					list<Ast*>* params = new list<Ast*>;
					params->push_back($1);
					$$ = params;
				}
				|	parameter_list ',' expression
				{
					list<Ast*>* params = $1;
					params->push_back($3);
					$$ = params;
				}
				;

print_statement:	PRINT variable ';'
					{
						Print_Ast * print_ast = new Print_Ast($2, yylineno);
						$$ = print_ast;
					}
					;

function_statement:	function ';'
					{
						$$ = (Ast*)$1;
					}
					;

return_statement:	RETURN ';'
					{
						Ast* return_ast = new Return_Ast(NULL, curr_proc->get_proc_name(), yylineno);
						$$ = return_ast;
					}
					|	RETURN expression ';'
					{
						Ast* return_ast = new Return_Ast($2, curr_proc->get_proc_name(),yylineno);
						$$ = return_ast;
					}
					;

conditional_statement:	IF '(' condition ')' then_statement
						{
							Ast* if_statement = new Selection_Statement_Ast($3, $5, NULL, yylineno);
							$$ = if_statement;
						}
						|	IF '(' condition ')' then_statement ELSE then_statement
						{
							Ast* if_else_statement = new Selection_Statement_Ast($3, $5, $7, yylineno);
							$$ = if_else_statement;
						}
						|	WHILE '(' condition ')' then_statement
						{
							Ast* while_statement = new Iteration_Statement_Ast($3, $5, yylineno, false);
							$$ = while_statement;
						}
						|	DO then_statement WHILE '(' condition ')' ';'
						{
							Ast* do_while_statement = new Iteration_Statement_Ast($5, $2, yylineno, true);
							$$ = do_while_statement;
						}
						;

then_statement:	assignment_statement
				|	conditional_statement
				|	print_statement
				|	function_statement
				|	return_statement
				|	'{' statement_list '}'
				{
					list<Ast*> * list_of_statements = $2;
					Sequence_Ast * st_list = new Sequence_Ast(yylineno);
					for (list<Ast*>::iterator it = list_of_statements->begin(); it!=list_of_statements->end(); it++){
						st_list->ast_push_back(*it);
					}
					$$ = st_list;
				}
				;

condition:	condition AND condition
			{
				Ast* and_condition = new Logical_Expr_Ast($1, _logical_and, $3, yylineno);
				$$ = and_condition;
			}
			|	condition OR condition
			{
				Ast* or_condition = new Logical_Expr_Ast($1, _logical_or, $3, yylineno);
				$$ = or_condition;
			}
			|	NOT condition
			{
				Ast* not_condition = new Logical_Expr_Ast(NULL, _logical_not, $2, yylineno);
				$$ = not_condition;
			}
			|	'(' condition ')'
			{
				$$ = $2;
			}
			|	single_condition
			;

single_condition:	expression EQUAL expression
					{
						Ast* equal = new Relational_Expr_Ast($1, equalto, $3, yylineno);
						$$ = equal;
						$$->check_ast();
					}
					|	expression GREATER_THAN expression
					{
						Ast* greater = new Relational_Expr_Ast($1, greater_than, $3, yylineno);
						$$ = greater;
						$$->check_ast();
					}
					|	expression LESS_THAN expression
					{
						Ast* less = new Relational_Expr_Ast($1, less_than, $3, yylineno);
						$$ = less;
						$$->check_ast();
					}
					|	expression GREATER_THAN_EQUAL expression
					{
						Ast* greater_or_equal = new Relational_Expr_Ast($1, greater_equalto, $3, yylineno);
						$$ = greater_or_equal;
						$$->check_ast();
					}
					|	expression LESS_THAN_EQUAL expression
					{
						Ast* less_or_equal = new Relational_Expr_Ast($1, less_equalto, $3, yylineno);
						$$ = less_or_equal;
						$$->check_ast();
					}
					|	expression NOT_EQUAL expression
					{
						Ast* not_equal = new Relational_Expr_Ast($1, not_equalto, $3, yylineno);
						$$ = not_equal;
						$$->check_ast();
					}
					;

expression:	expression '+' expression
			{
				Plus_Ast * ast_plus = new Plus_Ast($1, $3, yylineno);
				$$ = ast_plus;
				$$->set_data_type($3->get_data_type());
			}
	|	expression '-' expression
	{
		Minus_Ast * ast_minus = new Minus_Ast($1, $3, yylineno);
		$$ = ast_minus;
		$$->set_data_type($3->get_data_type());
	}
	|
	expression '*' expression
	{
		Mult_Ast * ast_mult = new Mult_Ast($1, $3, yylineno);
		$$ = ast_mult;
		$$->set_data_type($3->get_data_type());
	}
	|	expression '/' expression
		{
		Divide_Ast * ast_div = new Divide_Ast($1, $3, yylineno);
		$$ = ast_div;
		$$->set_data_type($3->get_data_type());
	}
	|	'-' expression %prec UMINUS
	{
		UMinus_Ast * ast_uminus = new UMinus_Ast($2, NULL, yylineno); //first parameter not needed
		$$ = ast_uminus;
		$$->set_data_type($2->get_data_type());
	}
	| '('  expression  ')'
	{
		$$ = $2;
	}
	|	condition '?' expression ':' expression
	{
		Ast* conditional_expression = new Conditional_Expression_Ast($1, $3, $5, yylineno);
		$$ = conditional_expression;
		$$->set_data_type($3->get_data_type());
	}
	|	variable
	|	constant
	;

variable:	NAME
			{
				if (local_symbol_table->variable_in_symbol_list_check(*$1))
			 	{
			 		Symbol_Table_Entry * var_te = &(local_symbol_table->get_symbol_table_entry(*$1));
			 		Name_Ast * ast_name = new Name_Ast(*$1, *var_te, yylineno);
					$$ = ast_name;
			 	}
				else if (global_symbol_table->variable_in_symbol_list_check(*$1))
			 	{
			 		Symbol_Table_Entry * var_te = &(global_symbol_table->get_symbol_table_entry(*$1));
			 		Name_Ast * ast_name = new Name_Ast(*$1, *var_te, yylineno);
					$$ = ast_name;
			 	}
			 	else yyerror((char *)"cs316: Error; Variable not declared");
			}
			;

constant:	NUM
			{
				Number_Ast<int> * ast_num = new Number_Ast<int>($1, int_data_type, yylineno);
				$$ = ast_num;
			}
			| FNUM
			{
				Number_Ast<double> * ast_fnum = new Number_Ast<double>($1, double_data_type, yylineno);
				$$ = ast_fnum;
			}
			;
//  scp /mnt/c/Users/Lenovo/Documents/A5-resources/* sarthak@sl2-15.cse.iitb.ac.in:~/Downloads/A5-resources