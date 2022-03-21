#include "stdio.h"

#include "pedrom.h"

/* It is an example of how to get the defined AMS 2.0x romcalls under PedroM */
#define FiftyMsecTick (*((volatile unsigned long*)(pedrom_rom_call_addr(4FC))))

/* To check if a (ams 2.0x) romcall is defined use IS_ROMCALL_DEFINED */
int main() {
  printf ("Current time is %lu\n", FiftyMsecTick);
  return 0;
}
