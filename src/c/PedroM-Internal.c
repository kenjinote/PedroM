/* This file is just used at configure time */

int _ti92plus;
int _nostub;

extern int main ();

void __main ()
{
  main ();
}

void exit (int x)
{
  abort ();
}
void abort (void)
{
  return;
}
void *malloc (unsigned long n)
{
  return 0;
}
void *HeapAllocPtr (unsigned long n)
{
  return 0;
}
void HeapFreePtr (void) {}
void free () {}
void strerror() {}
void strchr () {}

void __kernel_program_header() {}
void raise () {}

void FILE_TAB() {}
