package wtsi_clarity::epp::sm::report_maker;

use Moose;
use Carp;
use Readonly;
use Try::Tiny;
use Scalar::Util qw/looks_like_number/;
use wtsi_clarity::util::report;
use List::MoreUtils qw( uniq );

our $VERSION = '0.0';

extends 'wtsi_clarity::epp';

with qw/
  wtsi_clarity::util::clarity_elements
  wtsi_clarity::util::csv::report_common
  /;

## no critic(ValuesAndExpressions::RequireInterpolationOfMetachars)
Readonly::Scalar my $INPUT_ARTIFACTS_IDS_PATH               => q(/prc:process/input-output-map/input/@limsid);
Readonly::Scalar my $ART_DETAIL_SAMPLE_IDS_PATH             => q{/art:details/art:artifact/sample/@limsid};
Readonly::Scalar my $SAMPLE_PATH                            => q{smp:details/smp:sample[@limsid="%s"]};
Readonly::Scalar my $SMP_DETAIL_ARTIFACTS_IDS_PATH          => q{/smp:details/smp:sample/artifact/@limsid};
Readonly::Scalar my $ARTIFACTS_ARTIFACT_CONTAINTER_IDS_PATH => q{/art:details/art:artifact/location/container/@limsid};
Readonly::Scalar my $ARTIFACTS_ARTIFACT_URIS_PATH           => q{/art:artifacts/artifact/@uri};
Readonly::Scalar my $SAMPLE_LIMS_ID                         => q{./sample/@limsid};
Readonly::Scalar my $CONTAINER_LIMSID_FROM_SAMPLE           => qq{/art:details/art:artifact/sample[\@limsid='%s']/../location/container/\@limsid};
Readonly::Scalar my $LOCATION_FROM_SAMPLE                   => qq{/art:details/art:artifact/sample[\@limsid='%s']/../location/value/text()};
Readonly::Scalar my $CONTAINER_NAME_BY_ID                   => qq{/con:details/con:container[\@limsid='%s']/name/text()};
Readonly::Scalar my $UDF_FIELD_BY_NAME                      => qq{./udf:field[\@name="%s"]};
Readonly::Scalar my $THOUSANDTH                             => 0.001;
Readonly::Scalar my $LABORATORY_VOLUME_SUBTRACTION          => 2;

Readonly::Scalar my $UDF_VOLUME         => qq{Volume};
Readonly::Scalar my $UDF_CONCENTRATION  => qq{Concentration};
Readonly::Scalar my $PRC_VOLUME         => qq{Volume Check (SM)};
Readonly::Scalar my $PRC_CONCENTRATION  => qq{Picogreen Analysis (SM)};
Readonly::Scalar my $CALL_RATE          => qq{WTSI Fluidigm Call Rate (SM)};
Readonly::Scalar my $PRC_CALL_RATE      => qq{Fluidigm 96.96 IFC Analysis (SM)};
Readonly::Scalar my $FLUIDIGM_GENDER    => qq{WTSI Fluidigm Gender (SM)};
Readonly::Scalar my $PRC_FLUIDIGM_GENDER => qq{Fluidigm 96.96 IFC Analysis (SM)};

Readonly::Scalar my $CONCENTRATION_UDF_NAME => q{Sample Conc. (ng\/µL) (SM)};

Readonly::Scalar my $PAGE_SIZE     => 50;

## use critic

has 'produce_report_anyway' => (
  isa      => 'Bool',
  is       => 'ro',
  required => 0,
  default  => 0,
);

has 'report_file' => (
  is => 'ro',
  isa => 'wtsi_clarity::util::textfile',
  required => 0,
  lazy_build => 1,
);

sub _build_report_file {
  my ($self) = @_;
  return wtsi_clarity::util::report->new()->get_file($self->internal_csv_output);
}

has 'internal_csv_output' => (
  is => 'ro',
  isa => 'ArrayRef',
  required => 0,
  lazy_build => 1,
);

