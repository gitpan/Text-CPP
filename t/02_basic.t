use strict;
use Test::More tests => 10;
use Text::CPP qw(:all);

ok(Text::CPP::CLK_GNUC99, 'CLK_GNUC99 is defined in Text::CPP');
ok(CLK_GNUC99, 'CLK_GNUC99 is exported');
ok(CPP_NOT, 'CPP_EQ is exported');
ok(CPP_N_CATEGORY, 'CPP_N_CATEGORY is exported');
ok(TF_PREV_WHITE, 'TF_PREV_WHITE is exported');

my $reader = new Text::CPP(CLK_GNUC99);
ok(defined $reader, 'Created something ...');
ok(UNIVERSAL::isa($reader, 'Text::CPP'), '... which is a Text::CPP');
ok($reader->type(CPP_NAME) eq 'CPP_NAME', 'Text::CPP names tokens');
ok($reader->errors == 0, 'No errors were recorded');
$reader = undef;
ok(1, 'Successfully freed the Text::CPP object');
