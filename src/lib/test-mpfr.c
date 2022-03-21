/* Include all relevants tests files for MPFR into a PedroM builtin command */
#define HAVE_STDARG 1
#define HAVE_ATTRIBUTE_MODE 1
#define MPFR_HAVE_GMP_IMPL 1
#define MPFR_NEED_LONGLONG_H

/* To avoid exiting one test before the next one */
#define exit(c) ( (c) != 0 ? (exit) (c) : 0 )

#define main main_mpfr_tversion
#include "mpfr/tests/tversion.c"
#undef main

#define main main_mpfr_tinternals
#include "mpfr/tests/tinternals.c"
#undef main

#define main main_mpfr_tinits
#include "mpfr/tests/tinits.c"
#undef main

#define main main_mpfr_tisqrt
#include "mpfr/tests/tisqrt.c"
#undef main

#define main main_mpfr_tsgn
#include "mpfr/tests/tsgn.c"
#undef main

#define main main_mpfr_tcheck
#include "mpfr/tests/tcheck.c"
#undef main
#undef ERROR

#define main main_mpfr_tisnan
#include "mpfr/tests/tisnan.c"
#undef main

#define main main_mpfr_texceptions
#include "mpfr/tests/texceptions.c"
#undef main
#undef ERROR

#define main main_mpfr_tset_exp
#include "mpfr/tests/tset_exp.c"
#undef main

#define main main_mpfr_tset
#include "mpfr/tests/tset.c"
#undef main

#define main main_mpfr_tabs
#include "mpfr/tests/tabs.c"
#undef main

#define main main_mpfr_tset_d
#include "mpfr/tests/tset_d.c"
#undef main

#define main main_mpfr_tset_f
#include "mpfr/tests/tset_f.c"
#undef main

#define main main_mpfr_tset_q
#include "mpfr/tests/tset_q.c"
#undef main

#define main main_mpfr_tset_si
#include "mpfr/tests/tset_si.c"
#undef main

#define main main_mpfr_tset_str
#include "mpfr/tests/tset_str.c"
#undef main

#define main main_mpfr_tset_z
#define check0 check01
#define check  check1
#include "mpfr/tests/tset_z.c"
#undef main

#define main main_mpfr_tset_ld
#include "mpfr/tests/tset_ld.c"
#undef main

#define main main_mpfr_tset_sj
#undef N
#include "mpfr/tests/tset_sj.c"
#undef main

#define main main_mpfr_tswap
#include "mpfr/tests/tswap.c"
#undef main

#define main main_mpfr_tcopysign
#include "mpfr/tests/tcopysign.c"
#undef main

#define main main_mpfr_tcmp
#include "mpfr/tests/tcmp.c"
#undef main

#define main main_mpfr_tcmp2
#undef test_overflow
#include "mpfr/tests/tcmp2.c"
#undef main

#define main main_mpfr_tcmpabs
#undef ERROR
#include "mpfr/tests/tcmpabs.c"
#undef main

#define main main_mpfr_tcmp_d
#include "mpfr/tests/tcmp_d.c"
#undef main

#define main main_mpfr_tcmp_ld
#include "mpfr/tests/tcmp_ld.c"
#undef main

#define main main_mpfr_tcomparisons
#include "mpfr/tests/tcomparisons.c"
#undef main

#define main main_mpfr_teq
#define special special3
#include "mpfr/tests/teq.c"
#undef main

#define main main_mpfr_tadd
#define check_inexact check_inexact4
#undef check
#include "mpfr/tests/tadd.c"
#undef main

#define main main_mpfr_tsub
#undef MAX_PREC
#undef check_inexact
#define check_inexact check_inexact5
#define test_generic test_generic5
#include "mpfr/tests/tsub.c"
#undef main

#define main main_mpfr_tmul
#undef check
#define pcheck pcheck6
#define check_nans check_nans6
#undef test_generic
#undef check53
#define check53 check536
#define test_generic test_generic6
#include "mpfr/tests/tmul.c"
#undef main

#define main main_mpfr_tdiv
#undef check53
#define check24 check247
#define check_float check_float7
#undef MAX_PREC
#define check_inexact5 check_inexact57
#undef test_generic
#define test_generic test_generic7
#include "mpfr/tests/tdiv.c"
#undef main