has 'qc_report_file_name' => (
  isa      => 'Str',
  is       => 'ro',
  required => 1,
);

override 'run' => sub {
  my $self = shift;
  super();
  $self->_main_method();
  return;
};

sub _main_method {
  my ($self) = @_;

  my $missing_data = $self->_get_first_missing_necessary_data();
  if ($missing_data && !$self->produce_report_anyway) {
    croak qq{Impossible to produce the report: "$missing_data" could not be found on the genealogy of some samples. Have you run all the necessary steps on the samples? };
  }

  $self->report_file->saveas(q{./} . $self->qc_report_file_name);

  $self->request->batch_update('samples', $self->_sample_details);

  return;
}

sub _build_internal_csv_output {
  my ($self) = @_;
  my $report = wtsi_clarity::util::report->new();

  ## no critic(BuiltinFunctions::ProhibitComplexMappings
  my @content = map {
    my $sample_id = $_;
    my %hash = map {
      my $method = $self->get_method_from_header($_);
      $_ => $self->$method($sample_id);
    } @{$report->headers};

    \%hash;
  } @{$self->_sample_ids};
  ## use critic

  return \@content;
}

########################################################
# methods implementing the columns of the report
########################################################

## no critic(Subroutines::ProhibitUnusedPrivateSubroutines)

sub _get_status {
  my ($self, $sample_id) = @_;
  return $self->_extract_from_sample_directly( qq{/smp:details/smp:sample[\@limsid='$sample_id']/udf:field[\@name="WTSI Status"]/text()} );
}

sub _get_study {
  my ($self, $sample_id) = @_;
  return $self->_extract_from_sample_directly( qq{/smp:details/smp:sample[\@limsid='$sample_id']/udf:field[\@name="WTSI Study ID"]/text()} );
}

sub _get_supplier {
  my ($self, $sample_id) = @_;
  return $self->_extract_from_sample_directly( qq{/smp:details/smp:sample[\@limsid='$sample_id']/udf:field[\@name="WTSI Supplier"]/text()} );
}

sub _get_sanger_sample_name {
  my ($self, $sample_id) = @_;
  return $self->_extract_from_sample_directly( qq{/smp:details/smp:sample[\@limsid='$sample_id']/name/text()} );
}

sub _get_supplier_sample_name {
  my ($self, $sample_id) = @_;
  return $self->_extract_from_sample_directly( qq{/smp:details/smp:sample[\@limsid='$sample_id']/udf:field[\@name="WTSI Supplier Sample Name (SM)"]/text()} );
}

sub _get_well {
  my ($self, $sample_id) = @_;
  return $self->_location_of_samples->{$sample_id}->{'well'};
}

sub _get_plate {
  my ($self, $sample_id) = @_;
  return $self->_location_of_samples->{$sample_id}->{'plate'};
}

sub _get_supplier_volume {
  my ($self, $sample_id) = @_;
  return $self->_extract_from_sample_directly( qq{/smp:details/smp:sample[\@limsid='$sample_id']/udf:field[\@name="WTSI Supplier Volume"]/text()} );
}

sub _get_supplier_gender {
  my ($self, $sample_id) = @_;
  return $self->_extract_from_sample_directly( qq{/smp:details/smp:sample[\@limsid='$sample_id']/udf:field[\@name="WTSI Supplier Gender - (SM)"]/text()} );
}

sub _get_concentration {
  my ($self, $sample_id) = @_;
  my $concentration = $self->_get_value_from_data($UDF_CONCENTRATION, $sample_id);

  # We set this on the sample now so it can be used later in Cherrypicking ("Cherrypick Worksheet & Barcode" to be specific)
  $self->_update_sample_concentration($sample_id, $concentration);

  return $concentration;
}

sub _get_measured_volume {
  my ($self, $sample_id) = @_;
  return $self->_get_value_from_data($UDF_VOLUME, $sample_id);
}

