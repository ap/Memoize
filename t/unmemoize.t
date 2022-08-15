use strict; use warnings;
use Memoize qw(memoize unmemoize);
use Test::More tests => 7;

is eval { unmemoize('u') }, undef, 'trying to unmemoize without memoizing fails';
my $errx = qr/^Could not unmemoize function `u', because it was not memoized to begin with/;
like $@, $errx, '... with the expected error';

sub u {1}
my $sub = \&u;
my $wrapped = memoize('u');
is \&u, $wrapped, 'trying to memoize succeeds';

is eval { unmemoize('u') }, $sub, 'trying to unmemoize succeeds' or diag $@;

is \&u, $sub, '... and does in fact unmemoize it';

is eval { unmemoize('u') }, undef, 'trying to unmemoize it again fails';
like $@, $errx, '... with the expected error';
