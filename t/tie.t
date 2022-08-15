use strict; use warnings;
use Fcntl;

use lib 't/lib';
use DBMTest 'Memoize::AnyDBM_File', is_scalar_only => 1;

my ($file, @files);
$file = "md$$";
@files = ($file, "$file.db", "$file.dir", "$file.pag");
1 while unlink @files;
test_dbm $file, O_RDWR | O_CREAT, 0666;
1 while unlink $file, "$file.dir", "$file.pag";

{ 
  my @present = grep -e, @files;
  my @failed;
  if (@present && (@failed = grep { not unlink } @present)) {
    warn "Can't unlink @failed!  ($!)";
  }
}
