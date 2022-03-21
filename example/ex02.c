#include "stdio.h"

int main (int argc, const char *argv[])
{
  int i;
  char prenom[64];

  printf ("Le programme a recu %d arguments.\n", argc);
  for (i = 1; i < argc; i++)
    printf ("%s\n", argv[i]);
  printf ("Entrez votre prénom:");
  gets (prenom);
  printf ("Bonjour, %s !\n", prenom);
  return 0;
}
