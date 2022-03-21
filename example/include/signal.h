#ifndef __SIGNAL
#define __SIGNAL

#include "ped-base.h"

/* Signals.  */
#define	SIGINT		1	/* Interrupt (ANSI).  */
#define	SIGILL		2	/* Illegal instruction (ANSI).  */
#define	SIGABRT		3	/* Abort (ANSI).  */
#define	SIGFPE		4	/* Floating-point exception (ANSI).  */
#define	SIGSEGV		5	/* Segmentation violation (ANSI).  */
#define	SIGTERM		6	/* Termination (ANSI).  */

/* Fake signals */
#define SIG_ERR void (*-1)(int)
#define SIG_DFL void (* 0)(int)
#define SIG_IGN void (* 1)(int)

void (*signal(int sig asm("d0"), void (*fonc asm("a0"))(int)))(int);
int raise(int sig asm("d0"));

#endif /* __SIGNAL__*/
