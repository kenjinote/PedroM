#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

static	const char	*const ReplaceTab[] = {
  "\\0\"", "\",0",
  "\\\"", "\",$22,\"",
  "#0x", "#$",
  "#0X", "#$",
  ".ascii", " dc.b",
  "%d0", "d0",
  "%d1", "d1",
  "%d2", "d2",
  "%d3", "d3",
  "%d4", "d4",
  "%d5", "d5",
  "%d6", "d6",
  "%d7", "d7",
  "%a0", "a0",
  "%a1", "a1",
  "%a2", "a2",
  "%a3", "a3",
  "%a4", "a4",
  "%a5", "a5",
  "%a6", "a6",
  "%a7", "a7",
  "%sp", "sp",
  "%pc", "pc",
  "%fp", "a6",
  ".byte", "  dc.b",
  ".long", "  dc.l",
  ".word", "  dc.w",
  ".even", " EVEN",
  ".globl", " xdef",
  ".bss", "", //" BSS",
  ".data", "", //" DATA",
  ".xdef", " xdef",
  ".section", "; AutoComment ",
  ".text", "",
  ".dc", " dc",
  ".ds", " ds",
  "movm", "movem",
  "__00", "@00",
  ".comm", "ds.b",
  "/*", ";",
  "//", ";",
  "jbeq", "beq",
  "jbne", "bne",
  "jbhi", "bhi",
  "jbls", "bls",
  "jbge", "bge",
  "jbgt", "bgt",
  "jble", "ble",
  "jblt", "blt",
  "jbcc", "bcc",
  "jbcs", "bcs",
  "jbmi", "bmi",
  "jbpl", "bpl",
  "jbra", "bra",
  "jbsr", "jsr",
  "pc@(2,d0:w", "2(pc,d0.w",
  ".l,",",",
  ".w,",",",
  "mov."," move.",
  "#APP","",
  "#NO_APP","",
  ", ",",",
  "+2.l","+2",
  ".skip", "; skip",
  ".lcomm", "; rs ?",
  ".comm", "; rs ?",
};

static const char *const ReplaceDataTab1[] = {
  ".section", ";",
  ".globl", " ;xdef",
  ".bss", ";",
  ".data", ";",
  ".xdef", " ;xdef",
  ".even", " ;" //\ndata_global_offset set (data_global_offset+1)/2"
};

#define DATASIZE " EQU data_global_offset\ndata_global_offset set data_global_offset+"
static const char *const ReplaceDataTab2[] = {
  ".dc", DATASIZE "1 ;",
  ".ds", DATASIZE,
  ".byte ", DATASIZE "1 ;",
  ".long ", DATASIZE "4 ;",
  ".word ", DATASIZE "2 ;",
  ".skip ", DATASIZE,
  ".byte", DATASIZE "1 ;",
  ".long", DATASIZE "4 ;",
  ".word", DATASIZE "2 ;",
  ".skip", DATASIZE,
};

// Replace only the first substring
char *strreplace (const char *source, const char *find, const char *replace, char *dest)
{
  char	*a = strstr(source, find);
  if (a == NULL)
    strcpy(dest, source);
  else	{
    while (source < a)
      *dest++ = *source++;
    source += strlen(find);
    while (*replace)
      *dest++ = *replace++;
    while (*source)
      *dest++ = *source++;
    *dest = 0;
  }
  return a;
}


int	FGetLine(FILE *F, char* buffer)
{
  int c;

  c = fgetc(F);
  while ( (c != EOF) && (c != '\n'))
    {
      *(buffer++) = c;
      c = fgetc(F);
    }
  *(buffer++) = '\0';
  return (!(c == EOF));
}

char *FindComa (char *str)
{
  while (*str != 0) {
    if (*str == '(') {
      while (*str != ')' && *str)
        str++;
      if (*str == 0)
        return NULL;
    }
    if (*str == ',')
      return str+1;
    str++;
  }
  return NULL;
}

