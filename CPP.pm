package Text::CPP;

use strict;
use warnings;
use vars qw($VERSION @ISA @EXPORT_OK %EXPORT_TAGS);
use Exporter;

require DynaLoader;

$VERSION = 0.03;
@ISA = qw(Exporter DynaLoader);
@EXPORT_OK = ();
%EXPORT_TAGS = (
		all	=> \@EXPORT_OK,
			);

bootstrap Text::CPP;

#sub new {
#	my $class = shift;
#	my $self = ($#_ == 0) ? { %{ (shift) } } : { @_ };
#}

=head1 NAME

Text::CPP - A full C Preprocessor in XS

=head1 SYNOPSIS

	use Text::CPP;
	my $reader = new Text::CPP(CLK_GNUC99);
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

=item my $text = $reader->token
=item my ($text, $type, $flags) = $reader->token

Return the next available preprocessed token.

=item $reader->tokens

Preprocess and return a list of tokens.

=item $reader->type($type)

Return a human readable name for a token.

=item $reader->data

Returns a hashref in which user data may be stored by subclasses.

=head1 BUGS

It may not be possible to instantiate multiple Text::CPP objects,
since the underlying library does use many global variables. This is
yet to be tested.

Memory for hash tables, etc is only freed when the reader is
destroyed. If you create multiple readers then destroy one, this may
free global tables and make the code fail.

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
from, or based on, parts of the GNU C Compiler version 3.3.2. You
may therefore redistribute and/or modify this code under the terms of
the GNU GENERAL PUBLIC LICENSE, but I am unable to release this code
under the usual Perl license, because it includes the Artistic License.

The full text of the license can be found in the
COPYING file included with this module.

=head1 SEE ALSO

perl(1).

=cut

1;
__END__
