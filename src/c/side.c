/*
 * S-IDE - the Small Integrated Development Environment
 * Copyright (c) 2002, 2005 Clement Vasseur
 * Adaptation for use with PedroM -  Copyright (C) 2003, 2005, 2009 Patrick Pelissier
 *
 * This program is free software ; you can redistribute it and/or modify it under the
 * terms of the GNU General Public License as published by the Free Software Foundation;
 * either version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program
 * if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

/* Version 0.1.P9:
 *
 * List of changes:
 *  + Kernel Mode
 *  + No more Gray
 *  + No more Syntax Highling
 *  + Bigger Font much faster
 *  + Much more key sensitive!
 *  + New way for compiling.
 *  + Secondary text.
 *  + <> + LEFT/RIGHT : Left word, right word
 *  + Replace
 *  + Execute
 *  + Use of idle.
 *  + Harmonize the status message
 *  + Change FileName Wildcard from ! to *
 *  + Improve compilation
 *
 */

// TODO: Verification probleme lancement side a l'interieur tibasic

#ifndef PEDROM

#if !defined(USE_TI92PLUS) && !defined(USE_V200) && !defined(USE_TI89)
# define USE_TI92PLUS
# define USE_V200
#endif

#if defined(USE_TI92PLUS) && !defined(USE_V200)
# define USE_V200
#endif


# define USE_FLINE_ROM_CALLS
# define NO_EXIT_SUPPORT
# define MIN_AMS 204
# define USE_KERNEL
# include <tigcclib.h>

# define VARIABLE
# define _OSModKeyStatus (*((long*)(*((long*)(*((long*)0xC8)+4292)))))
# define STAT_STATE	_OSModKeyStatus
# define STAT_2ND	0x10000
# define STAT_DIAMOND	0x20000
# define STAT_SHIFT	0x40000
# define STAT_ALPHA	0x80000
# define STAT_ALOCK	0x00001
# define STAT_CAPS	0x08000

#else

# include "PedroM-Internal.h"
# define VARIABLE extern
# define STAT_STATE	(KEY_STATUS+65536*KEY_MAJ)
# define STAT_2ND	0x01000
# define STAT_DIAMOND	0x02000
# define STAT_SHIFT	0x04000
# define STAT_ALPHA	0x08000
# define STAT_ALOCK	0x20000
# define STAT_CAPS	0x10000
typedef short (*vcbprintf_Callback_t) (short, FILE *);

#endif

#define OSResetTimer OSTimerRestart

