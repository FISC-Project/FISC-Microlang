%{
    #define YYERROR_VERBOSE 1
    #define YYDEBUG 1
    #include <frontend.h>
    #include <debug_compiler.h>

    void frontend_init(FILE * input_file) {
        yyin = input_file;
        yyparse();
        DEBUG(GOOD, "Parsing finished!");

        static char stats_msg[128];
        sprintf(stats_msg, "\n 1. Lines parsed: %d", lineno + 1);
        DEBUG(INFO, stats_msg);
    }

    void yyerror(const char * str) {
        static char err_msg[128];
        sprintf(err_msg, "%s in line %d at: \"%s\"\n", str, lineno + 1, yytext);
        DEBUG(ERROR, err_msg);
        exit(-1);
    }

    int yywrap(void) { 
        /* This is called at end of input/lex */
        return 1; /* Terminate now */
    }

    void consume_multiline_comment(void) {
        int c;

        while ((c = yylex()) != 0) {
            if (c == '*') {
                while ((c = yylex()) == '*');

                if (c == '/')
                    return;
                if (c == 0)
                    break;
            }
        }

        yyerror("unterminated comment");
    }
%}

%error-verbose

/*------------------------------------------------*/
/*---- G R A M M A R    S T A R T S    H E R E ---*/
/*------------------------------------------------*/
%start source
%%
source:
    {}

%%
