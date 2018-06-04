# Project directories:
SRC          = src
LIB          = $(SRC)/lib
FRONTEND     = $(SRC)/frontend
BACKEND      = $(SRC)/backend
AST_TOKENS   = $(BACKEND)/ast_tokens
GEN_FRONTEND = $(FRONTEND)/gen
GEN_BACKEND  = $(BACKEND)/gen
TESTS        = tests
TOOLS        = toolchain
SCRIPTS      = $(TOOLS)/scripts
ENV          =
ifeq ($(OS),Windows_NT)
	ENV += $(TOOLS)/Windows/Tools/Flex_Bison/
endif

# Flags and output executables:
CPPFLAGS = -std=c++11 -I$(SRC) -I$(BACKEND) -I$(AST_TOKENS) -I$(GEN_BACKEND) -I$(FRONTEND) -I$(GEN_FRONTEND) -I$(LIB) -I$(LIB)/cmdline -I$(LIB)/util -I$(LIB)/debug
CXX      = g++
LEX      = $(ENV)flex
BISON    = $(ENV)bison
YFLAGS   = --debug -d --graph=$(BIN)/graph.gv --report=all --report-file=$(BIN)/$(SRC_PARSER).output
LFLAGS   = --header-file=$(GEN_FRONTEND)/$(SRC_LEXER).yy.h
OBJ      = obj
BIN      = bin
EXE      = ulang

# Toolchain scripts:
GEN_PARSER_PRODS = $(SCRIPTS)/gen_parser_productions.py

# Frontend parser source filenames:
SRC_LEXER  = lexer
SRC_PARSER = parser

# Target objects/outputs:
-include $(GEN_BACKEND)/subdir.mk

OBJS = $(GEN_FRONTEND)/$(SRC_LEXER).yy.c $(GEN_FRONTEND)/$(SRC_PARSER).tab.c \
	$(OBJ)/main.o $(OBJ)/cmdline.o $(OBJ)/debug_compiler.o $(OBJ)/config.o \
	$(OBJ)/ast.o $(OBJ)/ast_symbol.o $(OBJ)/ast_datatype.o

# Build frontend (lexer):
$(GEN_FRONTEND)/$(SRC_LEXER).yy.c: $(FRONTEND)/$(SRC_LEXER).l
	@printf "\n> Building...\n"
	$(LEX) $(LFLAGS) -o $@ $^

# Build frontend (parser):
$(GEN_FRONTEND)/$(SRC_PARSER).tab.c: $(FRONTEND)/$(SRC_PARSER).y
	$(BISON) $(YFLAGS) -o $@ $^

# Build backend:
$(OBJ)/ast.o: $(BACKEND)/ast.cpp
	$(CXX) -o $@ -c $^ $(CPPFLAGS)

$(OBJ)/ast_symbol.o: $(AST_TOKENS)/ast_symbol.cpp
	$(CXX) -o $@ -c $^ $(CPPFLAGS)

$(OBJ)/ast_datatype.o: $(AST_TOKENS)/ast_datatype.cpp
	$(CXX) -o $@ -c $^ $(CPPFLAGS)

# Build libraries:
$(OBJ)/cmdline.o: $(LIB)/cmdline/cmdline.cpp
	$(CXX) -o $@ -c $^ $(CPPFLAGS)

$(OBJ)/debug_compiler.o: $(LIB)/debug/debug_compiler.cpp
	$(CXX) -o $@ -c $^ $(CPPFLAGS)

$(OBJ)/config.o: $(SRC)/config.cpp
	$(CXX) -o $@ -c $^ $(CPPFLAGS)

# Build main:
$(OBJ)/main.o: $(SRC)/main.cpp
	$(CXX) -o $@ -c $^ $(CPPFLAGS)

# Main rules:
all: setup $(OBJS) $(GEN_OBJS)
	@printf "\n> Linking...\n"
	$(CXX) -o $(BIN)/$(EXE) $(OBJS) $(GEN_OBJS) $(CPPFLAGS)

clean:
	@printf "\n> Cleaning...\n"
	rm -f $(GEN_BACKEND)/*
	rm -f $(GEN_FRONTEND)/*
	rm -f $(BIN)/*
	rm -f $(OBJ)/*

run: setup
	@printf "\n> Running '$(TESTS)/${test}'...\n"
ifeq ($(OS),Windows_NT)
	@$(BIN)/$(EXE).exe ./$(TESTS)/${test}
else
	@$(BIN)/$(EXE) ./$(TESTS)/${test}
endif

# Setup project before building/running/anything else
setup: projgen genbackend

# Automatically generate AST nodes from the parser yacc code:
genbackend:
	@python ./$(GEN_PARSER_PRODS) "./$(FRONTEND)/$(SRC_LEXER).l" "./$(FRONTEND)/$(SRC_PARSER).y" "./$(FRONTEND)/target_$(SRC_LEXER).l" "./$(FRONTEND)/target_$(SRC_PARSER).y" "./$(GEN_BACKEND)"

# Prepare project folder structure before running the main rules:
projgen:
	@mkdir -p $(BIN)
	@mkdir -p $(OBJ)
	@mkdir -p $(GEN_FRONTEND)
	@mkdir -p $(GEN_BACKEND)
