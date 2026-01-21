#!/bin/bash

dossier="$(pwd)/.sh-toolbox"
fichier="$dossier/archives"
cmp=0

#verification de l existance du dossier
#s il n existe pas il sera crée
if [ ! -d "$dossier" ];then
        mkdir "$dossier"
                if [ "$?" -ne 0 ];then
                        echo "echec de creation du dossier"
                        exit 1
                else
                        echo "dossier créé avec succées"
                fi
fi
echo ""

#verification de l existance du fichier archives
if [ ! -e "$fichier" ];then
        echo "0" > $fichier
                if [ "$?" -ne 0 ];then
                        echo "echec de creation du ficher"
                        exit 1
                else
                        echo "fichier créé avec succées"
                fi
fi
echo ""
#si le dossier et le fichier existent on parcourt le dossier .sh-toolbox pour verifier l existance d autres fichiers\dossiers
if [ -d "$dossier" ] && [ -f "$fichier" ];then
        echo "dossier et fichier existants"
                for i in "$dossier"/*;
                do
                                if [ -e "$i" ];then
                                        cmp=$((cmp+1))
                                fi

                                if [ "$cmp" -gt 1 ];then
                                        echo "plusieurs fichiers existant dans le dosssiers"
                                        break;
                                fi  
                done
        

fi
echo ""

# on verifie si les fichiers sources sont disponibles 
fichiers_sources="src/decipher.c src/findkey.c src/base64_lib.c src/base64_lib.h src/vignere_lib.c src/vignere_lib.h src/key_lib.c src/key_lib.h src/Makefile"

for i in $fichiers_sources; do
    if [ ! -f "$i" ]; then
        echo "Erreur : fichier source $i manquant"
        exit 10
    fi
done
echo "Tous les fichiers sources sont présents"
echo ""


#on verifie si le compilateur est disponible (gcc)
if ! command -v gcc >/dev/null 2>&1; then 
        echo "le compilateur gcc n est pas disponible"
        exit 11 
fi
echo "le compilateur gcc est disponible" 
echo ""



binaires="decipher findkey"
for binaire in $binaires; do
    if [ -x "./$binaire" ]; then
        echo "$binaire déjà présent et exécutable"
    else
    echo ""
        echo "$binaire manquant ou non exécutable"

echo ""
                #on verifie  que le dossier src existe
                if [ ! -d "./src" ]; then
                        echo "Erreur : dossier src/ introuvable"
                        exit 1
                fi

                # Vérifier que le Makefile existe
                if [ ! -f "./src/Makefile" ]; then
                        echo "Erreur : Makefile introuvable dans src/"
                        exit 1
                fi

                # Aller dans src, nettoyer et compiler
                if ! make -C src clean >/dev/null 2>&1; then
                        echo "Échec du make clean dans src/"
                        exit 1
                fi

                if ! make -C src; then
                        echo "Échec de la compilation avec make dans src/"
                        exit 12
                fi

                # on copie le binaire compilé dans le dossier courant 
                if [ -f "src/$binaire" ]; then
                        cp "src/$binaire" .
                        chmod +x "./$binaire"     #le rendre executable  si il ne l est pas 
                        echo ""
                        echo "$binaire compilé et copié avec succès"
                else
                        echo "Erreur : $binaire n'a pas été généré dans src/"
                        exit 14
                fi
    fi
done

echo "Initialisation de la toolbox terminée ;) "
