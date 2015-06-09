use strict;
use warnings;
use Test::More tests => 17;
use Test::Exception;
use Test::Deep;
use Test::MockObject::Extends;

use wtsi_clarity::util::config;

local $ENV{'WTSI_CLARITY_HOME'}= q[t/data/config];

my $config = wtsi_clarity::util::config->new();
my $base_uri = $config->clarity_api->{'base_uri'};

use_ok('wtsi_clarity::epp::sm::report_maker');

local $ENV{'WTSICLARITY_WEBCACHE_DIR'} = 't/data/epp/sm/report_maker';
local $ENV{'SAVE2WTSICLARITY_WEBCACHE'} = 0;

{ # _get_artifact_uris_from_udf
  my $m = wtsi_clarity::epp::sm::report_maker->new(
    process_url => $base_uri . '/processes/24-25342',
    produce_report_anyway => 1,
    qc_report_file_name => '24-25342'
  );

  my @sample_ids = @{$m->_sample_ids};
  my @uris = $m->_search_artifacts('Volume Check (SM)', qq{Volume}, \@sample_ids);

  my $expected = [
    'http://testserver.com:1234/here/artifacts/2-112536',
    'http://testserver.com:1234/here/artifacts/2-112537',
    'http://testserver.com:1234/here/artifacts/2-112538',
    'http://testserver.com:1234/here/artifacts/2-112539',
    'http://testserver.com:1234/here/artifacts/2-112540',
    'http://testserver.com:1234/here/artifacts/2-112541'
  ];

  cmp_bag(\@uris, $expected, qq{_search_artifacts should return the correct ids.} );
}

{ # _get_udf_values
  my $m = Test::MockObject::Extends->new( wtsi_clarity::epp::sm::report_maker->new(
    process_url => $base_uri . '/processes/24-25342',
    produce_report_anyway => 1,
    qc_report_file_name => '24-25342'
  ) );
  $m->mock(q(_required_sources), sub{
      return {
        q{concentration} => {
          src_process => q{Picogreen Analysis (SM)},
          src_udf_name=> q{Concentration},
        },
        q{cherry_volume} => {
          src_process => q{Volume Check (SM)},
          src_udf_name=> qq{Volume},
        },
      };
    });

  my $res = $m->_get_udf_values('Volume Check (SM)', qq{Volume});
  my $expected = {
    'DEA103A1325' => {
      qq{Volume} => '27.6199',
    },
    'DEA103A1326' => {
      qq{Volume} => '30.4086',
    },
    'DEA103A1327' => {
      qq{Volume} => '54.235',
    },
    'DEA103A1328' => {
      qq{Volume} => '12.2143',
    },
    'DEA103A1329' => {
      qq{Volume} => '30.2489',
    },
    'DEA103A1330' => {
      qq{Volume} => '10.3196',
    }
  };
  is_deeply($res, $expected, qq{_get_udf_values should return the correct values.} );
}

{ # _get_udf_values
  my $m = wtsi_clarity::epp::sm::report_maker->new(
    process_url => $base_uri . '/processes/24-25342',
    produce_report_anyway => 1,
    qc_report_file_name => '24-25342'
  );

  my $res = $m->_get_udf_values('Picogreen Analysis (SM)', qq{Concentration});
  my $expected = {
    'DEA103A1325' => {
      qq{Concentration} => '1172.52872328884',
    },
    'DEA103A1326' => {
      qq{Concentration} => '390.574496576721',
    },
    'DEA103A1327' => {
      qq{Concentration} => '8.37181754305463',
    },
    'DEA103A1328' => {
      qq{Concentration} => '112.868147805859',
    },
    'DEA103A1329' => {
      qq{Concentration} => '38.49532042298',
    },
    'DEA103A1330' => {
      qq{Concentration} => '113.658712767363',
    }
  };
  is_deeply($res, $expected, qq{_get_udf_values should return the correct values.} );
}

