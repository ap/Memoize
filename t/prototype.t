use strict; use warnings;
use Memoize;
use Test::More tests => 6;

sub q1 ($) { $_[0] + 1 }
sub q2 ()  { time }
sub q3     { join "--", @_ }

sub no_warnings_ok (&$);

no_warnings_ok { memoize 'q1' } 'no warnings with $ protype';

no_warnings_ok { memoize 'q2' } 'no warnings with empty protype';

no_warnings_ok { memoize 'q3' } 'no warnings without protype';

is q1(@{['a'..'z']}), 27, '$ prototype is honored';
is eval('q2("test")'), undef, 'empty prototype is honored';
like $@, qr/^Too many arguments for main::q2 /, '... with expected parse error';

sub no_warnings_ok (&$) {
	my $w;
	local $SIG{'__WARN__'} = sub { push @$w, @_; &diag };
	shift->();
	local $Test::Builder::Level = $Test::Builder::Level + 1;
	is( $w, undef, shift ) or diag join '', @$w;
}
