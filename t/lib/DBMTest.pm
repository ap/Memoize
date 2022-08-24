use strict; use warnings;

package DBMTest;

my $module;

use Memoize qw(memoize unmemoize);

sub errlines { split /\n/, $@ }

my $ARG = 'Keith Bostic is a pinhead';

sub c5 { 5 }
sub c23 { 23 }

sub test_dbm {
	my $testno = 1;

	tie my %cache, $module, @_ or die $!;

	memoize 'c5',
		SCALAR_CACHE => [ HASH => \%cache ],
		LIST_CACHE => 'FAULT';

	my $t1 = c5($ARG);
	my $t2 = c5($ARG);
	print (($t1 == 5) ? "ok $testno\n" : "not ok $testno\n");
	$testno++;
	print (($t2 == 5) ? "ok $testno\n" : "not ok $testno\n");
	unmemoize 'c5';

	# Now something tricky---we'll memoize c23 with the wrong table that
	# has the 5 already cached.
	memoize 'c23',
		SCALAR_CACHE => [ HASH => \%cache ],
		LIST_CACHE => 'FAULT';

	my $t3 = c23($ARG);
	my $t4 = c23($ARG);
	$testno++;
	print (($t3 == 5) ? "ok $testno\n" : "not ok $testno\n");
	$testno++;
	print (($t4 == 5) ? "ok $testno\n" : "not ok $testno\n");
	unmemoize 'c23';
}

my @file;

sub cleanup { 1 while unlink @file }

sub import {
	(undef, $module, my %arg) = (shift, @_);

	if (eval "require $module") {
		printf "1..%d\n", 4 + ($arg{extra_tests}||0);
	} else {
		print join("\n# ", "1..0 # Skipped: Could not load $module", errlines), "\n";
		exit 0;
	}

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
