#ifndef BASE64_LIB_H
#define BASE64_LIB_H

#include <stddef.h>  //pour le size_t
int base64_index(char c);
char base64_char(int index);
#endif