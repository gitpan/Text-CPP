package Text::CPP;

use strict;
use warnings;
use vars qw($VERSION @ISA @EXPORT_OK %EXPORT_TAGS %LANGUAGE);
use Exporter;

require DynaLoader;

$VERSION = 0.08;
@ISA = qw(Exporter DynaLoader);
@EXPORT_OK = ();
%EXPORT_TAGS = (
		all	=> \@EXPORT_OK,
			);

bootstrap Text::CPP;

# Some of these choices are rather arbitrary
%LANGUAGE = (
		C				=> CLK_GNUC99(),

		C89				=> CLK_STDC89(),
		C94				=> CLK_STDC94(),
		C99				=> CLK_STDC99(),

		GNUC			=> CLK_GNUC99(),
		GNUC89			=> CLK_GNUC89(),
		GNUC99			=> CLK_GNUC99(),

		STDC			=> CLK_STDC99(),
		STDC89			=> CLK_STDC89(),
		STDC94			=> CLK_STDC94(),
		STDC99			=> CLK_STDC99(),

		'C++'			=> CLK_GNUCXX(),
		'C++98'			=> CLK_CXX98(),
		'GNUC++'		=> CLK_GNUCXX(),

		ASM				=> CLK_ASM(),
		ASSEMBLER		=> CLK_ASM(),
		ASSEMBLY		=> CLK_ASM(),

		CLK_GNUC89()	=> CLK_GNUC89(),
		CLK_GNUC99()	=> CLK_GNUC99(),
		CLK_STDC89()	=> CLK_STDC89(),
		CLK_STDC94()	=> CLK_STDC94(),
		CLK_STDC99()	=> CLK_STDC99(),
		CLK_GNUCXX()	=> CLK_GNUCXX(),
		CLK_CXX98()		=> CLK_CXX98(),
		CLK_ASM()		=> CLK_ASM(),


			);

