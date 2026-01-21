#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "base64_lib.h"
#include "vignere_lib.h"



int main(int argc, char*argv[]) { 
    if (argc != 3) {
        printf("pas assez d arguments\n");
        return 1;
    }

    FILE* f = fopen(argv[2], "r"); // on ouvre le fichier en mode lecture
    if (f == NULL) { // verifier l ouverture
        printf("erreur d ouverture du fichier\n");
        return 1;
    }

    // compter le nombre de caractères
    int c;
    size_t cmp = 0;
    while ((c = fgetc(f)) != EOF) {
        cmp++;
    }

    // revenir au début du fichier pour relire
    fseek(f, 0, SEEK_SET);

    char* donnee = (char*)malloc(cmp + 1); // tableau dynamique pour stocker le fichier base64
    if (!donnee) {
        printf("echec d allocation\n");
        fclose(f);
        return 1;
    }

    size_t i = 0;
    while ((c = fgetc(f)) != EOF) {
        donnee[i++] = (char)c;
    }
    donnee[i] = '\0'; // terminer la chaine

    printf("Contenu lu :\n%s\n", donnee);

    fclose(f);

    // préparation de la clé
    char* key = malloc(strlen(argv[1]) + 1);
    if (!key) { free(donnee); return 1; }

    int j = 0;
    for (i = 0; i < strlen(argv[1]); i++) {
        if (argv[1][i] != '=') { // enlever les '=' de la clé
            key[j++] = argv[1][i];
        }
    }
    key[j] = '\0';

    char* chiffre = vigenere_base64(donnee, key);
    printf("le texte chiffré est :\n%s\n", chiffre);

    

    // remplacement du fichier original par le binaire décodé
    FILE* fout = fopen(argv[2], "w");
    if (!fout) {
        printf("Erreur ouverture fichier pour écriture\n");
        free(chiffre);
        free(donnee);
        free(key);
        return 1;
    }
    fwrite(chiffre , 1, strlen(chiffre), fout);
    fclose(fout);

    free(chiffre);
    free(donnee);
    free(key);

    return 0;
}