const unsigned char TextFont46[] = {
/* 0 to 31 */
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0c, 0x08, 0x0d, 0x07,
  0x0d, 0x05, 0x0c, 0x08, 0x0d, 0x06, 0x05, 0x08, 0x0c, 0x08,
  0x0d, 0x0a, 0x0d, 0x00, 0x0c, 0x08, 0x0f, 0x0a, 0x0e, 0x02,
  0x0c, 0x08, 0x0f, 0x0d, 0x0f, 0x01, 0x04, 0x0e, 0x0a, 0x05,
  0x06, 0x05, 0x00, 0x04, 0x0e, 0x0f, 0x04, 0x00, 0x00, 0x07,
  0x0f, 0x07, 0x00, 0x00, 0x05, 0x03, 0x0f, 0x03, 0x05, 0x00,
  0x00, 0x0e, 0x02, 0x07, 0x02, 0x00, 0x00, 0x02, 0x05, 0x0f,
  0x0a, 0x0e, 0x0f, 0x06, 0x0f, 0x06, 0x06, 0x00, 0x00, 0x01,
  0x05, 0x0f, 0x04, 0x00, 0x06, 0x09, 0x0f, 0x0b, 0x0f, 0x00,
  0x00, 0x01, 0x01, 0x0a, 0x04, 0x00, 0x00, 0x0f, 0x0f, 0x0f,
  0x0f, 0x00, 0x00, 0x07, 0x0f, 0x0f, 0x07, 0x00, 0x00, 0x0e,
  0x0f, 0x0f, 0x0e, 0x00, 0x00, 0x06, 0x0f, 0x0f, 0x00, 0x00,
  0x00, 0x0f, 0x0f, 0x06, 0x00, 0x00, 0x02, 0x04, 0x0f, 0x04,
  0x02, 0x00, 0x04, 0x02, 0x0f, 0x02, 0x04, 0x00, 0x04, 0x0e,
  0x05, 0x04, 0x04, 0x00, 0x02, 0x02, 0x0a, 0x07, 0x02, 0x00,
  0x07, 0x0f, 0x0f, 0x0f, 0x07, 0x00, 0x0e, 0x0f, 0x0f, 0x0f,
  0x0e, 0x00, 0x06, 0x0f, 0x06, 0x06, 0x00, 0x00, 0x09, 0x09,
  0x09, 0x06, 0x00, 0x00, 0x06, 0x09, 0x09, 0x09, 0x00, 0x00,
  0x07, 0x08, 0x08, 0x07, 0x00, 0x00, 0x07, 0x08, 0x0f, 0x08,
  0x07, 0x00,
/* 32 to 127 */
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x02, 0x02, 0x00,
  0x02, 0x00, 0x05, 0x05, 0x00, 0x00, 0x00, 0x00, 0x02, 0x07,
  0x02, 0x07, 0x02, 0x00, 0x03, 0x06, 0x07, 0x03, 0x06, 0x00,
  0x05, 0x01, 0x02, 0x04, 0x05, 0x00, 0x02, 0x05, 0x02, 0x05,
  0x03, 0x00, 0x02, 0x02, 0x02, 0x00, 0x00, 0x00, 0x01, 0x02,
  0x02, 0x02, 0x01, 0x00, 0x02, 0x01, 0x01, 0x01, 0x02, 0x00,
  0x00, 0x05, 0x02, 0x05, 0x00, 0x00, 0x00, 0x02, 0x07, 0x02,
  0x00, 0x00, 0x00, 0x00, 0x02, 0x02, 0x04, 0x00, 0x00, 0x00,
  0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00,
  0x01, 0x01, 0x02, 0x04, 0x04, 0x00, 0x03, 0x05, 0x05, 0x05,
  0x06, 0x00, 0x02, 0x06, 0x02, 0x02, 0x07, 0x00, 0x07, 0x01,
  0x03, 0x04, 0x07, 0x00, 0x07, 0x01, 0x02, 0x01, 0x06, 0x00,
  0x05, 0x05, 0x07, 0x01, 0x01, 0x00, 0x07, 0x04, 0x07, 0x01,
  0x06, 0x00, 0x03, 0x04, 0x06, 0x05, 0x03, 0x00, 0x07, 0x01,
  0x02, 0x04, 0x04, 0x00, 0x03, 0x05, 0x02, 0x05, 0x06, 0x00,
  0x06, 0x05, 0x03, 0x01, 0x06, 0x00, 0x00, 0x02, 0x00, 0x02,
  0x00, 0x00, 0x00, 0x02, 0x00, 0x02, 0x04, 0x00, 0x01, 0x02,
  0x04, 0x02, 0x01, 0x00, 0x00, 0x07, 0x00, 0x07, 0x00, 0x00,
  0x04, 0x02, 0x01, 0x02, 0x04, 0x00, 0x06, 0x01, 0x02, 0x00,
  0x02, 0x00, 0x06, 0x01, 0x05, 0x05, 0x02, 0x00, 0x02, 0x05,
  0x07, 0x05, 0x05, 0x00, 0x06, 0x05, 0x06, 0x05, 0x06, 0x00,
  0x03, 0x04, 0x04, 0x04, 0x03, 0x00, 0x06, 0x05, 0x05, 0x05,
  0x06, 0x00, 0x07, 0x04, 0x06, 0x04, 0x07, 0x00, 0x07, 0x04,
  0x06, 0x04, 0x04, 0x00, 0x03, 0x04, 0x05, 0x05, 0x03, 0x00,
  0x05, 0x05, 0x07, 0x05, 0x05, 0x00, 0x07, 0x02, 0x02, 0x02,
  0x07, 0x00, 0x01, 0x01, 0x01, 0x05, 0x03, 0x00, 0x05, 0x05,
  0x06, 0x05, 0x05, 0x00, 0x04, 0x04, 0x04, 0x04, 0x07, 0x00,
  0x05, 0x07, 0x07, 0x05, 0x05, 0x00, 0x06, 0x05, 0x05, 0x05,
  0x05, 0x00, 0x02, 0x05, 0x05, 0x05, 0x02, 0x00, 0x06, 0x05,
  0x06, 0x04, 0x04, 0x00, 0x02, 0x05, 0x05, 0x06, 0x03, 0x00,
  0x06, 0x05, 0x06, 0x05, 0x05, 0x00, 0x03, 0x04, 0x02, 0x01,
  0x06, 0x00, 0x07, 0x02, 0x02, 0x02, 0x02, 0x00, 0x05, 0x05,
  0x05, 0x05, 0x07, 0x00, 0x05, 0x05, 0x05, 0x02, 0x02, 0x00,
  0x05, 0x05, 0x07, 0x07, 0x05, 0x00, 0x05, 0x05, 0x02, 0x05,
  0x05, 0x00, 0x05, 0x05, 0x02, 0x02, 0x02, 0x00, 0x07, 0x01,
  0x02, 0x04, 0x07, 0x00, 0x03, 0x02, 0x02, 0x02, 0x03, 0x00,
  0x04, 0x04, 0x02, 0x01, 0x01, 0x00, 0x06, 0x02, 0x02, 0x02,
  0x06, 0x00, 0x02, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x07, 0x00, 0x02, 0x01, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x03, 0x05, 0x05, 0x03, 0x00, 0x04, 0x06, 0x05, 0x05,
  0x06, 0x00, 0x00, 0x03, 0x04, 0x04, 0x03, 0x00, 0x01, 0x03,
  0x05, 0x05, 0x03, 0x00, 0x00, 0x03, 0x05, 0x06, 0x03, 0x00,
  0x03, 0x04, 0x06, 0x04, 0x04, 0x00, 0x00, 0x03, 0x05, 0x03,
  0x01, 0x06, 0x04, 0x06, 0x05, 0x05, 0x05, 0x00, 0x02, 0x00,
  0x06, 0x02, 0x07, 0x00, 0x00, 0x01, 0x00, 0x01, 0x05, 0x02,
  0x04, 0x05, 0x06, 0x05, 0x05, 0x00, 0x02, 0x02, 0x02, 0x02,
  0x01, 0x00, 0x00, 0x05, 0x07, 0x05, 0x05, 0x00, 0x00, 0x06,
  0x05, 0x05, 0x05, 0x00, 0x00, 0x02, 0x05, 0x05, 0x02, 0x00,
  0x00, 0x06, 0x05, 0x05, 0x06, 0x04, 0x00, 0x03, 0x05, 0x05,
  0x03, 0x01, 0x00, 0x03, 0x04, 0x04, 0x04, 0x00, 0x00, 0x03,
  0x06, 0x01, 0x06, 0x00, 0x02, 0x07, 0x02, 0x02, 0x01, 0x00,
  0x00, 0x05, 0x05, 0x05, 0x03, 0x00, 0x00, 0x05, 0x05, 0x05,
  0x02, 0x00, 0x00, 0x05, 0x05, 0x07, 0x05, 0x00, 0x00, 0x05,
  0x02, 0x02, 0x05, 0x00, 0x00, 0x05, 0x05, 0x03, 0x01, 0x06,
  0x00, 0x07, 0x01, 0x02, 0x07, 0x00, 0x03, 0x02, 0x04, 0x02,
  0x03, 0x00, 0x02, 0x02, 0x02, 0x02, 0x02, 0x00, 0x06, 0x02,
  0x01, 0x02, 0x06, 0x00, 0x00, 0x02, 0x05, 0x00, 0x00, 0x00,
  0x07, 0x07, 0x07, 0x07, 0x07, 0x00,
/* 128 to 255 */
  0x05, 0x0a, 0x0a, 0x05, 0x00, 0x00, 0x02, 0x05, 0x06, 0x05,
  0x0a, 0x00, 0x0f, 0x09, 0x08, 0x08, 0x08, 0x00, 0x05, 0x0a,
  0x06, 0x06, 0x00, 0x00, 0x00, 0x02, 0x05, 0x0f, 0x00, 0x00,
  0x06, 0x08, 0x06, 0x09, 0x06, 0x00, 0x06, 0x08, 0x06, 0x08,
  0x06, 0x00, 0x0b, 0x07, 0x08, 0x06, 0x06, 0x00, 0x06, 0x09,
  0x0f, 0x09, 0x06, 0x00, 0x08, 0x04, 0x06, 0x09, 0x00, 0x00,
  0x0f, 0x04, 0x03, 0x04, 0x03, 0x02, 0x0f, 0x05, 0x05, 0x05,
  0x05, 0x00, 0x00, 0x0f, 0x05, 0x05, 0x09, 0x00, 0x02, 0x05,
  0x06, 0x04, 0x04, 0x00, 0x0f, 0x04, 0x02, 0x04, 0x0f, 0x00,
  0x00, 0x07, 0x0a, 0x04, 0x00, 0x00, 0x07, 0x0a, 0x02, 0x04,
  0x03, 0x00, 0x04, 0x0e, 0x0e, 0x04, 0x00, 0x00, 0x0b, 0x0b,
  0x0b, 0x07, 0x02, 0x00, 0x06, 0x09, 0x09, 0x06, 0x09, 0x00,
  0x00, 0x05, 0x09, 0x0b, 0x05, 0x00, 0x00, 0x00, 0x07, 0x06,
  0x07, 0x00, 0x06, 0x09, 0x0f, 0x04, 0x03, 0x00, 0x06, 0x00,
  0x06, 0x06, 0x03, 0x00, 0x0e, 0x08, 0x08, 0x00, 0x00, 0x00,
  0x0e, 0x04, 0x04, 0x00, 0x00, 0x00, 0x0f, 0x09, 0x06, 0x06,
  0x09, 0x00, 0x0f, 0x09, 0x06, 0x01, 0x06, 0x00, 0x02, 0x04,
  0x08, 0x04, 0x0f, 0x00, 0x01, 0x0f, 0x02, 0x0f, 0x08, 0x00,
  0x04, 0x02, 0x01, 0x02, 0x0f, 0x00, 0x01, 0x02, 0x04, 0x0f,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x0b, 0x00, 0x00, 0x04, 0x00,
  0x04, 0x04, 0x04, 0x00, 0x01, 0x07, 0x0a, 0x07, 0x08, 0x00,
  0x02, 0x05, 0x0e, 0x0a, 0x0e, 0x00, 0x00, 0x09, 0x06, 0x06,
  0x09, 0x00, 0x09, 0x05, 0x0f, 0x0f, 0x02, 0x00, 0x04, 0x04,
  0x00, 0x04, 0x04, 0x00, 0x07, 0x08, 0x07, 0x01, 0x0e, 0x00,
  0x03, 0x0a, 0x04, 0x04, 0x00, 0x00, 0x06, 0x09, 0x0b, 0x09,
  0x06, 0x00, 0x06, 0x09, 0x07, 0x00, 0x0f, 0x00, 0x03, 0x06,
  0x0c, 0x06, 0x03, 0x00, 0x00, 0x0f, 0x01, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x0e, 0x00, 0x00, 0x00, 0x06, 0x09, 0x09, 0x0b,
  0x06, 0x00, 0x00, 0x0e, 0x00, 0x00, 0x00, 0x00, 0x06, 0x09,
  0x06, 0x00, 0x00, 0x00, 0x06, 0x0f, 0x06, 0x00, 0x00, 0x00,
  0x02, 0x05, 0x01, 0x02, 0x07, 0x00, 0x02, 0x01, 0x03, 0x01,
  0x03, 0x00, 0x01, 0x0d, 0x01, 0x01, 0x00, 0x00, 0x0a, 0x0a,
  0x0a, 0x0e, 0x08, 0x00, 0x07, 0x0b, 0x07, 0x03, 0x03, 0x00,
  0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x09, 0x06, 0x06, 0x09,
  0x00, 0x00, 0x02, 0x06, 0x02, 0x07, 0x00, 0x00, 0x06, 0x09,
  0x06, 0x00, 0x0f, 0x00, 0x0c, 0x06, 0x03, 0x06, 0x0c, 0x00,
  0x01, 0x05, 0x0a, 0x05, 0x00, 0x00, 0x03, 0x02, 0x02, 0x0a,
  0x04, 0x00, 0x00, 0x05, 0x0b, 0x05, 0x00, 0x00, 0x04, 0x00,
  0x04, 0x09, 0x06, 0x00, 0x0c, 0x0e, 0x0a, 0x0e, 0x0a, 0x00,
  0x06, 0x0e, 0x0a, 0x0e, 0x0a, 0x00, 0x04, 0x0e, 0x0a, 0x0e,
  0x0a, 0x00, 0x0e, 0x0e, 0x0a, 0x0e, 0x0a, 0x00, 0x0a, 0x0e,
  0x0a, 0x0e, 0x0a, 0x00, 0x02, 0x0e, 0x0a, 0x0e, 0x0a, 0x00,
  0x05, 0x0a, 0x0f, 0x0a, 0x03, 0x00, 0x06, 0x08, 0x06, 0x02,
  0x06, 0x00, 0x06, 0x0e, 0x08, 0x0e, 0x08, 0x0e, 0x0c, 0x0e,
  0x08, 0x0e, 0x08, 0x0e, 0x04, 0x0e, 0x08, 0x0e, 0x08, 0x0e,
  0x0a, 0x0e, 0x08, 0x0e, 0x08, 0x0e, 0x06, 0x0e, 0x04, 0x04,
  0x0e, 0x00, 0x0c, 0x0e, 0x04, 0x04, 0x0e, 0x00, 0x04, 0x0e,
  0x04, 0x04, 0x0e, 0x00, 0x0a, 0x0e, 0x04, 0x04, 0x0e, 0x00,
  0x0e, 0x05, 0x0d, 0x05, 0x0e, 0x00, 0x0e, 0x00, 0x0d, 0x0b,
  0x09, 0x00, 0x04, 0x02, 0x04, 0x0a, 0x04, 0x00, 0x04, 0x08,
  0x04, 0x0a, 0x04, 0x00, 0x04, 0x0a, 0x04, 0x0a, 0x04, 0x00,
  0x05, 0x0a, 0x04, 0x0a, 0x04, 0x00, 0x0a, 0x00, 0x04, 0x0a,
  0x04, 0x00, 0x00, 0x00, 0x0a, 0x04, 0x0a, 0x00, 0x06, 0x09,
  0x0b, 0x0d, 0x06, 0x00, 0x08, 0x04, 0x0a, 0x0a, 0x04, 0x00,
  0x02, 0x04, 0x0a, 0x0a, 0x04, 0x00, 0x0e, 0x00, 0x0a, 0x0a,
  0x04, 0x00, 0x0a, 0x00, 0x0a, 0x0a, 0x04, 0x00, 0x02, 0x04,
  0x09, 0x05, 0x02, 0x00, 0x08, 0x0e, 0x09, 0x0f, 0x08, 0x00,
  0x02, 0x05, 0x06, 0x05, 0x0a, 0x00, 0x0c, 0x0e, 0x0a, 0x0e,
  0x0a, 0x00, 0x06, 0x0e, 0x0a, 0x0e, 0x0a, 0x00, 0x04, 0x0e,
  0x0a, 0x0e, 0x0a, 0x00, 0x0e, 0x0e, 0x0a, 0x0e, 0x0a, 0x00,
  0x0a, 0x0e, 0x0a, 0x0e, 0x0a, 0x00, 0x02, 0x0e, 0x0a, 0x0e,
  0x0a, 0x00, 0x05, 0x0a, 0x0f, 0x0a, 0x03, 0x00, 0x06, 0x08,
  0x06, 0x02, 0x06, 0x00, 0x06, 0x0e, 0x08, 0x0e, 0x08, 0x0e,
  0x0c, 0x0e, 0x08, 0x0e, 0x08, 0x0e, 0x04, 0x0e, 0x08, 0x0e,
  0x08, 0x0e, 0x0a, 0x0e, 0x08, 0x0e, 0x08, 0x0e, 0x06, 0x0e,
  0x04, 0x04, 0x0e, 0x00, 0x0c, 0x0e, 0x04, 0x04, 0x0e, 0x00,
  0x04, 0x0e, 0x04, 0x04, 0x0e, 0x00, 0x0a, 0x0e, 0x04, 0x04,
  0x0e, 0x00, 0x0e, 0x05, 0x0d, 0x05, 0x0e, 0x00, 0x0e, 0x00,
  0x0d, 0x0b, 0x09, 0x00, 0x04, 0x02, 0x04, 0x0a, 0x04, 0x00,
  0x04, 0x08, 0x04, 0x0a, 0x04, 0x00, 0x04, 0x0a, 0x04, 0x0a,
  0x04, 0x00, 0x05, 0x0a, 0x04, 0x0a, 0x04, 0x00, 0x0a, 0x00,
  0x04, 0x0a, 0x04, 0x00, 0x04, 0x00, 0x0f, 0x00, 0x04, 0x00,
  0x06, 0x0b, 0x0d, 0x06, 0x00, 0x00, 0x08, 0x04, 0x0a, 0x0a,
  0x04, 0x00, 0x02, 0x04, 0x0a, 0x0a, 0x04, 0x00, 0x0e, 0x00,
  0x0a, 0x0a, 0x04, 0x00, 0x0a, 0x00, 0x0a, 0x0a, 0x04, 0x00,
  0x02, 0x09, 0x0d, 0x02, 0x0e, 0x00, 0x08, 0x0e, 0x09, 0x0f,
  0x08, 0x00, 0x05, 0x05, 0x02, 0x01, 0x06, 0x00
};


