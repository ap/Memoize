use strict; use warnings;
use Memoize 0.52 qw(memoize unmemoize);
use Fcntl;

sub test_dbm;
my $module;
BEGIN {
  $module = 'Memoize::AnyDBM_File';
  eval "require $module" or do {
    print "1..0 # Skipped: Could not load $module\n";
    exit 0;
  };
}

print "1..4\n";

sub i {
  $_[0];
}

my $ARG;
$ARG = 'Keith Bostic is a pinhead';

sub c119 { 119 }
sub c7 { 7 }
sub c43 { 43 }
sub c23 { 23 }
sub c5 { 5 }

sub n {
  $_[0]+1;
}

my ($file, @files);
$file = "md$$";
@files = ($file, "$file.db", "$file.dir", "$file.pag");
1 while unlink @files;
test_dbm $file, O_RDWR | O_CREAT, 0666;
1 while unlink $file, "$file.dir", "$file.pag";

sub test_dbm {
  my $testno = 1;

  tie my %cache, $module, @_ or die $!;

  memoize 'c5', 
    SCALAR_CACHE => [HASH => \%cache],
    LIST_CACHE => 'FAULT'
    ;

  my $t1 = c5($ARG);	
  my $t2 = c5($ARG);	
  print (($t1 == 5) ? "ok $testno\n" : "not ok $testno\n");
  $testno++;
  print (($t2 == 5) ? "ok $testno\n" : "not ok $testno\n");
  unmemoize 'c5';

  # Now something tricky---we'll memoize c23 with the wrong table that
  # has the 5 already cached.
  memoize 'c23', 
  SCALAR_CACHE => ['HASH', \%cache],
  LIST_CACHE => 'FAULT'
    ;

  my $t3 = c23($ARG);
  my $t4 = c23($ARG);
  $testno++;
  print (($t3 == 5) ? "ok $testno\n" : "not ok $testno  #   Result $t3\n");
  $testno++;
  print (($t4 == 5) ? "ok $testno\n" : "not ok $testno  #   Result $t4\n");
  unmemoize 'c23';
}

{ 
  my @present = grep -e, @files;
  my @failed;
  if (@present && (@failed = grep { not unlink } @present)) {
    warn "Can't unlink @failed!  ($!)";
  }
}
