CC = gcc
CFLAGS = -w -gz
LIBS = -lfl -lm

OBJECTS_NAME = lex_gv
EXEC_FILE = $(OBJECTS_NAME).o
LEX_C_FILE = $(OBJECTS_NAME).yy.c
LEX_SRC = $(OBJECTS_NAME).l

.PHONY: all
all: $(OBJECTS_NAME).o

$(EXEC_FILE): $(LEX_C_FILE)
	$(CC) $(CFLAGS) $^ -o $@ $(LIBS)

$(LEX_C_FILE): $(LEX_SRC)
	flex $^ -o $@

.PHONY: clean
clean:
	rm -f $(LEX_C_FILE) $(EXEC_FILE)
