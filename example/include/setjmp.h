#ifndef __SETJMP__
#define __SETJMP__

#include "ped-base.h"

typedef struct {
  unsigned long D2,D3,D4,D5,D6,D7;
  unsigned long A2,A3,A4,A5,A6,A7;
  unsigned long PC;
}JMP_BUF[1];

#define longjmp _rom_call(void,(void*,short),267)
#define setjmp _rom_call(short,(void*),266)

#define jmp_buf JMP_BUF

#endif
