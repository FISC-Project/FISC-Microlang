%{
    #define YYERROR_VERBOSE 1
    #define YYDEBUG         1

    #include <backend.h>
    #include <frontend.h>
    #include <debug_compiler.h>

    void frontend_init(FILE * input_file) {
        yyin = input_file;
        yyparse();
        DEBUG(GOOD, "Parsing finished!");

        static char stats_msg[128];
        sprintf(stats_msg, "\n 1. Lines parsed: %d", lineno + 1);
        DEBUG(INFO, stats_msg);
    }

    void yyerror(const char * str) {
        static char err_msg[128];
        sprintf(err_msg, "%s in line %d at: \"%s\"\n", str, lineno + 1, yytext);
        DEBUG(ERROR, err_msg);
        exit(-1);
    }

    int yywrap(void) { 
        /* This is called at end of input/lex */
        return 1; /* Terminate now */
    }

    void consume_multiline_comment(void) {
        int c;

        while ((c = yylex()) != 0) {
            if (c == '*') {
                while ((c = yylex()) == '*');

                if (c == '/')
                    return;
                if (c == 0)
                    break;
            }
        }

        yyerror("unterminated comment");
    }
%}

%error-verbose

%union {
    /* Standard types */
    char         cval;
	char *       sval;
	int          ival;
	unsigned int uival;
	float        fval;
	double       dval;

    /* AST node types */
    root                           * rootval;
	translation_unit               * translation_unit_v;
	translation_unit_anonymous     * translation_unit_anonymous_v;
	external_declaration           * external_declaration_v;
	external_declaration_anonymous * external_declaration_anonymous_v;
	function_definition            * function_definition_v;
	declaration_list               * declaration_list_v;
	declaration                    * declaration_v;
	declaration_specifiers         * declaration_specifiers_v;
	direct_abstract_declarator     * direct_abstract_declarator_v;
	abstract_declarator            * abstract_declarator_v;
	direct_declarator              * direct_declarator_v;
	declarator                     * declarator_v;
	designation                    * designation_v;
	designator_list                * designator_list_v;
	designator                     * designator_v;
	initializer                    * initializer_v;
	init_declarator                * init_declarator_v;
	initializer_list               * initializer_list_v;
	init_declarator_list           * init_declarator_list_v;
	pointer                        * pointer_v;
	type_specifier                 * type_specifier_v;
	storage_class_specifier        * storage_class_specifier_v;
	struct_or_union_specifier      * struct_or_union_specifier_v;
	struct_or_union                * struct_or_union_v;
	struct_declaration_list        * struct_declaration_list_v;
	struct_declaration             * struct_declaration_v;
	struct_declarator_list         * struct_declarator_list_v;
	struct_declarator              * struct_declarator_v;
	specifier_qualifier_list       * specifier_qualifier_list_v;
	enum_specifier                 * enum_specifier_v;
	enumerator_list                * enumerator_list_v;
	enumerator                     * enumerator_v;
	parameter_type_list            * parameter_type_list_v;
	parameter_list                 * parameter_list_v;
	parameter_declaration          * parameter_declaration_v;
	identifier_list                * identifier_list_v;
	type_name                      * type_name_v;
	type_qualifier_list            * type_qualifier_list_v;
	type_qualifier                 * type_qualifier_v;
	alignment_specifier            * alignment_specifier_v;
	struct_access                  * struct_access_v;
	primary_expression             * primary_expression_v;
	constant                       * constant_v;
	enumeration_constant           * enumeration_constant_v;
	prod_string                    * prod_string_v;
	postfix_expression             * postfix_expression_v;
	argument_expression_list       * argument_expression_list_v;
	unary_expression               * unary_expression_v;
	unary_operator                 * unary_operator_v;
	cast_expression                * cast_expression_v;
	arith_logic_expression         * arith_logic_expression_v;
	conditional_expression         * conditional_expression_v;
	assignment_expression          * assignment_expression_v;
	assignment_operator            * assignment_operator_v;
	expression                     * expression_v;
	constant_expression            * constant_expression_v;
	statement                      * statement_v;
	labeled_statement              * labeled_statement_v;
	compound_statement             * compound_statement_v;
	block_item_list                * block_item_list_v;
	block_item                     * block_item_v;
	expression_statement           * expression_statement_v;
	selection_statement            * selection_statement_v;
	selection_statement_list       * selection_statement_list_v;
	iteration_statement            * iteration_statement_v;
	jump_statement                 * jump_statement_v;
	always_statement               * always_statement_v;
	delay_statement                * delay_statement_v;
    ast_datatype_t                 * ast_datatype_v;
};

    /* Token operators */
