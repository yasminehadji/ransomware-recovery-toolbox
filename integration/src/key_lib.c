#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>  //pour le size_t
#include "key_lib.h"
/*
   pour Trouve la période minimale d'une chaîne 
   Exemple: ABCDABCDABCD -> période = 4   */

// s cest la cle brut repeter plusier fois
int find_period(const char *s) {
    int n = strlen(s);

    //on cherche ou ca cle se repette
    for (int p = 1; p <= n; p++) {
        int ok = 1;

        // on avance dans la cle jusqua ce quon trouve que elle se repete on verifie toute les accurence
        for (int i = 0; i < n-1; i++) {
            if (s[i] != s[i % p]) {
                ok = 0;
                break;
            }
        }

        if (ok) return p; // p est la vraie période
    }

    return n; // si aucune période trouvée
}