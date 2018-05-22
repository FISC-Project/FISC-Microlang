#ifndef _DEBUG_COMPILER_H_
#define _DEBUG_COMPILER_H_

#include <string>
#include <util.h>
#include <config.h>

enum DEBUG_GRAVITY {
    NONE, GOOD, INFO, WARNING, ERROR
};

void _debug(const char * location, const char * line, enum DEBUG_GRAVITY gravity, std::string msg);
void _debug(const char * location, const char * line, std::string msg);

#define DEBUG(...) GET_MACRO2(__VA_ARGS__, DEBUG_GRAVITY, DEBUG_ALL)(__VA_ARGS__)

#define DEBUG_GRAVITY(gravity, msg) _debug(__FILE__, ", line " STRSTR(__LINE__), gravity, msg)
#define DEBUG_ALL(msg)              _debug(__FILE__, ", line " STRSTR(__LINE__), msg)

#endif