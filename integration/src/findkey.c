#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "base64_lib.h"
#include "vignere_lib.h"
#include "key_lib.h"

int main(int argc, char *argv[]) {

    if (argc != 3) {
        fprintf(stderr, "Usage: %s fichier_clair_base64 fichier_chiffre_base64\n", argv[0]);
        return 1;
    }

 //lecture du fichier clair en base64 
    FILE *fc = fopen(argv[1], "r");   
    if (!fc) {
        fprintf(stderr, "Erreur ouverture fichier clair\n");
        return 1;
    }
// on obtient la taille 
    fseek(fc, 0, SEEK_END);
    long n1 = ftell(fc);
    fseek(fc, 0, SEEK_SET);

    char *clair64 = malloc(n1 + 1);
    fread(clair64, 1, n1, fc);        // MODIFIÉ ICI (on lit directement le texte Base64)
    clair64[n1] = '\0';
    fclose(fc);


// lecture du fichier chiffré en base64 
    FILE *fx = fopen(argv[2], "r");   
    if (!fx) {
        fprintf(stderr, "Erreur ouverture fichier chiffré\n");
        free(clair64);
        return 1;
    }
// pareil on recupere la taille 
    fseek(fx, 0, SEEK_END);
    long n2 = ftell(fx);
    fseek(fx, 0, SEEK_SET);

    char *chiffre64 = malloc(n2 + 1);
    fread(chiffre64, 1, n2, fx);     
    chiffre64[n2] = '\0';
    fclose(fx);


// extraction brute de la clé 
    int kr;
    char *key_raw = decode_vigenere(clair64, chiffre64, n1, n2, &kr);
// on detecte  de la vrai  periode (clé minimale)
    int period = find_period(key_raw);
// on extrait uniquement la premiere repetition 
    char *key = malloc(period + 1);
    memcpy(key, key_raw, period);
    key[period] = '\0';

    printf("%s\n", key);
    fprintf(stderr, "%d\n", period);

    free(clair64);
    free(chiffre64);
    free(key_raw);
    free(key);

    return 0;
}