{ # _build__all_udf_values
  my $m = Test::MockObject::Extends->new( wtsi_clarity::epp::sm::report_maker->new(
    process_url => $base_uri . '/processes/24-25342',
    produce_report_anyway => 1,
    qc_report_file_name => '24-25342'
  ) );
  $m->mock(q(_required_sources), sub{
      return {
        q{concentration} => {
          src_process => q{Picogreen Analysis (SM)},
          src_udf_name=> q{Concentration},
        },
        q{cherry_volume} => {
          src_process => q{Volume Check (SM)},
          src_udf_name=> q{Volume},
        },
      };
    });

  my $res = $m->_build__all_udf_values();
  my $expected = {
    'DEA103A1325' => {
      q{Concentration} => '1172.52872328884',
      qq{Volume} => '27.6199',
    },
    'DEA103A1326' => {
      q{Concentration} => '390.574496576721',
      qq{Volume} => '30.4086',
    },
    'DEA103A1327' => {
      q{Concentration} => '8.37181754305463',
      qq{Volume} => '54.235',
    },
    'DEA103A1328' => {
      q{Concentration} => '112.868147805859',
      qq{Volume} => '12.2143',
    },
    'DEA103A1329' => {
      q{Concentration} => '38.49532042298',
      qq{Volume} => '30.2489',
    },
    'DEA103A1330' => {
      q{Concentration} => '113.658712767363',
      qq{Volume} => '10.3196',
    }
  };
  is_deeply($res, $expected, qq{_build__all_udf_values should return the correct ids.} );
}

{ # _get_method_name_from_header
  my $testdata = {
    'Status'        => '_get_status',
    'word1 word2'   => '_get_word1_word2',
    ' Word3 word4 ' => '_get_word3_word4',
    };
  while (my ($test, $expected) = each %{$testdata} ) {
    my $res = wtsi_clarity::util::csv::report_common::_get_method_name_from_header($test);

    cmp_ok($res, 'eq', $expected, qq{_get_method_name_from_header should return the correct name.} );
  }
}

{ # get_method_from_header  (batch_199de3d8a642c1d94e8556286a50e52f)
  my $testdata = {
    'Status' => '_get_status',
    'hello' => '_get_not_implemented_yet',
    };
  my $m = wtsi_clarity::epp::sm::report_maker->new(
    process_url => $base_uri . '/processes/24-25342',
    produce_report_anyway => 1,
    qc_report_file_name => '24-25342'
  );
  while (my ($test, $expected) = each %{$testdata} ) {
    my $res = $m->get_method_from_header($test);

    is_deeply($res, $expected, qq{get_method_from_header should return the correct name.} );
  }
}

{ # _get_first_missing_necessary_data
  my $m = Test::MockObject::Extends->new( wtsi_clarity::epp::sm::report_maker->new(
    process_url => $base_uri . '/processes/24-25342',
    produce_report_anyway => 1,
    qc_report_file_name => '24-25342'
  ) );
  $m->mock(q(_required_sources), sub{
      return {
        q{concentration} => {
          src_process => q{Picogreen Analysis (SM)},
          src_udf_name=> q{Concentration},
        },
        q{cherry_volume} => {
          src_process => q{Volume Check (SM)},
          src_udf_name=> q{Volume},
        },
      };
    });

  is($m->_get_first_missing_necessary_data(), undef,  '_get_first_missing_necessary_data should return nothing when all the data are provided.');
}

{ # _get_first_missing_necessary_data
  my $m = Test::MockObject::Extends->new( wtsi_clarity::epp::sm::report_maker->new(
    process_url => $base_uri . '/processes/24-25342',
    produce_report_anyway => 1,
    qc_report_file_name => '24-25342'
  ) );
  $m->mock(q(_required_sources), sub{
      return {
        q{concentration} => {
          src_process => q{Picogreen Analysis (SM)},
          src_udf_name=> q{Concentration},
        },
        q{cherry_volume} => {
          src_process => q{Volume Check (SM)},
          src_udf_name=> q{Volume},
        },
        q{impossible_value} => {
          src_process => q{ProcessImpossible},
          src_udf_name=> q{Impossible Value},
        },
      };
    });

  cmp_ok($m->_get_first_missing_necessary_data(), 'eq', q{Impossible Value},  '_get_first_missing_necessary_data should return the correct value when not all the data are provided.');
}