%token EQ_OP      NEQ_OP     ELLIPSIS   RIGHT_ASSIGN LEFT_ASSIGN ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN
%token DIV_ASSIGN MOD_ASSIGN AND_ASSIGN XOR_ASSIGN   OR_ASSIGN   RIGHT_OP   LEFT_OP    INC_OP
%token DEC_OP     POW_OP     PTR_OP     AND_OP       OR_OP       GE_OP      LE_OP 

    /* Token keywords */
%token FN        CONST   TYPEDEF   STATIC    ENUM    UNION      STRUCT  THIS    DEFINE    
%token INCLUDE   PRAGMA  EXTERN    RETURN    SIZEOF  ALIGNAS    ALIGNOF IF      ELSE
%token ELSIF     SWITCH  WHILE     FOR       BREAK   CONTINUE   DO      PUBLIC  PRIVATE 
%token PROTECTED MODULE  TESTBENCH INTERFACE EXTENDS IMPLEMENTS VIRTUAL ALWAYS

    /* Native tokens */
%token <ival> I_CONSTANT
%token <sval> D_CONSTANT
%token <sval> IDENTIFIER
%token <sval> STRING_LITERAL
%token <sval> ENUMERATION_CONSTANT
%token <sval> HDL_CONSTANT
%token <sval> TYPEDEF_NAME
%token <sval> MODULE_NAME
%token <sval> TESTBENCH_NAME
%token <sval> GLOBAL_SRC
%token <sval> SYSOBJ

    /* AST tokens */
%token <ast_datatype_v> DATATYPE

	/* AST production types */
%type <rootval>                          root
%type <rootval>                          source
%type <translation_unit_v>               translation_unit
%type <translation_unit_anonymous_v>     translation_unit_anonymous
%type <external_declaration_v>           external_declaration
%type <external_declaration_anonymous_v> external_declaration_anonymous
%type <function_definition_v>            function_definition
%type <declaration_list_v>               declaration_list
%type <declaration_v>                    declaration
%type <declaration_specifiers_v>         declaration_specifiers
%type <direct_abstract_declarator_v>     direct_abstract_declarator
%type <abstract_declarator_v>            abstract_declarator
%type <direct_declarator_v>              direct_declarator
%type <declarator_v>                     declarator
%type <designation_v>                    designation
%type <designator_list_v>                designator_list
%type <designator_v>                     designator
%type <initializer_v>                    initializer
%type <init_declarator_v>                init_declarator
%type <initializer_list_v>               initializer_list
%type <init_declarator_list_v>           init_declarator_list
%type <pointer_v>                        pointer
%type <type_specifier_v>                 type_specifier
%type <storage_class_specifier_v>        storage_class_specifier
%type <struct_or_union_specifier_v>      struct_or_union_specifier
%type <struct_or_union_v>                struct_or_union
%type <struct_declaration_list_v>        struct_declaration_list
%type <struct_declarator_list_v>         struct_declarator_list
%type <struct_declaration_v>             struct_declaration
%type <struct_declarator_v>              struct_declarator
%type <specifier_qualifier_list_v>       specifier_qualifier_list
%type <enum_specifier_v>                 enum_specifier
%type <enumerator_list_v>                enumerator_list
%type <enumerator_v>                     enumerator
%type <parameter_type_list_v>            parameter_type_list
%type <parameter_list_v>                 parameter_list
%type <parameter_declaration_v>          parameter_declaration
%type <identifier_list_v>                identifier_list
%type <type_name_v>                      type_name
%type <type_qualifier_list_v>            type_qualifier_list
%type <type_qualifier_v>                 type_qualifier
%type <alignment_specifier_v>            alignment_specifier
%type <struct_access_v>                  struct_access
%type <primary_expression_v>             primary_expression
%type <constant_v>                       constant
%type <enumeration_constant_v>           enumeration_constant
%type <prod_string_v>                    prod_string
%type <postfix_expression_v>             postfix_expression
%type <argument_expression_list_v>       argument_expression_list
%type <unary_expression_v>               unary_expression
%type <unary_operator_v>                 unary_operator
%type <cast_expression_v>                cast_expression
%type <arith_logic_expression_v>         multiplicative_expression
%type <arith_logic_expression_v>         additive_expression
%type <arith_logic_expression_v>         shift_expression
%type <arith_logic_expression_v>         relational_expression
%type <arith_logic_expression_v>         equality_expression
%type <arith_logic_expression_v>         and_expression
%type <arith_logic_expression_v>         exclusive_or_expression
%type <arith_logic_expression_v>         inclusive_or_expression
%type <arith_logic_expression_v>         logical_and_expression
%type <arith_logic_expression_v>         logical_or_expression
%type <conditional_expression_v>         conditional_expression
%type <assignment_expression_v>          assignment_expression
%type <assignment_operator_v>            assignment_operator
%type <expression_v>                     expression
%type <constant_expression_v>            constant_expression
%type <statement_v>                      statement
%type <labeled_statement_v>              labeled_statement
%type <compound_statement_v>             compound_statement
%type <block_item_list_v>                block_item_list
%type <block_item_v>                     block_item
%type <expression_statement_v>           expression_statement
%type <selection_statement_v>            selection_statement
%type <selection_statement_list_v>       selection_statement_list
%type <iteration_statement_v>            iteration_statement
%type <jump_statement_v>                 jump_statement
%type <always_statement_v>               always_statement
%type <delay_statement_v>                delay_statement

