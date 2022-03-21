/* Test IEEE-754 conformance. Compile with:
 *   gcc -Wall -O2 -std=c99 tst-ieee754.c -o tst-ieee754 -lm
 * for instance.
 * To test SSE on Pentium 4 in 32 bits, add "-march=pentium4 -mfpmath=sse".
 */
#define NO_FENV_H
#define SVNID "$Id: tst-ieee754.c,v 1.1 2008/05/05 16:16:02 pphd Exp $"

#include <stdio.h>
#include <float.h>
#include <math.h>

#ifndef NO_FENV_H
#include <fenv.h>
#pragma STDC FENV_ACCESS ON
#endif

#ifndef NAN
#define NAN (0.0/0.0)
#endif

#ifndef INFINITY
#define INFINITY (1.0/0.0)
#endif

#define DBL_NAN (NAN)
#define DBL_POS_INF (INFINITY)
#define DBL_NEG_INF (- DBL_POS_INF)

/* <float.h> constants */
static void float_h (void)
{
  printf ("FLT_RADIX = %d\n", (int) FLT_RADIX);
  printf ("FLT_MANT_DIG = %d\n", (int) FLT_MANT_DIG);
  printf ("DBL_MANT_DIG = %d\n", (int) DBL_MANT_DIG);
  printf ("LDBL_MANT_DIG = %d\n\n", (int) LDBL_MANT_DIG);

  printf ("FLT_MIN_EXP = %d\n", (int) FLT_MIN_EXP);
  printf ("DBL_MIN_EXP = %d\n", (int) DBL_MIN_EXP);
  printf ("LDBL_MIN_EXP = %d\n\n", (int) LDBL_MIN_EXP);

  printf ("FLT_MAX_EXP = %d\n", (int) FLT_MAX_EXP);
  printf ("DBL_MAX_EXP = %d\n", (int) DBL_MAX_EXP);
  printf ("LDBL_MAX_EXP = %d\n\n", (int) LDBL_MAX_EXP);

  printf ("FLT_EPSILON = %g\n", (double) FLT_EPSILON);
  printf ("DBL_EPSILON = %g\n", (double) DBL_EPSILON);
  printf ("LDBL_EPSILON = %Lg\n\n", (long double) LDBL_EPSILON);

  printf ("FLT_MIN = %g\n", (double) FLT_MIN);
  printf ("DBL_MIN = %g\n", (double) DBL_MIN);
  printf ("LDBL_MIN = %Lg\n\n", (long double) LDBL_MIN);

  printf ("FLT_MAX = %g\n", (double) FLT_MAX);
  printf ("DBL_MAX = %g\n", (double) DBL_MAX);
  printf ("LDBL_MAX = %Lg\n\n", (long double) LDBL_MAX);
}

static void tstcast (void)
{
  double x;
  x = (double) 0;
  printf ("(double) 0 = %g\n", x);
}

static void tstadd (double x, double y)
{
  double a, s;

  a = x + y;
  s = x - y;
  printf ("%g + %g = %g\n", x, y, a);
  printf ("%g - %g = %g\n", x, y, s);
}

static void tstmul (double x, double y)
{
  double m;

  m = x * y;
  printf ("%g * %g = %g\n", x, y, m);
}

static void tstpow (void)
{
  double val[] = { 0.0, 0.0, 0.0, +0.0, -0.0,
                   +0.5, -0.5, +1.0, -1.0, +2.0, -2.0 };
  int i, j;

  /* Not used above to avoid an error with IRIX64 cc. */
  val[0] = DBL_NAN;
  val[1] = DBL_POS_INF;
  val[2] = DBL_NEG_INF;

  for (i = 0; i < sizeof (val) / sizeof (val[0]); i++)
    for (j = 0; j < sizeof (val) / sizeof (val[0]); j++)
      {
        double p;
        p = pow (val[i], val[j]);
        printf ("pow(%g, %g) = %g\n", val[i], val[j], p);
      }
}

