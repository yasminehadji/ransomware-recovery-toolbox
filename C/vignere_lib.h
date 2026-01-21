#ifndef VIGNERE_LIB_H
#define VIGNERE_LIB_H

char *vigenere_base64(const char *donnee, const char *key);
char *vigenere_base64_decode(const char *donnee, const char *key);
char* decode_vigenere(const char *clair64, const char *chiffre64, long n1, long n2, int *key_length);//pour trouver la cle brute

#endif