#define BUF_SIZE   512
#define CR         '\n'

typedef short error_t;

enum
{ INPUT_NUM, INPUT_PATH, INPUT_ALL };
enum
{ ERR_NONE, ERR_MEMORY, ERR_EXEC, ERR_FILE };
enum
{ EXEC_OTH, EXEC_SC, EXEC_AS };
enum
{ C_WHITE, C_BLACK, C_INVERSE = 128 };
enum
{ I_NONE, I_SECOND, I_DIAMOND, I_SHIFT, I_ALPHA, I_ALOCK, I_CAPS };
enum
{ K_SECOND = 4096, K_DIAMOND = 8192, K_SHIFT = 16384 };

#if defined(TI92P) || defined (USE_TI92PLUS)
enum
{ K_UP = 338, K_DOWN = 344, K_RIGHT = 340, K_LEFT = 337, K_F1 = 268,
  K_F2 = 269, K_F3 = 270, K_F4 = 271, K_F5 = 272, K_F6 = 273, K_F7 = 274,
  K_F8 = 275, K_ESC = 264, K_QUIT = 4360, K_APPS = 265, K_SWITCH = 4361,
  K_MODE = 266, K_BACKSPACE = 257, K_INS = 4353, K_CLEAR = 263,
  K_VARLNK = 4141, K_CHAR = 4139, K_ENTER = 13, K_STO = 258, K_ON = 267,
  K_OFF = 4363, K_COPY = K_DIAMOND + 'c', K_CUT = K_DIAMOND + 'x',
  K_PASTE = K_DIAMOND + 'v'
};
#elif defined(TI89) || defined (USE_TI89)
enum
{ K_UP = 337, K_DOWN = 340, K_RIGHT = 344, K_LEFT = 338, K_F1 = 268,
  K_F2 = 269, K_F3 = 270, K_F4 = 271, K_F5 = 272, K_F6 = 273, K_F7 = 274,
  K_F8 = 275, K_ESC = 264, K_QUIT = 4360, K_APPS = 265, K_SWITCH = 4361,
  K_MODE = 266, K_BACKSPACE = 257, K_INS = 4353, K_CLEAR = 263,
  K_VARLNK = 4141, K_CHAR = 4139, K_ENTER = 13, K_STO = 258, K_ON = 267,
  K_OFF = 4363, K_COPY = K_DIAMOND + 'y', K_CUT = K_DIAMOND + 'x',
  K_PASTE = K_DIAMOND + 'z'
};
#else
# error "Can't find Keys for Target!"
#endif

