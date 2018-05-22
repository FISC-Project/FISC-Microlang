#ifndef _CMDLINE_H_
#define _CMDLINE_H_

#include <string>

char get_single_opt(std::string opt);
std::string get_string_opt(std::string opt);
std::pair<char,std::string> cmd_query(char opt_query);
std::pair<std::string,std::string> cmd_query(std::string opt_query);
char cmd_has_opt(char opt);
char cmd_has_opt(std::string opt);
void cmdline_parse(int argc, char ** argv);

#endif