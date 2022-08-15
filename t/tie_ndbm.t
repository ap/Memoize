use strict; use warnings;
use Fcntl;

use lib 't/lib';
use DBMTest 'Memoize::NDBM_File', is_scalar_only => 1;

my $file;
$file = "md$$";
1 while unlink $file, "$file.dir", "$file.pag", "$file.db";
test_dbm $file, O_RDWR | O_CREAT, 0666;
1 while unlink $file, "$file.dir", "$file.pag", "$file.db";
