SRC = src
LIB      = $(SRC)/lib
FRONTEND = $(SRC)/frontend
BACKEND  = $(SRC)/backend
GEN = $(FRONTEND)/gen
OBJ = obj
BIN = bin
EXE = ulang
CPPFLAGS = -Isrc -Isrc/backend -Isrc/frontend -Isrc/frontend/gen -Isrc/lib -Isrc/lib/cmdline -Isrc/lib/util -Isrc/lib/debug
ENV =
ifeq ($(OS),Windows_NT)
	ENV += toolchain/Windows/Tools/Flex_Bison/
endif
CXX    = g++
LEX    = $(ENV)flex
BISON  = $(ENV)bison
YFLAGS = --debug -d --graph=$(BIN)/graph.gv --report=all --report-file=$(BIN)/$(SRC_PARSER).output
LFLAGS = --header-file=$(GEN)/$(SRC_LEXER).yy.h

# Frontend parser source filenames:
SRC_LEXER  = lexer
SRC_PARSER = parser

# Target objects/outputs:
OBJS = $(GEN)/$(SRC_LEXER).yy.c $(GEN)/$(SRC_PARSER).tab.c \
	$(OBJ)/main.o $(OBJ)/cmdline.o $(OBJ)/debug_compiler.o $(OBJ)/config.o

# Build frontend (lexer):
$(GEN)/$(SRC_LEXER).yy.c: $(FRONTEND)/$(SRC_LEXER).l
	@printf "\n> Building...\n"
	$(LEX) $(LFLAGS) -o $@ $^

# Build frontend (parser):
$(GEN)/$(SRC_PARSER).tab.c: $(FRONTEND)/$(SRC_PARSER).y
	$(BISON) $(YFLAGS) -o $@ $^

# Build backend:
# TODO

# Build libraries:
$(OBJ)/cmdline.o: $(LIB)/cmdline/cmdline.cpp
	$(CXX) -o $@ -c $^ -std=c++11 $(CPPFLAGS)

$(OBJ)/debug_compiler.o: $(LIB)/debug/debug_compiler.cpp
	$(CXX) -o $@ -c $^ -std=c++11 $(CPPFLAGS)

$(OBJ)/config.o: $(SRC)/config.cpp
	$(CXX) -o $@ -c $^ -std=c++11 $(CPPFLAGS)

# Build main:
$(OBJ)/main.o: $(SRC)/main.cpp
	$(CXX) -o $@ -c $^ $(CPPFLAGS)

# Main rules:
all: setup $(OBJS)
	@printf "\n> Linking...\n"
	$(CXX) -o $(BIN)/$(EXE) $(OBJS) $(CPPFLAGS)
	
clean:
	@printf "\n> Cleaning...\n"
	rm -f $(GEN)/*
	rm -f $(BIN)/*
	rm -f $(OBJ)/*

run: setup
	@printf "\n> Running '${ARGS}'...\n"
ifeq ($(OS),Windows_NT)
	@$(BIN)/$(EXE).exe ${ARGS}
else
	@$(BIN)/$(EXE) ${ARGS}	
endif

# Prepare project folder structure before running the main rules:
setup:
	@mkdir -p $(BIN)
	@mkdir -p $(OBJ)