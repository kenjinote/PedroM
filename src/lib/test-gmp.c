

/* Include all relevants tests files for GMP into a PedroM builtin command */

/* To avoid exiting one test before the following one */
#define exit(c) { if ((c) != 0) (exit) (c); }

/* TEST GMP CORE */

#define main main_tbswap
#include "gmp/tests/t-bswap.c"
#undef main

#define main main_tgmpmax
#include "gmp/tests/t-gmpmax.c"
#undef main

#define main main_tparity
#include "gmp/tests/t-parity.c"
#undef main

#define main main_tconstants
#include "gmp/tests/t-constants.c"
#undef main
#undef CHECK_MAX

#define main main_thightomask
#include "gmp/tests/t-hightomask.c"
#undef main

#define main main_tpopc
#include "gmp/tests/t-popc.c"
#undef main

#define main main_tcountzeros
#define check_various check_various2
#include "gmp/tests/t-count_zeros.c"
#undef main

#define main main_tmodlinv
#include "gmp/tests/t-modlinv.c"
#undef main

#define main main_tsub
#include "gmp/tests/t-sub.c"
#undef main
#undef M

/* TEST GMP MPN */
#define main main_taors_1
#include "gmp/tests/mpn/t-aors_1.c"
#undef main

#define main main_tasmtype
#include "gmp/tests/mpn/t-asmtype.c"
#undef main

#define main main_tdivrem_1
#define check_data check_data2
#include "gmp/tests/mpn/t-divrem_1.c"
#undef main

#define main main_tfat
#include "gmp/tests/mpn/t-fat.c"
#undef main

#define main main_tget_d
#include "gmp/tests/mpn/t-get_d.c"
#undef main

#define main main_tinstrument
#include "gmp/tests/mpn/t-instrument.c"
#undef main

#define main main_tiord_u
#define check_one check_onex2
#include "gmp/tests/mpn/t-iord_u.c"
#undef main
#undef SIZE

#define main main_tmp_bases
#include "gmp/tests/mpn/t-mp_bases.c"
#undef main

#define main main_tperfsqr
#include "gmp/tests/mpn/t-perfsqr.c"
#undef main

#define main main_tscan
#define check_rand check_rand2
#include "gmp/tests/mpn/t-scan.c"
#undef main

/* GMP MPZ */
#undef check_one
#undef check_data
#undef check_random

#define main main_taddsub
#include "gmp/tests/mpz/t-addsub.c"
#undef main

#define main main_taorsmul
#define check_one check_one3
#define check_data check_data3
#define check_random check_random3
#include "gmp/tests/mpz/t-aorsmul.c"
#undef main

#define main main_tbin
#include "gmp/tests/mpz/t-bin.c"
#undef main

#define main main_tcdiv_ui
#define dump_abort dump_abort3
#define debug_mp debug_mp3
#include "gmp/tests/mpz/t-cdiv_ui.c"
#undef main

#define main main_tcmp
#undef check_one
#define check_one check_one4
#define check_all check_all4
#undef check_various
#define check_various check_various4
#include "gmp/tests/mpz/t-cmp.c"
#undef main

#define main main_tcmp_d
#undef check_one
#define check_one check_one5
#undef check_data
#define check_data check_data5
#include "gmp/tests/mpz/t-cmp_d.c"
#undef main
#undef SGN

#define main main_tcmp_si
#undef check_data
#define check_data check_data6
#include "gmp/tests/mpz/t-cmp_si.c"
#undef main
#undef SGN

#define main main_tcong
#undef check_one
#define check_one check_one7
#undef check_data
#define check_data check_data7
#undef check_random
#define check_random check_random7
#include "gmp/tests/mpz/t-cong.c"
#undef main

#define main main_tcong_2exp
#undef check_one
#define check_one check_one8
#undef check_data
#define check_data check_data8
#undef check_random
#define check_random check_random8
#include "gmp/tests/mpz/t-cong_2exp.c"
#undef main

#define main main_tdiv_2exp
#undef check_one
#define check_one check_one9
#undef check_data
#define check_data check_data9
#undef check_random
#define check_random check_random9
#undef check_various
#define check_various check_various9
#undef check_all
#define check_all check_all9
#include "gmp/tests/mpz/t-div_2exp.c"
#undef main