int	ReplaceOp(char *buffer)
{
  // Search for a number in op1
  char *a0 = strpbrk(buffer, "0123456789"), *a1 = a0, *a2;
  int len;
  char *p;

  a2 = FindComa (buffer);
  if (a2)
    ReplaceOp (a2);

  // Warning d0-d7/a0-a7
  if (a0 != NULL)
    {
      // (number, -> number(
      if (a0[-1] == '(' || (a0[-1] == '-' && a0[-2] == '('))
	{
	  long val;
	  a0 -= a0[-1] == '-';
	  val = strtol (a0, &p, 0);
	  if (p != a0) {
	    char tempo[1000];
	    strcpy (tempo, p+1);
	    sprintf (a0-1, "%ld(%s", val, tempo);
	  }
	  return 1;
	}
      else if (a0[-1] != '#' && a0[-1] != 'd' && a0[-1] != 'a')
	{
	  // number.w -> (number).w
	  while (isdigit(*a1))
	    a1++;
	  if (*a1 == '.')
	    {
	      len = a1 - a0;
	      memmove(a0+2, a0, strlen(a0)+1);
	      *a0++ = '(';
	      while (len--)
		*a0++ = a0[1];
	      *a0 = ')';
	      return 1;
	    }
	  else if (*a1 == ':' && (a1[-1] == 'd' || a1[-1] == 'a'))
	    {
	      *a1  = '.';
	      return 1;
	    }
	}
    }
  // (xxx,yyy) -> 0(xxx,yyy) xxx not a number
  if (	(a0=strchr(buffer, '(')) != NULL && 
	!isdigit(a0[-1]) &&
	!isalpha(a0[-1]) && 
	(a1=strchr(a0, ',')) != NULL && 
	(a2=strchr(a0, ')')) != NULL &&
	a2 > a1) 
    {
      memmove(a0+1, a0, strlen(a0)+1);
      *a0 = '0';
      return 1;
    }
  // NananaLabel-NananaLabel.b(
  if (a0 != NULL && a0[-1] == 'b' && a0[-2] == '.')
    {
      for( a1 = a0 ; *a1 != '-' && a1 > buffer ; a1--);
      if (*a1 == '-')
	{
	  memmove(a1, a0, strlen(a0)+1);
	  return 1;
	}
    }
  
  return 0;
}

int main(int argc, char *argv[])
{
  FILE *F1,*F2,*F3;
  const char *local_label;
  char	buffer1[25600];
  char	buffer2[25600];
  int i, skipline = 10;
  char* a;
  int code = 1;
  int remove_last_char;

  if (argc < 5) {
    printf("Convert S file to Asm file (c) 2003-2006 Patrick Pelissier\n");
    printf("Usage: s2asm file.s file.asm LabelName SkipLine [DefFile]\n");
    exit(1);
  }

  /* Parse command line */
  F1 = fopen(argv[1],"r");
  F2 = fopen(argv[2],"w");
  if ((F1 == NULL) || (F2 == NULL)) {
    printf("Can't open files %s and %s!\n", argv[1], argv[2]);
    exit(1);
  }
  local_label = argv[3];
  skipline = atoi(argv[4]);
  F3 = NULL;
  if (argc > 5)
    F3 = fopen (argv[5], "w");

  /* Skip the first lines */
  while (skipline-- && FGetLine(F1,buffer1));

  while (FGetLine (F1, buffer1)) {

    /* Check for data and or code section */
    if (F3 != NULL) {
      /* Try to detect section */
      if (strstr (buffer1, ".section") != 0) {
        if (strstr (buffer1, ".text") != 0
            || strstr (buffer1, ".rodata") != 0)
          code = 1;
        else if (strstr (buffer1, ".data") != 0
                 || strstr (buffer1, ".bss") != 0)
          code = 0;
        /* .lcomm and .comm always put in data section */
      } else if (strstr (buffer1, ".lcomm") != 0
                 || strstr (buffer1, ".comm") != 0) {
        a = strreplace (buffer1, ".lcomm", " rs ", buffer2);
        if (a) strcpy(buffer1, buffer2);
        a = strreplace (buffer1, ".comm", " rs ", buffer2);
        if (a) strcpy(buffer1, buffer2);
        fprintf(F3, "%s\n", buffer1);
        continue;
      }
    }

    if (code) {
      /* Code section */
      for(i = 0 ; i < sizeof(ReplaceTab)/sizeof(ReplaceTab[0]) ; i+=2 ) {
        do {
          a = strreplace(buffer1, ReplaceTab[i], ReplaceTab[i+1], buffer2);
          if (a) strcpy(buffer1, buffer2);
        } while(a);
      }
      do {
        a = strreplace (buffer1, ".L", local_label, buffer2);
        if (a) strcpy(buffer1, buffer2);
      } while(a);
      ReplaceOp(buffer1);
      fprintf(F2, "%s\n", buffer1);
    } else {
      /* Data section */
      for(i = 0; i < sizeof(ReplaceDataTab1)/sizeof(ReplaceDataTab1[0]); i+=2 ) {
        do {
          a = strreplace(buffer1, ReplaceDataTab1[i], ReplaceDataTab1[i+1],
                         buffer2);
          if (a) strcpy(buffer1, buffer2);
        } while(a);
      }
      remove_last_char = 0;
      for(i = 0; i < sizeof(ReplaceDataTab2)/sizeof(ReplaceDataTab2[0]); i+=2 ){
        do {
          a = strreplace(buffer1, ReplaceDataTab2[i], ReplaceDataTab2[i+1],
                         buffer2);
          if (a) strcpy(buffer1, buffer2), remove_last_char = 1;
        } while(a);
      }
      if (remove_last_char)
        fseek (F3, -1, SEEK_END);
      fprintf (F3, "%s\n", buffer1);
    }
  }
  fclose(F1);
  fclose(F2);
  if (F3)
    fclose (F3);
  exit (0);
}
