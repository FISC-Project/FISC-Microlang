#ifndef _AST_DATATYPE_H_
#define _AST_DATATYPE_H_

#include <cstdbool>
#include <cstdint>

typedef struct {
    bool     is_unsigned;
    uint32_t bitsize;
} ast_datatype_t;

extern ast_datatype_t * ast_create_datatype(char * yytext, int pseudo_idx);
extern bool             ast_check_datatype(char * yytext);

#endif