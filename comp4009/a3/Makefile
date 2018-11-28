MPI=mpiCC
CC=g++
CFLAGS=-Wall -std=c++11
# -DDEBUG -g

life: main.cpp util.o
	$(MPI) main.cpp -o $@ $(CFLAGS)

test: test.cpp util.o catch.o
	$(CC) test.cpp catch.o -o $@ $(CFLAGS)

util.o: util.cpp
	$(CC) util.cpp -c $(CFLAGS)

catch.o: catch.cpp
	$(CC) catch.cpp -c $(CFLAGS)

clean:
	rm -f *.o life test output.txt