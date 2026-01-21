
CC = gcc

# Noms des exécutables
EXE1 = cipher
EXE2 = decipher
EXE3 = findkey

#all c'est le target par défaut.
all: $(EXE1) $(EXE2) $(EXE3)

$(EXE1): cipher.c base64_lib.c vignere_lib.c base64_lib.h vignere_lib.h
	$(CC) cipher.c base64_lib.c vignere_lib.c -o $(EXE1)

$(EXE2): decipher.c base64_lib.c vignere_lib.c base64_lib.h vignere_lib.h
	$(CC) decipher.c base64_lib.c vignere_lib.c -o $(EXE2)

$(EXE3): findkey.c base64_lib.c vignere_lib.c key_lib.c base64_lib.h vignere_lib.h key_lib.h
	$(CC) findkey.c base64_lib.c vignere_lib.c key_lib.c -o $(EXE3)


#Le target process dépend de all, donc il va compiler tous les programmes si ce n’est pas déjà fait.
process: all


#Vérifie que les variables INPUT et KEY sont définies.
ifndef INPUT
	$(error Vous devez specifier INPUT. Exemple : make process INPUT=message.txt KEY=MaCle)
endif
ifndef KEY
	$(error Vous devez specifier KEY. Exemple : make process INPUT=message.txt KEY=MaCle)
endif
	base64 $(INPUT) > clair64
	base64 $(INPUT) > exempleres
	./$(EXE1) $(KEY) exempleres
	cat exempleres > chiffre64
	./$(EXE2) $(KEY) exempleres
	./$(EXE3) clair64 chiffre64

clean:
	rm -f $(EXE1) $(EXE2) $(EXE3) *.o *~ clair64 exempleres chiffre64

