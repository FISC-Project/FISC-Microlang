#include <iostream>
#include <cstring>
#include "debug_compiler.h"

struct gravity_cfg {
    const char * gravity_str;
    const char * color_code;
} gravity_cfg_lut[] = {
    {"",        "\e[0m" },
    {"SUCCESS", "\e[92m"},
    {"INFO",    "\e[94m"},
    {"WARNING", "\e[93m"},
    {"ERROR",   "\e[91m"}
};

void _debug(const char * file, const char * line, enum DEBUG_GRAVITY gravity, std::string msg) {
    std::cout << "\n" << gravity_cfg_lut[(int)gravity].color_code 
        << (gravity > 0 ? "(" + std::string(gravity_cfg_lut[(int)gravity].gravity_str) + ") " : "") 
        << LANGUAGE << " @ " << &file[strlen("src") + 1]
        << ((gravity == WARNING || gravity == ERROR) ? line : "")
        << "\e[0m> " << msg;
}

void _debug(const char * file, const char * line, std::string msg) {
    _debug(file, line, NONE, msg);
}