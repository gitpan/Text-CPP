#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>
#include "config.h"
#include "system.h"
#include "cpplib.h"

#define ST_INIT		0
#define ST_READ		1
#define ST_FINAL	2
#define ST_FAIL		99

#define ASSERT_INIT(s) do { if ((s)->state != ST_INIT) \
	croak("Text::CPP reader is not ready to read a file"); } while(0)
#define ASSERT_READ(s) do { if ((s)->state != ST_READ) \
	croak("Text::CPP reader has not yet read a file"); } while(0)

typedef
struct _text_cpp {
    struct cpp_reader	*reader;
	unsigned int		 state;
	SV					*user_data;
	CV					*cb_file_change;
	CV					*cb_line_change;
	CV					*cb_define;
	CV					*cb_undef;
	CV					*cb_include;
	CV					*cb_ident;
	CV					*cb_pragma;
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

	EXPORT_INT(CPP_EQ);
	EXPORT_INT(CPP_NOT);
	EXPORT_INT(CPP_GREATER);
	EXPORT_INT(CPP_LESS);
	EXPORT_INT(CPP_PLUS);
	EXPORT_INT(CPP_MINUS);
	EXPORT_INT(CPP_MULT);
	EXPORT_INT(CPP_DIV);
	EXPORT_INT(CPP_MOD);
	EXPORT_INT(CPP_AND);
	EXPORT_INT(CPP_OR);
	EXPORT_INT(CPP_XOR);
	EXPORT_INT(CPP_RSHIFT);
	EXPORT_INT(CPP_LSHIFT);
	EXPORT_INT(CPP_MIN);
	EXPORT_INT(CPP_MAX);
	EXPORT_INT(CPP_COMPL);
	EXPORT_INT(CPP_AND_AND);
	EXPORT_INT(CPP_OR_OR);
	EXPORT_INT(CPP_QUERY);
	EXPORT_INT(CPP_COLON);
	EXPORT_INT(CPP_COMMA);
	EXPORT_INT(CPP_OPEN_PAREN);
	EXPORT_INT(CPP_CLOSE_PAREN);
	EXPORT_INT(CPP_EOF);
	EXPORT_INT(CPP_EQ_EQ);
	EXPORT_INT(CPP_NOT_EQ);
	EXPORT_INT(CPP_GREATER_EQ);
	EXPORT_INT(CPP_LESS_EQ);
	EXPORT_INT(CPP_PLUS_EQ);
	EXPORT_INT(CPP_MINUS_EQ);
	EXPORT_INT(CPP_MULT_EQ);
	EXPORT_INT(CPP_DIV_EQ);
	EXPORT_INT(CPP_MOD_EQ);
	EXPORT_INT(CPP_AND_EQ);
	EXPORT_INT(CPP_OR_EQ);
	EXPORT_INT(CPP_XOR_EQ);
	EXPORT_INT(CPP_RSHIFT_EQ);
	EXPORT_INT(CPP_LSHIFT_EQ);
	EXPORT_INT(CPP_MIN_EQ);
	EXPORT_INT(CPP_MAX_EQ);
	EXPORT_INT(CPP_HASH);
	EXPORT_INT(CPP_PASTE);
	EXPORT_INT(CPP_OPEN_SQUARE);
	EXPORT_INT(CPP_CLOSE_SQUARE);
	EXPORT_INT(CPP_OPEN_BRACE);
	EXPORT_INT(CPP_CLOSE_BRACE);
	EXPORT_INT(CPP_SEMICOLON);
	EXPORT_INT(CPP_ELLIPSIS);
	EXPORT_INT(CPP_PLUS_PLUS);
	EXPORT_INT(CPP_MINUS_MINUS);
	EXPORT_INT(CPP_DEREF);
	EXPORT_INT(CPP_DOT);
	EXPORT_INT(CPP_SCOPE);
	EXPORT_INT(CPP_DEREF_STAR);
	EXPORT_INT(CPP_DOT_STAR);
	EXPORT_INT(CPP_ATSIGN);
	EXPORT_INT(CPP_NAME);
	EXPORT_INT(CPP_NUMBER);
	EXPORT_INT(CPP_CHAR);
	EXPORT_INT(CPP_WCHAR);
	EXPORT_INT(CPP_OTHER);
	EXPORT_INT(CPP_STRING);
	EXPORT_INT(CPP_WSTRING);
	EXPORT_INT(CPP_HEADER_NAME);
	EXPORT_INT(CPP_COMMENT);
	EXPORT_INT(CPP_MACRO_ARG);
	EXPORT_INT(CPP_PADDING);