#define main main_mpfr_tsub1sp
#define check_special check_special8
#include "mpfr/tests/tsub1sp.c"
#undef main

#define main main_mpfr_tadd1sp
#define check_overflow check_overflow9
#define check_random check_random9
#undef check_special
#define check_special check_special9
#undef STD_ERROR
#undef STD_ERROR2
#include "mpfr/tests/tadd1sp.c"
#undef main

#define main main_mpfr_tadd_ui
#undef special3
#define special3 special39
#undef check_nans
#define check_nans check_nans69
#include "mpfr/tests/tadd_ui.c"
#undef main

#define main main_mpfr_tsub_ui
#undef check3
#define check3 check310
#undef check_two_sum
#define check_two_sum check_two_sum10
#undef check_nans
#define check_nans check_nans610
#undef test_generic_ui
#define test_generic_ui test_generic_ui10
#include "mpfr/tests/tsub_ui.c"
#undef main

#define main main_mpfr_tcmp_ui
#undef check_nan
#undef check
#define check check11
#define check_nan check_nan11
#include "mpfr/tests/tcmp_ui.c"
#undef main

#define main main_mpfr_tdiv_ui
#undef special39
#define special39 special3912
#undef check_inexact57
#define check_inexact57 check_inexact5712
#undef test_generic_ui
#define test_generic_ui test_generic_ui12
#include "mpfr/tests/tdiv_ui.c"
#undef main

#define main main_mpfr_tmul_ui
#undef special39
#define special39 special3913
#undef check_inexact57
#define check_inexact57 check_inexact5713
#undef test_generic_ui
#define test_generic_ui test_generic_ui13
#include "mpfr/tests/tmul_ui.c"
#undef main

#define main main_mpfr_tsqrt_ui
#undef check_inexact57
#define check_inexact57 check_inexact5713
#undef test_generic_ui
#define test_generic_ui test_generic_ui13
#undef check11
#define check11 check1113
#include "mpfr/tests/tsqrt_ui.c"
#undef main

#define main main_mpfr_tui_div
#undef check11
#define check11 check1114
#undef check_inexact57
#define check_inexact57 check_inexact5714
#undef check_nan
#define check_nan check_nan14
#include "mpfr/tests/tui_div.c"
#undef main

#define main main_mpfr_tui_sub
#undef check11
#define check11 check1115
#undef check_inexact57
#define check_inexact57 check_inexact5715
#undef check_nan
#define check_nan check_nan15
#undef check_two_sum
#define check_two_sum check_two_sum15
#undef check_nans
#define check_nans check_nans615
#include "mpfr/tests/tui_sub.c"
#undef main

#define main main_mpfr_tgmpop
#undef special39
#define special39 special3916
#include "mpfr/tests/tgmpop.c"
#undef main

#define main main_mpfr_tsi_op
#undef test_generic_ui
#include "mpfr/tests/tsi_op.c"
#undef main

#define main main_mpfr_tmul_2exp
#undef test_mul
#include "mpfr/tests/tmul_2exp.c"
#undef main

#define main main_mpfr_tfma
#include "mpfr/tests/tfma.c"
#undef main

#define main main_mpfr_tfms
#undef test_exact
#define test_exact test_exact18
#undef test_overflow1
#define test_overflow1 test_overflow118
#undef test_overflow2
#define test_overflow2 test_overflow218
#undef test_underflow1
#define test_underflow1 test_underflow118
#undef test_underflow2
#define test_underflow2 test_underflow218
#include "mpfr/tests/tfms.c"
#undef main

#define main main_mpfr_tsum
#undef check_special9
#define check_special9 check_special920
#undef test_generic
#define test_generic test_generic20
#include "mpfr/tests/tsum.c"
#undef main
#undef ERROR1

#define main main_mpfr_tdim
#include "mpfr/tests/tdim.c"
#undef main

#define main main_mpfr_tminmax
#include "mpfr/tests/tminmax.c"
#undef main

#define main main_mpfr_tnext
#include "mpfr/tests/tnext.c"
#undef main

#define main main_mpfr_tfits
#include "mpfr/tests/tfits.c"
#undef main

#define main main_mpfr_tget_d
#undef check_max
#define check_max check_max23
#undef check_min
#define check_min check_min23
#include "mpfr/tests/tget_d.c"
#undef main

