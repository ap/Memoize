# -*- mode: perl; perl-indent-level: 2 -*-
# vim: ts=8 sw=2 sts=2 noexpandtab

use strict; use warnings;
# $Memoize::Storable::Verbose = 0;

use lib 't/lib';
use DBMTest 'Memoize::Storable', extra_tests => 1;

my $file;
$file = "storable$$";
1 while unlink $file;
test_dbm $file;
1 while unlink $file;

if (eval { Storable->VERSION('0.609') }) {
  { tie my %cache, 'Memoize::Storable', $file, 'nstore' or die $! }
  print Storable::last_op_in_netorder() ? "ok 5\n" : "not ok 5\n";
  1 while unlink $file;
} else {
  print "ok 5 # skip Storable $Storable::VERSION too old for last_op_in_netorder\n";
}
