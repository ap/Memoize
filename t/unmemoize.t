use strict; use warnings;
use Memoize qw(memoize unmemoize);

print "1..5\n";

eval { unmemoize('f') };	# Should fail
print (($@ ? '' : 'not '), "ok 1\n");

sub u {1}
my $sub = \&u;
my $wrapped = memoize('u');
print (($wrapped == \&u) ? "ok 2\n" : "not ok 2\n");

eval { unmemoize('u') };	# Should succeed
print ($@ ? "not ok 3\n" : "ok 3\n");

print (($sub == \&u) ? "ok 4\n" : "not ok 4\n");

eval { unmemoize('u') };	# Should fail
print ($@ ? "ok 5\n" : "not ok 5\n");
