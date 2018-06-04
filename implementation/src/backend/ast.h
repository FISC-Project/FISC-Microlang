#ifndef _AST_H_
#define _AST_H_

#include <vector>
#include <map>
#include <ast_node_gen.h>

void ast_init(void);
void ast_dump(void);

extern std::vector<root*>         ast_roots;
extern std::map<std::string, int> ast_sym_table;

#endif