use strict; use warnings;
use Memoize;
use Test::More tests => 4;

# here we test whether memoization actually has the desired effect

my ($fib, $ns1_calls, $ns2_calls, $total_calls) = ([0,1], 1, 1, 1+1);
while (@$fib < 23) {
	push @$fib, $$fib[-1] + $$fib[-2];
	my $n_calls = 1 + $ns1_calls + $ns2_calls;
	$total_calls += $n_calls;
	($ns2_calls, $ns1_calls) = ($ns1_calls, $n_calls);
}

my $num_calls;
sub fib {
	++$num_calls;
	my $n = shift;
	return $n if $n < 2;
	fib($n-1) + fib($n-2);
}

my @s1 = map 0+fib($_), 0 .. $#$fib;
is_deeply \@s1, $fib, 'unmemoized Fibonacci works';
is $num_calls, $total_calls, '... with the expected amount of calls';

undef $num_calls;
memoize 'fib';

my @f1 = map 0+fib($_), 0 .. $#$fib;
my @f2 = map 0+fib($_), 0 .. $#$fib;
is_deeply \@f1, $fib, 'memoized Fibonacci works';
is $num_calls, @$fib, '... with a minimal amount of calls';
