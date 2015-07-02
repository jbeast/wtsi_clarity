use strict;
use warnings;
use Test::More tests => 29;
use Test::Exception;

local $ENV{'WTSI_CLARITY_HOME'}= q[t/data/config];

use wtsi_clarity::util::config;
my $config = wtsi_clarity::util::config->new();
my $base_uri = $config->clarity_api->{'base_uri'};

local $ENV{'WTSICLARITY_WEBCACHE_DIR'} = 't/data/epp/isc/analyte_pooler';
local $ENV{'SAVE2WTSICLARITY_WEBCACHE'} = 0;

use_ok('wtsi_clarity::epp::isc::pooling::analyte_pooler', 'can use ISC Analyte Pooler');

{
  my $pooler = wtsi_clarity::epp::isc::pooling::analyte_pooler->new(
  process_url => $base_uri . '/processes/122-21977',
  step_url => $base_uri . '/steps/122-21977',
  );

  isa_ok( $pooler, 'wtsi_clarity::epp::isc::pooling::analyte_pooler');
}

{ # Test for getting the input artifacts (analytes)
  my $pooler = wtsi_clarity::epp::isc::pooling::analyte_pooler->new(
  process_url => $base_uri . '/processes/122-21977',
  step_url => $base_uri . '/steps/122-21977',
  );

  lives_ok {$pooler->process_doc->input_artifacts} 'got input artifacts';

  my $input_artifacts = $pooler->process_doc->input_artifacts;
  my @nodes = $input_artifacts->findnodes(q{ /art:details/art:artifact });

  is(scalar @nodes, 2, 'correct number of input_artifacts');
}

