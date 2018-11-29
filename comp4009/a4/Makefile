MPI=mpiCC
CC=g++
CFLAGS=-Wall -std=c++11
# -DDEBUG -g

sort: main.cpp
	$(MPI) main.cpp -o $@ $(CFLAGS)

clean:
	rm -f *.o sort