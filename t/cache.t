use strict; use warnings;
use Memoize 0.45 qw(memoize unmemoize);
use Fcntl;
use Test::More tests => 22;

# Test MERGE
sub list { wantarray ? @_ : $_[-1] }
sub xx { wantarray }
ok !scalar(xx()), 'false in scalar context';
ok list(xx()), 'true in list context';
ok eval { memoize 'xx', LIST_CACHE => 'MERGE'; 1 }, 'LIST_CACHE => MERGE';
ok !scalar(xx()), 'false in scalar context again';
# Should return cached false value from previous invocation
ok !list(xx()), 'still false in list context';

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
