use strict;
use File::Basename qw(basename dirname);
use IO::File;

# Some bits of this were borrowed from PDL.

chdir(dirname($0));
my $file = "typemap";
unlink $file if -f $file;
my $fh = new IO::File "> $file" or die "Can't create $file: $!";

# my $pl5_5_3 = eval { require 5.005003; 1; };
# my $pl5_6_1 = eval { require 5.006001; 1; };
my $pl5_8_0 = eval { require 5.008000; 1; };

print $fh "Text::CPP	T_PTROBJ\n";
unless ($pl5_8_0) {
	print $fh <<'EOT';
const char *	T_PV

########################################################
INPUT
T_HVREF
	if (SvROK($arg) && SvTYPE(SvRV($arg))==SVt_PVHV)
		$var = (HV*)SvRV($arg);
	else
		croak(\"$var is not a hash reference\")
EOT
}

$fh->close;
chmod 0644, $file;