#define main main_mpfr_tget_d_2exp
#undef check_inf_nan
#define check_inf_nan check_inf_nan24
#include "mpfr/tests/tget_d_2exp.c"
#undef main

#define main main_mpfr_tget_z
#undef check1115
#define check1115 check111525
#include "mpfr/tests/tget_z.c"
#undef main

#define main main_mpfr_tget_str
#undef check3
#define check3 check326
#undef check_large
#define check_large check_large26
#undef check_special
#define check_special check_special26
#include "mpfr/tests/tget_str.c"
#undef main

#define main main_mpfr_tget_sj
#include "mpfr/tests/tget_sj.c"
#undef main

#define main main_mpfr_tout_str
#undef check
#undef check4
#define check4 check427
#undef check_large
#define check_large check_large27
#undef special39
#define special39 special3927
#include "mpfr/tests/tout_str.c"
#undef main

#define main main_mpfr_tinp_str
#include "mpfr/tests/tinp_str.c"
#undef main

#define main main_mpfr_toutimpl
#include "mpfr/tests/toutimpl.c"
#undef main

#define main main_mpfr_tcan_round
#include "mpfr/tests/tcan_round.c"
#undef main

#define main main_mpfr_tround_prec
#include "mpfr/tests/tround_prec.c"
#undef main

#define main main_mpfr_tsqrt
#undef check3
#define check3 check328
#undef check4
#define check4 check428
#undef check2
#define check2 check228
#undef check_float
#define check_float check_float28
#undef special3
#define special3 special328
#undef test_generic
#define test_generic test_generic28
#undef check24
#define check24 check2428
#undef check_diverse
#define check_diverse check_diverse28
#include "mpfr/tests/tsqrt.c"
#undef main

#define main main_mpfr_tconst_log2
#undef check
#define check check29
#undef check_large
#define check_large check_large29
#include "mpfr/tests/tconst_log2.c"
#undef main

#define main main_mpfr_tconst_pi
#undef check_large
#define check_large check_large30
#include "mpfr/tests/tconst_pi.c"
#undef main

#define main main_mpfr_tconst_euler
#include "mpfr/tests/tconst_euler.c"
#undef main

#define main main_mpfr_trandom
#include "mpfr/tests/trandom.c"
#undef main

#define main main_mpfr_ttrunc
#include "mpfr/tests/ttrunc.c"
#undef main

#define main main_mpfr_trint
#undef special3
#define special3 special331
#include "mpfr/tests/trint.c"
#undef main

#define main main_mpfr_tfrac
#undef check0
#define check0 check032
#undef check1
#define check1 check132
#undef special3
#define special3 special332
#include "mpfr/tests/tfrac.c"
#undef main

#define main main_mpfr_texp
#undef check3
#define check3 check333
#undef check_large
#define check_large check_large33
#undef test_generic
#define test_generic test_generic33
#undef check_special
#define check_special check_special33
#undef check_inexact
#define check_inexact check_inexact33
#undef check_inexact57
#define check_inexact57 check_inexact5733
#include "mpfr/tests/texp.c"
#undef main

#define main main_mpfr_texp2
#undef test_generic
#define test_generic test_generic34
#include "mpfr/tests/texp2.c"
#undef main

#define main main_mpfr_texp10
#undef test_generic
#define test_generic test_generic35
#undef special_overflow
#define special_overflow special_overflow35
#define emax_m_eps emax_m_eps35
#define exp_range exp_range35
#include "mpfr/tests/texp10.c"
#undef main

#define main main_mpfr_texpm1
#undef test_generic
#define test_generic test_generic36
#undef special3
#define special3 special336
#include "mpfr/tests/texpm1.c"
#undef main

#define main main_mpfr_tlog
#undef check3
#define check3 check337
#undef check_worst_cases
#define check_worst_cases check_worst_cases37
#undef special3
#define special3 special337
#undef test_generic
#define test_generic test_generic37
#include "mpfr/tests/tlog.c"
#undef main

#define main main_mpfr_tlog2
#undef test_generic
#define test_generic test_generic38
#undef special3
#define special3 special338
#include "mpfr/tests/tlog2.c"
#undef main