sub new {
	my $class = shift;
	my $self = ($#_ == 0) ? { %{ (shift) } } : { @_ };

	if (exists $self->{Language}) {
		my $language = $LANGUAGE{$self->{Language}};
		unless ($language) {
			my @languages = keys %LANGUAGE;
			push(@languages, grep { /^CLK_/ } @EXPORT_OK);
			die "Invalid language $self->{Language}. " .
							"Try one of @languages";
		}
		$self->{Language} = $language;
	}

	my $language = (exists $self->{Language})
					? $self->{Language}
					: CLK_GNUC99();
	my $builtins = (exists $self->{Builtins})
					? $self->{Builtins}
					: { };
	my $options = (exists $self->{Options})
					? $self->{Options}
					: { };
	return Text::CPP::_create($class, $language, $builtins, $options);
}

=head1 NAME

Text::CPP - A full C Preprocessor in XS

=head1 SYNOPSIS

	use Text::CPP;
	my $reader = new Text::CPP(
		Language	=> CLK_GNUC99,
		Builtins	=> {
			foo	=> 'this',
			bar	=> 'that',
		},
	);
	$reader->read("file.c");
	while (my $token = $reader->token) {
		print "Token: $token\n";
	}

	$reader->data->{MyKey} = $MyData;

=head1 DESCRIPTION

A fast C preprocessor in XS. This does not require an external C
preprocessor, and will not fork() or exec() any external process.

=head1 USAGE

The following methods have been implemented, allowing the use of
this module as a pure C preprocessor, or as a lexer for a C, C++
or Assembler-like language.

=over 4

=item new Text::CPP(...)

Takes a hash or hashref with the following possible keys:

=over 4

=item Language

Defines the source language to preprocess and/or tokenise. It may
be any of:

=over 4

=item CLK_GNUC89 - GNU C89

=item CLK_GNUC99 - GNU C99

=item CLK_STDC89 - Standard C89

=item CLK_STDC94 - Standard C94

=item CLK_STDC99 - Standard C99

=item CLK_GNUCXX - GNU C++

=item CLK_CXX98 - Standard C++ 98

=item CLK_ASM - Assembler

=back

=item Options

A hashref of options for the preprocessor. Valid entries are given
with alternative forms (from GNU cpp) in brackets.

=over 4

=item DiscardComments (-C): boolean

=item DiscardCommentsInMacroExp (-CC): boolean

=item PrintIncludeNames (-H): boolean

=item NoLineCommands (-P): boolean

=item WarnComments (-Wcomment -Wcomments): boolean

=item WarnDeprecated (-Wdeprecated): boolean

=item WarningsAreErrors (-Werror): boolean

=item WarnImport (-Wimport): boolean

=item WarnMultichar (-Wmultichar): boolean

=item WarnSystemHeaders (-Wsystem-headers): boolean

Ignore errors in system header files.

=item WarnTraditional (-Wtraditional): boolean

=item WarnTrigraphs (-Wtrigraphs): boolean

=item WarnUnusedMacros (-Wunused-macros): boolean

=item Pedantic (-pedantic): boolean

=item PedanticErrors (-pedantic-errors): boolean

Implies, and overrides, Pedantic.

=item Remap (-remap): boolean

Deal with some brokennesses of MSDOS. Untested.

=item Trigraphs (-trigraphs): boolean

=item Traditional (-traditional): boolean

=item NoWarnings (-w): boolean

=item IncludePrefix (-iprefix): string

=item SysRoot (-isysroot): string

=item Include (-include): array of strings

Include the specified files before reading the main file to be
processed.

=item IncludeMacros (-imacros): array of strings

Include the specified files before reading the main file to be
processed. Output from preprocessing these files is discarded. Files
specified by IncludeMacros are processed before files specified
by Include.

=item IncludePath (-I): array of strings

This include path is searched first.

=item SystemIncludePath (-isystem): array of strings

Specify the standard system include path, searched second.

=item AfterIncludePath (-idirafter): array of strings

This include path is searched after the system include path.

=back

=item Builtins

A hashref of predefined macros. The values must be strings or integers.
Macros in this hash will be defined before preprocessing starts.

=back

=item $text = $reader->token

=item ($text, $type, $flags) = $reader->token

Return the next available preprocessed token. Some tokens are not
stringifiable. These include tokens of type CPP_MACRO_ARG, CPP_PADDING
and CPP_EOF. Text::CPP returns a dummy string in the 'text' field for
these tokens. Tokens of type CPP_EOF should never actually be returned.

=item @tokens = $reader->tokens

Preprocess and return a list of tokens. This is approximately
equivalent to:

	push(@tokens, $_) while ($_ = $reader->token);

=item $reader->type($type)

Return a human readable name for a token type, as returned by
$reader->token.

=item $reader->data

Returns a hashref in which user data may be stored by subclasses.
This hashref is created with a new Text::CPP object, and is ignored
for all functional purposes. The user may do with it as he wishes.

=item $reader->errors

In scalar context, returns the fatal error count. In list context,
returns a list of warnings and errors encountered by the preprocessor.
Thus scalar(@errors) >= $errors, since @errors will also contain
the warnings.

=back

=head1 BUGS

This documentation is incomplete. There are many important functions
in the source which are not yet documented.

It is not possible to instantiate multiple Text::CPP objects, since
the underlying library uses many global variables.

C99 may not implement variadic macros correctly according to the ISO
standard. I must check this. If anyone knows, please tell me.

It is not yet possible to specify a list of include directories.

The code is still tied into gcc in some places. Files like prefix.c
can be removed entirely when this is cleaned up.

The following options are not yet handled.

=item -M*

=item -D/-U

=item -std

=item -ansi

=item -foperator-names

=item -fshow-column

=item -ftabstop

=head1 CAVEATS

Memory for hash tables, token names, etc is only freed when the reader
is destroyed.

Assertions are a deprecated feature, and thus the -A flag is not
supported.

It does not seem necessary to support the following flags:

=item -x

=item -iwithprefix

=item -iwithprefixbefore

=item -fpreprocessed

=head1 TODO

=item Include lists

=item Dependency output

=item Support remaining options

=item Lots more tests

=item Remaining callbacks

=item Virtual file support

=item Multiplicity

=head1 SUPPORT

Mail the author at <cpan@anarres.org>

=head1 AUTHOR

	Shevek
	CPAN ID: SHEVEK
	cpan@anarres.org
	http://www.anarres.org/projects/

=head1 COPYRIGHT

Copyright (c) 2002 Shevek. All rights reserved.

This program is free software; but parts of it have been borrowed
from, or based on, parts of the GNU C Compiler version 3.3.2. You may
therefore redistribute and/or modify this code under the terms of the
GNU GENERAL PUBLIC LICENSE. I am unable to release this code under the
usual Perl license because that license includes the Artistic License,
and I cannot rerelease GPL code under the Artistic License. Sorry.

The full text of the license can be found in the
COPYING file included with this module.

=head1 SEE ALSO

perl(1).

=cut

1;
__END__
