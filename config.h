#ifndef __CONFIG_H__
#define __CONFIG_H__

/* These control system.h */

#define HAVE_STRING_H 1
#define HAVE_STDLIB_H 1
#define HAVE_UNISTD_H 1
#define HAVE_STRSIGNAL 1
#define HAVE_SYS_STAT_H 1
#define HAVE_SYS_WAIT_H 1
#define HAVE_FCNTL_H 1
#define TIME_WITH_SYS_TIME 1

/* And I've included these anyway for now. */

#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <limits.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include "ansidecl.h"

#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#define progname "Text::CPP"

	/* Since the gcc code is written in terms of x() functions
	 * normally provided by libiberty, it is simple to rewrite
	 * in terms of Perl. Unfortunately I looked at the definition
	 * of Newz and choked. */
static inline void *xmalloc(int s)
	{ void *ret; New(0, ret, s, char); return ret; }
static inline void *xcalloc(int n, int s)
	{ void *ret; Newz(0, ret, n * s, char); return ret; }
static inline void *xrealloc(void *p, int s)	/* Needed? */
	{ Renew(p, s, char); return p; }
static inline char *xstrdup(const char *p)
	{ char *ret; int len = strlen(p) + 1; ret = xmalloc(len);
	  Copy(p, ret, len, char); return ret; }

// #include "defaults.h"

/* This from gcc's defaults.h */
#ifndef GET_ENVIRONMENT
#define GET_ENVIRONMENT(VALUE, NAME) \
		do { (VALUE) = getenv (NAME); } while (0)
#endif

/* This from gcc's defaults.h */
/* Define default standard character escape sequences.  */
#ifndef TARGET_BELL
#  define TARGET_BELL 007
#  define TARGET_BS 010
#  define TARGET_TAB 011
#  define TARGET_NEWLINE 012
#  define TARGET_VT 013
#  define TARGET_FF 014
#  define TARGET_CR 015
#  define TARGET_ESC 033
#endif

#include "safe-ctype.h"
#include "system.h"

#endif




#if 0
HAVE__BOOL
HAVE_DECL_ABORT
HAVE_DECL_ATOF
HAVE_DECL_ATOL
HAVE_DECL_CALLOC
HAVE_DECL_ERRNO
HAVE_DECL_FPRINTF_UNLOCKED
HAVE_DECL_FPUTS_UNLOCKED
HAVE_DECL_FREE
HAVE_DECL_FWRITE_UNLOCKED
HAVE_DECL_GETCWD
HAVE_DECL_GETENV
HAVE_DECL_GETOPT
HAVE_DECL_GETRLIMIT
HAVE_DECL_GETWD
HAVE_DECL_MALLOC
HAVE_DECL_PUTC_UNLOCKED
HAVE_DECL_REALLOC
HAVE_DECL_SBRK
HAVE_DECL_SETRLIMIT
HAVE_DECL_STRSTR
HAVE_DESIGNATED_INITIALIZERS
HAVE_DOS_BASED_FILE_SYSTEM
HAVE_FCNTL_H
HAVE_FPRINTF_UNLOCKED
HAVE_FPUTC_UNLOCKED
HAVE_FPUTS_UNLOCKED
HAVE_FWRITE_UNLOCKED
HAVE_GETRLIMIT
HAVE_LIMITS_H
HAVE_MALLOC_H
HAVE_PRINTF_PTR
HAVE_PUTC_UNLOCKED
HAVE_SETRLIMIT
HAVE_STDBOOL_H
HAVE_STDDEF_H
HAVE_STDLIB_H
HAVE_STRING_H
HAVE_STRINGS_H
HAVE_STRSIGNAL
HAVE_SYS_FILE_H
HAVE_SYS_PARAM_H
HAVE_SYS_STAT_H
HAVE_SYS_TIME_H
HAVE_SYS_WAIT_H
HAVE_TIME_H
HAVE_UNISTD_H
HAVE_VOLATILE
#endif