sub _get_total_micrograms {
  my ($self, $sample_id) = @_;
  my $total_micrograms = q{};

  my $concentration = $self->_get_concentration($sample_id);
  my $measured_volume = $self->_get_measured_volume($sample_id);

  # Ocasionaly have seen concentration set to something other than a number, hence the check
  if (looks_like_number($concentration) && looks_like_number($measured_volume)) {
    $total_micrograms = $concentration * ($measured_volume - $LABORATORY_VOLUME_SUBTRACTION) * $THOUSANDTH;
  }

  return $total_micrograms;
}

sub _get_fluidigm_count {
  my ($self, $sample_id) = @_;
  return $self->_get_value_from_data($CALL_RATE, $sample_id);
}

sub _get_fluidigm_gender {
  my ($self, $sample_id) = @_;
  return $self->_get_value_from_data($FLUIDIGM_GENDER, $sample_id);
}

sub _get_genotyping_status {
  my ($self, $sample_id) = @_;
  return q{};
}

sub _get_genotyping_chip {
  my ($self, $sample_id) = @_;
  return q{};
}

sub _get_genotyping_infinium_barcode {
  my ($self, $sample_id) = @_;
  return q{};
}

sub _get_genotyping_barcode {
  my ($self, $sample_id) = @_;
  return q{};
}

sub _get_genotyping_well_cohort {
  my ($self, $sample_id) = @_;
  return q{};
}

sub _get_not_implemented_yet {
  my ($self, $sample_id) = @_;
  return qq{*}; #qq{Not implemented yet};
}

## use critic

sub _extract_from_sample_directly {
  my ($self, $xpath) = @_;
  return $self->find_elements_first_value($self->_sample_details, $xpath, qq{});
}

sub _get_value_from_data {
  my ($self, $udf_name, $sample_id) = @_;
  my $data = $self->_all_udf_values->{$sample_id};

  if (!defined $data) {
    return qq{[Sample id not present ($sample_id)]};
  }
  if (!defined $data->{$udf_name} || !$data->{$udf_name}) {
    return q{};
  }
  return $data->{$udf_name};
}

########################################################
# end of methods implementing the columns of the report
########################################################

has '_input_artifacts_ids' => (
  isa => 'ArrayRef',
  is  => 'ro',
  required => 0,
  lazy_build => 1,
);

sub _build__input_artifacts_ids {
  my ($self) = @_;
  return $self->grab_values($self->process_doc, $INPUT_ARTIFACTS_IDS_PATH);
}

has '_input_artifacts_details' => (
  isa => 'XML::LibXML::Document',
  is  => 'ro',
  required => 0,
  lazy_build => 1,
);

sub _build__input_artifacts_details {
  my $self = shift;
  my $base_url = $self->config->clarity_api->{'base_uri'};

  my @uris = map {
    $base_url . '/artifacts/' . $_;
  } @{$self->_input_artifacts_ids};

  return $self->request->batch_retrieve('artifacts', \@uris );
};

has '_sample_ids' => (
  isa => 'ArrayRef',
  is  => 'ro',
  required => 0,
  lazy_build => 1,
);

sub _build__sample_ids {
  my ($self) = @_;
  return $self->grab_values($self->_input_artifacts_details, $ART_DETAIL_SAMPLE_IDS_PATH);
}

has '_sample_details' => (
  isa => 'XML::LibXML::Document',
  is  => 'rw',
  required => 0,
  lazy_build => 1,
);

sub _build__sample_details {
  my $self = shift;
  my $base_url = $self->config->clarity_api->{'base_uri'};

  my @uris = map {
    $base_url . '/samples/' . $_;
  } @{$self->_sample_ids};

  return $self->request->batch_retrieve('samples', \@uris );
};

sub _update_sample_concentration {
  my ($self, $sample_limsid, $concentration) = @_;

  my $sample_list = $self->_sample_details->findnodes(sprintf $SAMPLE_PATH, $sample_limsid);

  if ($sample_list->size() != 1) {
    croak sprintf 'Found %i samples for sample %s', $sample_list->size(), $sample_limsid;
  }

  my $sample_xml = $sample_list->pop();
  my $concentration_udf = $self->create_udf_element($self->_sample_details, $CONCENTRATION_UDF_NAME, $concentration);

  $sample_xml->appendChild($concentration_udf);

  return;
}

