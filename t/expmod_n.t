use strict; use warnings;
use Memoize;
use Memoize::Expire;
use Test::More tests => 14;

my $RETURN = 1;
my %CALLS;

tie my %cache => 'Memoize::Expire', NUM_USES => 2;
memoize sub { ++$CALLS{$_[0]}; $RETURN },
    SCALAR_CACHE => [ HASH => \%cache ],
    LIST_CACHE => 'FAULT',
    INSTALL => 'call';

# $Memoize::Expire::DEBUG = 1;

is call($_), 1, "$_ gets new val" for 0..3;

is_deeply \%CALLS, {0=>1,1=>1,2=>1,3=>1}, 'memoized function called once per argument';

$RETURN = 2;
is call(1), 1, '1 expires';
is call(1), 2, '1 gets new val';
is call(2), 1, '2 expires';

is_deeply \%CALLS, {0=>1,1=>2,2=>1,3=>1}, 'memoized function called for expired argument';

$RETURN = 3;
is call(0), 1, '0 expires';
is call(1), 2, '1 expires';
is call(2), 3, '2 gets new val';
is call(3), 1, '3 expires';

is_deeply \%CALLS, {0=>1,1=>2,2=>2,3=>1}, 'memoized function called for other expired argument';
