use strict;
use warnings;
use Data::Dumper;
use Test::More tests => 7;
use Text::CPP qw(:all);

my @token;
my $reader = new Text::CPP(
		Language	=> CLK_GNUC99,
		Options	=> {
						WarnTrigraphs	=> 1,
						WarningsAreErrors	=> 1,
						},
			);
ok($reader, 'Created a reader');
ok($reader->read('t/options0.c'), 'Read a source file');
ok($reader->tokens, 'Preprocessed the file');
my $errors = $reader->errors;
ok($errors, 'Got at least one error');
my @errors = $reader->errors;
ok($errors == @errors, 'Library and Perl error counts match');
ok(length $errors[0], 'First error is nonempty');
ok($errors[0] =~ /trigraph/, 'First error mentions trigraphs');
