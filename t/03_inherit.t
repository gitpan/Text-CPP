use strict;
use Test::More tests => 2;
use Text::CPP qw(:all);

{
	package My::CPP;
	use base 'Text::CPP';
}

my $reader = new My::CPP(CLK_GNUC99);
ok(defined $reader, 'Created something ...');
ok(UNIVERSAL::isa($reader, 'My::CPP'), '... which is a My::CPP');
