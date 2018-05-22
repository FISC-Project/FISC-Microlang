#ifndef _FRONTEND_H_
#define _FRONTEND_H_

#include <lexer.yy.h>
#include <parser.tab.h>

extern int lineno;

void frontend_init(FILE * input_file);

#endif