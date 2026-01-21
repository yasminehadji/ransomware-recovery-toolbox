#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>  //pour le size_t
#include "base64_lib.h"

/* Retourne l'indice base64 d'un caractère base64 */
int base64_index(char c) {
    if (c >= 'A' && c <= 'Z') return c - 'A';             // 0 - 25
    if (c >= 'a' && c <= 'z') return c - 'a' + 26;        // 26 - 51
    if (c >= '0' && c <= '9') return c - '0' + 52;        // 52 - 61
    if (c == '+') return 62;
    if (c == '/') return 63;
    return -1; // pas un caractère base64
}

/* Convertit un index 0..63 en caractère base64 */
char base64_char(int index) {
    if (index >= 0 && index <= 25) return 'A' + index;
    if (index >= 26 && index <= 51) return 'a' + (index - 26);
    if (index >= 52 && index <= 61) return '0' + (index - 52);
    if (index == 62) return '+';
    if (index == 63) return '/';
    return '?'; // cas impossible
}