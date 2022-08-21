use strict; use warnings;
use Memoize;
use Test::More tests => 6;

my $timestamp;
sub timelist { (++$timestamp) x $_[0] }

memoize('timelist');

my $t1 = [timelist(1)];
is_deeply [timelist(1)], $t1, 'memoizing a volatile function makes it stable';
my $t7 = [timelist(7)];
isnt @$t1, @$t7, '... unless the arguments change';
is_deeply $t7, [($$t7[0]) x 7], '... which leads to the expected new return value';
is_deeply [timelist(7)], $t7, '... which then also stays stable';

sub con { wantarray ? 'list' : 'scalar' }
memoize('con');
is scalar(con(1)), 'scalar', 'scalar context propgates properly';
is_deeply [con(1)], ['list'], 'list context propgates properly';
