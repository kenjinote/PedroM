#ifdef NOSTUB
#error PedroM native format is Kernel mode! Remove _nostub definition.
#endif

#ifdef DOORS
#ifndef __PEDROM__BASE__
#error Please, do not use tigcc std headers if you want to create a PedroM program.
#endif
#endif

#ifndef __PEDROM__BASE__
#define __PEDROM__BASE__

/* if no target are defined, compiled for all calcs */
#if !defined(USE_TI92PLUS) && !defined(USE_TI89) && !defined(USE_V200) \
 && !defined(USE_TI89TI)
# define USE_TI92PLUS
# define USE_TI89
# define USE_V200
# define USE_TI89TI
#endif


#undef	NO_AMS_CHECK				/* Useless for PedroM */
#undef	NO_CALC_DETECT				/* Useless for Kernel mode */
#undef	EXECUTE_IN_GHOST_SPACE			/* Useless for PedroM */
#undef	USE_KERNEL
#undef  MIN_AMS

#undef	USE_INTERNAL_FLINE_EMULATOR		/* Useless for PedroM */
#undef	RETURN_VALUE				/* Return value are not compatible */

#define	NO_AMS_CHECK
#define	NO_CALC_DETECT
#define	USE_KERNEL
#define MIN_AMS 101
#define _NO_INCLUDE_PATCH
#define DOORS					/* To avoid double entry point */

#include <default.h>				/* Include std header from tigcc */
#include <romsymb.h>

extern	unsigned long pedrom__0000[];
extern  void pedrom__0001(void *adr asm("a0"));

/* int main(int argc, char *argv[]);
 * It doesn't work on PedroM 0.80 (the pushed args are wrong).
 * If you cared with PedroM 0.80 compatibility, run pedrom_0001 (main)
 * in _main section:
 * void _main (void) {pedrom_0001 (main);}
 * int main (int argc, const char *argv[]);
 */
#undef main
#undef _main
#define main _main

#endif						/* __PEDROM__BASE_ */