#define main main_mpfr_tlog10
#undef test_generic
#define test_generic test_generic39
#include "mpfr/tests/tlog10.c"
#undef main

#define main main_mpfr_tlog1p
#undef test_generic
#define test_generic test_generic40
#undef special3
#define special3 special340
#include "mpfr/tests/tlog1p.c"
#undef main

#define main main_mpfr_tpow
#undef test_generic
#define test_generic test_generic41
#undef test_generic_ui
#define test_generic_ui test_generic_ui41
#undef check_inexact
#define check_inexact check_inexact41
#undef special3
#define special3 special341
#define x_near_one x_near_one41
#include "mpfr/tests/tpow.c"
#undef main

#define main main_mpfr_tui_pow
#undef check1
#define check1 check142
#include "mpfr/tests/tui_pow.c"
#undef main

#define main main_mpfr_tpow3
#include "mpfr/tests/tpow3.c"
#undef main

#define main main_mpfr_tcosh
#undef test_generic
#define test_generic test_generic43
#undef special3
#define special3 special343
#undef special_overflow
#define special_overflow special_overflow43
#include "mpfr/tests/tcosh.c"
#undef main

#define main main_mpfr_tsinh
#undef test_generic
#define test_generic test_generic44
#undef special3
#define special3 special344
#include "mpfr/tests/tsinh.c"
#undef main

#define main main_mpfr_ttanh
#undef test_generic
#define test_generic test_generic45
#undef special3
#define special3 special345
#undef special_overflow
#define special_overflow special_overflow45
#include "mpfr/tests/ttanh.c"
#undef main

#define main main_mpfr_tacosh
#undef test_generic
#define test_generic test_generic46
#undef special3
#define special3 special346
#undef special_overflow
#define special_overflow special_overflow46
#include "mpfr/tests/tacosh.c"
#undef main

#define main main_mpfr_tasinh
#undef test_generic
#define test_generic test_generic47
#undef special3
#define special3 special347
#undef special_overflow
#define special_overflow special_overflow47
#include "mpfr/tests/tasinh.c"
#undef main

#define main main_mpfr_tatanh
#undef test_generic
#define test_generic test_generic48
#undef special3
#define special3 special348
#undef special_overflow
#define special_overflow special_overflow48
#include "mpfr/tests/tatanh.c"
#undef main

#define main main_mpfr_thyperbolic
#include "mpfr/tests/thyperbolic.c"
#undef main

#define main main_mpfr_tasin
#undef test_generic
#define test_generic test_generic49
#undef special3
#define special3 special349
#include "mpfr/tests/tasin.c"
#undef main

#define main main_mpfr_tacos
#undef test_generic
#define test_generic test_generic50
#undef special3
#define special3 special350
#undef special_overflow
#define special_overflow special_overflow50
#include "mpfr/tests/tacos.c"
#undef main

#define main main_mpfr_tcos
#undef check53
#undef REDUCE_EMAX
#undef test_generic
#define test_generic test_generic51
#undef special3
#define special3 special351
#undef special_overflow
#define special_overflow special_overflow51
#undef check_nans
#define check_nans check_nans51
#include "mpfr/tests/tcos.c"
#undef main

#define main main_mpfr_tatan
#undef special_overflow
#define special_overflow special_overflow52
#include "mpfr/tests/tatan.c"
#undef main

#define main main_mpfr_tsin
#define check53 check5353
#undef check_nans
#define check_nans check_nans53
#undef test_generic
#define test_generic test_generic53
#undef check_regression
#define check_regression check_regression53
#include "mpfr/tests/tsin.c"
#undef main

#define main main_mpfr_ttan
#undef test_generic
#define test_generic test_generic54
#undef check_nans
#define check_nans check_nans54
#include "mpfr/tests/ttan.c"
#undef main

#define main main_mpfr_tsin_cos
#undef check53
#define check53 check5355
#undef check_nans
#define check_nans check_nans55
#include "mpfr/tests/tsin_cos.c"
#undef main

#define main main_mpfr_tagm
#undef check
#undef check4
#define check4 check456
#undef check_large
#define check_large check_large56
#undef check_nans
#define check_nans check_nans56
#undef test_generic
#define test_generic test_generic56
#include "mpfr/tests/tagm.c"
#undef main

