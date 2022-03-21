/*
 * QSort/strtol/stroul (Extract from TIGCC LIB)
 * Copyright (C) 2000-2003 Zeljko Juric, Thomas Nussbaumer, Kevin Kofler and Sebastian Reichelt
 * Copyright (C) 2009 Lionel Debroux
 *
 * This program is free software ; you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free Software Foundation;
 * either version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser Public License along with this program;
 * if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */
#include "PedroM-Internal.h"

/* Do not use register a5; callback function might need it. */
register long __tbl asm ("a5");

// This is not a quick sort, it's a shell sort.  - See Knuht v3 for details
// For sorting data that has no significant statistical property, on embedded platforms
// without processor caches, the shell sort is one of the very best size/speed tradeoffs.

/* The assembly routine was created using the following C code as a starting point:
void qsort (void *list asm("a0"), short num_items asm("d0"), short size asm("d1"), compare_t cmp_func asm("a1"))
{
    unsigned short byte_gap,i;
    short j;
    unsigned short k;
    char *p,*a,temp;

    k = ((unsigned short)num_items <= 16) ? 1 : 4096;
    num_items = (unsigned short)num_items * (unsigned short)size;

    for (; k > 0; k = (k>>1) - (k>>4)) {
        byte_gap=k*(unsigned short)size;
        for(i=byte_gap; i<(unsigned short)num_items; i+=size) {
            for(p=(char*)list+i-byte_gap; p>=(char*)list; p-= byte_gap) {
                a=p;
                if(cmp_func(a,a+byte_gap)<=0) break;
                for(j=size;j;j--) {
                    temp=*a; *a=*(a+byte_gap); *(a+byte_gap)=temp; a++;
                }
            }
        }
    }
}*/
asm("
| d3 <- p
| d4 <- a+byte_gap
| d5 <- k
| d6 <- i
| d7 <- size
| a2 <- cmp_func
| a3 <- byte_gap
| a4 <- list
| a6 <- num_items * size
.text
	.even
	.globl qsort
qsort:
	movem.l %d3-%d7/%a2-%a4/%a6,-(%sp)
	move.l %a0,%a4	;# list, list
	move.w %d1,%d7	;# size, size
	move.l %a1,%a2	;# cmp_func, cmp_func
	move.w #4096,%d5	;#, k
	cmp.w #16,%d0	;#, num_items
	bhi.s .MYL4	;#
	moveq #1,%d5	;#, k
.MYL4:
	mulu.w %d7,%d0	;# size, num_items
	move.w %d0,%a6	;# num_items, num_items.61
	bra.s .MYL5	;#
.MYL6:
	move.w %d5,%d6	;# k, i
	mulu.w %d7,%d6	;# size, i
	move.l %d6,%d0	;# i, byte_gap
	neg.l %d0
	move.l %d0,%a3
	bra.s .MYL7	;#
.MYL8:
	moveq #0,%d0	;# i
	move.w %d6,%d0	;# i, i
	move.l %a4,%d3	;# list, p
	add.l %d0,%d3	;# i, p
	add.l %a3,%d3	;# D.1283, p
	move.l %d3,%d4	;# p, ivtmp.60
	sub.l %a3,%d4	;# D.1283, ivtmp.60
	bra.s .MYL9	;#
.MYL10:
	move.l %d4,-(%sp)	;# ivtmp.60,
	move.l %d3,-(%sp)	;# p,
	jsr (%a2)	;#
	addq.l #8,%sp	;#,
	tst.w %d0	;#
	ble.s .MYL11	;#
	move.l %d4,%a1	;# ivtmp.60, ivtmp.47
	move.w %d7,%d1	;# size, j
	move.l %d3,%a0	;# p, a
	subq.w #1,%d1	;#
.MYL14:
	move.b (%a0),%d0	;#* a, temp
	move.b (%a1),(%a0)+	;#* ivtmp.47,
	move.b %d0,(%a1)+	;# temp,
	dbf %d1,.MYL14	;#, j

	add.l %a3,%d3	;# D.1283, p
	add.l %a3,%d4	;# ivtmp.53, ivtmp.60
.MYL9:
	cmp.l %d3,%a4	;# p, list
	bls.s .MYL10	;#
.MYL11:
	add.w %d7,%d6	;# size, i
.MYL7:
	cmp.w %a6,%d6	;# num_items.61, i
	bcs.s .MYL8	;#
	lsr.w #1,%d5	;#, tmp59
	move.w %d5,%d0	;# k, tmp60
	lsr.w #3,%d0	;#, tmp60
	sub.w %d0,%d5	;# tmp60, k
.MYL5:
	tst.w %d5	;# k
	bne.s .MYL6	;#
	movm.l (%sp)+,%d3-%d7/%a2-%a4/%a6
	rts
");


__ATTR_LIB_C__ unsigned long strtoul(const char *nptr, char **endptr, short base)
{
  const unsigned char *s=nptr;
  unsigned long acc,cutoff;
  unsigned short c,cutlim;
  short any;
  do {c=*s++;} while (c==' ');
  if (c=='+') c=*s++;
  if((base==0||base==16)&&c=='0'&&(*s=='x'||*s=='X'))
    {
      c=s[1]; s+=2; base=16;
    }
  if(base==0) base=c=='0'?8:10;
  asm volatile("\n"
    "	move.l #-1,%%d1\n"
    "	move.l %2,%%d0\n"
    "	jsr _du32u32\n"
    "	move.l %%d1,%0\n"
    "	move.l #-1,%%d1\n"
    "	move.l %2,%%d0\n"
    "	jsr _mu32u32\n"
    "	move.w %%d1,%1":"=g"(cutoff),"=g"(cutlim):"g"((unsigned long)base):
    "a0","a1","d0","d1","d2");
  for(acc=0,any=0;;c=*s++)
    {
      if(isdigit(c)) c-='0';
      else if(isalpha(c)) c-=isupper(c)?'A'-10:'a'-10;
      else break;
      if(c>=(unsigned short)base) break;
      if(any<0||acc>cutoff||(acc==cutoff&&c>cutlim)) any=-1;
      else
        {
          any=1;
          asm volatile("\n"
            "	move.l %1,%%d0\n"
            "	mulu %2,%%d0\n"
            "	move.l %1,%%d1\n"
            "	swap %%d1\n"
            "	mulu %2,%%d1\n"
            "	swap %%d1\n"
            "	clr.w %%d1\n"
            "	add.l %%d1,%%d0\n"
            "	move.l %%d0,%0":"=g"(acc):"g"(acc),"g"(base):"d0","d1","d2");
          acc+=c;
        }
    }
  if(any<0) acc=0xFFFFFFFF;
  if(endptr!=0) *endptr=(char*)(any?(char*)s-1:nptr);
  return(acc);
}

__ATTR_LIB_C__ long strtol(const char *nptr, char **endptr, short base)
{
  const unsigned char *s=nptr;
  unsigned long acc,cutoff,cb;
  unsigned short c,cutlim,neg=0;
  short any;
  do {c=*s++;} while (c==' ');
  if(c=='-'||c==0xAD) neg=1, c=*s++;
  else if (c=='+') c=*s++;
  if((base==0||base==16)&&c=='0'&&(*s=='x'||*s=='X'))
    {
      c=s[1]; s+=2; base=16;
    }
  if(base==0) base=c=='0'?8:10;
  cb=neg?0x80000000:0x7FFFFFFF;
  asm volatile("\n"
    "	move.l %3,%%d1\n"
    "	move.l %2,%%d0\n"
    "	jsr _du32u32\n"
    "	move.l %%d1,%0\n"
    "	move.l %3,%%d1\n"
    "	move.l %2,%%d0\n"
    "	jsr _mu32u32\n"
    "	move.w %%d1,%1":"=g"(cutoff),"=g"(cutlim):"g"((unsigned long)base),
    "g"(cb):"a0","a1","d0","d1","d2");
  for(acc=0,any=0;;c=*s++)
    {
      if(isdigit(c)) c-='0';
      else if(isalpha(c)) c-=isupper(c)?'A'-10:'a'-10;
      else break;
      if (c>=(unsigned short)base) break;
      if (any<0||acc>cutoff||(acc==cutoff&&c>cutlim)) any=-1;
      else
        {
          any=1;
          asm volatile("\n"
            "	move.l %1,%%d0\n"
            "	mulu %2,%%d0\n"
            "	move.l %1,%%d1\n"
            "	swap %%d1\n"
            "	mulu %2,%%d1\n"
            "	swap %%d1\n"
            "	clr.w %%d1\n"
            "	add.l %%d1,%%d0\n"
            "	move.l %%d0,%0":"=g"(acc):"g"(acc),"g"(base):"d0","d1","d2");
          acc+=c;
        }
    }
  if (any<0) acc=neg?0x80000000:0x7FFFFFFF;
  else if(neg) acc=-acc;
  if(endptr!=0) *endptr=(char*)(any?(char*)s-1:nptr);
  return (acc);
}

/*
 * bsearch
 * Copyright (c) 1990 Regents of the University of California.
 * Copyright (c) 2009 Lionel Debroux
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. [rescinded 22 July 1999]
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/*
 * Perform a binary search.
 *
 * The code below is a bit sneaky.  After a comparison fails, we
 * divide the work in half by moving either left or right. If lim
 * is odd, moving left simply involves halving lim: e.g., when lim
 * is 5 we look at item 2, so we change lim to 2 so that we will
 * look at items 0 & 1.  If lim is even, the same applies.  If lim
 * is odd, moving right again involves halving lim, this time moving
 * the base up one item past p: e.g., when lim is 5 we change base
 * to item 3 and make lim 2 so that we will look at items 3 and 4.
 * If lim is even, however, we have to shrink it by one before
 * halving: e.g., when lim is 4, we still looked at item 2, so we
 * have to make lim 3, then halve, obtaining 1, so that we will only
 * look at item 3.
 */
void *bsearch(const void *key asm("a0"), const void *bptr asm("a1"), short n asm("d0"), short w asm("d1"), compare_t cmp_func asm("a2"))
{
  char *base = (char *)bptr;
  unsigned short lim;
  short rcmp;
  void *rptr;

  for (lim = n; lim != 0; lim >>= 1) {
    rptr = base + ((long)(lim >> 1) * (unsigned short)w);
    rcmp = cmp_func(key, rptr);
    if (rcmp == 0)
      return rptr;
    if (rcmp > 0) {  /* key > p: move right */
      base = (char *)rptr + w;
      lim--;
    } /* else move left */
  }
  return NULL;
}
