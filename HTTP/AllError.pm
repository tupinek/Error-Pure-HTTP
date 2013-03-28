package Error::Pure::HTTP::AllError;

# Pragmas.
use base qw(Exporter);
use strict;
use warnings;

# Modules.
use Error::Pure::Utils qw(err_helper);
use Error::Pure::Output::Text qw(err_bt_pretty);
use List::MoreUtils qw(none);
use Readonly;

# Constants.
Readonly::Array our @EXPORT_OK => qw(err);
Readonly::Scalar my $EVAL => 'eval {...}';

# Version.
our $VERSION = 0.10;

# Ignore die signal.
$SIG{__DIE__} = 'IGNORE';

# Process error.
sub err {
	my @msg = @_;

	# Get errors structure.
	my @errors = err_helper(@msg);

	# Finalize in main on last err.
	my $stack_ar = $errors[-1]->{'stack'};
	if ($stack_ar->[-1]->{'class'} eq 'main'
		&& none { $_ eq $EVAL || $_ =~ m/^eval '/ms }
		map { $_->{'sub'} } @{$stack_ar}) {

		print "Content-type: text/plain\n\n";
		print scalar err_bt_pretty(@errors);
		return;

	# Die for eval.
	} else {
		my $e = $errors[-1]->{'msg'}->[0];
		chomp $e;
		die "$e\n";
	}

	return;
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Error::Pure::HTTP::AllError - Error::Pure module with full backtrace over HTTP.

=head1 SYNOPSIS

 use Error::Pure::HTTP::AllError qw(err);
 err "This is a fatal error.", "name", "value";

=head1 SUBROUTINES

=over 4

=item B<err(@messages)>

 Process error with messages @messages.

=back

=head1 EXAMPLE1

 # Pragmas.
 use strict;
 use warnings;

 # Modules.
 use Error::Pure::HTTP::AllError qw(err);

 # Error.
 err "This is a fatal error.", "name", "value";

 # Output:
 # Content-type: text/plain
 #
 # ERROR: This is a fatal error.
 # name: value
 # main  err  ./script.pl  12

=head1 EXAMPLE2

 # Pragmas.
 use strict;
 use warnings;

 # Modules.
 use Error::Pure::HTTP::AllError qw(err);

 # Print before.
 print "Before\n";

 # Error.
 err "This is a fatal error.", "name", "value";

 # Print after.
 print "After\n";

 # Output:
 # Before
 # Content-type: text/plain
 #
 # ERROR: This is a fatal error.
 # name: value
 # main  err  ./script.pl  12
 # After

=head1 DEPENDENCIES

L<Error::Pure::Utils>,
L<Error::Pure::Output::Text>,
L<Exporter>,
L<List::MoreUtils>,
L<Readonly>.

=head1 SEE ALSO

L<Error::Pure>,
L<Error::Pure::AllError>,
L<Error::Pure::Die>,
L<Error::Pure::Error>,
L<Error::Pure::ErrorList>,
L<Error::Pure::Output::Text>,
L<Error::Pure::Print>,
L<Error::Pure::Utils>.

=head1 REPOSITORY

L<https://github.com/tupinek/Error-Pure-HTTP>

=head1 AUTHOR

Michal Špaček L<mailto:skim@cpan.org>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

BSD license.

=head1 VERSION

0.01

=cut