#define main main_mpfr_thypot
#undef special3
#define special3 special356
#include "mpfr/tests/thypot.c"
#undef main

#define main main_mpfr_tfactorial
#undef TEST_FUNCTION
#undef special3
#define special3 special357
#include "mpfr/tests/tfactorial.c"
#undef main

#define main main_mpfr_tgamma
#undef TEST_FUNCTION
#undef special3
#define special3 special358
#undef test_generic
#define test_generic test_generic58
#undef special_overflow
#define special_overflow special_overflow58
#include "mpfr/tests/tgamma.c"
#undef main

#define main main_mpfr_terf
#include "mpfr/tests/terf.c"
#undef main

#define main main_mpfr_tcbrt
#undef special3
#define special3 special359
#undef test_generic
#define test_generic test_generic59
#include "mpfr/tests/tcbrt.c"
#undef main

#define main main_mpfr_tzeta
#define test1 test160
#define val val60
#undef test_generic
#define test_generic test_generic60
#include "mpfr/tests/tzeta.c"
#undef main

#define main main_mpfr_mpf_compat
#include "mpfr/tests/mpf_compat.c"
#undef main

#define main main_mpfr_mpfr_compat
#include "mpfr/tests/mpfr_compat.c"
#undef main

#define main main_mpfr_reuse
#define test2 test261
#include "mpfr/tests/reuse.c"
#undef main

#define main main_mpfr_tsqr
#undef check_special
#define check_special check_special362
#undef test_generic
#define test_generic test_generic62
#undef special_overflow
#define special_overflow special_overflow62
#define inexact_sign inexact_sign62
#undef check_random
#define check_random check_random62
#include "mpfr/tests/tsqr.c"
#undef main

#define main main_mpfr_tstrtofr
#undef check_special
#define check_special check_special363
#undef check_overflow
#define check_overflow check_overflow363
#include "mpfr/tests/tstrtofr.c"
#undef main

#define main main_mpfr_tpow_z
#undef ERROR
#undef check_special
#define check_special check_special64
#undef check_regression
#define check_regression check_regression64
#define bug20071104 bug20071104_B
#undef check_overflow
#define check_overflow check_overflow64
#include "mpfr/tests/tpow_z.c"
#undef main

#define main main_mpfr_tget_f
#include "mpfr/tests/tget_f.c"
#undef main

#define main main_mpfr_tconst_catalan
#undef test_generic
#define test_generic test_generic65
#include "mpfr/tests/tconst_catalan.c"
#undef main

#define main main_mpfr_troot
#undef special3
#define special3 special366
#undef test_generic_ui
#define test_generic_ui test_generic_ui66
#include "mpfr/tests/troot.c"
#undef main

#define main main_mpfr_tsec
#undef test_generic
#define test_generic test_generic67
#include "mpfr/tests/tsec.c"
#undef main

#define main main_mpfr_tcsc
#undef test_generic
#define test_generic test_generic68
#define check_specials check_specials68
#include "mpfr/tests/tcsc.c"
#undef main

#define main main_mpfr_tcot
#undef test_generic
#define test_generic test_generic69
#undef check_specials
#define check_specials check_specials69
#include "mpfr/tests/tcot.c"
#undef main

#define main main_mpfr_teint
#undef test_generic
#define test_generic test_generic70
#undef check_specials
#define check_specials check_specials70
#include "mpfr/tests/teint.c"
#undef main

#define main main_mpfr_tcoth
#undef test_generic
#define test_generic test_generic71
#undef check_specials
#define check_specials check_specials71
#include "mpfr/tests/tcoth.c"
#undef main

#define main main_mpfr_tcsch
#undef test_generic
#define test_generic test_generic72
#undef check_specials
#define check_specials check_specials72
#include "mpfr/tests/tcsch.c"
#undef main

#define main main_mpfr_tsech
#undef test_generic
#define test_generic test_generic73
#undef check_specials
#define check_specials check_specials73
#include "mpfr/tests/tsech.c"
#undef main

#define main main_mpfr_tstckintc
#define Buffer Buffer74
#undef test1
#define test1 test174
#undef test2
#define test2 test274
#include "mpfr/tests/tstckintc.c"
#undef main

#define main main_mpfr_tsubnormal
#define tab tab75
#undef check1
#define check1 check175
#undef check2
#define check2 check275
#undef check3
#define check3 check375
#include "mpfr/tests/tsubnormal.c"
#undef main

