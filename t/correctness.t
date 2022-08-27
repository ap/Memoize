use strict; use warnings;
use Memoize;

# here we test whether memoization actually has the desired effect

print "1..6\n";

print "# Fibonacci\n";

sub mt1 {			# Fibonacci
  my $n = shift;
  return $n if $n < 2;
  mt1($n-1) + mt2($n-2);
}
sub mt2 {		
  my $n = shift;
  return $n if $n < 2;
  mt1($n-1) + mt2($n-2);
}

my (@f1, @f2, @f3, @f4, $n, $i, $j, $k, @arrays);
@f1 = map { mt1($_) } (0 .. 15);
@f2 = map { mt2($_) } (0 .. 15);
memoize('mt1');
@f3 = map { mt1($_) } (0 .. 15);
@f4 = map { mt1($_) } (0 .. 15);
@arrays = (\@f1, \@f2, \@f3, \@f4); 
for ($i=0; $i<3; $i++) {
  for ($j=$i+1; $j<3; $j++) {
    $n++;
    print ((@{$arrays[$i]} == @{$arrays[$j]}) ? "ok $n\n" : "not ok $n\n");
    $n++;
    for ($k=0; $k < @{$arrays[$i]}; $k++) {
      (print "not ok $n\n", next)  if $arrays[$i][$k] != $arrays[$j][$k];
    }
    print "ok $n\n";
  }
}