#if !defined(PEDROM) && (defined(TI89) || defined (USE_TI89))
# define K_COPY  (K_DIAMOND + K_SHIFT)
# define K_PASTE (K_DIAMOND + K_ESC)
# define K_CUT   (K_DIAMOND + K_SECOND)
#endif

VARIABLE const char *filename;
VARIABLE char *file_ptr;
VARIABLE char *end_ptr;
VARIABLE char *page_ptr;
VARIABLE char *curs_ptr;
VARIABLE char *gap_ptr;
VARIABLE char exec_name[28];
VARIABLE char exec_name2[28];
VARIABLE int line, select;
VARIABLE int penCol, penRow, penColor;
VARIABLE int curCol, curRow;
VARIABLE short key_delay, key_rate;
VARIABLE short disp_indic;
VARIABLE char text2_name[28];
VARIABLE unsigned short text2_pos;
VARIABLE HANDLE clipboard;
VARIABLE BOOL cursor_on, modified, refresh;
VARIABLE BOOL auto_code;
VARIABLE BOOL auto_indent;
VARIABLE char find_str[32];
VARIABLE char replace_str[32];


void
init_side (void)
{
  strcpy (exec_name, "as(\"*\",\"*_p\")");
  strcpy (exec_name2, "*_p");
  strcpy (text2_name, "as_error");
  strcpy (replace_str, "");
  strcpy (find_str, "");
  key_delay = 336;
  key_rate = 48;
  disp_indic = I_NONE;
  clipboard = H_NULL;
  auto_code = TRUE;
  auto_indent = TRUE;
  text2_pos = 0;
}

static void
draw_hline (short x1, short x2, short y, short color)
{
  unsigned char *addr = LCD_MEM + (y << 5) - (y << 1) + (x1 >> 3);
  unsigned char mask = 0x80 >> (x1 & 7);

  while (x1++ <= x2)
    {
      if (color & 1)
	*addr |= mask;
      else
	*addr &= ~mask;
      asm ("ror.b #1,%0\n bcc.s SideNextHline\n addq.l #1,%1\nSideNextHline:": "=d" (mask), 
	   "=g" (addr):"0" (mask), "1" (addr));
    }
}

static void
draw_vline (short x, short y1, short y2, short color)
{
  unsigned char *addr = LCD_MEM + (y1 << 5) - (y1 << 1) + (x >> 3);
  unsigned char mask = 0x80 >> (x & 7);

  while (y1++ <= y2)
    {
      if (color & C_INVERSE)
	*addr ^= mask;
      else if (color & 1)
	*addr |= mask;
      else
	*addr &= ~mask;
      addr += 30;
    }
}

static void
window (int w, int h)
{
  short i;
  int x1 = (LCD_WIDTH - w) / 2;
  int x2 = x1 + w;
  int y1 = (LCD_HEIGHT - h) / 2;
  int y2 = y1 + h;

  penRow = y1 + 2;
  penCol = x1 + 2;
  draw_hline (x1, x2, y1, C_BLACK);
  draw_hline (x1, x2, y2, C_BLACK);
  draw_hline (x1 + 1, x2 + 1, y2 + 1, C_BLACK);
  for (i = y1 + 1; i < y2; i++)
    draw_hline (x1, x2, i, C_WHITE);
  draw_vline (x1, y1, y2, C_BLACK);
  draw_vline (x2, y1, y2, C_BLACK);
  draw_vline (x2 + 1, y1 + 1, y2 + 1, C_BLACK);
}

static void
draw_char46 (unsigned short a)
{
  long *addr = (long *) ((char *) LCD_MEM + penRow * 30 +
			 (((penCol - 4) >> 3) & 0xfffe));
  unsigned short cnt = 24 - ((penCol - 4) & 15), h = 6 - 1;
  long mask = ~(0x0FL << cnt);
  const unsigned char *sprite = TextFont46 + a * 6;

  if (penCol == 0)
    addr = (long *) ((char *) LCD_MEM + penRow * 30 - 2);
  if (penColor & C_INVERSE)
    do
      {
	*addr = (*addr & mask) | ((long) (~(*sprite++) & 0x0F) << cnt);
	addr = (long *) ((char *) addr + 30);
      }
    while (h--);
  else
    do
      {
	*addr = (*addr & mask) | (long) (*sprite++) << cnt;
	addr = (long *) ((char *) addr + 30);
      }
    while (h--);
  penCol += 4;
}

#define	read_char(c)                                          \
{ if (stream_ptr == curs_ptr) stream_ptr = gap_ptr;           \
  c = *stream_ptr & 0x00FF;                                   \
  if (c == '\r') { stream_ptr++; c = CR; }                    \
  if (c && c != (EOF&0xFF)) stream_ptr++;                     \
}

static void
draw_text_screen (short nb_row, short nb_col, void *stream)
{
  BOOL end_of_line;
  unsigned short c1, inv, c2, cnt, i;
  unsigned char *scr_line = LCD_MEM + 30 * 8;
  const unsigned char *spr1, *spr2;
  unsigned char *scr_addr, *addr;
  char *sel_low, *sel_hi;
  char *stream_ptr = stream;

  if (select > 0)
    {
      sel_low = curs_ptr;
      sel_hi = gap_ptr + select;
    }
  else
    {
      sel_hi = curs_ptr;
      sel_low = sel_hi + select;
    }

  while (nb_row--)
    {
      scr_addr = scr_line;
      end_of_line = FALSE;
      for (cnt = 0; cnt < (unsigned short) nb_col; cnt += 2)
	{
	  if (end_of_line)
	    {
	      c1 = ' ';
	      c2 = ' ';
	      inv = 0;
	    }
	  else
	    {
	      inv = ((sel_low <= stream_ptr)
		     && (stream_ptr < sel_hi) ? 1 : 0);
	      read_char (c1);
	      if (c1 == CR || c1 == (EOF & 0xFF))
		{
		  end_of_line = TRUE;
		  c1 = ' ';
		  c2 = ' ';
		  inv = 0;
		}
	      else
		{
		  inv |= ((sel_low <= stream_ptr)
			  && (stream_ptr < sel_hi) ? 2 : 0);
		  read_char (c2);
		  if (c2 == CR || c2 == (EOF & 0xFF))
		    {
		      end_of_line = TRUE;
		      c2 = ' ';
		    }
		}
	    }

	  spr1 = TextFont46 + c1 * 6;
	  spr2 = TextFont46 + c2 * 6;
	  addr = scr_addr++;
	  *(addr) = 0;
	  addr += 30;
	  i = 6 - 1;
	  switch (inv)
	    {
	    case 0:
	      do
		{
		  *addr = *(spr1++) << 4 | *(spr2++);
		  addr += 30;
		}
	      while (i--);
	      break;
	    case 1:
	      do
		{
		  *addr = (~*(spr1++)) << 4 | *(spr2++);
		  addr += 30;
		}
	      while (i--);
	      break;
	    case 2:
	      do
		{
		  *addr = *(spr1++) << 4 | ((~*(spr2++)) & 0x0F);
		  addr += 30;
		}
	      while (i--);
	      break;
	    default:
	      do
		{
		  *addr = ~(*(spr1++) << 4 | *(spr2++));
		  addr += 30;
		}
	      while (i--);
	      break;
	    }
	}
      scr_line += 30 * 7;
    }
}

static void
draw_str46 (const char *str)
{
  while (*str)
    draw_char46 (*str++ & 0xFF);
}

static void
draw_str_center46 (const char *str)
{
  penCol = (LCD_WIDTH - strlen (str) * 4) / 2;
  draw_str46 (str);
  penRow += 8;
}

