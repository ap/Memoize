use strict; use warnings;
use Memoize qw(memoize unmemoize);
use Test::More;

plan tests => 7;

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
