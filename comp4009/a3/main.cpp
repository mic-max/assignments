
# include <cstdlib>
# include <iostream>
# include "mpi.h"
using namespace std;



int main(int argc, char *argv[])

{
  int id;
  int p;
  double wtime;
  
  MPI::Init(argc, argv); //  Initialize MPI.
  p = MPI::COMM_WORLD.Get_size(); //  Get the number of processes.
  id = MPI::COMM_WORLD.Get_rank(); //  Get the individual process ID.

//  Process 0 prints an introductory message.
  if (id == 0) 
  {
    cout << "\n";
    cout << "--- HELLO_MPI. I am Master Process 0:\n";
    cout << "--- The number of processes is " << p << "\n";
    cout << "\n";
  }
//  Every process prints a hello.
  if (id == 0) 
  {
    wtime = MPI::Wtime();
  }
  cout << "  Process " << id << " says 'Hello, world!'\n";
//  Process 0 says goodbye.
  if (id == 0)
  {
    wtime = MPI::Wtime() - wtime;
    cout << "  Elapsed wall clock time = " << wtime << " seconds.\n";
  }
//  Terminate MPI.
  MPI::Finalize();
  return 0;
}