{ # Test for getting the input artifacts container(s) (analytes) uris
  my $pooler = wtsi_clarity::epp::isc::pooling::analyte_pooler->new(
  process_url => $base_uri . '/processes/122-21977',
  step_url => $base_uri . '/steps/122-21977',
  );
  
  my @expected_container_uris = [ q{http://web-claritytest-01.internal.sanger.ac.uk:8080/api/v2/containers/27-1890} ];

  my @container_uris = $pooler->_container_uris;

  is(scalar @container_uris, 1, 'correct number of the container(s)');
  is_deeply(@container_uris, @expected_container_uris, 'Got back the correct uri(s) of the containers');
}

{ # Test for getting back the correct container names
  my $pooler = wtsi_clarity::epp::isc::pooling::analyte_pooler->new(
  process_url => $base_uri . '/processes/122-21977',
  step_url => $base_uri . '/steps/122-21977',
  );
  
  my @expected_container_ids = [ q{27-1890} ];

  my @container_ids = $pooler->_container_ids;

  is(scalar @container_ids, 1, 'correct number of container names');
  is_deeply(@container_ids, @expected_container_ids, 'Got back the correct container names');
}

{ # Test for getting back the correct mapping
  my $pooler = wtsi_clarity::epp::isc::pooling::analyte_pooler->new(
  process_url => $base_uri . '/processes/122-21977',
  step_url => $base_uri . '/steps/122-21977',
  );
  
  my $expected_mapping = { 
    '27-1890' => {
      'A:1' => 'A:1',
      'B:1' => 'A:1',
      'C:1' => 'A:1',
      'D:1' => 'A:1',
      'E:1' => 'A:1',
      'F:1' => 'A:1',
      'G:1' => 'A:1',
      'H:1' => 'A:1',
      'A:2' => 'A:1',
      'B:2' => 'A:1',
      'C:2' => 'A:1',
      'D:2' => 'A:1',
      'E:2' => 'A:1',
      'F:2' => 'A:1',
      'G:2' => 'A:1',
      'H:2' => 'A:1',
      'A:3' => 'B:1',
      'B:3' => 'B:1',
      'C:3' => 'B:1',
      'D:3' => 'B:1',
      'E:3' => 'B:1',
      'F:3' => 'B:1',
      'G:3' => 'B:1',
      'H:3' => 'B:1',
      'A:4' => 'B:1',
      'B:4' => 'B:1',
      'C:4' => 'B:1',
      'D:4' => 'B:1',
      'E:4' => 'B:1',
      'F:4' => 'B:1',
      'G:4' => 'B:1',
      'H:4' => 'B:1',
      'A:5' => 'C:1',
      'B:5' => 'C:1',
      'C:5' => 'C:1',
      'D:5' => 'C:1',
      'E:5' => 'C:1',
      'F:5' => 'C:1',
      'G:5' => 'C:1',
      'H:5' => 'C:1',
      'A:6' => 'C:1',
      'B:6' => 'C:1',
      'C:6' => 'C:1',
      'D:6' => 'C:1',
      'E:6' => 'C:1',
      'F:6' => 'C:1',
      'G:6' => 'C:1',
      'H:6' => 'C:1',
      'A:7' => 'D:1',
      'B:7' => 'D:1',
      'C:7' => 'D:1',
      'D:7' => 'D:1',
      'E:7' => 'D:1',
      'F:7' => 'D:1',
      'G:7' => 'D:1',
      'H:7' => 'D:1',
      'A:8' => 'D:1',
      'B:8' => 'D:1',
      'C:8' => 'D:1',
      'D:8' => 'D:1',
      'E:8' => 'D:1',
      'F:8' => 'D:1',
      'G:8' => 'D:1',
      'H:8' => 'D:1',
      'A:9' => 'E:1',
      'B:9' => 'E:1',
      'C:9' => 'E:1',
      'D:9' => 'E:1',
      'E:9' => 'E:1',
      'F:9' => 'E:1',
      'G:9' => 'E:1',
      'H:9' => 'E:1',
      'A:10' => 'E:1',
      'B:10' => 'E:1',
      'C:10' => 'E:1',
      'D:10' => 'E:1',
      'E:10' => 'E:1',
      'F:10' => 'E:1',
      'G:10' => 'E:1',
      'H:10' => 'E:1',
      'A:11' => 'F:1',
      'B:11' => 'F:1',
      'C:11' => 'F:1',
      'D:11' => 'F:1',
      'E:11' => 'F:1',
      'F:11' => 'F:1',
      'G:11' => 'F:1',
      'H:11' => 'F:1',
      'A:12' => 'F:1',
      'B:12' => 'F:1',
      'C:12' => 'F:1',
      'D:12' => 'F:1',
      'E:12' => 'F:1',
      'F:12' => 'F:1',
      'G:12' => 'F:1',
      'H:12' => 'F:1',
    }
  };
  my $mapping = $pooler->_mapping;

  is(scalar keys %{$mapping}, 1, 'correct number of container elements');

  while (my ($container_limsid, $mapping_elements) = each %{$mapping}) {
    is(scalar keys %{$mapping_elements}, 96, 'correct number of mapping elements');
  }
  is_deeply($mapping, $expected_mapping, 'Got back the correct mapping');
}

{ # Tests for getting the well location of the input artifacts
  my $pooler = wtsi_clarity::epp::isc::pooling::analyte_pooler->new(
  process_url => $base_uri . '/processes/122-21977',
  step_url => $base_uri . '/steps/122-21977',
  );
  
  my $expected_input_artifacts_location =
    {
      "27-1890" => {
        "A:1" => "http://web-claritytest-01.internal.sanger.ac.uk:8080/api/v2/artifacts/2-55027?state=25327",
        "A:3" => "http://web-claritytest-01.internal.sanger.ac.uk:8080/api/v2/artifacts/2-55028?state=25328",
      }
    };

  my $input_artifacts_location = $pooler->_input_artifacts_location;

  my @expected_containers_keys = ('27-1890');

  my @containers_keys = keys %{$input_artifacts_location};
  my $container_size = @containers_keys;
  is_deeply(@containers_keys, @expected_containers_keys, 'Returns the correct container limsid');
  is(1, $container_size, 'Correct number of input artifacts');
  is_deeply($input_artifacts_location, $expected_input_artifacts_location, 'Got back the correct hash of artifact locations');
}

{ # tests getting the pool name by destination well with 8 plex
  use wtsi_clarity::epp::isc::pooling::pooling_by_8_plex;

  my $pooler = wtsi_clarity::epp::isc::pooling::analyte_pooler->new(
  process_url => $base_uri . '/processes/122-21977',
  step_url => $base_uri . '/steps/122-21977',
  );

  my $expected_a1_well_pool_name_by_8_plex = 'A1:H1 (A:1)';
  my $expected_d1_well_pool_name_by_8_plex = 'A4:H4 (D:1)';

  my $plexing_by_8 = wtsi_clarity::epp::isc::pooling::pooling_by_8_plex->new();

  is($pooler->get_pool_name_by_plexing('A:1', $plexing_by_8), $expected_a1_well_pool_name_by_8_plex, 'Returns the expected pool name with 8 plex.');
  is($pooler->get_pool_name_by_plexing('D:1', $plexing_by_8), $expected_d1_well_pool_name_by_8_plex, 'Returns the expected pool name with 8 plex.');
}

{ # tests getting the pool name by destination well with 16 plex
  use wtsi_clarity::epp::isc::pooling::pooling_by_16_plex;

  my $pooler = wtsi_clarity::epp::isc::pooling::analyte_pooler->new(
    process_url => $base_uri . '/processes/122-21977',
    step_url    => $base_uri . '/steps/122-21977',
    _bait_info  => '16'
  );

  my $expected_a1_well_pool_name_by_16_plex = 'A1:H2 (A:1)';
  my $expected_d1_well_pool_name_by_16_plex = 'A7:H8 (D:1)';
  my $plexing_by_16 = wtsi_clarity::epp::isc::pooling::pooling_by_16_plex->new();

  is($pooler->get_pool_name_by_plexing('A:1', $plexing_by_16), $expected_a1_well_pool_name_by_16_plex, 'Returns the expected pool name with 16 plex.');
  is($pooler->get_pool_name_by_plexing('D:1', $plexing_by_16), $expected_d1_well_pool_name_by_16_plex, 'Returns the expected pool name with 16 plex.');
}

{ # Test for getting back the expected pool hash
  my $pooler = wtsi_clarity::epp::isc::pooling::analyte_pooler->new(
  process_url => $base_uri . '/processes/122-21977',
  step_url => $base_uri . '/steps/122-21977',
  );
  
 my $expected_pools_hash =
    {
      '1234567890123 A3:H4 (B:1)' => [
                 'http://web-claritytest-01.internal.sanger.ac.uk:8080/api/v2/artifacts/2-55028?state=25328'
               ],
      '1234567890123 A1:H2 (A:1)' => [
                 'http://web-claritytest-01.internal.sanger.ac.uk:8080/api/v2/artifacts/2-55027?state=25327'
               ]
    };
  my $actual_pool_hash = $pooler->_pools;

  my @expected_keys = keys %{$actual_pool_hash};
  my $expected_size = @expected_keys;
  is($expected_size, 2, 'Correct number of pools');
  is_deeply($actual_pool_hash, $expected_pools_hash, 'Got the correct pools');
}

{ # Tests for creating the pooled inputs
  my $pooler = wtsi_clarity::epp::isc::pooling::analyte_pooler->new(
  process_url => $base_uri . '/processes/122-21977',
  step_url => $base_uri . '/steps/122-21977',
  );
  
  lives_ok {$pooler->_pools_doc} "get a correct response for GET request for the step's pools";
  isa_ok($pooler->_create_pools, 'XML::LibXML::Document');
}

{ # Tests for updating the current step with the created pools
  my $pooler = wtsi_clarity::epp::isc::pooling::analyte_pooler->new(
    process_url => $base_uri . '/processes/122-37660',
    step_url => $base_uri . '/steps/122-37660',
  );
  lives_ok {$pooler->update_step_with_pools} "Get a correct response for updating for the step's pools";
}

{ # Test for getting the samples details
  my $pooler = wtsi_clarity::epp::isc::pooling::analyte_pooler->new(
    process_url => $base_uri . '/processes/122-30490',
    step_url => $base_uri . '/steps/122-30490',
  );

  lives_and ( sub {is ref($pooler->_samples), 'XML::LibXML::Document'}, "Got a correct response with sample details");
}

{ # Test for getting the bait information from the samples
  my $pooler = wtsi_clarity::epp::isc::pooling::analyte_pooler->new(
    process_url => $base_uri . '/processes/122-30490',
    step_url => $base_uri . '/steps/122-30490',
  );

  my $expected_bait_library = "14M_haemv1";

  is($pooler->_bait_library, $expected_bait_library, "Got the expected bait library name.");
}

{ # Test for getting the bait information from the samples, when no bait info at all
  my $pooler = wtsi_clarity::epp::isc::pooling::analyte_pooler->new(
    process_url => $base_uri . '/processes/122-29034',
    step_url => $base_uri . '/steps/122-29034',
  );

  throws_ok { $pooler->_bait_library}
    qr/The samples does not contains Bait Library Name information./,
    'Got error when the BAIT Library information is missing from the samples.';
}

{ # Test for getting the bait information from the samples, when no bait info at all
  my $pooler = wtsi_clarity::epp::isc::pooling::analyte_pooler->new(
    process_url => $base_uri . '/processes/122-29034_without_baits',
    step_url => $base_uri . '/steps/122-29034_without_baits',
  );

  throws_ok { $pooler->_bait_library}
    qr/One or some of the samples does not contains Bait Library Name information./,
    'Got error when the BAIT Library information is missing from one of the samples.';
}

{ # Tests if the bait info is registered in the config file
  my $pooler = wtsi_clarity::epp::isc::pooling::analyte_pooler->new(
    process_url => $base_uri . '/processes/122-30490',
    step_url => $base_uri . '/steps/122-30490',
  );

  my $expedted_plexing_mode = '16_plex';

  is($pooler->_plexing_mode_by_bait_library('14M_haemv1'), $expedted_plexing_mode, 'Got back the expected plexing mode for valid bait library');
  throws_ok { $pooler->_plexing_mode_by_bait_library('not valid bait library')}
    qr/This Bait Library is not registered\: not valid bait library./,
    'Got error when the Bait Library is not registered in the config file.';
}

1;