#define main main_mpfr_tlngamma
#undef test_generic
#define test_generic test_generic76
#undef special
#define special special76
#undef CHECK_Y1
#undef CHECK_Y2
#include "mpfr/tests/tlngamma.c"
#undef main

#define main main_mpfr_tlgamma
#undef test_generic
#define test_generic test_generic77
#undef special
#define special special77
#undef TEST_FUNCTION
#undef check_inf_nan
#define check_inf_nan check_inf_nan77
#include "mpfr/tests/tlgamma.c"
#undef main

#define main main_mpfr_tzeta_ui
#include "mpfr/tests/tzeta_ui.c"
#undef main

#define main main_mpfr_tget_ld_2exp
#define check_round check_round_78
#include "mpfr/tests/tget_ld_2exp.c"
#undef main

#define main main_mpfr_tget_set_d64
#include "mpfr/tests/tget_set_d64.c"
#undef main

#define main main_mpfr_tj0
#undef TEST_FUNCTION
#undef test_generic
#define test_generic test_generic79
#include "mpfr/tests/tj0.c"
#undef main

#define main main_mpfr_tj1
#undef test_generic
#define test_generic test_generic80
#include "mpfr/tests/tj1.c"
#undef main

#define main main_mpfr_tjn
#include "mpfr/tests/tjn.c"
#undef main

#define main main_mpfr_ty0
#undef test_generic
#define test_generic test_generic81
#include "mpfr/tests/ty0.c"
#undef main

#define main main_mpfr_ty1
#undef test_generic
#define test_generic test_generic82
#include "mpfr/tests/ty1.c"
#undef main

#define main main_mpfr_tyn
#include "mpfr/tests/tyn.c"
#undef main

#define main main_mpfr_tremquo
#include "mpfr/tests/tremquo.c"
#undef main

#define main main_mpfr_tl2b
#include "mpfr/tests/tl2b.c"
#undef main

#define RUN(x) __gmp_rands_initialized = 0; printf (#x "\n"); x (argc,argv);

