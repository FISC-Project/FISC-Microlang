#include <frontend.h>
#include <debug_compiler.h>
#include <cmdline.h>

/* RUN COMMAND: make -f toolchain/makefile clean all run ARGS="tests/test1.ul" */

int main(int argc, char ** argv) {
    if(argc > 1) {
        cmdline_parse(argc, argv);

        FILE * file = fopen(argv[1], "r");
        if(!file) {
            DEBUG(ERROR, "Could not open '" + std::string(argv[1]) + "'.\n");
            return 1;
        }

        DEBUG(INFO, "Parsing started...");
        frontend_init(file);
    }

    DEBUG(INFO, "Finished compilation.\n\n");
    return 0;
}
