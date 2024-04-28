###
# Author: lkj0096
# CREATED: 2024-04-27
###

CC = gcc
CFLAGS = -w -gz -std=c99
LIBS = -lfl -lm

LEX_SRC = $(wildcard ./*.l)
LEX_C_FILE = $(LEX_SRC:.l=.yy.c)
EXEC_FILE = $(LEX_SRC:.l=.o)

SAMPLE_DIR = ./sample
SAMPLE_FILE = $(wildcard $(SAMPLE_DIR)/*.qv)
SAMPLE_RESULT = $(SAMPLE_FILE:.qv=.qv.result)

.PHONY: all
all: $(EXEC_FILE)

$(EXEC_FILE): $(LEX_C_FILE)
	$(CC) $(CFLAGS) $^ -o $@ $(LIBS)

$(LEX_C_FILE): $(LEX_SRC)
	flex -o $@ $^

.PHONY: test
test: $(SAMPLE_RESULT)
$(SAMPLE_RESULT): $(SAMPLE_DIR)/%.qv.result: $(SAMPLE_DIR)/%.qv $(EXEC_FILE)
	./$(EXEC_FILE) $^

.PHONY: clean
clean:
	rm -f $(LEX_C_FILE) $(EXEC_FILE) $(SAMPLE_RESULT)