static void
print_str (const char *format, ...)
{
  va_list a;
  va_start (a, format);
  vcbprintf ((vcbprintf_Callback_t) draw_char46, NULL, format, a);
  va_end (a);
}

static void
prepare_bottom (void)
{
  memset (LCD_MEM + (LCD_HEIGHT - 7) * 30, 0, 8 * 30);
  memset (LCD_MEM + (LCD_HEIGHT - 8) * 30, 0xff, 30);
  penCol = 0;
  penRow = LCD_HEIGHT - 7;
  penColor = C_BLACK;
}

static void
show_msg (const char *str)
{
  prepare_bottom ();
  draw_str46 (str);
}

static void
draw_menu_bar (void)
{
  short i;
#if defined(TI92P) || defined (USE_TI92PLUS)
  static const char * const menu[] =
    { "Build", "Exec", "Goto", "Find", "Replace", "Config", "About" };

  prepare_bottom ();
  for (i = 0; i < 7; i++)
    {
      print_str ("F%1d %s", i + 1, menu[i]);
      penCol += 2;
    }
#else
  static const char *const menu[] =
    { "Build", "Exec", "Go", "Find", "Repl", "Conf" };

  prepare_bottom ();
  for (i = 0; i < 6; i++)
    {
      print_str ("F%1d", i + 1);
      penCol ++;
      print_str (menu[i]);
      penCol += 2;
    }
#endif
  refresh = TRUE;
}

static void
turn_off (void)
{
  off ();
  OSInitKeyInitDelay (key_delay);
  OSInitBetweenKeyDelay (key_rate);
}

static short
get_key (void)
{
  long mod;
  short key, indic;
  void *kbq = kbd_queue ();
  unsigned short delay = 0;
  static unsigned char indic_spr[] = {
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x1F, 0x11, 0x1D, 0x19, 0x17, 0x11,
    0x04, 0x0E, 0x1F, 0x0E, 0x04, 0x00,
    0x04, 0x0E, 0x1F, 0x0E, 0x0E, 0x00,
    0x00, 0x06, 0x0A, 0x0A, 0x06, 0x00,
    0x1F, 0x19, 0x15, 0x15, 0x19, 0x1F,
    0x1F, 0x1B, 0x15, 0x11, 0x15, 0x15
  };

  if (cursor_on)
    draw_vline (curCol, curRow, curRow + 6, C_BLACK);
  OSResetTimer (APD_TIMER);
  while (OSdequeue (&key, kbq))
    {
      if (OSTimerExpired (APD_TIMER))
	{
	  turn_off ();
	  OSResetTimer (APD_TIMER);
	  continue;
	}

      mod = STAT_STATE;
      if (mod & STAT_2ND)
	indic = I_SECOND;
      else if (mod & STAT_DIAMOND)
	indic = I_DIAMOND;
      else if (mod & STAT_SHIFT)
	indic = I_SHIFT;
      else if (mod & STAT_ALPHA)
	indic = I_ALPHA;
      else if (mod & STAT_CAPS)
	indic = I_CAPS;
      else if (mod & STAT_ALOCK)
	indic = I_ALOCK;
      else
	indic = I_NONE;

      if (indic != disp_indic)
	{
	  unsigned char *sprite = indic_spr + indic * 6;
	  unsigned char *addr = LCD_MEM + LCD_WIDTH / 8 - 1;
	  short h = 6;

	  for (; h; h--, addr += 30)
	    {
	      *addr &= 0xE0;
	      *addr |= *sprite++;
	    }
	  disp_indic = indic;
	}
      delay++;

      if ((delay ^ (delay + 1)) & 0x2000)
	if (cursor_on)
	  draw_vline (curCol, curRow, curRow + 6, C_BLACK + C_INVERSE);
      idle ();
    }
  key &= 0xF7FF;

  if (key == K_DIAMOND + K_ON || key == K_OFF)
    turn_off ();
  if (cursor_on)
    draw_vline (curCol, curRow, curRow + 6, C_WHITE);
  return key;
}

static error_t
error (error_t state)
{
  prepare_bottom ();
  if (state == ERR_MEMORY)
    draw_str46 ("Out of memory");
  else if (state == ERR_EXEC)
    draw_str46 ("Can't exec command.");
  else
    print_str ("Error opening '%s'", filename);
  get_key ();
  draw_menu_bar ();
  return state;
}

static BOOL
prompt (const char *str)
{
  prepare_bottom ();
  print_str ("%s  [ENTER]=Yes [ESC]=No", str);
  return get_key () == K_ENTER;
}

static BOOL
input_str (char *buf, short maxlen, short mode)
{
  short key, i = strlen (buf);
  short col = penCol;

  do
    {
      buf[i] = 0;
      penCol = col;
      print_str ("%s_ ", buf);
      key = get_key ();
      if (key == K_BACKSPACE && i)
	i--;
      if (i < maxlen &&
	  (isdigit (key) || (mode == INPUT_ALL && 32 <= key && key <= 127) ||
	   (mode == INPUT_PATH
	    && (isalnum (key) || key == '_' || key == '\\'))))
	buf[i++] = (mode == INPUT_PATH) ? tolower (key) : key;
    }
  while (((key != K_ENTER) || !i) && (key != K_ESC));
  return key == K_ENTER;
}

static BOOL
input_num (const char *prompt, int *num)
{
  char buf[5];
  BOOL ret;

  show_msg (prompt);
  buf[0] = 0;
  ret = input_str (buf, 4, INPUT_NUM);
  if (ret)
    *num = atol (buf);
  draw_menu_bar ();
  return ret;
}

static void
draw_title_bar (void)
{
  memset (LCD_MEM, 0, 8 * 30);
  memset (LCD_MEM + 6 * 30, 0xff, 30);
  penColor = C_BLACK;
  penCol = penRow = 0;
  print_str ("[S-IDE]   file:%s", filename);
  disp_indic = I_NONE;
}

static void
about (void)
{
  window (112, 60);
  penRow += 2;
  penColor = C_BLACK;
  draw_str_center46 ("The Small Integrated");
  draw_str_center46 ("Development Environment");
  draw_str_center46 ("v0.1.P9 by Clem Vasseur");
  draw_str_center46 ("<nitro@epita.fr>");
  draw_str_center46 ("Adapted by PpHd for PedroM");
  get_key ();
  draw_menu_bar ();
}

static void
draw_str_config (const char *str1, short mode, void *val)
{
  int col = penCol;
  short i;

  penColor = C_BLACK;
  draw_str46 (str1);
  switch (mode)
    {
    case 0:
      draw_str46 (*(BOOL *) val ? "Yes" : "No ");
      break;
    case 1:
      print_str ("%3d", *(short *) val);
      break;
    default:
      draw_str46 ((char *) val);
      for (i = strlen (val); i < 26; i++)
	draw_char46 (' ');
    }
  penRow += 8;
  penCol = col;
}