int main (int argc, char * argv[]) {
  __gmpfr_default_fp_bit_precision = 53;
  __gmpfr_emin = MPFR_EMIN_DEFAULT;
  __gmpfr_emax = MPFR_EMAX_DEFAULT;
  __gmpfr_default_rounding_mode = GMP_RNDN;
#if 0
RUN (main_mpfr_tversion(););
RUN (main_mpfr_tinternals);
RUN (main_mpfr_tinits(););
RUN (main_mpfr_tisqrt(););
RUN (main_mpfr_tsgn);
RUN (main_mpfr_tcheck(););
RUN (main_mpfr_tisnan(););
RUN (main_mpfr_texceptions);
RUN (main_mpfr_tset_exp);
RUN (main_mpfr_tset(););
RUN (main_mpfr_tabs);
RUN (main_mpfr_tset_f(););
RUN (main_mpfr_tset_q(););
RUN (main_mpfr_tset_si);
#endif
RUN (main_mpfr_tset_str);
RUN (main_mpfr_tset_z);
RUN (main_mpfr_tset_sj);
RUN (main_mpfr_tswap(););
RUN (main_mpfr_tcopysign(););
RUN (main_mpfr_tcmp(););
 RUN (main_mpfr_tcmp2(););
 RUN (main_mpfr_tcmpabs(););
 RUN (main_mpfr_tcomparisons(););
 RUN (main_mpfr_teq(););
RUN (main_mpfr_tadd);
 RUN (main_mpfr_tsub(););
RUN (main_mpfr_tmul);
RUN (main_mpfr_tdiv);
 RUN (main_mpfr_tsub1sp(););
 RUN (main_mpfr_tadd1sp(););
RUN (main_mpfr_tadd_ui);
RUN (main_mpfr_tsub_ui);
 RUN (main_mpfr_tcmp_ui(););
RUN (main_mpfr_tdiv_ui);
RUN (main_mpfr_tmul_ui);
 RUN (main_mpfr_tsqrt_ui(););
RUN (main_mpfr_tui_div);
RUN (main_mpfr_tui_sub);
RUN (main_mpfr_tgmpop);
RUN (main_mpfr_tsi_op);
RUN (main_mpfr_tmul_2exp);
RUN (main_mpfr_tfma);
RUN (main_mpfr_tfms);
 RUN (main_mpfr_tsum(););
 RUN (main_mpfr_tdim(););
 RUN (main_mpfr_tminmax(););
 RUN (main_mpfr_tnext(););
 RUN (main_mpfr_tfits(););
 RUN (main_mpfr_tget_z(););
RUN (main_mpfr_tget_str);
 RUN (main_mpfr_tget_sj(););
RUN (main_mpfr_tout_str);
RUN (main_mpfr_tinp_str);
RUN (main_mpfr_toutimpl);
 RUN (main_mpfr_tcan_round(););
 RUN (main_mpfr_tround_prec(););
 RUN (main_mpfr_tsqrt(););
RUN (main_mpfr_tconst_log2);
RUN (main_mpfr_tconst_pi);
RUN (main_mpfr_tconst_euler);
RUN (main_mpfr_trandom);
 RUN (main_mpfr_ttrunc(););
RUN (main_mpfr_trint);
 RUN (main_mpfr_tfrac(););
RUN (main_mpfr_texp);
RUN (main_mpfr_texp2);
RUN (main_mpfr_texp10);
RUN (main_mpfr_texpm1);
RUN (main_mpfr_tlog);
RUN (main_mpfr_tlog2);
RUN (main_mpfr_tlog10);
RUN (main_mpfr_tlog1p);
RUN (main_mpfr_tpow);
RUN (main_mpfr_tui_pow);
RUN (main_mpfr_tpow3);
RUN (main_mpfr_tcosh);
RUN (main_mpfr_tsinh);
RUN (main_mpfr_ttanh);
RUN (main_mpfr_tacosh);
RUN (main_mpfr_tasinh);
RUN (main_mpfr_tatanh);
 RUN (main_mpfr_thyperbolic(););
 RUN (main_mpfr_tasin(););
 RUN (main_mpfr_tacos(););
RUN (main_mpfr_tcos);
RUN (main_mpfr_tatan);
RUN (main_mpfr_tsin);
RUN (main_mpfr_ttan);
RUN (main_mpfr_tsin_cos);
RUN (main_mpfr_tagm);
RUN (main_mpfr_thypot);
RUN (main_mpfr_tfactorial);
RUN (main_mpfr_tgamma);
RUN (main_mpfr_terf);
 RUN (main_mpfr_tcbrt(););
RUN (main_mpfr_tzeta);
RUN (main_mpfr_mpf_compat);
RUN (main_mpfr_mpfr_compat);
 RUN (main_mpfr_reuse(););
 RUN (main_mpfr_tsqr(););
RUN (main_mpfr_tstrtofr);
 RUN (main_mpfr_tpow_z(););
 RUN (main_mpfr_tget_f(););
RUN (main_mpfr_tconst_catalan);
 RUN (main_mpfr_troot(););
RUN (main_mpfr_tsec);
RUN (main_mpfr_tcsc);
RUN (main_mpfr_tcot);
RUN (main_mpfr_teint);
RUN (main_mpfr_tcoth);
RUN (main_mpfr_tcsch);
RUN (main_mpfr_tsech);
 RUN (main_mpfr_tstckintc(););
RUN (main_mpfr_tsubnormal);
 RUN (main_mpfr_tlngamma(););
 RUN (main_mpfr_tlgamma(););
RUN (main_mpfr_tzeta_ui);
 RUN (main_mpfr_tget_ld_2exp(););
 RUN (main_mpfr_tget_set_d64(););
RUN (main_mpfr_tj0);
RUN (main_mpfr_tj1);
RUN (main_mpfr_tjn);
RUN (main_mpfr_ty0);
RUN (main_mpfr_ty1);
RUN (main_mpfr_tyn);
RUN (main_mpfr_tremquo);
RUN (main_mpfr_tl2b);

/* test fail */
 RUN (main_mpfr_tset_d);
 RUN (main_mpfr_tset_ld);
 RUN (main_mpfr_tcmp_d(););
 RUN (main_mpfr_tcmp_ld(););
 RUN (main_mpfr_tget_d(););
 RUN (main_mpfr_tget_d_2exp(););

 return 0;
}