/*------------------------------------------------*/
/*---- G R A M M A R    S T A R T S    H E R E ---*/
/*------------------------------------------------*/
%start source
%%
source:
                                      {}
|   source root                       {}
|   source translation_unit_anonymous {}
;

root:
    MODULE    IDENTIFIER '{' translation_unit '}' ';' { ast_sym_add($2, MODULE_NAME);    }
|   TESTBENCH IDENTIFIER '{' translation_unit '}' ';' { ast_sym_add($2, TESTBENCH_NAME); }
;

    /* Global, static anonymous translation unit */
translation_unit_anonymous:
                                                                  {}
|   external_declaration_anonymous                                {}
|   translation_unit_anonymous     external_declaration_anonymous {}
;

    /* Named translation unit */
translation_unit:
                                              {}
|   external_declaration                      {}
|   translation_unit     external_declaration {}
;

external_declaration_anonymous:
    function_definition {}
|   declaration         {}
;

external_declaration:
    function_definition {}
|   declaration         {}
|   always_statement    {}
|   struct_access       {}
|   struct_access ':'   {}
;

function_definition:
    declaration_specifiers declarator declaration_list   compound_statement {}
|   declaration_specifiers declarator compound_statement                    {}
|   direct_declarator      compound_statement                               {}
;

declaration_list:
    declaration                  {}
|   declaration_list declaration {}
;

declaration:
    declaration_specifiers                      ';' {}
|   declaration_specifiers init_declarator_list ';' { /* Create variable */ }
;

declaration_specifiers:
    storage_class_specifier declaration_specifiers {}
|   storage_class_specifier                        {}
|   type_specifier          declaration_specifiers {}
|   type_specifier                                 {}
|   type_qualifier          declaration_specifiers {}
|   type_qualifier                                 {}
|   alignment_specifier     declaration_specifiers {}
|   alignment_specifier                            {}
;

init_declarator_list:
    init_declarator                          {}
|   init_declarator_list ',' init_declarator {}
;

init_declarator:
    declarator '=' initializer {}
|   declarator                 {}
;

declarator:
    pointer direct_declarator {}
|   direct_declarator         {}
|   initializer_list          {}
;

direct_declarator:
    identifier_or_sysobj                                                          {} /* <- Name of the function */
|   '~' identifier_or_sysobj                                                      {} /* <- Deconstructor        */
|   '(' declarator ')'                                                            {}
|   direct_declarator '[' ']'                                                     {}
|   direct_declarator '['     constant_expression ']'                             {}
|   direct_declarator '['     constant_expression ':' constant_expression     ']' {}
|   direct_declarator '[' ';' constant_expression ':' constant_expression     ']' {}
|   direct_declarator '['     constant_expression ':' constant_expression ';' ']' {}
|   direct_declarator '[' ';' ']'                                                 {}
|   direct_declarator '['
    constant_expression ':' constant_expression ';'
    constant_expression ':' constant_expression ']'                               {}