static void
config (void)
{
  int row, col, mod;
  short key, cursor = 0;
  char buf[28];

  show_msg ("Move[UP,DOWN], Change[LEFT,RIGHT]");
  window (150 + 8, 54 + 6);
  row = penRow + 2;
  col = penCol;

  do
    {
      penRow = row;
      penCol = col;
      draw_str_config ("  Build: ", 2, exec_name);
      draw_str_config ("  Exec : ", 2, exec_name2);
      draw_str_config ("  2nd Text: ", 2, text2_name);
      draw_str_config ("  Auto insert brackets: ", 0, &auto_code);
      draw_str_config ("  Auto indent: ", 0, &auto_indent);
      draw_str_config ("  Key repeat delay: ", 1, &key_delay);
      draw_str_config ("  Key repeat rate: ", 1, &key_rate);
      penRow = row + cursor * 8;
      penCol += 2;
      draw_char46 ('>');
      mod = 0;
      switch (key = get_key ())
	{
	case K_RIGHT:
	  mod = 1;
	  break;
	case K_LEFT:
	  mod = -1;
	  break;
	case K_UP:
	  if (cursor)
	    cursor--;
	  break;
	case K_DOWN:
	  if (cursor < 6)
	    cursor++;
	}
      if (mod)
	{
	  switch (cursor)
	    {
	    case 0:
	      penCol -= 4;
	      draw_char46 (' ');
	      penCol += 42 - 4 * 3;
	      memcpy (buf, exec_name, 26);
	      if (input_str (buf, 25, INPUT_ALL))
		memcpy (exec_name, buf, 26);
	      break;
	    case 1:
	      penCol -= 4;
	      draw_char46 (' ');
	      penCol += 42 - 4 * 3;
	      memcpy (buf, exec_name2, 26);
	      if (input_str (buf, 25, INPUT_ALL))
		memcpy (exec_name2, buf, 26);
	      break;
	    case 2:
	      penCol -= 4;
	      draw_char46 (' ');
	      penCol += 42;
	      memcpy (buf, text2_name, 18);
	      if (input_str (buf, 17, INPUT_PATH))
		{
		  memcpy (text2_name, buf, 18);
		  text2_pos = 5;
		}
	      break;
	    case 3:
	      auto_code ^= 1;
	      break;
	    case 4:
	      auto_indent ^= 1;
	      break;
	    case 5:
	      mod = key_delay + mod * 10;
	      if (mod > 0 && mod < 400)
		OSInitKeyInitDelay (key_delay = mod);
	      break;
	    default:
	      mod += key_rate;
	      if (mod > 0 && mod < 50)
		OSInitBetweenKeyDelay (key_rate = mod);
	    }
	}
    }
  while (key != K_ENTER && key != K_ESC);
  draw_menu_bar ();
}



static void
forget_selection (void)
{
  if (select != 0)
    {
      select = 0;
      refresh = TRUE;
    }
}

static void
move_right (void)
{
  forget_selection ();
  if (*gap_ptr == EOF)
    return;
  curCol += 4;
  if (*gap_ptr == CR || curCol >= LCD_WIDTH)
    {
      if (*gap_ptr == CR)
	line++;
      curCol = 0;
      curRow += 7;
      if (curRow >= LCD_HEIGHT - 8)
	{
	  short col = LCD_WIDTH;
	  curRow -= 7;
	  while (col > 0 && *page_ptr++ != CR)
	    col -= 4;
	  refresh = TRUE;
	}
    }
  *curs_ptr++ = *gap_ptr++;
}

static void
move_left (void)
{
  forget_selection ();
  if (curs_ptr == file_ptr)
    return;
  *--gap_ptr = *--curs_ptr;
  curCol -= 4;
  if (*gap_ptr == CR || curCol < 0)
    {
      short col = 0;
      if (*gap_ptr == CR)
	line--;
      while ((curs_ptr - col) != file_ptr && *(curs_ptr - col - 1) != CR)
	col++;
      curCol = (col * 4) % LCD_WIDTH;
      curRow -= 7;
      if (curRow < 8)
	{
	  curRow += 7;
	  page_ptr = curs_ptr - (curCol / 4);
	  refresh = TRUE;
	}
    }
}

static void
move_down (void)
{
  int curCol_save = curCol;
  BOOL allow_cr = TRUE;

  do
    {
      move_right ();
      if (!curCol)
	allow_cr = FALSE;
    }
  while (*gap_ptr != EOF &&
	 (allow_cr || ((*gap_ptr != CR) && (curCol < curCol_save))));
}

static void
move_up (void)
{
  int curCol_save = curCol;
  BOOL allow_cr = TRUE;

  do
    {
      if (!curCol)
	allow_cr = FALSE;
      move_left ();
    }
  while (curs_ptr != file_ptr && (allow_cr || (curCol > curCol_save)));
}

static void
move_right_word (void)
{
  while (*gap_ptr != EOF && *gap_ptr != ' ' && *gap_ptr != CR)
    move_right ();
  while (*gap_ptr != EOF && (*gap_ptr == ' ' || *gap_ptr == CR))
    move_right ();
}

static void
move_left_word (void)
{
  do
    {
      move_left ();
    }
  while (curs_ptr != file_ptr && (*gap_ptr == ' ' || *gap_ptr == CR));
  while (curs_ptr != file_ptr && *gap_ptr != ' ' && *gap_ptr != CR)
    move_left ();
  if (curs_ptr != file_ptr)
    move_right ();
}


static BOOL clear_selection (void);

static void
del (void)
{
  if (clear_selection () || *gap_ptr == EOF)
    return;
  gap_ptr++;
  modified = 1;
  refresh = TRUE;
}

static void
back (void)
{
  if (clear_selection () || curs_ptr == file_ptr)
    return;
  move_left ();
  del ();
}

static BOOL
clear_selection (void)
{
  short cnt = select;

  forget_selection ();
  if (cnt > 0)
    while (cnt--)
      del ();
  else if (cnt < 0)
    while (cnt++)
      back ();
  return cnt;
}

static error_t
write (short c)
{
  clear_selection ();
  if (curs_ptr + 2 >= gap_ptr)
    {
      char *ptr;
      long ptr_diff;

      if ((ptr = realloc (file_ptr, end_ptr - file_ptr + 1 + BUF_SIZE)))
	{
	  ptr_diff = ptr - file_ptr;
	  file_ptr = ptr;
	  page_ptr += ptr_diff;
	  curs_ptr += ptr_diff;
	  gap_ptr += ptr_diff;
	  end_ptr += ptr_diff;
	  gap_ptr =
	    memmove (gap_ptr + BUF_SIZE, gap_ptr, end_ptr - gap_ptr + 1);
	  end_ptr += BUF_SIZE;
	}
      else
	return error (ERR_MEMORY);
    }

  *--gap_ptr = c;
  move_right ();
  modified = 1;
  refresh = TRUE;
  if (!auto_code)
    return ERR_NONE;
  if (c == '(')
    c = ')';
  else if (c == '[')
    c = ']';
  else if (c == '{')
    c = '}';
  else if (c == '\'' || c == '\"');
  else
    return ERR_NONE;
  *--gap_ptr = c;
  return ERR_NONE;
}

static void
clear_line (void)
{
  if (!clear_selection ())
    while (*gap_ptr != CR && *gap_ptr != EOF)
      del ();
}

static void
line_start (void)
{
  forget_selection ();
  while (curs_ptr != file_ptr && *(curs_ptr - 1) != CR)
    move_left ();
}

static void
line_end (void)
{
  forget_selection ();
  while (*gap_ptr != EOF && *gap_ptr != CR)
    move_right ();
}

static void
page_top (void)
{
  forget_selection ();
  while (curs_ptr != file_ptr)
    move_up ();
}

static void
page_end (void)
{
  forget_selection ();
  while (*gap_ptr != EOF)
    move_down ();
}

static void
page_up (void)
{
  short i = (LCD_HEIGHT - 16) / 7;
  while (i--)
    move_up ();
}

static void
page_down (void)
{
  short i = (LCD_HEIGHT - 16) / 7;
  while (i--)
    move_down ();
}

static void
select_proc (void (*proc) (void))
{
  short sel = select;
  char *ptr = curs_ptr;

  proc ();
  select = sel + ptr - curs_ptr;
  refresh = TRUE;
}

static void
select_right (void)
{
  select_proc (move_right);
}

static void
select_left (void)
{
  select_proc (move_left);
}

static void
select_up (void)
{
  select_proc (move_up);
}

static void
select_down (void)
{
  select_proc (move_down);
}

static void
go_line (void)
{
  int target_line = 0;

  if (!input_num ("Goto line: ", &target_line))
    return;
  if (!target_line)
    target_line++;
  if (line > target_line)
    while (line > target_line)
      move_up ();
  else
    while (line < target_line && *gap_ptr != EOF)
      move_down ();
}


