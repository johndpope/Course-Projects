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
%token VOID INTEGER FLOAT ASSIGN DO WHILE IF ELSE
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
%type<procedure> procedure_definition
%type<symbol_table> optional_variable_declaration_list declaration_list variable_declaration_list variable_declaration
%type<symbol_entry_list> variable_list
%type<ast_list> statement_list
%type<ast> assignment_statement expression variable constant conditional_statement then_statement condition single_condition
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
				;

assignment_statement:	variable ASSIGN expression ';'
						{
							Assignment_Ast * ast_assign = new Assignment_Ast($1, $3, yylineno);
							$$ = ast_assign;
							if( !( $$->check_ast() ) ) yyerror((char *)"cs316: Error; Data type not compatible");
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
				| conditional_statement
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
//  scp /mnt/c/Users/Lenovo/Documents/A4-resources/* sarthak@sl2-15.cse.iitb.ac.in:~/Downloads/A4-resources