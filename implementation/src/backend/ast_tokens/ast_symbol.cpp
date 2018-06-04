#include <backend.h>
#include <frontend.h>

void ast_sym_add(char * key, int token_id) {
    if(ast_sym_table.find(key) == ast_sym_table.end())
        ast_sym_table.insert(std::pair<std::string, int>(key, token_id));
}

int ast_sym_check_type(void) {
    if(ast_check_datatype(yytext)) {
        /* Return data type */
        return DATATYPE;
    } else {
        /* Copy symbol text first */
        yylval.sval = new char[strlen(yytext) + 1];
        strcpy(yylval.sval, yytext);

        /* Fetch symbol type from map */
        if(ast_sym_table.find(yytext) != ast_sym_table.end()) 
            return ast_sym_table.at(yytext);
        else /* Return identifier type */
            return IDENTIFIER;
    }
}
