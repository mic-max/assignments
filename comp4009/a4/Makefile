MPI=mpiCC
CC=g++
CFLAGS=-Wall -std=c++11
# -DDEBUG -g

distsort: main.cpp util.h Stopwatch.o
	$(MPI) main.cpp Stopwatch.o -o $@ $(CFLAGS)

Stopwatch.o: Stopwatch.cpp Stopwatch.h
	$(MPI) -c Stopwatch.cpp $(CFLAGS)

clean:
	rm -f *.o distsort data/output-*.txt 