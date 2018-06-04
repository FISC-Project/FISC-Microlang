#include <vector>
#include <string>
#include <cstring>
#include <backend.h>
#include <parser.tab.h>

const std::vector<std::string> pseudo_datatype_lut = {
    "bool",
    "char"
    "string"
    "usize",
    "ssize",
    "var",
    "array"
};

ast_datatype_t * ast_create_datatype(char * yytext, int pseudo_idx) {
    ast_datatype_t * ast_datatype_v = new ast_datatype_t;
    if(pseudo_idx > -1) {
        /* TODO: translate to native */
    } else {
        /* TODO: parse native */
    }
    return ast_datatype_v;
}

bool ast_check_datatype(char * yytext) {
    for(int i = 0; i < pseudo_datatype_lut.size(); i++) {
        if(!strcmp(yytext, pseudo_datatype_lut[i].c_str())) {
            yylval.ast_datatype_v = ast_create_datatype(yytext, i);
            return true;
        }
    }
    return false;
}
