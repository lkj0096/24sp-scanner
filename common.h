#include <stdio.h>  // fprintf() fflush(), stdout
#include <unistd.h> // dup(), dup2(), STDOUT_FILENO
#include <fcntl.h>  // open(), O_RDWR, O_CREAT, O_APPEND

int origin_stdout = 0;

void redirect_stdout(char log_file_name[]) {
    fflush(stdout);
    int log_file = open(log_file_name, O_RDWR|O_CREAT|O_APPEND, 0666);
    origin_stdout = dup(STDOUT_FILENO);
    if( dup2(log_file, STDOUT_FILENO) < 0 ) {
        fprintf(stdout, "redirect failed");
    }
    close(log_file);
}

void restore_stdout() {
    fflush(stdout);
    close(STDOUT_FILENO);
    if( dup2(origin_stdout, STDOUT_FILENO) < 0 ) {
        fprintf(stdout, "restore failed");
    }
    close(origin_stdout);
}