{ # _build__all_udf_values
  my $m = Test::MockObject::Extends->new( wtsi_clarity::epp::sm::report_maker->new(
    process_url => $base_uri . '/processes/24-25342',
    qc_report_file_name => '24-25342'
  ) );
  $m->mock(q(_required_sources), sub{
      return {
        q{concentration} => {
          src_process => q{Picogreen Analysis (SM)},
          src_udf_name=> q{Concentration},
        },
        q{cherry_volume} => {
          src_process => q{Volume Check (SM)},
          src_udf_name=> qq{Volume},
        },
        q{impossible_value} => {
          src_process => q{ProcessImpossible},
          src_udf_name=> q{Impossible Value},
        },
      };
    });
  throws_ok
   { $m->_main_method() }
   qr{Impossible to produce the report: "Impossible Value" could not be found on the genealogy of some samples. Have you run all the necessary steps on the samples?},
   q{_main_method should croak if not all the data are present.} ;
}

{
  my $m = wtsi_clarity::epp::sm::report_maker->new(
    process_url => $base_uri . '/processes/24-26114',
    produce_report_anyway => 1,
    qc_report_file_name => '24-26114'
  );
  # print Dumper $m->_get_value_from_data(qq{WTSI Fluidigm Call Rate (SM)}, 'DEA103A2087');
  my $expected_volume = '16.1914';
  is($m->_get_value_from_data(qq{Volume}, 'DEA103A2127'), $expected_volume, qq{_get_value_from_data should return the correct values.});
}

{
  my $m = wtsi_clarity::epp::sm::report_maker->new(
    process_url => $base_uri . '/processes/24-26114',
    produce_report_anyway => 1,
    qc_report_file_name => '24-26114'
  );
  my $expected_call_rate = '';
  is($m->_get_value_from_data(qq{WTSI Fluidigm Call Rate (SM)}, 'DEA103A2127'), $expected_call_rate, qq{_get_value_from_data should return empty string for a missing value.});
}

