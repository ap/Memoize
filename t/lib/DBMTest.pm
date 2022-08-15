use strict; use warnings;

package DBMTest;

my $module;

use Memoize qw(memoize unmemoize);
use Test::More;

sub errlines { split /\n/, $@ }

my $ARG = 'Keith Bostic is a pinhead';

sub c5 { 5 }
sub c23 { 23 }

sub test_dbm {
	tie my %cache, $module, @_ or die $!;

	memoize 'c5',
		SCALAR_CACHE => [ HASH => \%cache ],
		LIST_CACHE => 'FAULT';

	is c5($ARG), 5, 'store value during first memoization';
	unmemoize 'c5';

	# Now something tricky---we'll memoize c23 with the wrong table that
	# has the 5 already cached.
	memoize 'c23',
		SCALAR_CACHE => [ HASH => \%cache ],
		LIST_CACHE => 'FAULT';

	is c23($ARG), 5, '... and find it still there after second memoization';
	unmemoize 'c23';
}

my @file;

sub cleanup { 1 while unlink @file }

sub import {
	(undef, $module, my %arg) = (shift, @_);

	eval "require $module"
		? plan tests => 2 + ($arg{extra_tests}||0)
		: plan skip_all => join "\n# ", "Could not load $module", errlines;

	my ($basename) = map { s/.*:://; s/_file\z//; 'm_'.$_.$$ } lc $module;
	my $dirfext = $^O eq 'VMS' ? '.sdbm_dir' : '.dir'; # copypaste from DBD::DBM
	@file = map { $_, "$_.db", "$_.pag", $_.$dirfext } $basename;
	cleanup;

	my $pkg = caller;
	no strict 'refs';
	*{$pkg.'::'.$_} = \&$_ for qw(test_dbm cleanup);
	*{$pkg.'::file'} = \$basename;
}

END {
	cleanup;
	if (my @failed = grep -e, @file) {
		@failed = grep !unlink, @failed; # to set $!
		warn "Can't unlink @failed! ($!)\n" if @failed;
	}
}

1;
