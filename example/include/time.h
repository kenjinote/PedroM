#ifndef __TIME
#define __TIME

#include "ped_base.h"

#ifndef __HAVE_size_t
#define __HAVE_size_t
typedef unsigned long size_t;
#endif

typedef unsigned long clock_t;
typedef unsigned long time_t;
struct tm
{
  int	tm_sec;
  int	tm_min;
  int	tm_hour;
  int	tm_mday;
  int	tm_mon;
  int	tm_year;
  int	tm_wday;
  int	tm_yday;
  int	tm_isdst;
};

#define CLOCKS_PER_SEC 20
#define CLK_TCK CLOCKS_PER_SEC

#define clock() (*((volatile unsigned long*)__jmp_Tbl[0x4FC]) + 0)
#define time(_tp)  ({time_t _t = clock () / CLOCKS_PER_SEC; if (_tp) *(_tp) = _t; _t})
#define difftime(_t1,_t2) ((double) ((_t1)-(_t2)))

time_t    mktime(struct tm  *_t);
struct tm *gmtime(const time_t *_timer);

#define localtime gmtime

static char __time_buffer[30];
static const char *const __month[]= {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};
static const char *const __day[]  = {"Sun","Mon","Tue","Wed","Thu","Fri","Sat"};

#define asctime(_tptr) (sprintf(__time_buffer, "%s %s %d %2.2d:%2.2d:%2.2d %4.4d\n", __day[(_tptr)->tm_wday], __month[(_tptr)->tm_mon], (_tptr)->tm_mday, (_tptr)->tm_hour, (_tptr)->min, (_tptr)->sec, (_tptr)->tm_year+1900), __time_buffer)
#define ctime(_time) asctime(localtime(_time))

size_t	   strftime(char *_s, size_t _maxsize, const char *_fmt, const struct tm *_t);

#endif
