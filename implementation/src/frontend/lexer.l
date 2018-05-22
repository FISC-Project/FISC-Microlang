%{
    int lineno = 0;

    extern void consume_multiline_comment(void);
%}

%%

    /* Comments: */
"/*"    { consume_multiline_comment(); }
"//".*  { } /* Consume single line comment */

	/* Single characters: */
"/"     return '/';

	/* Operators: */
"*"     return '*';

.       ;
[ \t\n] lineno++;

%%