static void tstall (void)
{
  tstcast ();

  tstadd (+0.0, +0.0);
  tstadd (+0.0, -0.0);
  tstadd (-0.0, +0.0);
  tstadd (-0.0, -0.0);
  tstadd (+1.0, +1.0);
  tstadd (+1.0, -1.0);

  tstmul (+0.0, +0.0);
  tstmul (+0.0, -0.0);
  tstmul (-0.0, +0.0);
  tstmul (-0.0, -0.0);

  tstpow ();
}

static void tsteval_method (void)
{
  volatile double x, y, z;

#if __STDC__ == 1 && __STDC_VERSION__ >= 199901 && defined(__STDC_IEC_559__)
  printf ("__STDC_IEC_559__ defined:\n"
          "The implementation shall conform to the IEEE-754 standard.\n"
          "FLT_EVAL_METHOD is %d (see ISO/IEC 9899, 5.2.4.2.2#7).\n\n",
          (int) FLT_EVAL_METHOD);
#endif

  x = 9007199254740994.0; /* 2^53 + 2 */
  y = 1.0 - 1/65536.0;
  z = x + y;
  printf ("x + y, with x = 9007199254740994.0 and y = 1.0 - 1/65536.0\n"
          "The IEEE-754 result is 9007199254740994 with double precision.\n"
          "The IEEE-754 result is 9007199254740996 with extended precision.\n"
          "The obtained result is %.17g.\n", z);

  if (z == 9007199254740996.0)  /* computations in extended precision */
    {
      volatile double a, b;
      double c;

      a = 9007199254740992.0; /* 2^53 */
      b = a + 0.25;
      c = a + 0.25;
      if (b != c)
        printf ("\nBUG:\nThe implementation doesn't seem to convert values "
                "to the target type after\nan assignment (see ISO/IEC 9899: "
                "5.1.2.3#12, 6.3.1.5#2 and 6.3.1.8#2[52]).\n");
    }
}

static void tstnan (void)
{
  double d;

  /* Various tests to detect a NaN without using the math library (-lm).
   * MIPSpro 7.3.1.3m (IRIX64) does too many optimisations, so that
   * both NAN != NAN and !(NAN >= 0.0 || NAN <= 0.0) give 0 instead
   * of 1. As a consequence, in MPFR, one needs to use
   *    #define DOUBLE_ISNAN(x) (!(((x) >= 0.0) + ((x) <= 0.0)))
   * in this case. */

  d = NAN;
  printf ("\n");
  printf ("NAN != NAN --> %d (should be 1)\n", d != d);
  printf ("isnan(NAN) --> %d (should be 1)\n", isnan (d));
  printf ("NAN >= 0.0 --> %d (should be 0)\n", d >= 0.0);
  printf ("NAN <= 0.0 --> %d (should be 0)\n", d <= 0.0);
  printf ("  #3||#4   --> %d (should be 0)\n", d >= 0.0 || d <= 0.0);
  printf ("!(#3||#4)  --> %d (should be 1)\n", !(d >= 0.0 || d <= 0.0));
  printf ("  #3 + #4  --> %d (should be 0)\n", (d >= 0.0) + (d <= 0.0));
  printf ("!(#3 + #4) --> %d (should be 1)\n", !((d >= 0.0) + (d <= 0.0)));
}

int main (void)
{
  printf ("%s\n\n", SVNID);

  float_h ();
  tsteval_method ();
  tstnan ();

  printf ("\nRounding to nearest\n");
#ifdef FE_TONEAREST
  if (fesetround (FE_TONEAREST))
    printf ("Error, but let's do the test since it "
            "should be the default rounding mode.\n");
#endif
  tstall ();

#ifdef FE_TOWARDZERO
  printf ("\nRounding toward 0\n");
  if (fesetround (FE_TOWARDZERO))
    printf ("Error\n");
  else
    tstall ();
#endif

#ifdef FE_DOWNWARD
  printf ("\nRounding to -oo\n");
  if (fesetround (FE_DOWNWARD))
    printf ("Error\n");
  else
    tstall ();
#endif

#ifdef FE_UPWARD
  printf ("\nRounding to +oo\n");
  if (fesetround (FE_UPWARD))
    printf ("Error\n");
  else
    tstall ();
#endif

  return 0;
}
