#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "base64_lib.h"
#include "vignere_lib.h"

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("Usage : ./decipher cleBase64 fichier\n");
        return 1;
    }

    // Lecture du fichier chiffré
    FILE *f = fopen(argv[2], "r");
    if (!f) { printf("Erreur ouverture fichier\n"); return 1; }
// on calcule la taille du fichier 
    fseek(f, 0, SEEK_END);
    size_t cmp = ftell(f); // nbr d octet dans le fichier , comme le curseur 
    // est a la fin donc
    fseek(f, 0, SEEK_SET);

    char *donnee = malloc(cmp + 1);
    if (!donnee) { fclose(f); return 1; }

    size_t i = 0;
    int c;
    while ((c = fgetc(f)) != EOF) donnee[i++] = (char)c;
    donnee[i] = '\0';
    fclose(f);

    printf("Contenu chiffré Base64 lu :\n%s\n", donnee);

    // Préparer la clé (enlever '=' éventuels)
    char *key = malloc(strlen(argv[1]) + 1);
    if (!key) { free(donnee); return 1; }

    int k = 0;
    for (i = 0; i < strlen(argv[1]); i++)
        if (argv[1][i] != '=') key[k++] = argv[1][i];
    key[k] = '\0';

    // Déchiffrement Vigenère sur Base64
    char *base64_dechiffre = vigenere_base64_decode(donnee, key);
    printf("\nBase64 après déchiffrement Vigenère :\n%s\n", base64_dechiffre);


    // Écrire le fichier final en clair
    FILE *fout = fopen(argv[2], "w");
    if (!fout) { printf("Erreur écriture fichier\n"); free(donnee); free(key); free(base64_dechiffre); return 1; }
    fwrite(base64_dechiffre, 1, strlen(base64_dechiffre), fout);
    fclose(fout);

    printf("\nFichier déchiffré et remplacé avec succès.\n");

    free(donnee);
    free(key);
    free(base64_dechiffre);

    return 0;
}