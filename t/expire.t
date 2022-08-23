use strict; use warnings;
use Memoize;

my %underlying;
sub ExpireTest::TIEHASH { bless \%underlying, shift }
sub ExpireTest::EXISTS  { exists $_[0]{$_[1]} }
sub ExpireTest::FETCH   { $_[0]{$_[1]} }
sub ExpireTest::STORE   { $_[0]{$_[1]} = $_[2] }

my $n = 0;

print "1..17\n";

$n++; print "ok $n\n";

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
$n++; print "ok $n\n";

my $i;
for $i (1, 2, 3, 1, 2, 1) {
  $n++;
  unless ($i == id($i)) {
    print "not ";
  }
  print "ok $n\n";
}

for $i (1, 2, 3) {
  $n++;
  unless ($CALLS{$i} == 1) {
    print "not ";
  }
  print "ok $n\n";
}

delete $underlying{1};

for $i (1, 2, 3) {
  my $v = id($i);
}

for $i (1, 2, 3) {
  $n++;
  unless ($CALLS{$i} == 1 + ($i == 1)) {
    print "not ";
  }
  print "ok $n\n";
}

delete @underlying{1,2};

for $i (1, 2, 3) {
  my $v = id($i);
}

for $i (1, 2, 3) {
  $n++;
  unless ($CALLS{$i} == 4 - $i) {
    print "not ";
  }
  print "ok $n\n";
}

exit 0;
