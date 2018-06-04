#include <backend.h>
#include <frontend.h>
#include <debug_compiler.h>

std::vector<root*>         ast_roots;
std::map<std::string, int> ast_sym_table;

void ast_init(void) {

}

void ast_dump_function() {

}

void ast_dump_var() {

}

void ast_dump_sensitivity() {

}

void ast_dump(void) {
    static char dump_msg[128];
    sprintf(dump_msg, "Dumping AST...\n> Roots: %d\n", (int)ast_roots.size());
    DEBUG(INFO, dump_msg);

    for(root * r : ast_roots) {

    }

    DEBUG(INFO, "Dump finished");
}