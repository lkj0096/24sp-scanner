###
# Author: lkj0096
# CREATED: 2024-06-06
###

CC = gcc
CFLAGS = -g

LEX_SRC = $(wildcard ./*.lex)
YYAC_SRC = $(wildcard ./*.y)
LEX_C_FILE = $(LEX_SRC:.lex=.yy.c)
YYAC_C_FILE = $(YYAC_SRC:.y=.tab.c)
YYAC_H_FILE = $(YYAC_SRC:.y=.tab.h)
YYAC_O_FILE = $(YYAC_SRC:.y=.output)
MAIN_FILE = main.c
EXEC_FILE = parser.o

SAMPLE_DIR = ./sample
SAMPLE_FILE = $(wildcard $(SAMPLE_DIR)/*.qv)
SAMPLE_RESULT = $(SAMPLE_FILE:.qv=.cpp)

.PHONY: all
all: $(EXEC_FILE)

$(EXEC_FILE): $(LEX_C_FILE) $(YYAC_C_FILE) $(MAIN_FILE)
	$(CC) $(CFLAGS) $^ -o $@

$(LEX_C_FILE): $(LEX_SRC)
	flex -o $@ $^

$(YYAC_C_FILE): $(YYAC_SRC)
	bison -d -v $^

.PHONY: test
test: $(SAMPLE_RESULT)
$(SAMPLE_RESULT): $(SAMPLE_DIR)/%.cpp: $(SAMPLE_DIR)/%.qv $(EXEC_FILE)
	./$(EXEC_FILE) $^ > $@ 2>&1

.PHONY: clean
clean:
	rm -f $(LEX_C_FILE) $(YYAC_H_FILE) $(YYAC_C_FILE) $(YYAC_O_FILE) $(EXEC_FILE) $(SAMPLE_RESULT)
