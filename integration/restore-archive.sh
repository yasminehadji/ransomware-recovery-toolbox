#!/bin/bash


source ./check-archive.sh || {
    echo "Erreur : impossible de charger check-archive.sh"
    exit 1
}





wd="$(pwd)/.sh-toolbox"
doc="$1"

archive_select="$ARCHIVE_SELECTED"    # le nom de l'archive décompressée choisi
attack_ts="$ATTACK_TS"                # Timestamp de la dernière connexion admin
data_dir="$DATA_DIR"                  # Chemin vers le dossier data contenant les fichiers
modified_files="$MODIFIED_FILES"      # Chemin du fichier temporaire listant les modifiés
tmp_extrait="$TMP_DIR"                # Dossier temporaire où tout a été décompressé




./init-toolbox.sh

./restore-toolbox.sh

if [ -z "$doc" ]; then
    echo "Usage : $0 <dossier_destination>"
    exit 2
fi

if [ ! -d "$doc" ]; then
    mkdir -p "$doc" || {
        echo "Erreur : création du dossier de destination échouée"
        exit 3
    }
fi

#bon la on va rechercher la cle de chiffrement
#on teste chaque fichier modifie jsq trouver une cle valide

tmp_key="/tmp/key_restore"                            #fichier temporaire pour stocker la clé trouvee par findkey

while IFS= read -r fichier_chiffre; do
    [ -f "$fichier_chiffre" ] || continue

    base_name=$(basename "$fichier_chiffre")          #on extrait le nom du fichier sans chemin

    fichier_clair=""                                  #variable pour stocker le chemin de la version claire 

        #on va chercher une version modifiée  du mm fichier (mm nom,date ancienne)
        while IFS= read -r f; do
            [ "$f" = "$fichier_chiffre" ] && continue     #on exclut le fichier chiffré lui-meme
            file_ts=$(stat -c "%Y" "$f")                  #timestamp de modification 
            if [ "$file_ts" -le "$attack_ts" ]; then
                fichier_clair="$f"                        #on garde la premiere version claire trouvée 
            fi
        done < <(find "$data_dir" -type f -name "$base_name")

    [ -z "$fichier_clair" ] && continue               #si on trouve pas de version claire on passe au fichier suivant 
    echo""
    echo "Fichier chiffré : $fichier_chiffre"
    echo""
    echo "Fichier clair   : $fichier_clair"

    rm -f "$tmp_key"                                  #nettoyage du resultat precedent 

#conversion en base64 
    base64 "$fichier_chiffre" > /tmp/fichier_chiffre_base64
    base64 "$fichier_clair"   > /tmp/fichier_clair_base64

   ./findkey /tmp/fichier_clair_base64 /tmp/fichier_chiffre_base64 > "$tmp_key"

#si findkey n a rien trouvé (donc fichier vide)
    if [ ! -s "$tmp_key" ]; then
        echo "Erreur : clé non trouvée"
        rm -f "$tmp_key"
        continue                                     #on passe au fichier chiffré suivant sans arreter le scrript 
    fi

    key=$(tr -d '\n' < "$tmp_key")
    safe_archive=$(echo "$archive_select" | sed 's/[][\.*^$/]/\\&/g')  #on echappe le nom par mesure de securité si le nom a des caracteres speciaux  

#on verifie que la clé a des caracteres imprimables (appartient a la classe [[:print]])
    if [[ $key =~ ^[[:print:]]+$ ]]; then

#donc si la cle est valide on met a jour du fichier archives avec la clé et l etat "s" 
        sed -Ei "2,\$ s|^($safe_archive:[^:]*:).*|\1$key:s|" "$wd/archives"
        rm -f "$tmp_key"
        break   #si on trouve la cle on sort de la boucle 
    else
#si non on la sauvegarde dans un fichier KEY qui est dans un dossier qui a le meme nom que l archive sans .tar.gz 
        key_name=$(basename "$archive_select" | sed 's/\.tar\.gz$//')
        key_dir="$wd/$key_name"
        mkdir -p "$key_dir"
        mv "$tmp_key" "$key_dir/KEY"
        sed -Ei "2,\$ s|^($safe_archive:[^:]*:).*|\1:f|" "$wd/archives"
        rm -f "$tmp_key"
        break
    fi
done < "$modified_files"


#mnt on restaure les fichier chiffrés 

#on recupere l etat de la clé ( si "s" ou "f" )
indice=$(grep "^$archive_select:" "$wd/archives" | cut -d ':' -f4)

if [ "$indice" = "s" ]; then
    cle=$(grep "^$archive_select:" "$wd/archives" | awk -F':' '{print $3}') #on l extrait du fichier archives 
else
    key_dir="$wd/$(echo "$archive_select" | sed 's/\.tar\.gz$//')"
    cle=$(cat "$key_dir/KEY")  #on extrait la clé du fichier key 
fi
#tmp extrait pwd temp
#pareil on echappe le chemin temporaire pour l utiliser dans sed 
escaped_tmp=$(printf '%s\n' "$tmp_extrait" | sed 's/[\/&]/\\&/g')
echo""
#on parcourt tous les fichiers modifiés pour les restaurer 
while IFS= read -r f; do
    [ -f "$f" ] || continue

#on calcule le chemin relatif pour recreer l arborescence originale 
    rel_path=$(echo "$f" | sed -E "s|^$escaped_tmp/?||")

    dest_file="$doc/$rel_path"   #chemin final dans le dossier destination 
    dest_dir="$(dirname "$dest_file")" 

    mkdir -p "$dest_dir"     #on cree l arboreacence 

#si le fichier a deja ete restaurer on demande l utilisateur si il veut l ecraser et remplacer 
#si non il passe au fichier suivant 

    if [ -f "$dest_file" ]; then
        read -p "Le fichier $dest_file existe. Écraser ? (o/n) " rep
        [ "$rep" != "o" ] && continue
    fi
    
    echo "Restauration de $dest_file"

    base64 "$f" > /tmp/fichier_chiffre_base64
    
    
    if ! ./decipher "$cle" /tmp/fichier_chiffre_base64 1>/dev/null; then
        echo "Échec de restauration : $f"
        continue
    fi
#on copie le resultat de decipher (fichier dechiffrer en base64 ) dans le dosier de destination 
   cp /tmp/fichier_chiffre_base64 "$dest_file"

done < "$modified_files"


rm -f /tmp/fichier_chiffre_base64 /tmp/fichier_clair_base64 /tmp/key_restore
rm -f "$modified_files"
rm -r "$tmp_extrait"
echo""
echo "Restauration terminée."
exit 0