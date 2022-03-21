/*
 * Strip a TI File
 * Copyright (C)  2005 Patrick Pelissier
 *
 * This program is free software ; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the 
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
 * Boston, MA 02111-1307 USA 
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define TI_HEADER_BEGIN_SIZE 86
#define TI_HEADER_END_SIZE    2

long FileLength (FILE *h)
{
  long orgpos, len;

  orgpos = ftell (h);
  fseek (h, 0, SEEK_END);
  len = ftell (h);
  fseek (h, orgpos, SEEK_SET);
  return len;
  /* return (filelength (fileno (h))); */
}

int main (int argc, const char *argv[]) 
{
  FILE *in, *out;
  long len, i;

  if (argc != 3)
   {
     fprintf (stderr, "Wrong number of arg. strip TIFILE BINFILE\n");
     exit (1);
   }

  in = fopen (argv[1], "r");
  if (in == NULL)
    {
      fprintf (stderr, "Can't open TIFILE %s\n", argv[1]);
      exit (2); 
    }
  len = FileLength (in);
  if (len < TI_HEADER_BEGIN_SIZE+TI_HEADER_END_SIZE)
    {
      fprintf (stderr, "TIFILE %s is TOO SMALL\n", argv[1]);
      exit (4); 
    }

  out = fopen (argv[2], "w");
  if (out == NULL)
    {
      fprintf (stderr, "Can't open BINFILE %s\n", argv[2]);
      exit (3); 
    }
  
  for (i = 0 ; i < TI_HEADER_BEGIN_SIZE ; i++)
    fgetc (in);
  for (i = 0 ; i < len-(TI_HEADER_BEGIN_SIZE+TI_HEADER_END_SIZE) ; i++)
    fputc (fgetc (in), out);

  fclose (in);
  fclose (out);
  
  return 0;
}
