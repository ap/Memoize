package Memoize::SDBM_File;

use SDBM_File 1.01;
@ISA = qw(SDBM_File);
$VERSION = '1.05';

1;

__END__

=pod

=head1 NAME

Memoize::SDBM_File - DEPRECATED compability shim

=head1 DESCRIPTION

This class used to provide L<EXISTS|perltie/C<EXISTS>> support for L<SDBM_File>
before support for C<EXISTS> was added to L<SDBM_File> itself
L<in Perl 5.6.0|perl56delta/SDBM_File>.

Any code still using this class should be rewritten to use L<SBDM_File> directly.

=cut