|   direct_declarator '[' '*' ']'                                                 {}
|   direct_declarator '[' STATIC type_qualifier_list assignment_expression ']'    {}
|   direct_declarator '[' STATIC assignment_expression                     ']'    {}
|   direct_declarator '[' type_qualifier_list '*'                          ']'    {}
|   direct_declarator '[' type_qualifier_list STATIC assignment_expression ']'    {}
|   direct_declarator '[' type_qualifier_list assignment_expression        ']'    {}
|   direct_declarator '[' type_qualifier_list                              ']'    {}
|   direct_declarator '[' assignment_expression                            ']'    {}
|   direct_declarator '(' parameter_type_list   ')'                               {}
|   direct_declarator '(' ')'                                                     {}
|   direct_declarator '(' argument_expression_list ')'                            {}
;

pointer:
    '*' type_qualifier_list pointer {}
|   '*' type_qualifier_list         {}
|   '*' pointer                     {}
|   '*'                             {}
;

type_qualifier_list:
    type_qualifier                     {}
|   type_qualifier_list type_qualifier {}
;

parameter_type_list:
    parameter_list ',' ELLIPSIS {}
|   parameter_list              {}
;

parameter_list:
    parameter_declaration                    {}
|   parameter_list ',' parameter_declaration {}
;

parameter_declaration:
    declaration_specifiers declarator          {}
|   declaration_specifiers abstract_declarator {}
|   declaration_specifiers                     {}
;

identifier_list:
    identifier_or_sysobj                                            {}
|   type_qualifier        identifier_or_sysobj                      {}
|   identifier_list ','   identifier_or_sysobj                      {}
|   identifier_list '.'   identifier_or_sysobj                      {}
|   identifier_list ','   type_qualifier       identifier_or_sysobj {}
;

identifier_or_sysobj:
    IDENTIFIER {}
|   SYSOBJ     {}
;

type_name:
    specifier_qualifier_list abstract_declarator {}
|   specifier_qualifier_list                     {}
;

abstract_declarator:
    pointer direct_abstract_declarator {}
|   pointer                            {}
|   direct_abstract_declarator         {}
;

direct_abstract_declarator:
    '(' abstract_declarator ')'                                                         {}
|   '[' ']'                                                                             {}
|   '[' constant_expression ':' constant_expression ']'                                 {}
|   '[' constant_expression ']'                                                         {}
|   '[' constant_expression ':' constant_expression ';'
  	    constant_expression ':' constant_expression ']'                                 {}
|   '[' '*' ']'                                                                         {}
|   '[' STATIC type_qualifier_list assignment_expression ']'                            {}
|   '[' STATIC assignment_expression                     ']'                            {}
|   '[' type_qualifier_list STATIC assignment_expression ']'                            {}
|   '[' type_qualifier_list assignment_expression        ']'                            {}
|   '[' type_qualifier_list                              ']'                            {}
|   '[' assignment_expression                            ']'                            {}
|   direct_abstract_declarator '[' ']'                                                  {}
|   direct_abstract_declarator '[' '*' ']'                                              {}
|   direct_abstract_declarator '[' STATIC type_qualifier_list assignment_expression ']' {}
|   direct_abstract_declarator '[' STATIC assignment_expression                     ']' {}
|   direct_abstract_declarator '[' type_qualifier_list assignment_expression        ']' {}
|   direct_abstract_declarator '[' type_qualifier_list STATIC assignment_expression ']' {}
|   direct_abstract_declarator '[' type_qualifier_list                              ']' {}
|   direct_abstract_declarator '[' assignment_expression                            ']' {}
|   '(' ')'                                                                             {}
|   '(' parameter_type_list ')'                                                         {}
|   direct_abstract_declarator '(' ')'                                                  {}
|   direct_abstract_declarator '(' parameter_type_list ')'                              {}
;

initializer:
    '{' initializer_list     '}' {}
|   '{' initializer_list ',' '}' {}
|   assignment_expression        {}
;

initializer_list:
    designation initializer                      {}
|   initializer                                  {}
|   initializer_list ',' designation initializer {}
|   initializer_list ',' initializer             {}
;

designation:
    designator_list '=' {}
;

designator_list:
    designator                 {}
|   designator_list designator {}
;

designator:
    '[' constant_expression ']'                         {}
|   '.' identifier_or_sysobj                            {}
|   '[' constant_expression ':' constant_expression ']' {}
|   '[' constant_expression ':' constant_expression ';'
        constant_expression ':' constant_expression ']' {}
;

    /* Types */
storage_class_specifier:
    TYPEDEF {}
|   EXTERN  {}
|   STATIC  {}
|   VIRTUAL {}
;

type_specifier:
    FN                        {}
|   DATATYPE                  {}
|   TYPEDEF_NAME              {}
|   MODULE_NAME               {}
|   TESTBENCH_NAME            {}
|   struct_or_union_specifier {}
|   enum_specifier            {}
;

