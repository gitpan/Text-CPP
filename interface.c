/* Written by Shevek as glue between cpplib and Text::CPP */

#include "config.h"
#include "system.h"
#include "cpplib.h"
#include "cpphash.h"

/* Adjust pfile->print.line for newlines embedded in output.  */
static void
account_for_newlines (cpp_reader *pfile, const uchar *str, size_t len)
{
    while (len--)
	if (*str++ == '\n')
	    pfile->print.line++;
}

const char *
text_cpp_get_token (cpp_reader *pfile)
{
    bool avoid_paste = false;
	const cpp_token *token;

	for (;;) {
	  // pfile->print.source = NULL;
		token = cpp_get_token (pfile);

		if (token->type == CPP_PADDING) {
			avoid_paste = true;
			if (pfile->print.source == NULL
				|| (!(pfile->print.source->flags & PREV_WHITE)
				&& token->val.source == NULL))
				pfile->print.source = token->val.source;
			continue;
		}
		break;
	}

    if (token->type == CPP_EOF)
		return NULL;

    /* Subtle logic to output a space if and only if necessary.  */
    if (avoid_paste) {
		if (pfile->print.source == NULL)
			pfile->print.source = token;
		if (pfile->print.source->flags & PREV_WHITE
				|| (pfile->print.prev
				&& cpp_avoid_paste (pfile, pfile->print.prev, token))
				|| (pfile->print.prev == NULL
						&& token->type == CPP_HASH))
			putc (' ', pfile->print.outf);
    }
    else if (token->flags & PREV_WHITE)
		putc (' ', pfile->print.outf);

    avoid_paste = false;
    pfile->print.source = NULL;
    pfile->print.prev = token;
    cpp_output_token (token, pfile->print.outf);

    if (token->type == CPP_COMMENT)
		account_for_newlines (pfile, token->val.str.text, token->val.str.len);

	return "";
}
