/*
 * cmdline.cpp
 *
 *  Created on: 09/06/2016
 *      Author: Miguel
 */

#include <utility>
#include <vector>
#include <util.h>
#include "cmdline.h"

std::vector<std::pair<char, std::string>> opts_single_list;
std::vector<std::pair<std::string, std::string>> opts_list;

char is_opt(std::string opt) {
	return !opt.find("--") ? 2 : !opt.find("-") ? 1 : 0;
}

char get_single_opt(std::string opt) {
	for(int i = 0; i < opt.size(); i++)
		if(opt[i] != '-')
			return opt[i];
	return -1;
}

std::string get_string_opt(std::string opt) {
	for(int i = 0; i < opt.size(); i++)
		if(opt[i] != '-')
			return opt.substr(i, opt.size());
	return NULLSTR;
}

/* Pushes options such as -o, -c, -e, etc */
void cmd_push_single(std::string opt, std::string arg) {
	opts_single_list.push_back(std::make_pair(get_single_opt(opt), arg));
}

/* Pushes options such as --opt=, --compile, --enable="feature", etc */
void cmd_push(std::string opt, std::string arg) {
	opts_list.push_back(make_pair(get_string_opt(opt), arg));
}

std::pair<char,std::string> cmd_query(char opt_query) {
	for(auto pair : opts_single_list)
		if(pair.first == opt_query) return pair;
	return std::make_pair(0, NULLSTR);
}

std::pair<std::string,std::string> cmd_query(std::string opt_query) {
	for(auto pair : opts_list)
		if(pair.first == opt_query) return pair;
	return std::make_pair(NULLSTR, NULLSTR);
}

char cmd_has_opt(char opt) {
	for(auto pair : opts_single_list)
		if(pair.first == opt) return 1;
	return 0;
}

char cmd_has_opt(std::string opt) {
	for(auto pair : opts_list)
		if(pair.first == opt) return 1;
	return 0;
}

void cmdline_parse(int argc, char ** argv) {
	/* Iterate through the cmdline: */
	int ctr = 2;
	while(ctr < argc) {
		std::string opt = std::string(argv[ctr++]);
		char opt_type;
		if((opt_type = is_opt(opt)))
			if(opt_type == 1)
				cmd_push_single(opt, ctr < argc ? std::string(argv[ctr]) : NULLSTR);
			else if(opt_type == 2)
				cmd_push(opt, ctr < argc ? std::string(argv[ctr]) : NULLSTR);
	}
}