struct_or_union_specifier:
    struct_or_union            '{' struct_declaration_list '}' {}
    struct_or_union IDENTIFIER '{' struct_declaration_list '}' {}
|   struct_or_union IDENTIFIER                                 {}
;

struct_or_union:
    STRUCT {}
|   UNION  {}
;

struct_declaration_list:
    struct_declaration                         {}
|   struct_declaration_list struct_declaration {}
;

struct_declaration:
    specifier_qualifier_list                        ';' {}
|   specifier_qualifier_list struct_declarator_list ';' {}
;

specifier_qualifier_list:
    type_specifier specifier_qualifier_list {}
|   type_specifier                          {}
|   type_qualifier specifier_qualifier_list {}
|   type_qualifier                          {} 
;

struct_declarator_list:
    struct_declarator                            {}
|   struct_declarator_list ',' struct_declarator {}
;

struct_declarator:
               ':' constant_expression {}
|   declarator ':' constant_expression {}
|   declarator                         {}
;

enum_specifier:
                                                {}
|   ENUM            '{' enumerator_list     '}' {}
|   ENUM            '{' enumerator_list ',' '}' {}
|   ENUM IDENTIFIER '{' enumerator_list     '}' {}
|   ENUM IDENTIFIER '{' enumerator_list ',' '}' {}
|   ENUM IDENTIFIER                             {}
;

enumerator_list:
    enumerator                     {}
|   enumerator_list ',' enumerator {}
;

enumerator:
    enumeration_constant '=' constant_expression {}
|   enumeration_constant                         {}
;

type_qualifier:
    CONST {}
|   '+'   {}
|   '-'   {}
;

    /* Access keywords */
struct_access:
    PUBLIC    {}
|   PRIVATE   {}
|   PROTECTED {}
;

alignment_specifier:
    ALIGNAS '(' type_name           ')' {}
|   ALIGNAS '(' constant_expression ')' {}
;

    /* Expressions and constants */
primary_expression:
    IDENTIFIER         {}
|   MODULE_NAME        { /* Calling module constructor */ }
|   constant           {}
|   prod_string        {}
|   '(' expression ')' {}
|   SYSOBJ             {}
;

constant:
    I_CONSTANT           {}
|   ENUMERATION_CONSTANT {}
|   HDL_CONSTANT         {}
;

enumeration_constant:
    IDENTIFIER {}
;

prod_string:
    STRING_LITERAL {}
;

postfix_expression:
    primary_expression                                                             {}
|   postfix_expression '['     constant_expression                             ']' {}
|   postfix_expression '['     constant_expression ':' constant_expression     ']' {}
|   postfix_expression '[' ';' constant_expression ':' constant_expression     ']' {}
|   postfix_expression '['     constant_expression ':' constant_expression ';' ']' {}
|   postfix_expression '[' ';' ']'                                                 {}
|   postfix_expression '['
    constant_expression ':' constant_expression ';'
    constant_expression ':' constant_expression ']'                                {}
|   postfix_expression '(' ')'                                                     {}
|   postfix_expression '('       argument_expression_list ')'                      {}
|   postfix_expression '.'       IDENTIFIER                                        {}
|   postfix_expression    PTR_OP IDENTIFIER                                        {}
|   postfix_expression    INC_OP                                                   {}
|   postfix_expression    DEC_OP                                                   {}
|   '(' type_name ')' '{' initializer_list     '}'                                 {}
|   '(' type_name ')' '{' initializer_list ',' '}'                                 {}
;

argument_expression_list:
    assignment_expression                              {}
|   argument_expression_list ',' assignment_expression {}
;

unary_expression:
    postfix_expression              {}
|   INC_OP         unary_expression {}
|   DEC_OP         unary_expression {}
|   unary_operator cast_expression  {}
|   SIZEOF         unary_expression {}
|   SIZEOF     '(' type_name ')'    {}
|   ALIGNOF    '(' type_name ')'    {}
;

unary_operator:
    '&' {}
|   '*' {}
|   '+' {}
|   '-' {}
|   '~' {}
|   '!' {}
|   '.' {}
;

cast_expression:
    unary_expression                  {}
|   '(' type_name ')' cast_expression {}
;

multiplicative_expression:
    cast_expression                               {}
|   multiplicative_expression '*' cast_expression {}
|   multiplicative_expression '/' cast_expression {}
|   multiplicative_expression '%' cast_expression {}
;

additive_expression:
    multiplicative_expression                           {}
