#include "common.h"
#include "syn_gv.tab.h"

#include <unistd.h> // dup(), dup2(), STDOUT_FILENO
#include <fcntl.h>  // open(), O_RDWR, O_CREAT, O_APPEND


int ORIGIN_STDOUT = -1;
int ORIGIN_STDERR = -1;

void redirect_stdout(char log_file_name[]) {
    fflush(stdout);
    int log_file = open(log_file_name, O_RDWR|O_CREAT|O_TRUNC, 0666);
    ORIGIN_STDOUT = dup(STDOUT_FILENO);
    ORIGIN_STDERR = dup(STDERR_FILENO);
    if( dup2(log_file, STDOUT_FILENO) < 0 ) {
        fprintf(stdout, "stdout redirect failed");
    }
    if( dup2(log_file, STDERR_FILENO) < 0 ) {
        fprintf(stdout, "stderr redirect failed");
    }
    close(log_file);
}

void restore_stdout() {
    fflush(stdout);
    close(STDOUT_FILENO);
    if( dup2(ORIGIN_STDOUT, STDOUT_FILENO) < 0 ) {
        fprintf(stdout, "restore failed");
    }

    if( dup2(ORIGIN_STDERR, STDERR_FILENO) < 0 ) {
        fprintf(stdout, "restore failed");
    }
    close(ORIGIN_STDOUT);
}

size_t line_number = 1;
extern int yyparse(void);
extern FILE* yyin;

int main(int argc, char* argv[]) {
    if (argc < 2) {
        printf("Usage: %s <filename>\n", argv[0]);
        return -1;
    }
    char sFile[100];
    sprintf(sFile, "%s.result", argv[1]);
    // redirect_stdout(sFile);
    FILE* fp = NULL;
    if (NULL == (fp = fopen(argv[1], "r"))) {
        printf("cannot open %s\n", argv[1]);
        return -1;
    }
    yyin = fp;
    yyparse();
    // restore_stdout();
    return 0;
}

char escape_seq_val(char* str){
    switch (str[2]){
        case 'n': return '\n';
        case 't': return '\t';
        case '\\': return '\\';
        case '?': return '\?';
        case '\'': return '\'';
        case '\"': return '\"';
        default: return str[1];
    }
}