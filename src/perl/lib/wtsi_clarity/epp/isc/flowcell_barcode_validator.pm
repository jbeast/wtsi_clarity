package wtsi_clarity::epp::isc::flowcell_barcode_validator;

use Moose;
use Carp;
use wtsi_clarity::util::clarity_validation qw/flowcell_bc/;

extends 'wtsi_clarity::epp';
with 'wtsi_clarity::util::clarity_elements';

our $VERSION = '0.0';

has 'barcode' => (
  is => 'ro',
  lazy => 1,
  builder => '_build_barcode',
);

sub _build_barcode {
  my $self = shift;

  return $self->find_udf_element($self->process_doc->xml(), "Flow Cell ID")->textContent;
}

override 'run' => sub {
  my $self= shift;
  super();

  my $validation = flowcell_bc($self->barcode);

  if ($validation->failed) {
    croak $validation->error_message;
  }

  return 1;
};

1;

__END__

=head1 NAME

wtsi_clarity::epp::isc::flowcell_barcode_validator

=head1 SYNOPSIS

  wtsi_clarity::epp:isc::flowcell_barocode_validator->new(
    process_url => 'http://my.com/processes/3345',
  )->run();

=head1 DESCRIPTION

  Will look at the output plate's barcode and validate that it is a valid Fluidigm barcode. It will
  throw an error if it isn't valid. It'll do nothing otherwise.

=head1 SUBROUTINES/METHODS

=head2 run - executes the callback

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item Moose

=item Carp

=item wtsi_clarity::util::validators

=back

=head1 AUTHOR

Chris Smith E<lt>cs24@sanger.ac.ukE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2015 Genome Research Ltd.

This file is part of wtsi_clarity project.

wtsi_clarity is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut