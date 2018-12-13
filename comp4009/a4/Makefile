MPI=mpiCC
CC=g++
CFLAGS=-Wall -std=c++11
# -DDEBUG -g

distsort: main.cpp
	$(MPI) main.cpp -o $@ $(CFLAGS)

clean:
	rm -f *.o distsort data/output-*.txt 