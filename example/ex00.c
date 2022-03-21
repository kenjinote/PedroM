#include "stdlib.h"
#include "stdio.h"

void	dummy1(void)
{
  printf("Atexit 1 called!\n");
}

void	dummy2(void)
{
  printf("Atexit 2 called!\n");
}

int main(int argc, char *argv[])
{
  int i;
  char Buffer[40];

  atexit (dummy1);
  atexit (dummy2);
  for (i = 0; i < argc; i++)
    fprintf(stdout, "Arg %d: %s\n", i, argv[i]);
  printf ("Entrez votre nom:");
  fgets (Buffer, sizeof Buffer, stdin);
  printf ("Wellcome, %s\n", Buffer);
  perror ("Well done!");
  exit (0);
}
