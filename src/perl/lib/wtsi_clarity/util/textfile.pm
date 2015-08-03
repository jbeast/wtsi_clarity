package wtsi_clarity::util::textfile;

use Moose;
use Carp;
use File::Temp;

use WTSI::NPG::iRODS;

our $VERSION = '0.0';

has '_irods' => (
  is      => 'ro',
  isa     => 'WTSI::NPG::iRODS',
  lazy    => 1,
  builder => '_build__irods',
);

has '_irods_path' => (
  is      => 'ro',
  isa     => 'Str',
  lazy    => 1,
  builder => '_build__irods_path',
);

has 'content' => (
  is => 'rw',
  isa => 'ArrayRef',
);

sub saveas {
  my ($self, $path) = @_;

  open my $fh, '>', $path
    or croak qq{Could not create/open file '$path'.};
  foreach my $line (@{$self->content})
  {
      print {$fh} qq{$line\n} or croak qq[Failed to write to the file: $fh]; # Print each entry in our array to the file
  }
  close $fh
    or croak qq{ Unable to close $path.};

  return $path;
};

sub save_to_irods {
  my ($self, $file_name) = @_;

  my $file_path = $self->saveas(join '/', File::Temp->new(), $file_name);
  my $rods_path = join '/', $self->_irods_path, $file_name;

  if (!$self->_irods->list_object($rods_path)) {

    $self->_irods->add_object($file_path, $rods_path);
    $self->_irods->add_object_avu($rods_path, 'a', 'b', 'c' ); # Not sure what to put here yet

  } else {

    $self->_irods->replace_object($file_path, $rods_path);

    # Remove the old meta data
    $self->_irods->remove_object_avu($rods_path, 'a', 'b', 'c'); # Again, unsure;

    # Add the new stuff
    $self->_irods->add_object_avu($rods_path, 'a', 'b', 'c' ); # Not sure what to put here yet
  }

  return 1;
}

sub read_content {
  my ($self, $path) = @_;

  open my $fh, '<', $path
    or croak qq{Could not open file '$path'.};

  my @array = <$fh>;

  close $fh
    or croak qq{ Unable to close $path.};

  $self->content(\@array);

  return \@array;
};

sub _build__irods {
  my $self = shift;
  return WTSI::NPG::iRODS->new();
}

sub _build__irods_path {
  my $self = shift;
  return $self->config->irods->{'path'};
}

1;

__END__

=head1 NAME

wtsi_clarity::util::textfile

=head1 SYNOPSIS

  use wtsi_clarity::util::textfile;

  ...

  my $textfile = wtsi_clarity::util::textfile->new(content => $data);
  $textfile->saveas("filename.txt");

  my $other_textfile = wtsi_clarity::util::textfile->new();
  $other_textfile->read_content("filename.txt");
  $data = $other_textfile->content;

=head1 DESCRIPTION

  Represents a file and encapsulate the FS interactions.

=head1 SUBROUTINES/METHODS

=head2 saveas

  Dump the internal content in an actual file on the filesystem, with a given name.

=head2 read_content

  read the content of an actual file on the filesystem, with a given name, and load it into
  the textfile instance.

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item Moose

=item Carp

=back

=head1 AUTHOR

Author: Chris Smith E<lt>cs24@sanger.ac.ukE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2014 Genome Research Ltd.

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