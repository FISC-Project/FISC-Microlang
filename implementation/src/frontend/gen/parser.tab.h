/* A Bison parser, made by GNU Bison 3.0.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2013 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_SRC_FRONTEND_GEN_PARSER_TAB_H_INCLUDED
# define YY_YY_SRC_FRONTEND_GEN_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    EQ_OP = 258,
    NEQ_OP = 259,
    ELLIPSIS = 260,
    RIGHT_ASSIGN = 261,
    LEFT_ASSIGN = 262,
    ADD_ASSIGN = 263,
    SUB_ASSIGN = 264,
    MUL_ASSIGN = 265,
    DIV_ASSIGN = 266,
    MOD_ASSIGN = 267,
    AND_ASSIGN = 268,
    XOR_ASSIGN = 269,
    OR_ASSIGN = 270,
    RIGHT_OP = 271,
    LEFT_OP = 272,
    INC_OP = 273,
    DEC_OP = 274,
    POW_OP = 275,
    PTR_OP = 276,
    AND_OP = 277,
    OR_OP = 278,
    GE_OP = 279,
    LE_OP = 280,
    FN = 281,
    CONST = 282,
    TYPEDEF = 283,
    STATIC = 284,
    ENUM = 285,
    UNION = 286,
    STRUCT = 287,
    THIS = 288,
    DEFINE = 289,
    INCLUDE = 290,
    PRAGMA = 291,
    EXTERN = 292,
    RETURN = 293,
    SIZEOF = 294,
    ALIGNAS = 295,
    ALIGNOF = 296,
    IF = 297,
    ELSE = 298,
    ELSIF = 299,
    SWITCH = 300,
    WHILE = 301,
    FOR = 302,
    BREAK = 303,
    CONTINUE = 304,
    DO = 305,
    PUBLIC = 306,
    PRIVATE = 307,
    PROTECTED = 308,
    MODULE = 309,
    TESTBENCH = 310,
    INTERFACE = 311,
    EXTENDS = 312,
    IMPLEMENTS = 313,
    VIRTUAL = 314,
    ALWAYS = 315,
    I_CONSTANT = 316,
    D_CONSTANT = 317,
    IDENTIFIER = 318,
    STRING_LITERAL = 319,
    ENUMERATION_CONSTANT = 320,
    HDL_CONSTANT = 321,
    TYPEDEF_NAME = 322,
    MODULE_NAME = 323,
    TESTBENCH_NAME = 324,
    GLOBAL_SRC = 325,
    SYSOBJ = 326,
    DATATYPE = 327
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE YYSTYPE;
union YYSTYPE
{
#line 79 "src/frontend/parser.y" /* yacc.c:1909  */

    /* Standard types: */
    char         cval;
	char *       sval;
	int          ival;
	unsigned int uival;
	float        fval;
	double       dval;

    /* AST Types: */
    ast_datatype_t * ast_datatype_v;
    /* TODO: ADD MORE AST TYPES */

#line 141 "src/frontend/gen/parser.tab.h" /* yacc.c:1909  */
};
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_SRC_FRONTEND_GEN_PARSER_TAB_H_INCLUDED  */