static error_t
clipboard_copy (void)
{
  short cnt;
  HANDLE n_clipboard;

  unsigned short c;
  char *stream_ptr;

  if (!select)
    return ERR_NONE;
  if (select > 0)
    {
      cnt = select;
      stream_ptr = gap_ptr;
    }
  else
    {
      cnt = -select;
      stream_ptr = curs_ptr - cnt;
    }
  if ((n_clipboard = HeapRealloc (clipboard, cnt + 1)))
    {
      char *buf = HeapDeref (clipboard = n_clipboard);
      while (cnt--)
	{
	  read_char (c);
	  *buf++ = c /*read_char() */ ;
	}
      *buf = EOF;
      return ERR_NONE;
    }
  return error (ERR_MEMORY);
}

static void
clipboard_paste (void)
{
  char *buf;
  BOOL auto_code_saved = auto_code;

  if (clipboard == H_NULL)
    return;
  auto_code = FALSE;
  buf = HLock (clipboard);
  while (*buf != EOF && write (*buf++) == ERR_NONE);
  HeapUnlock (clipboard);
  auto_code = auto_code_saved;
}


static void
find (void)
{
  int find_str_len;
  show_msg ("Find: ");
  if (input_str (find_str, 31, INPUT_ALL))
    {
      find_str_len = strlen (find_str);
      do
	move_right ();
      while (*gap_ptr != EOF && strncmp (gap_ptr, find_str, find_str_len));
    }
  draw_menu_bar ();
}

static void
replace (void)
{
  const char *a;
  int doit = 1, key, find_str_len;

  show_msg ("Replace: ");
  if (input_str (find_str, 31, INPUT_ALL))
    {
      show_msg ("By: ");
      if (input_str (replace_str, 31, INPUT_ALL))
	{
	  find_str_len = strlen (find_str);
	  while (*gap_ptr != EOF && doit)
	    {
	      // Find it
	      do
		move_right ();
	      while (*gap_ptr != EOF
		     && strncmp (gap_ptr, find_str, find_str_len));
	      if (*gap_ptr != EOF)
		{
		  a = find_str;
		  while (*a++)
		    select_right ();
		  draw_text_screen ((LCD_HEIGHT - 16) / 7, LCD_WIDTH / 4,
				    page_ptr);
		  show_msg
		    ("Replace[ENTER], Next[F1], All[F5], Cancel[ESC]");
		  if (doit == 1)
		    key = get_key ();
		  else
		    key = K_ENTER;
		  switch (key)
		    {
		    case K_F5:
		      doit = 2;
		    case K_ENTER:
		      del ();
		      a = replace_str;
		      while (*a)
			write (*a++);
		      break;
		    case K_ESC:
		      doit = 0;
		    default:
		      break;
		    }
		}
	    }
	}
    }
  draw_menu_bar ();
}

#define FS_OK 0
#define SYM_LEN 8
#define MAX_SYM_LEN (4 + (SYM_LEN) * 2)

static error_t
open_file (void)
{
  SYM_ENTRY *sym;
  char sym_buf[MAX_SYM_LEN];
  char *sym_buf_ptr = sym_buf + MAX_SYM_LEN - 1;
  size_t size;
  short *sptr = NULL;
  char *ptr;

  if (TokenizeName (filename, sym_buf) != FS_OK)
    return error (ERR_FILE);
  if ((sym = SymFindPtr (sym_buf_ptr, 0)))
    {
      if (*(unsigned char *) HToESI (sym->handle) != TEXT_TAG
	  || sym->flags.bits.in_view == 1)
	return error (ERR_FILE);
      sym->flags.bits.in_view = 1;
      sptr = HeapDeref (sym->handle);
      size = *sptr - 5;
      sptr += 2;
      ptr = (char *) sptr;
      if (!(file_ptr = malloc (size + BUF_SIZE + 1)))
	return error (ERR_MEMORY);
      page_ptr = curs_ptr = file_ptr;
      end_ptr = gap_ptr = file_ptr + BUF_SIZE;
      while (*++ptr)
	if (*ptr == '\r')
	  {
	    *end_ptr++ = CR;
	    ptr++;
	  }
	else
	  *end_ptr++ = *ptr;
    }
  else if (DerefSym (SymAdd (sym_buf_ptr)))
    {
      SymDel (sym_buf_ptr);
      if (!(file_ptr = malloc (BUF_SIZE + 1)))
	return error (ERR_MEMORY);
      page_ptr = curs_ptr = file_ptr;
      end_ptr = gap_ptr = file_ptr + BUF_SIZE;
    }
  else
    return error (ERR_FILE);
  *end_ptr = EOF;
  line = 1;
  modified = FALSE;
  curCol = select = 0;
  curRow = 8;
  if (sptr)
    {
      sptr--;
      size = 1;
      while ((short) (curs_ptr - file_ptr + size) < *sptr)
	{
	  if (*gap_ptr == CR)
	    size++;
	  move_right ();
	}
    }
  return ERR_NONE;
}

static error_t
unuse_file (void)
{
  SYM_ENTRY *sym;
  char sym_buf[MAX_SYM_LEN];
  if (TokenizeName (filename, sym_buf) != FS_OK)
    return ERR_FILE;
  if (!(sym = SymFindPtr (sym_buf + MAX_SYM_LEN - 1, 0)))
    return ERR_FILE;
  sym->flags.bits.in_view = 0;
  return ERR_NONE;
}

static error_t
save_file (void)
{
  BOOL archived;
  SYM_ENTRY *sym;
  HANDLE handle;
  char sym_buf[MAX_SYM_LEN];
  char *sym_buf_ptr = sym_buf + MAX_SYM_LEN - 1;
  char *src, *ptr = NULL;
  size_t size = curs_ptr - file_ptr + end_ptr - gap_ptr + 7;
  size_t curs_size = 1;

  if (!modified)
    return ERR_NONE;
  if (TokenizeName (filename, sym_buf) != FS_OK)
    return error (ERR_FILE);
  if (!(sym = SymFindPtr (sym_buf_ptr, 0)) &&
      !(sym = DerefSym (SymAdd (sym_buf_ptr))))
    return error (ERR_FILE);
  if ((archived = sym->flags.bits.archived))
    if (!EM_moveSymFromExtMem (sym_buf_ptr, HS_NULL))
      return error (ERR_MEMORY);
  for (src = file_ptr; src < end_ptr; src++)
    {
      if (src == curs_ptr)
	src = gap_ptr;
      if (*src == CR)
	{
	  size++;
	  if (src < curs_ptr)
	    curs_size++;
	}
    }
  HeapUnlock (sym->handle);
  if ((handle = HeapRealloc (sym->handle, size)))
    {
      sym->handle = handle;
      ptr = HeapDeref (handle);
      *(short *) ptr = size - 2;
      ptr += 2;
      *(short *) ptr = curs_ptr - file_ptr + curs_size;
      ptr += 2;
      *ptr++ = 0x20;
      for (src = file_ptr; src < end_ptr; src++)
	{
	  if (src == curs_ptr)
	    src = gap_ptr;
	  if (*src == CR)
	    {
	      *ptr++ = '\r';
	      *ptr++ = 0x20;
	    }
	  else if (*src != EOF)
	    *ptr++ = *src;
	}
      *ptr++ = 0x00;
      *ptr++ = 0xE0;
    }
  if (archived)
    {
#ifndef PEDROM
      pushkey(K_ENTER);
      EM_moveSymToExtMem (sym_buf_ptr, HS_NULL);
      GKeyFlush();
#else
      EM_moveSymToExtMem (sym_buf_ptr, HS_NULL);
#endif
    }
  if (!ptr)
    return error (ERR_MEMORY);
  modified = 0;
  return ERR_NONE;
}

