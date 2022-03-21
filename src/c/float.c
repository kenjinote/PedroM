/*
;* PedroM - Operating System for Ti-89/Ti-92+/V200.
;* Copyright (C) 2003, 2005 Patrick Pelissier
;*
;* This program is free software ; you can redistribute it and/or modify it under the
;* terms of the GNU General Public License as published by the Free Software Foundation;
;* either version 2 of the License, or (at your option) any later version. 
;* 
;* This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
;* without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
;* See the GNU General Public License for more details. 
;* 
;* You should have received a copy of the GNU General Public License along with this program;
;* if not, write to the 
;* Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA 
 */

#include "PedroM-Internal.h"

/* TODO: Completly buggy! To rewrite from scrash! */

static const internal_bcd tan_range[] = {
  {0x0000,0x3FFF,0x63661977,0x23675814}, /* 2/pi to extended precision */
  {0x0000,0x4000,0x15708007,0x81250000}, /* M1 = 1.57080078125 exactly */
  {0xFFFF,0x3FFA,0x44544551,0x03000000}  /* M2 = pi/2-M1 to ext. prec.: -.4454455103e-5 */
  };

static const poly_bcd tanp_poly = {
  4, {
  {0xFFFF,0x3FFB,0x17861707,0x34225442}, /* p3 = -0.17861707342254426711e-4 */
  {0x0000,0x3FFD,0x34248878,0x23589058}, /* p2 =  0.34248878235890589960e-2 */
  {0xFFFF,0x3FFF,0x13338350,0x00642196}, /* p1 = -0.13338350006421960681e+0 */
  {0x0000,0x4000,0x10000000,0x00000000}  /* p0 =  1.0 */
  }};
static const poly_bcd tanq_poly = {
  5, {
  {0x0000,0x3FF9,0x49819433,0x99378651}, /* q4 =  0.49819433993786512270e-6 */
  {0xFFFF,0x3FFC,0x31181531,0x90701002}, /* q3 = -0.31181531907010027307e-3 */
  {0x0000,0x3FFE,0x25663832,0x28944011}, /* q2 =  0.25663832289440112864e-1 */
  {0xFFFF,0x3FFF,0x46671683,0x33975529}, /* q1 = -0.46671683339755294240e+0 */
  {0x0000,0x4000,0x10000000,0x00000000}  /* q0 =  1.0 */
  }};  
static const poly_bcd asnacsp_poly = {
  5, {
  {0xFFFF,0x3FFF,0x69674573,0x44735064}, /* p5 = -0.69674573447350646411e0 */
  {0x0000,0x4001,0x10152522,0x23380646}, /* p4 =  0.10152522233806463645e2 */
  {0xFFFF,0x4001,0x39688862,0x99750487}, /* p3 = -0.39688862997504877339e2 */
  {0x0000,0x4001,0x57208227,0x87789173}, /* p2 =  0.57208227877891731407e2 */
  {0xFFFF,0x4001,0x27368494,0x52416425}  /* p1 = -0.27368494524164255994e2 */
  }};
static const poly_bcd asnacsq_poly = {
  6, {
  {0x0000,0x4000,0x10000000,0x00000000}, /* q4 = -0.23823859153670238830e2 */  	
  {0xFFFF,0x4001,0x23823859,0x15367023}, /* q4 = -0.23823859153670238830e2 */
  {0x0000,0x4002,0x15095270,0x84103060}, /* q3 =  0.15095270841030604719e3 */
  {0xFFFF,0x4002,0x38186303,0x36175014}, /* q2 = -0.38186303361750149284e3 */
  {0x0000,0x4002,0x41714430,0x24826041}, /* q1 =  0.41714430248260412556e3 */
  {0xFFFF,0x4002,0x16421096,0x71449856}  /* q0 = -0.16421096714498560795e3 */
  }};

void	FloatTan(void)
{
  range_red range;

  if (FIsZero(FloatReg1))	return;  
  range = FRangeRedByMod(FloatReg1, tan_range);

  if (FIsGreaterThan10Pow(range.x, -10))
	{
	internal_bcd g, xnum, xden;
	g = FSquare(range.x);
	xnum = FMul( FPolyEval(&tanp_poly, g), range.x);
	xden = FPolyEval(&tanq_poly, g);
	if (range.n&1)
		xden.sign ^= 0xFFFF;
	FloatReg1 = FDiv(xnum, xden);
	}
   else if (range.n & 1)
	FloatReg1 = FDiv(FloatMinusOne, range.x);
}

void	_asnacs(int acs_flag)
{
  internal_bcd ix,g;
  int sign,flags;

  sign = FloatReg1.sign;
  FloatReg1.sign = 0;

  if (FUCmp(FloatReg1,FloatHalf) >=0 ) {
    if (FIsGreaterThan10Pow(FloatReg1,0))
      goto error;
    flags = acs_flag ? sign ? 0xe : 0x0 : sign ? 0xd : 0xc;
    g = FMul(FSub(FloatOne, FloatReg1), FloatHalf);
    ix = FMult2(FSqrt(g));
  } else {
    flags=acs_flag ? sign ? 0x4 : 0xc : sign ? 0x1 : 0x0;
    ix = FloatReg1;
    if (!FIsGreaterThan10Pow(ix,-10))
      goto very_small;
    g = FSquare(FloatReg1);
  }
  FloatReg1 = FSpike(FDiv(FPolyEval(&asnacsq_poly, g), FPolyEval(&asnacsp_poly, g)), ix);

very_small:
  if (flags & 8)
    FloatReg1.sign ^= 0xFFFF;
  if (flags & 0x4) {
    if (flags & 0x2)
      FloatReg1 = FAdd(FloatReg1, FloatPi);
    else
      FloatReg1 = FAdd(FloatReg1, FloatPiDiv2);
  }
  if (flags & 0x1)
    FloatReg1.sign ^= 0xFFFF;
  return;

error:
  FloatReg1 = FloatNAN;
}

void	FloatAsin(void)
{
  if (FIsZero(FloatReg1))
  	return;
  else	_asnacs(0);
}

void	FloatAcos(void)
{
  _asnacs(1);
}

