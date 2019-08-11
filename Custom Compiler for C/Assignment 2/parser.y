%{
	#include <stdio.h>
	extern "C" void yyerror (char *);
	extern int yylex (void);
	extern int yylineno;
	Symbol_Table  * global_symbol_table;
	Symbol_Table  * local_symbol_table;
%}
%union {
	int integer_value;
	double double_value;
	std::string * string_value;
	list<Ast *> * ast_list;
	Ast * ast;
	Symbol_Table * symbol_table;
	Symbol_Table_Entry * symbol_entry;
	list<Symbol_Table_Entry *> * symbol_entry_list; 
	Basic_Block * basic_block;
	Procedure * procedure;
	Program * program_object;
}
%token<double_value> FNUM
%token<integer_value> NUM
%token<string_value> NAME
%token VOID INTEGER FLOAT ASSIGN
%left '+' '-'
%left '*' '/'
%left UMINUS
%type<program_object> program
%type<procedure> procedure_definition
%type<symbol_table> optional_variable_declaration_list declaration_list variable_declaration_list variable_declaration
%type<symbol_entry_list> variable_list
%type<ast_list> statement_list 
%type<ast> assignment_statement expression variable constant
%%

program	:	declaration_list
			procedure_definition
			{
				program_object.set_procedure($2, yylineno);
			}
			;

declaration_list:	//empty
					{
						Symbol_Table * gl_table = new Symbol_Table();
						program_object.set_global_table(* gl_table);
						gl_table->set_table_scope(global);
						$$ = gl_table;
					}
					|	variable_declaration_list
					{
						program_object.set_global_table(*$1);
						$1->set_table_scope(global);
						global_symbol_table = $1;
						$$ = $1;
					}
					; 

procedure_definition:	VOID NAME '(' ')'
              	   		'{'
						optional_variable_declaration_list
                        statement_list
    	           		'}'
    	           		{
    	           			$6->set_table_scope(local);
    	           			Procedure * proc = new Procedure(void_data_type, * $2, yylineno);
    	           			proc->set_local_list(*$6);
    	           			proc->set_ast_list(*$7);
    	           			$$ = proc;
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
                 		|       variable_list ',' NAME
                 		{
								Symbol_Table_Entry * st_var = new Symbol_Table_Entry(* $3, void_data_type, yylineno);
								list<Symbol_Table_Entry *> * var_list = $1;
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
				;

assignment_statement:	variable ASSIGN expression ';'
						{
							Assignment_Ast * ast_assign = new Assignment_Ast($1, $3, yylineno);
							$$ = ast_assign;
							if( !( $$->check_ast() ) ) yyerror((char *)"cs316: Error; Data type not compatible");
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
//  scp /mnt/c/Users/Lenovo/Documents/A2-resources/parser.y sarthak@sl2-15.cse.iitb.ac.in:~/Downloads/A2-resources