|   additive_expression '+'   multiplicative_expression {}
|   additive_expression '-'   multiplicative_expression {}
;

shift_expression:
    additive_expression                           {}
|   shift_expression LEFT_OP  additive_expression {}
|   shift_expression RIGHT_OP additive_expression {}
;

relational_expression:
    shift_expression                             {}
|   relational_expression '<'   shift_expression {}
|   relational_expression '>'   shift_expression {}
|   relational_expression LE_OP shift_expression {}
|   relational_expression GE_OP shift_expression {}
;

equality_expression:
    relational_expression                            {}
|   equality_expression EQ_OP  relational_expression {}
|   equality_expression NEQ_OP relational_expression {}
;

and_expression:
    equality_expression                    {}
|   and_expression '&' equality_expression {}
;

exclusive_or_expression:
    and_expression                             {}
|   exclusive_or_expression '^' and_expression {}
;

inclusive_or_expression:
    exclusive_or_expression                             {}
|   inclusive_or_expression '|' exclusive_or_expression {}
;

logical_and_expression:
    inclusive_or_expression                               {}
|   logical_and_expression AND_OP inclusive_or_expression {}
;

logical_or_expression:
    logical_and_expression                             {}
|   logical_or_expression OR_OP logical_and_expression {}
;

conditional_expression:
    logical_or_expression                                           {}
|   logical_or_expression '?' expression ':' conditional_expression {}
;

assignment_expression:
    selection_statement                                        {}
|   unary_expression assignment_operator assignment_expression {}
;

assignment_operator:
    '='          {}
|   LE_OP        {}
|   MUL_ASSIGN   {}
|   DIV_ASSIGN   {}
|   MOD_ASSIGN   {}
|   ADD_ASSIGN   {}
|   SUB_ASSIGN   {}
|   LEFT_ASSIGN  {}
|   RIGHT_ASSIGN {}
|   AND_ASSIGN   {}
|   XOR_ASSIGN   {}
|   OR_ASSIGN    {}
;

expression:
    assignment_expression                {}
|   expression ',' assignment_expression {}
;

constant_expression:
    conditional_expression {}
;

    /* Statements */
statement:
    labeled_statement    {}
|   compound_statement   {}
|   expression_statement {}
|   iteration_statement  {}
|   jump_statement       {}
|   always_statement     {}
|   delay_statement      {}
;

labeled_statement:
    IDENTIFIER ':' statement                         {}
|   '@'            constant_expression ':' statement {}
|   '@'        ':' statement                         {}
;

compound_statement:
    '{' '}'                 {}
|   '{' block_item_list '}' {}
;

block_item_list:
    block_item                 {}
|   block_item_list block_item {}
;

block_item:
    declaration {}
|   statement   {}
;

expression_statement:
               ';' {}
|   expression ';' {}
|   expression ',' { /* Returns value on a switch statement */ }
|   expression     { /* Returns value */                       }
;

selection_statement_list:
    ELSIF                          '(' expression ')' statement {}
|   selection_statement_list ELSIF '(' expression ')' statement {}
;

selection_statement:
    conditional_expression                                                      { /* Ternary IF */ }
|   IF     '(' expression ')' statement ELSE statement                          {}
|   IF     '(' expression ')' statement                                         {}
|   IF     '(' expression ')' statement selection_statement_list                {}
|   IF     '(' expression ')' statement selection_statement_list ELSE statement {}
|   SWITCH '(' expression ')' statement                                         {}
;

iteration_statement:
    WHILE '(' expression ')' statement                                         {}
|   DO statement WHILE '(' expression ')' ';'                                  {}
|   FOR '(' expression_statement expression_statement ')'            statement {}
|   FOR '(' expression_statement expression_statement expression ')' statement {}
|   FOR '(' declaration expression_statement            ')'          statement {}
|   FOR '(' declaration expression_statement expression ')'          statement {}
;

jump_statement:
    CONTINUE          ';' {}
|   BREAK             ';' {}
|   RETURN            ';' {}
|   RETURN expression ';' {}
;

always_statement:
    ALWAYS            '(' identifier_list ')' statement {}
|   ALWAYS IDENTIFIER '(' identifier_list ')' statement {}
|   ALWAYS            '(' ')'                 statement {}
|   ALWAYS IDENTIFIER '(' ')'                 statement {}
|   ALWAYS                                    statement {}
;

delay_statement:
    D_CONSTANT     {}
|   D_CONSTANT ';' {}
;

%%
