CC = gcc

# Noms des exécutables
EXE2 = decipher
EXE3 = findkey

# Target par défaut
all: $(EXE2) $(EXE3)

# Règle pour decipher
$(EXE2): decipher.c base64_lib.c vignere_lib.c base64_lib.h vignere_lib.h
	$(CC) $(CFLAGS) decipher.c base64_lib.c vignere_lib.c -o $(EXE2)

# Règle pour findkey
$(EXE3): findkey.c base64_lib.c vignere_lib.c key_lib.c base64_lib.h vignere_lib.h key_lib.h
	$(CC) $(CFLAGS) findkey.c base64_lib.c vignere_lib.c key_lib.c -o $(EXE3)

# Nettoyage
clean:
	rm -f $(EXE2) $(EXE3) *.o *~ core

