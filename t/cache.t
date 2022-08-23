use strict; use warnings;
use Memoize 0.45 qw(memoize unmemoize);
use Fcntl;
use Test::More tests => 47;

sub list { wantarray ? @_ : $_[-1] }

# Test FAULT
sub ns {}
sub na {}
ok eval { memoize 'ns', SCALAR_CACHE => 'FAULT'; 1 }, 'SCALAR_CACHE => FAULT';
ok eval { memoize 'na', LIST_CACHE => 'FAULT'; 1 }, 'LIST_CACHE => FAULT';
is eval { scalar(ns()) }, undef, 'exception in scalar context';
is eval { list(na()) }, undef, 'exception in list context';

# Test HASH
my (%s, %l);
sub nul {}
ok eval { memoize 'nul', SCALAR_CACHE => [HASH => \%s], LIST_CACHE => [HASH => \%l]; 1 }, '*_CACHE => HASH';
nul('x');
nul('y');
is_deeply [sort keys %s], [qw(x y)], 'scalar context calls populate SCALAR_CACHE';
is_deeply \%l, {}, '... and does not touch the LIST_CACHE';
%s = ();
() = nul('p');
() = nul('q');
is_deeply [sort keys %l], [qw(p q)], 'list context calls populate LIST_CACHE';
is_deeply \%s, {}, '... and does not touch the SCALAR_CACHE';

# Test MERGE
sub xx { wantarray }
ok !scalar(xx()), 'false in scalar context';
ok list(xx()), 'true in list context';
ok eval { memoize 'xx', LIST_CACHE => 'MERGE'; 1 }, 'LIST_CACHE => MERGE';
ok !scalar(xx()), 'false in scalar context again';
# Should return cached false value from previous invocation
ok !list(xx()), 'still false in list context';

sub reff { [1,2,3] }
sub listf { (1,2,3) }

memoize 'reff', LIST_CACHE => 'MERGE';
memoize 'listf';

scalar reff();
is_deeply [reff()], [[1,2,3]], 'reff list context after scalar context';

scalar listf();
is_deeply [listf()], [1,2,3], 'listf list context after scalar context';

unmemoize 'reff';
memoize 'reff', LIST_CACHE => 'MERGE';
unmemoize 'listf';
memoize 'listf';

is_deeply [reff()], [[1,2,3]], 'reff list context';

is_deeply [listf()], [1,2,3], 'listf list context';

sub f17 { return 17 }
memoize 'f17', SCALAR_CACHE => 'MERGE';
is_deeply [f17()], [17], 'f17 first call';
is_deeply [f17()], [17], 'f17 second call';
is scalar(f17()), 17, 'f17 scalar context call';

my (%cache, $num_cache_misses);
sub cacheit {
	++$num_cache_misses;
	"cacheit result";
}
sub test_cacheit {
	is scalar(cacheit()), 'cacheit result', 'scalar context';
	is $num_cache_misses, 1, 'function called once';

	is +(cacheit())[0], 'cacheit result', 'list context';
	is $num_cache_misses, 1, 'function not called again';

	is_deeply [values %cache], [['cacheit result']], 'expected cached value';

	%cache = ();

	is +(cacheit())[0], 'cacheit result', 'list context';
	is $num_cache_misses, 2, 'function again called after clearing the cache';

	is scalar(cacheit()), 'cacheit result', 'scalar context';
	is $num_cache_misses, 2, 'function not called again';
}

memoize 'cacheit', LIST_CACHE => [HASH => \%cache], SCALAR_CACHE => 'MERGE';
test_cacheit;
unmemoize 'cacheit';
( $num_cache_misses, %cache ) = ();
memoize 'cacheit', SCALAR_CACHE => [HASH => \%cache], LIST_CACHE => 'MERGE';
test_cacheit;

# Test errors
my @w;
my $sub = eval {
	local $SIG{'__WARN__'} = sub { push @w, @_ };
	memoize(sub {}, LIST_CACHE => ['TIE', 'WuggaWugga']);
};
is $sub, undef, 'bad TIE fails';
like $@, qr/^Can't locate WuggaWugga.pm in \@INC/, '... with the expected error';
like $w[0], qr/^TIE option to memoize\(\) is deprecated; use HASH instead/, '... and the expected deprecation warning';
is @w, 1, '... and no other warnings';

is eval { memoize sub {}, LIST_CACHE => 'YOB GORGLE' }, undef, 'bad LIST_CACHE fails';
like $@, qr/^Unrecognized option to `LIST_CACHE': `YOB GORGLE'/, '... with the expected error';

is eval { memoize sub {}, SCALAR_CACHE => ['YOB GORGLE'] }, undef, 'bad SCALAR_HASH fails';
like $@, qr/^Unrecognized option to `SCALAR_CACHE': `YOB GORGLE'/, '... with the expected error';