#define main main_tdivis
#undef check_one
#define check_one check_one10
#undef check_data
#define check_data check_data10
#undef check_random
#define check_random check_random10
#undef check_various
#define check_various check_various10
#include "gmp/tests/mpz/t-divis.c"
#undef main

#define main main_tdivis_2exp
#undef check_one
#define check_one check_one11
#undef check_data
#define check_data check_data11
#undef check_random
#define check_random check_random11
#undef check_various
#define check_various check_various11
#include "gmp/tests/mpz/t-divis_2exp.c"
#undef main

#define main main_texport
#undef check_one
#define check_one check_one12
#undef check_data
#define check_data check_data12
#undef check_random
#define check_random check_random12
#undef check_various
#define check_various check_various12
#include "gmp/tests/mpz/t-export.c"
#undef main

#define main main_tfac_ui
#include "gmp/tests/mpz/t-fac_ui.c"
#undef main

#define main main_tfdiv
#undef dump_abort
#define dump_abort dump_abort13
#undef debug_mp
#define debug_mp debug_mp13
#include "gmp/tests/mpz/t-fdiv.c"
#undef main

#define main main_tfdiv_ui
#undef dump_abort
#define dump_abort dump_abort14
#undef debug_mp
#define debug_mp debug_mp14
#include "gmp/tests/mpz/t-fdiv_ui.c"
#undef main

#define main main_tfib_ui
#include "gmp/tests/mpz/t-fib_ui.c"
#undef main

#define main main_tfits
#include "gmp/tests/mpz/t-fits.c"
#undef main

#define main main_tgcd
#undef check_one
#define check_one check_one15
#undef check_data
#define check_data check_data15
#undef check_random
#define check_random check_random15
#undef check_various
#define check_various check_various15
#undef check_all
#define check_all check_all15
#undef dump_abort
#define dump_abort dump_abort15
#undef debug_mp
#define debug_mp debug_mp15
#include "gmp/tests/mpz/t-gcd.c"
#undef main

#define main main_tgcd_ui
#include "gmp/tests/mpz/t-gcd_ui.c"
#undef main

#define main main_mpz_tget_d
#define check_onebit check_onebit16
#include "gmp/tests/mpz/t-get_d.c"
#undef main

#define main main_tget_d_2exp
#undef check_onebit
#define check_onebit check_onebit17
#undef check_rand
#define check_rand check_rand17
#include "gmp/tests/mpz/t-get_d_2exp.c"
#undef main

#define main main_tget_si
#undef check_data
#define check_data check_data18
#include "gmp/tests/mpz/t-get_si.c"
#undef main

#define main main_thamdist
#define check_twobits check_twobits19
#undef check_rand
#define check_rand check_rand19
#include "gmp/tests/mpz/t-hamdist.c"
#undef main

#define main main_timport
#undef check_data
#define check_data check_data20
#include "gmp/tests/mpz/t-import.c"
#undef main

#define main main_tinp_str
#undef check_data
#define check_data check_data21
#include "gmp/tests/mpz/t-inp_str.c"
#undef main
#undef FILENAME

#define main main_tio_raw
#undef check_rand
#define check_rand check_rand22
#include "gmp/tests/mpz/t-io_raw.c"
#undef main

#define main main_tjac
#undef check_data
#define check_data check_data23
#include "gmp/tests/mpz/t-jac.c"
#undef main

#define main main_tlcm
#include "gmp/tests/mpz/t-lcm.c"
#undef main

#define main main_tlucnum_ui
#include "gmp/tests/mpz/t-lucnum_ui.c"
#undef main

#define main main_tmul
#undef debug_mp
#define debug_mp debug_mp24
#define one one24
#include "gmp/tests/mpz/t-mul.c"
#undef main

#define main main_tmul_i
#define x x25
#include "gmp/tests/mpz/t-mul_i.c"
#undef main

#define main main_toddeven
#undef check_data
#define check_data check_data26
#include "gmp/tests/mpz/t-oddeven.c"
#undef main

