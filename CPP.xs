#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>
#include "config.h"
#include "system.h"
#include "cpplib.h"

#define ST_INIT		0
#define ST_READ		1
#define ST_TOKEN	2
#define ST_FINAL	3
#define ST_FAIL		99

typedef
struct _text_cpp {
    struct cpp_reader	*reader;
	unsigned int		 state;
} *Text__CPP;

#define EXPORT_INT(x) do { \
				newCONSTSUB(stash, #x, newSViv(x)); \
				av_push(export, newSVpv(#x, strlen(#x))); \
					} while(0)


MODULE = Text::CPP PACKAGE = Text::CPP

PROTOTYPES: ENABLE

BOOT:
{
	HV	*stash;
	AV	*export;

	stash = gv_stashpv("Text::CPP", TRUE);
	export = get_av("Text::CPP::EXPORT_OK", TRUE);

	EXPORT_INT(CLK_GNUC89);
	EXPORT_INT(CLK_GNUC99);
	EXPORT_INT(CLK_STDC89);
	EXPORT_INT(CLK_STDC94);
	EXPORT_INT(CLK_STDC99);
	EXPORT_INT(CLK_GNUCXX);
	EXPORT_INT(CLK_CXX98);
	EXPORT_INT(CLK_ASM);

	EXPORT_INT(ST_INIT);
	EXPORT_INT(ST_READ);
	EXPORT_INT(ST_TOKEN);
	EXPORT_INT(ST_FINAL);
	EXPORT_INT(ST_FAIL);
}

Text::CPP
new(class, lang)
	SV *    class
	int		lang
	CODE:
		Newz(0, RETVAL, 1, struct _text_cpp);
		RETVAL->reader = cpp_create_reader(lang);
		RETVAL->state = ST_INIT;
	OUTPUT:
		RETVAL

void
preprocess(self, file, stream)
	Text::CPP	self
	const char *file
	FILE*		stream
	CODE:
		if (self->state != ST_INIT)
			croak("Text::CPP reader not in initial state");
		cpp_preprocess_file(self->reader, file, stream);
		self->state = ST_FINAL;

SV *
read(self, file)
	Text::CPP	self
	const char *file
	CODE:
		if (self->state != ST_INIT)
			croak("Text::CPP reader not in initial state");
		if (cpp_read_main_file(self->reader, file, NULL)) {
			self->state = ST_READ;
			RETVAL = &PL_sv_yes;
		}
		else {
			self->state = ST_FAIL;
			RETVAL = &PL_sv_no;
		}
	OUTPUT:
		RETVAL

const char *
token(self)
	Text::CPP	self
	CODE:
		const cpp_token	*token;
		if (self->state != ST_READ)
			croak("Text::CPP reader has not yet read a file");
		token = cpp_get_token(self->reader);
		RETVAL = cpp_token_as_text(self->reader, token);
	OUTPUT:
		RETVAL

void
DESTROY(self)
	Text::CPP  self
	CODE:
		cpp_finish(self->reader, stderr);
		cpp_destroy(self->reader);
		Safefree(self);
