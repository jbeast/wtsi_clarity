package wtsi_clarity::util::clarity_elements_fetcher_role_util;

use Moose::Role;
use XML::LibXML;

use wtsi_clarity::util::request;
use wtsi_clarity::util::clarity_elements;

our $VERSION = '0.0';

has '_targets' => (
  isa => 'HashRef',
  is  => 'ro',
  required => 0,
  lazy => 1,
  default => sub { {} },
);

has '_cached_targets' => (
  isa => 'HashRef',
  is  => 'ro',
  required => 0,
  lazy => 1,
  default => sub { {} },
);



# Finding the targets....

sub _fetch_target_from_local {
  my ($self, $uri) = @_;

  if (!exists $self->_cached_targets->{$uri}) {
    $self->_cached_targets->{$uri} = $self->fetch_and_parse($uri);
  }

  return $self->_cached_targets->{$uri}; #$self->fetch_and_parse($uri);
}

sub fetch_targets_hash {
  # start the recursive search for targets.
  my ($self, @list_of_xpath) = @_;

  my @output =  $self->_find_xml_recursively($self->process_doc->getDocumentElement(), @list_of_xpath);

  my %hash =  map { $_->getValue() => $self->_fetch_target_from_local($_->value) } @output;

  return \%hash;
}

## no critic(Subroutines::ProhibitUnusedPrivateSubroutines)
sub _fetch_targets_hash {
  my ($self) = @_;
  my $hash = $self->fetch_targets_hash($self->get_targets_uri());

  return $hash;
}
## use critic

sub _find_xml_recursively {
  my ($self,$xml, @xpaths) = @_;
  my $first = shift @xpaths;

  my @nodeList = $xml->findnodes($first)->get_nodelist();
  my @found_targets = ();

  if (scalar @xpaths != 0)
  {
    foreach my $element (@nodeList)
    {
      my $partial_xml = $self->_fetch_target_from_local($element->getValue());
      my @new_targets   = $self->_find_xml_recursively($partial_xml->getDocumentElement() , @xpaths);
      push @found_targets, @new_targets;
    }
    return @found_targets;
  }
  else
  {
    return @nodeList;
  }
}

# core methods ....

sub put_changes {
  my ($self) = @_;
  foreach my $targetURI (keys %{$self->_targets})
  {
    $self->request->put($targetURI, $self->_targets->{$targetURI});
  }
  return;
}

1;

__END__

=head1 NAME

wtsi_clarity::util::clarity_elements_fetcher_role_util

=head1 SYNOPSIS

  with 'wtsi_clarity::util::clarity_elements_fetcher_role_util';

=head1 DESCRIPTION

  Utility role for wtsi_clarity::util::clarity_elements_fetcher_role

=head1 SUBROUTINES/METHODS

=head2 fetch_targets_hash
  Takes a list of XPaths, and use them to find the targets that will need to be
  updated, as a hash (its keys are the URI of the targets).
  Each Xpath has to point toward a URI, that will be fetched, and use to apply the next one.

=head2 fetch_and_update_targets
  Takes an XML doc to process.
  Method used by clarity_elements_fetcher to fetch the target, and update them.

=head2  put_changes
  Method used to send the update requests after having updated the targets.

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item Moose

=item XML::LibXML

=back

=head1 AUTHOR

Benoit Mangili E<lt>bm10@sanger.ac.ukE<gt>

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