#define main main_mpz_tperfsqr
#define sq_res_0x100 sq_res_0x100_27
#include "gmp/tests/mpz/t-perfsqr.c"
#undef main

#define main main_tpopcount
#undef check_onebit
#define check_onebit check_onebit28
#undef check_data
#define check_data check_data28
#include "gmp/tests/mpz/t-popcount.c"
#undef main

#define main main_tpow
#undef check_random
#define check_random check_random29
#include "gmp/tests/mpz/t-pow.c"
#undef main

#define main main_tpowm
#undef debug_mp
#define debug_mp debug_mp30
#include "gmp/tests/mpz/t-powm.c"
#undef main

#define main main_tpowm_ui
#undef debug_mp
#define debug_mp debug_mp31
#undef dump_abort
#define dump_abort dump_abort31
#include "gmp/tests/mpz/t-powm_ui.c"
#undef main

#define main main_tpprime_p
#undef check_one
#define check_one check_one32
#include "gmp/tests/mpz/t-pprime_p.c"
#undef main

#define main main_troot
#undef debug_mp
#define debug_mp debug_mp33
#include "gmp/tests/mpz/t-root.c"
#undef main

#define main main_mpz_tscan
#include "gmp/tests/mpz/t-scan.c"
#undef main

#define main main_tset_d
#undef check_data
#define check_data check_data34
#include "gmp/tests/mpz/t-set_d.c"
#undef main

#define main main_tset_f
#undef check_one
#define check_one check_one35
#undef check_various
#define check_various check_various35
#include "gmp/tests/mpz/t-set_f.c"
#undef main

#define main main_tset_si
#undef check_data
#define check_data check_data36
#include "gmp/tests/mpz/t-set_si.c"
#undef main

#define main main_tset_str
#undef check_one
#define check_one check_one37
#undef check_samples
#define check_samples check_samples37
#include "gmp/tests/mpz/t-set_str.c"
#undef main

#define main main_tsizeinbase
#include "gmp/tests/mpz/t-sizeinbase.c"
#undef main

#define main main_tsqrtrem
#undef dump_abort
#define dump_abort dump_abort38
#undef debug_mp
#define debug_mp debug_mp38
#include "gmp/tests/mpz/t-sqrtrem.c"
#undef main

#define main main_ttdiv
#undef dump_abort
#define dump_abort dump_abort1
#undef debug_mp
#define debug_mp debug_mp1
#include "gmp/tests/mpz/t-tdiv.c"
#undef main

#define main main_ttdiv_ui
#undef dump_abort
#define dump_abort dump_abort40
#undef debug_mp
#define debug_mp debug_mp40
#include "gmp/tests/mpz/t-tdiv_ui.c"
#undef main


/* GMP -- MPQ */
#define main main_mpq_taors
#undef check_all
#define check_all check_all41
#undef check_data
#define check_data check_data41
#undef check_rand
#define check_rand check_rand41
#include "gmp/tests/mpq/t-aors.c"
#undef main
#undef SGN

#define main main_mpq_tcmp
#include "gmp/tests/mpq/t-cmp.c"
#undef main
#undef SGN

#define main main_mpq_tcmp_si
#undef check_data
#define check_data check_data42
#include "gmp/tests/mpq/t-cmp_si.c"
#undef main
#undef SGN

#define main main_mpq_tcmp_ui
#include "gmp/tests/mpq/t-cmp_ui.c"
#undef main
#undef SGN

#undef SET4
#define main main_mpq_tequal
#undef check_all
#define check_all check_all43
#undef check_one
#define check_one check_one43
#undef check_various
#define check_various check_various43
#include "gmp/tests/mpq/t-equal.c"
#undef main
#undef SGN

#define main main_mpq_tget_d
#undef SIZE
#undef check_random
#define check_random check_random44
#undef check_onebit
#define check_onebit check_onebit44
#include "gmp/tests/mpq/t-get_d.c"
#undef main
#undef SGN

#define main main_mpq_tget_str
#undef check_one
#define check_one check_one45
#undef check_all
#define check_all check_all45
#undef check_data
#define check_data check_data45
#include "gmp/tests/mpq/t-get_str.c"
#undef main
#undef SGN

