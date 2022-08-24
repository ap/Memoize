use strict; use warnings;
use Memoize;
use Config;

$|=1;
print "1..13\n";

my $n;
sub like {
  my ($got, $expected) = @_;
  print 'not ' x ($got !~ $expected), 'ok ', ++$n, "\n";
}

eval { memoize({}) };
like $@, qr/^Usage: memoize 'functionname'\|coderef \{OPTIONS\}/;

eval { memoize([]) };
like $@, qr/^Usage: memoize 'functionname'\|coderef \{OPTIONS\}/;

eval { my $x; memoize(\$x) };
like $@, qr/^Usage: memoize 'functionname'\|coderef \{OPTIONS\}/;

my $dummyfile = './dummydb';
use Fcntl;
my %args = ( DB_File => [],
             GDBM_File => [$dummyfile, \&GDBM_File::GDBM_NEWDB, 0666],
             ODBM_File => [$dummyfile, O_RDWR|O_CREAT, 0666],
             NDBM_File => [$dummyfile, O_RDWR|O_CREAT, 0666],
             SDBM_File => [$dummyfile, O_RDWR|O_CREAT, 0666],
           );
my $mod;
for $mod (qw(DB_File GDBM_File SDBM_File ODBM_File NDBM_File)) {
  eval { require "$mod.pm" } or do {
	++$n;
	print "ok $n # skip Could not load $mod\n";
	next;
  };
  eval {
    tie my %cache => $mod, map { (ref($_) eq 'CODE') ? &$_ : $_ } @{$args{$mod}};
    memoize(sub {}, LIST_CACHE => [HASH => \%cache ]);
  };
  like $@, qr/^You can't use \Q$mod\E for LIST_CACHE because it can only store scalars/;
  1 while unlink $dummyfile, "$dummyfile.dir", "$dummyfile.pag", "$dummyfile.db";
}

my @w;
eval { local $SIG{'__WARN__'} = sub { push @w, @_ };
       memoize(sub {}, LIST_CACHE => ['TIE', 'WuggaWugga']) 
     };
like $@, qr/^Can't locate WuggaWugga.pm in \@INC/, '... with the expected error';
print 'not ' x ($w[0] !~ /^TIE option to memoize\(\) is deprecated; use HASH instead/), 'ok ', ++$n, "\n";
print 'not ' x (@w != 1), 'ok ', ++$n, "\n";

eval { memoize(sub {}, LIST_CACHE => 'YOB GORGLE') };
like $@, qr/^Unrecognized option to `LIST_CACHE': `YOB GORGLE'/;

eval { memoize(sub {}, SCALAR_CACHE => ['YOB GORGLE']) };
like $@, qr/^Unrecognized option to `SCALAR_CACHE': `YOB GORGLE'/;
