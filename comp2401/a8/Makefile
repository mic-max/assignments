OBJ = chat.o util.o
OUT = chat

all: $(OBJ)
	gcc $(OBJ) -o $(OUT) -Wall -std=c99 -pthread

chat.o: a8Defs.h chat.c
	gcc -c chat.c

util.o: a8Defs.h util.c
	gcc -c util.c

clean:
	rm $(OUT) $(OBJ)

run:
	./$(OUT)