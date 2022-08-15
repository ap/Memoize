use strict; use warnings;
use Fcntl;

use lib 't/lib';
use DBMTest 'GDBM_File', is_scalar_only => 1;

my $file;
$file = "md$$";
1 while unlink $file, "$file.dir", "$file.pag";
test_dbm $file, GDBM_File::GDBM_NEWDB, 0666;
1 while unlink $file, "$file.dir", "$file.pag";