has '_required_sources' => (
  isa => 'HashRef',
  is  => 'ro',
  required => 0,
  default => sub {
    return {
      q{concentration} => {
        src_process => $PRC_CONCENTRATION,
        src_udf_name => $UDF_CONCENTRATION,
      },
      q{call_rate} => {
        src_process => $PRC_CALL_RATE,
        src_udf_name => $CALL_RATE,
      },
      q{fluidigm_gender} => {
        src_process => $PRC_FLUIDIGM_GENDER,
        src_udf_name => $FLUIDIGM_GENDER,
      },
      q{cherry_volume} => {
        src_process => $PRC_VOLUME,
        src_udf_name => $UDF_VOLUME,
      },
    };
  },
);

has '_extra_sources' => (
  isa => 'HashRef',
  is  => 'ro',
  required => 0,
  default => sub {
    return {
    };
  },
);

has '_all_udf_values' => (
  isa => 'HashRef',
  is  => 'ro',
  required => 0,
  lazy_build => 1,
);

sub _get_first_missing_necessary_data {
  my ($self) = @_;

  my @c_udfs = map {
    $self->_required_sources->{$_}->{'src_udf_name'};
  } keys %{$self->_required_sources};

  my @missing_data = grep {
    my $udf_name = $_;
    grep {
      !defined $self->_all_udf_values->{$_}->{$udf_name};
    } @{$self->_sample_ids}
  } @c_udfs;

  return $missing_data[0];
}

sub _build__all_udf_values {
  my ($self) = @_;

  my %src_data = (%{$self->_extra_sources}, %{$self->_required_sources});

  while (my ($param_name, $parameter) = each %src_data ) {
    $parameter->{'results'} = $self->_get_udf_values($parameter->{'src_process'}, $parameter->{'src_udf_name'});
  };

  my $data = {};

  while (my ($param_name, $parameter) = each %src_data ) {
    my @sample_ids = sort keys %{$parameter->{'results'}};
    my $name = $parameter->{'src_udf_name'};
    foreach my $sample_id (@sample_ids) {
      $data->{$sample_id}->{$name} = $parameter->{'results'}->{$sample_id}->{$name};
    }
  }

  return $data;
}

# We have to find all artifacts in a recursive manner, because if we searched for all artifacts
# on 4 plates, the URL gets so long Clarity returns a 400
# That's why we chunk it up into 50 artifacts at a time...
sub _search_artifacts {
  my ($self, $step, $udf_name, $sample_ids, @artifact_uris) = @_;

  my @samples_to_find = splice @{$sample_ids}, 0, $PAGE_SIZE;
  my $artifacts_doc = $self->request->query_resources(
    q{artifacts},
    {
      udf         => qq{udf.$udf_name.min=0},
      type        => qq{Analyte},
      step        => $step,
      sample_id   => \@samples_to_find,
      start_index => 0,
    }
  );

  push @artifact_uris, @{$self->grab_values($artifacts_doc, $ARTIFACTS_ARTIFACT_URIS_PATH)};

  if (@{$sample_ids}) {
    return $self->_search_artifacts($step, $udf_name, $sample_ids, @artifact_uris);
  } else {
    return @artifact_uris;
  }
};

sub _get_udf_values {
  my ($self, $step, $udf_name) = @_;

  # We need to make a copy of _sample_ids as _search_artifacts splices away at it
  my @sample_ids = @{$self->_sample_ids};
  my @artifact_uris = $self->_search_artifacts($step, $udf_name, \@sample_ids);

  my $artifacts = $self->request->batch_retrieve('artifacts', \@artifact_uris);

  my @nodes = ();

  try {
    @nodes = $artifacts->findnodes(q{/art:details/art:artifact})->get_nodelist();
  } catch {
    @nodes = ();
  };

  my %res = map {
    $_->findvalue($SAMPLE_LIMS_ID) => {
      $udf_name => $_->findvalue(sprintf $UDF_FIELD_BY_NAME, $udf_name)
    };
  } @nodes;

  return \%res;
}

