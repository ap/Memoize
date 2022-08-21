use strict; use warnings;
use Memoize;
use Test::More tests => 6;

my %underlying;
sub ExpireTest::TIEHASH { bless \%underlying, shift }
sub ExpireTest::EXISTS  { exists $_[0]{$_[1]} }
sub ExpireTest::FETCH   { $_[0]{$_[1]} }
sub ExpireTest::STORE   { $_[0]{$_[1]} = $_[2] }

my %CALLS;
sub id {	
  my($arg) = @_;
  ++$CALLS{$arg};
  $arg;
}

tie my %cache => 'ExpireTest';
memoize 'id',
  SCALAR_CACHE => [HASH => \%cache], 
  LIST_CACHE => 'FAULT';

my $arg = [1..3, 1, 2, 1];
is_deeply [map scalar(id($_)), @$arg], $arg, 'memoized function sanity check';
is_deeply \%CALLS, {1=>1,2=>1,3=>1}, 'amount of initial calls per arg as expected';

delete $underlying{1};
$arg = [1..3];
is_deeply [map scalar(id($_)), @$arg], $arg, 'memoized function sanity check';
is_deeply \%CALLS, {1=>2,2=>1,3=>1}, 'amount of calls per arg after expiring 1 as expected';

delete @underlying{1,2};
is_deeply [map scalar(id($_)), @$arg], $arg, 'memoized function sanity check';
is_deeply \%CALLS, {1=>3,2=>2,3=>1}, 'amount of calls per arg after expiring 1 & 2 as expected';
