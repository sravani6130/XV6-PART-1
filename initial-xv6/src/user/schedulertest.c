#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

#define higher 405
#define higher2 10


#define NFORK 10  // Total number of processes to create
#define IO 5      // Number of I/O-bound processes

int main() {
  int n, pid;
  int wtime, rtime;
  int twtime = 0, trtime = 0; // Total wait time and runtime for all processes

  // Loop to create NFORK processes
  for (n = 0; n < NFORK; n++) {
    // Assign a large number of tickets to the 8th process to give it a higher chance
    //if (n == 8)
      //settickets(higher); // Process 8 gets higher tickets
    //else
     settickets(1);   // All other processes get 1 ticket each

    // Fork a new process
    pid = fork();
    if (pid < 0)
      break; // Break if fork fails

    if (pid == 0) { // Child process
      if (n < IO) {
        sleep(200); // Simulate I/O-bound process
      } else {
        // Simulate CPU-bound process with a computational loop
        for (uint64 i = 0; i < 1000000000; i++) {} 
      }
      printf("Process %d finished\n", n); // Print when process finishes
      exit(0); // Child process exits after finishing
    } else { // Parent process

    }
  }

  // Wait for all child processes to finish
  for (; n > 0; n--) {
    if (waitx(0, &wtime, &rtime) >= 0) { // Collect wait time and runtime for each process
      trtime += rtime; // Add runtime to total runtime
      twtime += wtime; // Add wait time to total wait time
    }
  }
 //printlog();
  // Print the average runtime and wait time for all processes
  printf("Average runtime: %d, Average wait time: %d\n", trtime / NFORK, twtime / NFORK);

  //printlog();

  exit(0); // Parent process exits
}
