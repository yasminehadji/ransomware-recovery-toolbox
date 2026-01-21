#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>  //pour le size_t
#include "vignere_lib.h"
#include "base64_lib.h"

//pour chifre

char *vigenere_base64(const char *donnee, const char *key) {
    int keylen = strlen(key);
    int keypos = 0;
    int n = strlen(donnee);

    char *chiffre = malloc(n + 1);
    if (!chiffre) return NULL; // si echec d allocation

    for (int i = 0; i < n; i++) { // on parcourt le tableau donnee
        if (donnee[i] == '=' || donnee[i] == '\n') {
            chiffre[i] = donnee[i]; // on copie tel qu il est sans faire avancer la clé que ca soit un '=' ou retour a la ligne
        } else {
            int idx_d = base64_index(donnee[i]);// on recupere l indice du caractere dans donnee[i]
            int idx_k = base64_index(key[keypos]);// on recupere l indice du caractere dans key[i]
            int idx_c = (idx_d + idx_k) % 64;//on applique le chiffrement de vigenere
            chiffre[i] = base64_char(idx_c);//on transofme l indice en caractere
            keypos = (keypos + 1) % keylen;// le mod pour repeter la clé autant de fois necessaire
        }
    }

    chiffre[n] = '\0';
    return chiffre;
}

// Déchiffrement Vigenère sur Base64
char *vigenere_base64_decode(const char *donnee, const char *key) {
    int keylen = strlen(key); //Longueur de la clé (pour savoir quand recommencer au début)
    int keypos = 0; //la position actuelle dans la clé 
    int n = strlen(donnee); // ca c la taille de la donnée chiffrée 

    char *clair = malloc(n + 1); // on alloue une zone memoire pour le texte dechiffré 
    if (!clair) return NULL; // tester l allocation 

    for (int i = 0; i < n; i++) { 
        if (donnee[i] == '=' || donnee[i] == '\n' ) {
            clair[i] = donnee[i]; // ne pas toucher '=' (fais partie du padding Base64) ou retour ligne
        } else {
            int idx_d = base64_index(donnee[i]); //on extrait l index du caractere chiffré
            int idx_k = base64_index(key[keypos]); // on extrait l  index ddu caractere de la clé
            int idx_p = (idx_d - idx_k + 64) % 64; // Vigenère inverse, pour annuler le chiffrement 
            clair[i] = base64_char(idx_p); // on remet cet index en caractere base64 
            keypos = (keypos + 1) % keylen; // on avance dans la clé 
        }
    }
    clair[n] = '\0'; // on termine la chaine proprement 
    return clair; // et enfin on renvoie le texte dechiffré 
}

/* Décodage Vigenère en Base64 */
char* decode_vigenere(const char *clair64, const char *chiffre64, long n1, long n2, int *key_length) {
    long L = (n1 < n2 ? n1 : n2); // On ne parcourt que jusqu'à la longueur minimale des deux chaînes

    char *key_raw = malloc(L + 1); // tableau pour stocker la clé brute
    int kr = 0;// position actuelle dans la clé
 

    for (long i = 0; i < L; i++) {
    // On ignore le padding '=' et les retours à la ligne 
        if (clair64[i] == '=' || clair64[i] == '\n') continue;
        if (chiffre64[i] == '=' || chiffre64[i] == '\n') continue;

        int idx_c = base64_index(clair64[i]); // index Base64 du caractère clair
        int idx_x = base64_index(chiffre64[i]);// index Base64 du caractère chiffré

        if (idx_c < 0 || idx_x < 0) continue; // index Base64 du caractère chiffré

   // Calcul de l’index de la clé (Vigenère inverse)
        int idx_k = (idx_x - idx_c + 64) % 64;

// Conversion de l’index en caractère Base64 et stockage
        key_raw[kr++] = base64_char(idx_k);
    }

    key_raw[kr] = '\0';
    *key_length = kr;

    return key_raw;
}