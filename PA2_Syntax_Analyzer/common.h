#include <stdio.h>  // fprintf() fflush(), stdout
#include <stdint.h> // uint*_t
#include <string.h>
#include <stdlib.h>
#include <math.h>

typedef enum{
    int_B, int_O, int_D, int_H, real, char_one, char_esp, char_unesp
} type;

typedef struct {
    uint8_t _FLAGS; // 1st bit for signed, 2nd bit for array
    type _type;
    union {
        char _char_value;
        int _int_value;
        double _real_value;
        char* _str_value;
        void* _array_value;
    };
    char* _name;
} value_t;

typedef struct {
    type _type;
    union {
        int _int_value;
        double _real_value;
        char _char_value;
    };
    char* _str_value;
} number_t;

extern size_t line_number;

void yywarning(const char *msg);
void yyerror(const char *msg);

char escape_seq_val(char* str);
