#ifndef __PEDROM__
#define __PEDROM__

#include "ped-base.h"

#ifndef __jmp_Tbl
# define __jmp_Tbl __jmp_tbl
#endif

#define pedrom_rom_call_addr(Index) (__jmp_Tbl[0x##Index])
#define pedrom_rom_call_addr_concat(Intindex,Romindex) (__jmp_Tbl[Intindex])
#define pedrom_rom_call(Type,Args,Index) (*((Type(*__attr_tios__)Args)(pedrom_rom_call_addr_concat(0x##Index,_rom_call_##Index))))
#define pedrom_is_romcall_defined(Index) (pedrom_rom_call_addr(Index) != pedrom_rom_call(169))

#endif
