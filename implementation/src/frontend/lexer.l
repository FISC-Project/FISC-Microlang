%{
    #include <backend.h>
    #include <parser.tab.h>
    int lineno = 0;

    extern void consume_multiline_comment(void);

    #define UIVAL(retid)      { yylval.uival = atoi(yytext); return retid; }
    #define UIVAL_HEX(retid)  { yylval.uival = strtol(yytext, 0, 16); return retid; }
    #define SVAL(retid)       { yylval.sval = new char[strlen(yytext) + 1]; strcpy(yylval.sval, yytext); return retid; }
    #define DATATYPE_V(retid) { yylval.ast_datatype_v = ast_create_datatype(yytext, -1); return retid; }
%}

O   [0-7]
D   [0-9]
NZ  [1-9]
L   [a-zA-Z_]
A   [a-zA-Z_0-9]
H   [a-fA-F0-9]
HV  [a-fA-F0-9xXzZ]
HP  (0[xX])
IS  (((u|U)(l|L|ll|LL)?)|((l|L|ll|LL)(u|U)?))
CP  (u|U|L)
SP  (u8|u|U|L)
ES  (\\(['"\?\\abfnrtv]|[0-7]{1,3}|x[a-fA-F0-9]+))

%%

    /* Comments: */
"/*"                         { consume_multiline_comment();      }
"//".*                       { /* Consume single line comment */ }

	/* Single characters: */
";"                          return ';';
":"                          return ':';
"("                          return '(';
")"                          return ')';
"{"                          return '{';
"}"                          return '}';
"'"                          return '\'';
"/"                          return '/';
"\\"                         return '\\';
"["                          return '[';
"]"                          return ']';
"_"                          return '_';
"."                          return '.';
"?"                          return '?';
","                          return ',';

	/* Operators: */
"+"                          return '+';
"-"                          return '-';
"*"                          return '*';
"%"                          return '%';
"="                          return '=';
"!"                          return '!';
"&"                          return '&';
"|"                          return '|';
"^"                          return '^';
"~"                          return '~';
">"                          return '>';
"<"                          return '<';
"#"                          return '#';
"=="                         return EQ_OP;
"!="                         return NEQ_OP;
"..."                        return ELLIPSIS;
">>="                        return RIGHT_ASSIGN;
"<<="                        return LEFT_ASSIGN;
"+="                         return ADD_ASSIGN;
"-="                         return SUB_ASSIGN;
"*="                         return MUL_ASSIGN;
"/="                         return DIV_ASSIGN;
"%="                         return MOD_ASSIGN;
"&="                         return AND_ASSIGN;
"^="                         return XOR_ASSIGN;
"|="                         return OR_ASSIGN;
">>"                         return RIGHT_OP;
"<<"                         return LEFT_OP;
"++"                         return INC_OP;
"--"                         return DEC_OP;
"**"                         return POW_OP;
"->"                         return PTR_OP;
"&&"                         return AND_OP;
"||"                         return OR_OP;
">="                         return GE_OP;
"<="                         return LE_OP;
"@"                          return '@';
"$"                          return '$';

    /* Keywords: */
fn                           return FN;
[us]{D}+                     DATATYPE_V(DATATYPE);
const                        return CONST;
typedef                      return TYPEDEF;
static                       return STATIC;
enum                         return ENUM;
union                        return UNION;
struct                       return STRUCT;
this                         return THIS;
define                       return DEFINE;
include                      return INCLUDE;
pragma                       return PRAGMA;
extern                       return EXTERN;
return                       return RETURN;
sizeof                       return SIZEOF;
alignas                      return ALIGNAS;
alignof                      return ALIGNOF;
if                           return IF;
else                         return ELSE;
elsif                        return ELSIF;
switch                       return SWITCH;
while                        return WHILE;
for                          return FOR;
break                        return BREAK;
continue                     return CONTINUE;
do                           return DO;
public                       return PUBLIC;
private                      return PRIVATE;
protected                    return PROTECTED;
module                       return MODULE;
testbench                    return TESTBENCH;
interface                    return INTERFACE;
extends                      return EXTENDS;
implements                   return IMPLEMENTS;
virtual                      return VIRTUAL;
always                       return ALWAYS;

    /* Variables/numbers/strings/constants/everything else: */
{HP}{H}+{IS}?                UIVAL_HEX(I_CONSTANT);
{NZ}{D}*{IS}?                UIVAL(I_CONSTANT);
"0"{O}*{IS}?                 UIVAL(I_CONSTANT);
{CP}?"'"([^'\\\n]|{ES})+"'"  UIVAL(I_CONSTANT);
{D}+(b|d|o|h)(s|u)?{HV}+     SVAL(HDL_CONSTANT);
({SP}?\"([^"\\\n]|{ES})*\")+ SVAL(STRING_LITERAL);
#{D}+                        SVAL(D_CONSTANT);
\${L}{A}*                    SVAL(SYSOBJ);

{L}{A}*                      return ast_sym_check_type(); /* Symbols / Identifiers */
.                            ;
[ \t\n]                      lineno++;

%%