#define main main_mpq_tinp_str
#undef FILENAME
#undef check_data
#define check_data check_data46
#include "gmp/tests/mpq/t-inp_str.c"
#undef main
#undef SGN

#define main main_mpq_tmd_2exp
#include "gmp/tests/mpq/t-md_2exp.c"
#undef main
#undef SGN

#define main main_mpq_tset_f
#include "gmp/tests/mpq/t-set_f.c"
#undef main
#undef SGN

#define main main_mpq_tset_str
#undef check_one
#define check_one check_one47
#undef check_samples
#define check_samples check_samples47
#include "gmp/tests/mpq/t-set_str.c"
#undef main
#undef SGN


#define RUN(x) __gmp_rands_initialized = 0; printf (#x "\n"); x (argc,argv);

int main (int argc, char *argv[])
{
  /* CORE */
  RUN (main_tbswap(););
  RUN (main_tgmpmax);
  RUN (main_tparity);
  RUN (main_tconstants);
  RUN (main_thightomask(); );
  RUN (main_tpopc(); );
  RUN (main_tcountzeros);
  RUN (main_tmodlinv);
  RUN (main_tsub(); );

  /* MPN */
  RUN (main_taors_1(); );
  RUN (main_tasmtype(); );
  RUN (main_tdivrem_1(); );
  RUN (main_tfat(); );
  RUN (main_tinstrument(); );
  RUN (main_tiord_u(); );
  RUN (main_tmp_bases);
  RUN (main_tperfsqr(); );
  RUN (main_tscan(); );

  /* MPQ */
  RUN (main_taddsub);
  RUN (main_taorsmul);
  RUN (main_tbin(); );
  RUN (main_tcdiv_ui);
  RUN (main_tcmp(); );
  RUN (main_tcmp_si(); );
  RUN (main_tcong);
  RUN (main_tcong_2exp);
  RUN (main_tdiv_2exp);
  RUN (main_tdivis);
  RUN (main_tdivis_2exp);
  RUN (main_texport(); );
  RUN (main_tfac_ui);
  RUN (main_tfdiv);
  RUN (main_tfdiv_ui);
  RUN (main_tfib_ui);
  RUN (main_tfits(); );
  RUN (main_tgcd);
  RUN (main_tgcd_ui(); );
  RUN (main_tget_si(); );
  RUN (main_thamdist(); );
  RUN (main_timport(); );
  RUN (main_tinp_str(); );
  RUN (main_tio_raw(); );
  RUN (main_tjac );
  RUN (main_tlcm);
  RUN (main_tlucnum_ui);
  RUN (main_tmul);
  RUN (main_tmul_i);
  RUN (main_toddeven(); );
  RUN (main_mpz_tperfsqr);
  RUN (main_tpopcount(); );
  RUN (main_tpow);
  RUN (main_tpowm);
  RUN (main_tpowm_ui);
  RUN (main_tpprime_p(); );
  RUN (main_troot );
  RUN (main_mpz_tscan );
  RUN (main_tset_f);
  RUN (main_tset_si(); );
  RUN (main_tset_str(); );
  RUN (main_tsizeinbase(); );
  RUN (main_tsqrtrem);
  RUN (main_ttdiv);
  RUN (main_ttdiv_ui);

  /* MPQ */
  RUN (main_mpq_taors(); );
  RUN (main_mpq_tcmp);
  RUN (main_mpq_tcmp_si);
  RUN (main_mpq_tcmp_ui);
  RUN (main_mpq_tequal(); );
  RUN (main_mpq_tget_str(); );
  RUN (main_mpq_tinp_str(); );
  RUN (main_mpq_tmd_2exp(); );
  RUN (main_mpq_tset_f);
  RUN (main_mpq_tset_str(); );

  /* Theses tests FAILED */
  RUN (main_tget_d(); );

  RUN (main_tset_d(); );
  RUN (main_tcmp_d);
  RUN (main_mpz_tget_d(); );
  RUN (main_tget_d_2exp(); );

  RUN (main_mpq_tget_d);

  return 0;
}