{ # _build_internal_csv_output
  my $m = Test::MockObject::Extends->new( wtsi_clarity::epp::sm::report_maker->new(
    process_url => $base_uri . '/processes/24-25342',
    produce_report_anyway => 1,
    qc_report_file_name => '24-25342'
  ) );
  $m->mock(q(_required_sources), sub{
      return {
        q{concentration} => {
          src_process => q{Picogreen Analysis (SM)},
          src_udf_name=> q{Concentration},
        },
        q{cherry_volume} => {
          src_process => q{Volume Check (SM)},
          src_udf_name=> q{Volume},
        },
      };
    });

  my @expected = [
          {
            'Supplier Volume' => '',
            'Well' => 'C:5',
            'Status' => '',
            'Genotyping Status' => '',
            'Supplier Gender' => 'Male',
            'Total micrograms' => '30.0400686377878',
            'Genotyping Barcode' => '',
            'Sanger Sample Name' => '35',
            'Genotyping Chip' => '',
            'Genotyping Well Cohort' => '',
            'Fluidigm Count' => '',
            'Plate' => '',
            'Supplier Sample Name' => '',
            'Genotyping Infinium Barcode' => '',
            'Concentration' => '1172.52872328884',
            'Supplier' => '',
            'Measured Volume' => '27.6199',
            'Fluidigm Gender' => '',
            'Study' => '',
            'Proceed' => '*'
          },
          {
            'Supplier Volume' => '',
            'Well' => 'D:5',
            'Status' => '',
            'Genotyping Status' => '',
            'Supplier Gender' => 'Female',
            'Total micrograms' => '11.0956746434494',
            'Genotyping Barcode' => '',
            'Sanger Sample Name' => '36',
            'Genotyping Chip' => '',
            'Genotyping Well Cohort' => '',
            'Fluidigm Count' => '',
            'Plate' => '',
            'Supplier Sample Name' => '',
            'Genotyping Infinium Barcode' => '',
            'Concentration' => '390.574496576721',
            'Supplier' => '',
            'Measured Volume' => '30.4086',
            'Fluidigm Gender' => '',
            'Study' => '',
            'Proceed' => '*'
          },
          {
            'Supplier Volume' => '',
            'Well' => 'E:5',
            'Status' => '',
            'Genotyping Status' => '',
            'Supplier Gender' => 'Male',
            'Total micrograms' => '0.437301889361459',
            'Genotyping Barcode' => '',
            'Sanger Sample Name' => '37',
            'Genotyping Chip' => '',
            'Genotyping Well Cohort' => '',
            'Fluidigm Count' => '',
            'Plate' => '',
            'Supplier Sample Name' => '',
            'Genotyping Infinium Barcode' => '',
            'Concentration' => '8.37181754305463',
            'Supplier' => '',
            'Measured Volume' => '54.235',
            'Fluidigm Gender' => '',
            'Study' => '',
            'Proceed' => '*'
          },
          {
            'Supplier Volume' => '',
            'Well' => 'F:5',
            'Status' => '',
            'Genotyping Status' => '',
            'Supplier Gender' => 'Female',
            'Total micrograms' => '1.15286912213339',
            'Genotyping Barcode' => '',
            'Sanger Sample Name' => '38',
            'Genotyping Chip' => '',
            'Genotyping Well Cohort' => '',
            'Fluidigm Count' => '',
            'Plate' => '',
            'Supplier Sample Name' => '',
            'Genotyping Infinium Barcode' => '',
            'Concentration' => '112.868147805859',
            'Supplier' => '',
            'Measured Volume' => '12.2143',
            'Fluidigm Gender' => '',
            'Study' => '',
            'Proceed' => '*'
          },
          {
            'Supplier Volume' => '',
            'Well' => 'G:5',
            'Status' => '',
            'Genotyping Status' => '',
            'Supplier Gender' => 'Male',
            'Total micrograms' => '1.08745045709672',
            'Genotyping Barcode' => '',
            'Sanger Sample Name' => '39',
            'Genotyping Chip' => '',
            'Genotyping Well Cohort' => '',
            'Fluidigm Count' => '',
            'Plate' => '',
            'Supplier Sample Name' => '',
            'Genotyping Infinium Barcode' => '',
            'Concentration' => '38.49532042298',
            'Supplier' => '',
            'Measured Volume' => '30.2489',
            'Fluidigm Gender' => '',
            'Study' => '',
            'Proceed' => '*'
          },
          {
            'Supplier Volume' => '',
            'Well' => 'H:5',
            'Status' => '',
            'Genotyping Status' => '',
            'Supplier Gender' => 'Female',
            'Total micrograms' => '0.945595026739353',
            'Genotyping Barcode' => '',
            'Sanger Sample Name' => '40',
            'Genotyping Chip' => '',
            'Genotyping Well Cohort' => '',
            'Fluidigm Count' => '',
            'Plate' => '',
            'Supplier Sample Name' => '',
            'Genotyping Infinium Barcode' => '',
            'Concentration' => '113.658712767363',
            'Supplier' => '',
            'Measured Volume' => '10.3196',
            'Fluidigm Gender' => '',
            'Study' => '',
            'Proceed' => '*'
          }
        ];

  my $res = $m->_build_internal_csv_output();

  is_deeply($res, @expected, qq{_build_internal_csv_output should return the correct values.} );
}

# Update sample concentrations by limsid
{
  my $sample_file_path = $ENV{'WTSICLARITY_WEBCACHE_DIR'} . '/POST/samples.batch_45da142638aed19c403dcd3c650c3edc';
  my $sample_details   = XML::LibXML->load_xml( location => $sample_file_path );

  my $m = wtsi_clarity::epp::sm::report_maker->new(
    process_url         => $base_uri . '/processes/24-25342',
    qc_report_file_name => '24-25342',
    _sample_details     => $sample_details,
  );

  $m->_update_sample_concentration('DEA103A1325', 20);

  my $sample_concentration = $m->_sample_details->findvalue('/smp:details/smp:sample[@limsid="DEA103A1325"]/udf:field[@name="Sample Conc. (ng\/µL) (SM)"]');

  is($sample_concentration, 20, 'Updates a sample concentration within a sample batch');
}

1;
