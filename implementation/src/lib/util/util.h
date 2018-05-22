#ifndef _UTIL_H_
#define _UTIL_H_

#define NULLSTR "(null)"

#define STRSTR(s) STR(s)
#define STR(s) #s

#define GET_MACRO2(_1,_2,NAME,...)          NAME
#define GET_MACRO3(_1,_2,_3,NAME,...)       NAME
#define GET_MACRO4(_1,_2,_3,_4,NAME,...)    NAME
#define GET_MACRO5(_1,_2,_3,_4,_5,NAME,...) NAME

#endif