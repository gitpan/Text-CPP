require 5.006001;
use ExtUtils::MakeMaker;

my @hdr = qw(ansidecl.h config.h cppdefault.h cpphash.h cpplib.h
	global.h hashtable.h hwint.h intl.h libiberty.h line-map.h
	mbchar.h mkdeps.h obstack.h prefix.h safe-ctype.h splay-tree.h
	symcat.h system.h);
my @base = qw(CPP concat cppdefault cpperror cppexp cppfiles cpphash
	cppinit cpplex cpplib cppmacro cppmain cpptrad hashtable hex
	interface lbasename line-map mbchar mkdeps safe-ctype
	splay-tree);
# prefix
my @src = map { "$_.c"} @base;
my @obj = map { "$_.o"} @base;

WriteMakefile(
	NAME			=> 'Text::CPP',
	VERSION_FROM	=> 'CPP.pm',
    ABSTRACT_FROM	=> "CPP.pm",
	AUTHOR			=> 'Shevek <cpan@anarres.org>',
	PREREQ_PM		=> { },
	INC				=> "-I.",
	OBJECT			=> "@obj",
	C				=> \@src,
	H				=> \@hdr,
	# OPTIMIZE		=> q[-O2 -g -Wall -DHAVE_CONFIG_H -DPREFIX='"/xxx"'],
	OPTIMIZE		=> q[-O0 -g -Wall -DHAVE_CONFIG_H -DPREFIX='"/xxx"'],
	clean			=> { FILES => "config.h" },
);

sub MY::postamble {
	my $self = shift;
	my $old = $self->MM::postamble(@_);
	chomp($old);
	my $new = <<'EON';

.PHONY : aux dep readme

aux : readme dep

readme : CPP.pm
	perldoc -t CPP.pm > README

dep : $(C_FILES) $(H_FILES)
	$(RM_F) .depend
	$(CC) -MM $(INC) -isystem $(PERL_INC) $(CCFLAGS) $(C_FILES) >> .depend

EON
	return $old . $new;
}
