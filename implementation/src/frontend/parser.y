%{
    #define YYERROR_VERBOSE 1
    #define YYDEBUG 1
    #include <map>
    #include <backend.h>
    #include <frontend.h>
    #include <debug_compiler.h>

    std::map<std::string, int> sym_table;

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

    /**
        TODO: MOVE THE TWO FUNCTIONS BELOW TO THE BACKEND 
    **/

    void sym_add(char * key, int token_id) {
        if(sym_table.find(key) == sym_table.end())
            sym_table.insert(std::pair<std::string, int>(key, token_id));
    }

    int sym_check_type(void) {
        if(ast_check_datatype(yytext)) {
            /* Return data type */
            return DATATYPE;
        } else {
            /* Copy symbol text first */
            yylval.sval = new char[strlen(yytext) + 1];
            strcpy(yylval.sval, yytext);

            /* Fetch symbol type from map */
            if(sym_table.find(yytext) != sym_table.end()) 
                return sym_table.at(yytext);
            else /* Return identifier type */
                return IDENTIFIER;
        }
    }
%}

%error-verbose

%union {
    /* Standard types: */
    char         cval;
	char *       sval;
	int          ival;
	unsigned int uival;
	float        fval;
	double       dval;

    /* AST Types: */
    ast_datatype_t * ast_datatype_v;
    /* TODO: ADD MORE AST TYPES */
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

%token <ival>           I_CONSTANT
%token <sval>           D_CONSTANT
%token <sval>           IDENTIFIER
%token <sval>           STRING_LITERAL
%token <sval>           ENUMERATION_CONSTANT
%token <sval>           HDL_CONSTANT
%token <sval>           TYPEDEF_NAME
%token <sval>           MODULE_NAME
%token <sval>           TESTBENCH_NAME
%token <sval>           GLOBAL_SRC
%token <sval>           SYSOBJ
%token <ast_datatype_v> DATATYPE

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
    MODULE    IDENTIFIER '{' translation_unit '}' ';' { sym_add($2, MODULE_NAME);    }
|   TESTBENCH IDENTIFIER '{' translation_unit '}' ';' { sym_add($2, TESTBENCH_NAME); }
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
	  constant_expression ':' constant_expression ']'                             {}
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
|   string             {}
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

string:
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