	EXPORT_INT(CPP_N_CATEGORY);
	EXPORT_INT(CPP_N_INVALID);
	EXPORT_INT(CPP_N_INTEGER);
	EXPORT_INT(CPP_N_FLOATING);
	EXPORT_INT(CPP_N_WIDTH);
	EXPORT_INT(CPP_N_SMALL);
	EXPORT_INT(CPP_N_MEDIUM);
	EXPORT_INT(CPP_N_LARGE);
	EXPORT_INT(CPP_N_RADIX);
	EXPORT_INT(CPP_N_DECIMAL);
	EXPORT_INT(CPP_N_HEX);
	EXPORT_INT(CPP_N_OCTAL);
	EXPORT_INT(CPP_N_UNSIGNED);
	EXPORT_INT(CPP_N_IMAGINARY);

	EXPORT_INT(ST_INIT);
	EXPORT_INT(ST_READ);
	EXPORT_INT(ST_FINAL);
	EXPORT_INT(ST_FAIL);
}

SV *
new(class, lang)
	const char *class
	int			lang
	CODE:
		Text__CPP	self;
		Newz(0, self, 1, struct _text_cpp);
		self->reader = cpp_create_reader(lang);
		self->state = ST_INIT;
		self->user_data = newRV_noinc((SV *)newHV());
		/* This is slightly uglier than just returning self as a
		 * Text::CPP but does allow proper subclassing. */
		RETVAL = newSV(0);
		sv_setref_pv(RETVAL, class, (void *)self);
	OUTPUT:
		RETVAL

SV *
data(self)
	Text::CPP	self
	CODE:
		RETVAL = SvREFCNT_inc(self->user_data);
	OUTPUT:
		RETVAL

SV *
read(self, file)
	Text::CPP	self
	const char *file
	CODE:
		ASSERT_INIT(self);
		if (cpp_read_main_file(self->reader, file, NULL)) {
			self->state = ST_READ;
			RETVAL = &PL_sv_yes;
		}
		else {
			self->state = ST_FAIL;
			RETVAL = &PL_sv_undef;
		}
	OUTPUT:
		RETVAL

void
token(self)
	Text::CPP	self
	PPCODE:
		const cpp_token	*token;
		SV				*sv;
		ASSERT_READ(self);
		token = cpp_get_token(self->reader);
		if (token->type == CPP_EOF) {
			self->state = ST_FINAL;
			XSRETURN_UNDEF;
		}
		sv = newSVpv(
				cpp_token_as_text(self->reader, token),
				cpp_token_len(token));
		XPUSHs(sv_2mortal(sv));
		if (GIMME_V == G_SCALAR)
			XSRETURN(1);
		XPUSHs(sv_2mortal(newSViv(token->type)));
		XPUSHs(sv_2mortal(newSViv(token->flags)));
		XSRETURN(3);

void
tokens(self)
	Text::CPP	self
	PPCODE:
		const cpp_token	*token;
		int				 wa;
		AV				*av;
		SV				*sv;
		ASSERT_READ(self);
		wa = GIMME_V;
		if (wa == G_SCALAR)
			av = newAV();
		else
			av = NULL;	/* Avoid warning */
		for (;;) {
			token = cpp_get_token(self->reader);
			if (token->type == CPP_EOF)
				break;
			if (wa == G_VOID)
				continue;
			sv = newSVpv(
					cpp_token_as_text(self->reader, token),
					cpp_token_len(token));
			if (wa == G_SCALAR)
				av_push(av, sv);
			else
				XPUSHs(sv_2mortal(sv));
		}
		if (wa == G_SCALAR)
			XPUSHs(sv_2mortal(newRV_noinc((SV *)av)));
		self->state = ST_FINAL;

void
preprocess_to_stream(self, file, stream)
	Text::CPP	self
	const char *file
	FILE*		stream
	CODE:
		/* We get this method for free. */
		ASSERT_INIT(self);
		cpp_preprocess_file(self->reader, file, stream);
		self->state = ST_FINAL;

SV *
preprocess(self, file)
	Text::CPP	self
	const char *file
	CODE:
		ASSERT_INIT(self);
		if (!cpp_read_main_file(self->reader, file, NULL)) {
			self->state = ST_FAIL;
			XSRETURN_UNDEF;
		}
		self->state = ST_READ;
		RETVAL = &PL_sv_undef;
	OUTPUT:
		RETVAL

int
errors(self)
	Text::CPP	self
	CODE:
		RETVAL = cpp_errors(self->reader);
	OUTPUT:
		RETVAL

void
DESTROY(self)
	Text::CPP  self
	CODE:
		cpp_finish(self->reader, stderr);
		cpp_destroy(self->reader);
		SvREFCNT_dec(self->user_data);
		Safefree(self);
