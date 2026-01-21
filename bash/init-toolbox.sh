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
			exit 2
		fi
	done 
	exit 0
else  
	exit 1
fi







