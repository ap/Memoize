package Memoize::AnyDBM_File;

use vars qw(@ISA $VERSION);
$VERSION = '1.05';

for my $mod (qw(DB_File GDBM_File Memoize::NDBM_File SDBM_File ODBM_File)) {
  if (eval "require $mod") {
    print STDERR "AnyDBM_File => Selected $mod.\n" if $Verbose;
    @ISA = $mod;
    return 1;
  }
}

die "No DBM package was successfully found or installed";

__END__

=pod

=head1 NAME

Memoize::AnyDBM_File - glue to provide EXISTS for AnyDBM_File for Storable use

=head1 DESCRIPTION

See L<Memoize>.

=cut
