use strict;
use Test::More tests => 4;
use Text::CPP qw(:all);

ok(Text::CPP::CLK_GNUC99, 'CLK_GNUC99 is defined in Text::CPP');
ok(CLK_GNUC99, 'CLK_GNUC99 is exported');

my $reader = new Text::CPP(CLK_GNUC99);
ok(defined $reader, 'Created something ...');
ok(UNIVERSAL::isa($reader, 'Text::CPP'), '... which is a Text::CPP');