static void
chars_table (void)
{
  short i, j, key;
  short c_col = 0, c_row = 0;
  short col, row;

  show_msg ("Move[ARROWS], Copy[ENTER], Cancel[ESC]");
  /* 24 x 10 */
  window (24 * 5 + 3, 10 * 8 + 2);
  col = penCol;
  row = penRow;

  do
    {
      penRow = row;
      for (i = 0; i < 10; i++)
	{
	  penCol = col;
	  for (j = 0; j < 24; j++)
	    {
	      penColor = C_BLACK;
	      if (i == c_row && j == c_col)
		penColor += C_INVERSE;
	      draw_char46 (16 + i * 24 + j);
	      penCol++;
	    }
	  penRow += 8;
	}
      switch (key = get_key ())
	{
	case K_RIGHT:
	  c_col = (c_col + 1) % 24;
	  break;
	case K_LEFT:
	  c_col = ((--c_col) < 0 ? 23 : c_col);
	  break;
	case K_UP:
	  c_row = ((--c_row) < 0 ? 9 : c_row);
	  break;
	case K_DOWN:
	  c_row = (c_row + 1) % 10;
	  break;
	case K_ENTER:
	  write (16 + c_row * 24 + c_col);
	}
    }
  while (key != K_ENTER && key != K_ESC);
  draw_menu_bar ();
}

static void
compile (const char name[])
{
  char *dest;
  const char *src, *f;
  char cmd[64];

  if (save_file () != ERR_NONE)
    return;

  dest = cmd;
  for (src = name; *src; src++)
    if (*src == '*')
      for (f = filename; *f; f++)
	*dest++ = *f;
    else
      *dest++ = *src;
  *dest = 0;

  show_msg ("Execute: ");
  if (!input_str (cmd, 63, INPUT_ALL))
    return;
  ScreenClear ();
#ifdef	PEDROM
  system (cmd);
#else
  {
    HANDLE handle = 0;

    TRY
      {
	push_parse_text (cmd);
	handle = HS_popEStack ();
	NG_execute (handle, 0);
      }
    ONERR
      error (ERR_EXEC);
    ENDTRY;
    if (handle)
      HeapFree (handle);
  }
#endif
  PortRestore ();
  show_msg ("Press any key to continue.");
  get_key ();

  ScreenClear ();
  refresh = TRUE;
  draw_title_bar ();
  draw_menu_bar ();
}

static void
show_text2 (void)
{
  char *ptr;
  SYM_ENTRY *sym;
  short key;
  HANDLE hd;
  BOOL lock;
  char buff_name[20];

  sym =  SymFindPtr (StrToTokN (text2_name, buff_name), 0);
  if (sym == NULL)
    return;
  show_msg ("Scroll[UP,DOWN], Cancel[ESC,APPS]");
  hd = sym->handle;
  lock = HeapGetLock (hd);
  ptr = HLock (hd);
  do
    {
      draw_text_screen ((LCD_HEIGHT - 16) / 7, LCD_WIDTH / 4,
			ptr + text2_pos);
      key = get_key ();
      if (key == K_DOWN)
	{
	  key = LCD_WIDTH / 4;
	  while (key-- && ptr[text2_pos] && ptr[++text2_pos - 2] != '\r');
	  key = ptr[text2_pos] ? 0 : K_UP;
	}
      if (key == K_UP)
	{
	  key = LCD_WIDTH / 4;
	  while (key-- && text2_pos > 5 && ptr[--text2_pos - 2] != '\r');
	}
    }
  while (key != K_APPS && key != K_ESC);
  if (lock)
    HeapUnlock (hd);
  refresh = TRUE;
  draw_menu_bar ();
}

static void
write_cr (void)
{
  short nb_spaces = 0;
  char *ptr = curs_ptr;

  write (CR);
  if (!auto_indent)
    return;
  while (ptr != file_ptr && *--ptr != CR)
    if (*ptr == ' ')
      nb_spaces++;
    else
      nb_spaces = 0;
  while (nb_spaces--)
    write (' ');
}

void
run_side (void)
{
  char filebuffer[28];
  short key;

  if (filename)
    strcpy (filebuffer, filename);
  else
    filebuffer[0] = '\0';
  filename = filebuffer;

  do
    {
      ScreenClear ();
      draw_title_bar ();
      if (filebuffer[0] == 0)
	{
	  show_msg ("Filename: ");
	  if (!input_str (filebuffer, 17, INPUT_PATH))
	    return;
	  draw_title_bar ();
	}
      show_msg ("Loading ...");
      if (open_file () != ERR_NONE)
	return;
      draw_menu_bar ();
      refresh = TRUE;

      do
	{
	  penRow = 0;
	  penCol = LCD_WIDTH - 24;
	  penColor = C_BLACK;
	  print_str ("%4d", line);
	  if (refresh)
	    draw_text_screen ((LCD_HEIGHT - 16) / 7, LCD_WIDTH / 4, page_ptr);
	  refresh = FALSE;
	  cursor_on = TRUE;
	  key = get_key ();
	  cursor_on = FALSE;
	  if (16 <= key && key <= 255)
	    write (key);
	  else
	    switch (key)
	      {
	      case K_COPY:
		clipboard_copy ();
		break;
	      case K_PASTE:
		clipboard_paste ();
		break;
	      case K_CUT:
		if (clipboard_copy () == ERR_NONE)
		  clear_selection ();
		break;
	      case K_LEFT:
		move_left ();
		break;
	      case K_RIGHT:
		move_right ();
		break;
	      case K_UP:
		move_up ();
		break;
	      case K_DOWN:
		move_down ();
		break;
	      case K_SECOND + K_LEFT:
		line_start ();
		break;
	      case K_SECOND + K_RIGHT:
		line_end ();
		break;
	      case K_SECOND + K_UP:
		page_up ();
		break;
	      case K_SECOND + K_DOWN:
		page_down ();
		break;
	      case K_SHIFT + K_LEFT:
		select_left ();
		break;
	      case K_SHIFT + K_RIGHT:
		select_right ();
		break;
	      case K_SHIFT + K_UP:
		select_up ();
		break;
	      case K_SHIFT + K_DOWN:
		select_down ();
		break;
	      case K_DIAMOND + K_UP:
		page_top ();
		break;
	      case K_DIAMOND + K_DOWN:
		page_end ();
		break;
	      case K_DIAMOND + K_LEFT:
		move_left_word ();
		break;
	      case K_DIAMOND + K_RIGHT:
		move_right_word ();
		break;
	      case K_BACKSPACE:
		back ();
		break;
	      case K_DIAMOND + K_BACKSPACE:
		del ();
		break;
	      case K_ENTER:
		write_cr ();
		break;
	      case K_CLEAR:
		clear_line ();
		break;
	      case K_CHAR:
		chars_table ();
		break;
	      case K_APPS:
		show_text2 ();
		break;
	      case K_F1:
		compile (exec_name);
		break;
	      case K_F2:
		compile (exec_name2);
		break;
	      case K_F3:
		go_line ();
		break;
	      case K_F4:
		find ();
		break;
	      case K_F5:
		replace ();
		break;
	      case K_F6:
		config ();
		break;
	      case K_F7:
		about ();
		break;
#ifdef	PEDROM
	      default:
		PID_CheckSwitch (key, filename);
		break;
#endif
	      }
	}
      while (key != K_ESC && key != K_QUIT);

      if (modified && prompt ("Save changes?"))
	{
	  memset (LCD_MEM + 30 * 8, 0, 30 * (LCD_HEIGHT - 16));
	  save_file ();
	}
      unuse_file ();
      free (file_ptr);
      filebuffer[0] = '\0';
    }
  while (key != K_QUIT);
}

#ifndef	PEDROM
void
_main (void)
{
  short save_key_delay;
  short save_key_rate;
  ESI argptr = top_estack;
  unsigned char *flag;

  init_side ();
  if (ArgCount () == 1 && GetArgType (argptr) == STR_TAG)
    filename = GetStrnArg (argptr);
  else
    filename = NULL;
  save_key_delay = OSInitKeyInitDelay (key_delay);
  save_key_rate = OSInitBetweenKeyDelay (key_rate);
  PortRestore ();

  clipboard = H_NULL;
  /* KK fixs. */
  flag = (unsigned char *) &ST_flags;
  flag++;
  *flag &= ~(1 << 4);
  run_side ();
  *flag |= 1<<4;

  if (clipboard != H_NULL)
    HeapFree (clipboard);
  OSInitKeyInitDelay (save_key_delay);
  OSInitBetweenKeyDelay (save_key_rate);
}
#endif