has '_original_artifact_ids' => (
  isa => 'ArrayRef',
  is  => 'ro',
  required => 0,
  lazy_build => 1,
);

sub _build__original_artifact_ids {
  my $self = shift;
  return $self->grab_values($self->_sample_details, $SMP_DETAIL_ARTIFACTS_IDS_PATH);
}

has '_original_artifact_details' => (
  isa => 'XML::LibXML::Document',
  is  => 'ro',
  required => 0,
  lazy_build => 1,
);

sub _build__original_artifact_details {
  my $self = shift;
  my $base_url = $self->config->clarity_api->{'base_uri'};

  my @uris = map {
    $base_url . '/artifacts/' . $_;
  } @{$self->_original_artifact_ids};

  return $self->request->batch_retrieve('artifacts', \@uris );
};

has '_original_container_ids' => (
  isa => 'ArrayRef',
  is  => 'ro',
  required => 0,
  lazy_build => 1,
);

sub _build__original_container_ids {
  my $self = shift;
  return $self->grab_values($self->_original_artifact_details, $ARTIFACTS_ARTIFACT_CONTAINTER_IDS_PATH);
}

has '_original_container_details' => (
  isa => 'XML::LibXML::Document',
  is  => 'ro',
  required => 0,
  lazy_build => 1,
);

sub _build__original_container_details {
  my $self = shift;
  my $base_url = $self->config->clarity_api->{'base_uri'};

  my @uris = map {
    $base_url . '/containers/' . $_;
  } uniq @{$self->_original_container_ids};

  return $self->request->batch_retrieve('containers', \@uris );
};

has '_original_container_map' => (
  isa => 'HashRef',
  is  => 'ro',
  required => 0,
  lazy_build => 1,
);

sub _build__original_container_map {
  my $self = shift;

  my %hash = map {
    $_ => $self->find_elements_first_value($self->_original_container_details, sprintf($CONTAINER_NAME_BY_ID, $_), qq{})
  } @{$self->_original_container_ids};

  return \%hash;
};

has '_location_of_samples' => (
  isa => 'HashRef',
  is  => 'ro',
  required => 0,
  lazy_build => 1,
);

sub _build__location_of_samples {
  my $self = shift;

  my %hash = map {
    $_ => {
      'plate' => $self
        ->_original_container_map
        ->{$self->find_elements_first_value($self->_original_artifact_details, sprintf($CONTAINER_LIMSID_FROM_SAMPLE, $_), qq{})},
      'well'  => $self->find_elements_first_value($self->_original_artifact_details, sprintf($LOCATION_FROM_SAMPLE, $_), qq{}),
    }
  } @{$self->_sample_ids};

  return \%hash;
}

1;

__END__

=head1 NAME

wtsi_clarity::epp::sm::report_maker

=head1 SYNOPSIS

  wtsi_clarity::epp::sm::report_maker->new(process_url => 'http://my.com/processes/3345')->run();

=head1 DESCRIPTION

  Creates a QC report, and upload it on the server, as an output for the step.
  Activate the stock plate corresponding to the sample that went through the QC process.

=head1 SUBROUTINES/METHODS

=head2 process_url - required attribute

=head2 run - executes the callback

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item Moose

=item Carp

=item Readonly

=item Try::Tiny

=item Scalar::Util

=item List::MoreUtils

=item wtsi_clarity::util::report

=item wtsi_clarity::epp

=item wtsi_clarity::util::clarity_elements

=item wtsi_clarity::util::csv::report_common

=back

=head1 AUTHOR

Author: Marina Gourtovaia E<lt>mg8@sanger.ac.ukE<gt>

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
