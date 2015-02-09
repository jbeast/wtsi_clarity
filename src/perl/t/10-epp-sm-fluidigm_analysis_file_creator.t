use strict;
use warnings;

use Test::More tests => 7;

use_ok('wtsi_clarity::epp::sm::fluidigm_analysis_file_creator');

{
  local $ENV{'WTSICLARITY_WEBCACHE_DIR'} = 't/data/epp/sm/fluidigm_analysis_file_creator';

  my $file_creator = wtsi_clarity::epp::sm::fluidigm_analysis_file_creator->new(
    process_url => 'http://web-claritytest-01.internal.sanger.ac.uk:8080/api/v2/processes/24-26663',
    filename    => '123456789.csv',
  );

  isa_ok($file_creator, 'wtsi_clarity::epp::sm::fluidigm_analysis_file_creator', 'Module is initialized correctly');
  can_ok($file_creator, qw/run process_url filename io_map input_artifacts/);
}

{
  local $ENV{'WTSICLARITY_WEBCACHE_DIR'} = 't/data/epp/sm/fluidigm_analysis_file_creator';

  my $file_creator = wtsi_clarity::epp::sm::fluidigm_analysis_file_creator->new(
    process_url => 'http://web-claritytest-01.internal.sanger.ac.uk:8080/api/v2/processes/24-26663',
    filename    => '123456789.csv',
  );

  is($file_creator->_sample_plate, '27-4301', 'Extracts the input plate limsid');
  is($file_creator->_barcode, '123456789', 'Extracts the input plate barcode');
}

{
  local $ENV{'WTSICLARITY_WEBCACHE_DIR'} = 't/data/epp/sm/fluidigm_analysis_file_creator';

  my $file_creator = wtsi_clarity::epp::sm::fluidigm_analysis_file_creator->new(
    process_url => 'http://web-claritytest-01.internal.sanger.ac.uk:8080/api/v2/processes/24-26663',
    filename    => '123456789.csv',
  );

  my %container_size = (
    'x_dimension' => '6',
    'y_dimension' => '16',
  );

  is_deeply($file_creator->_container_size, \%container_size, 'Finds the container size');
}

{
  local $ENV{'WTSICLARITY_WEBCACHE_DIR'} = 't/data/epp/sm/fluidigm_analysis_file_creator';

  my $file_creator = wtsi_clarity::epp::sm::fluidigm_analysis_file_creator->new(
    process_url => 'http://web-claritytest-01.internal.sanger.ac.uk:8080/api/v2/processes/24-26663',
    filename    => '123456789.csv',
  );

  my $samples = [
          {
            'sample_name' => 'DEA103A624',
            'well_location' => 'A01'
          },
          {
            'sample_name' => 'DEA103A613',
            'well_location' => 'B01'
          },
          {
            'sample_name' => 'DEA103A570',
            'well_location' => 'C01'
          },
          {
            'sample_name' => 'DEA103A582',
            'well_location' => 'D01'
          },
          {
            'sample_name' => 'DEA103A605',
            'well_location' => 'E01'
          },
          {
            'sample_name' => 'DEA103A604',
            'well_location' => 'F01'
          },
          {
            'sample_name' => 'DEA103A538',
            'well_location' => 'G01'
          },
          {
            'sample_name' => 'DEA103A562',
            'well_location' => 'H01'
          },
          {
            'sample_name' => 'DEA103A568',
            'well_location' => 'I01'
          },
          {
            'sample_name' => 'DEA103A612',
            'well_location' => 'J01'
          },
          {
            'sample_name' => 'DEA103A602',
            'well_location' => 'K01'
          },
          {
            'sample_name' => 'DEA103A557',
            'well_location' => 'L01'
          },
          {
            'sample_name' => 'DEA103A608',
            'well_location' => 'M01'
          },
          {
            'sample_name' => 'DEA103A596',
            'well_location' => 'N01'
          },
          {
            'sample_name' => 'DEA103A603',
            'well_location' => 'O01'
          },
          {
            'sample_name' => 'DEA103A586',
            'well_location' => 'P01'
          },
          {
            'sample_name' => 'DEA103A618',
            'well_location' => 'A02'
          },
          {
            'sample_name' => 'DEA103A548',
            'well_location' => 'B02'
          },
          {
            'sample_name' => 'DEA103A597',
            'well_location' => 'C02'
          },
          {
            'sample_name' => 'DEA103A541',
            'well_location' => 'D02'
          },
          {
            'sample_name' => 'DEA103A534',
            'well_location' => 'E02'
          },
          {
            'sample_name' => 'DEA103A573',
            'well_location' => 'F02'
          },
          {
            'sample_name' => 'DEA103A607',
            'well_location' => 'G02'
          },
          {
            'sample_name' => 'DEA103A609',
            'well_location' => 'H02'
          },
          {
            'sample_name' => 'DEA103A537',
            'well_location' => 'I02'
          },
          {
            'sample_name' => 'DEA103A575',
            'well_location' => 'J02'
          },
          {
            'sample_name' => 'DEA103A579',
            'well_location' => 'K02'
          },
          {
            'sample_name' => 'DEA103A543',
            'well_location' => 'L02'
          },
          {
            'sample_name' => 'DEA103A574',
            'well_location' => 'M02'
          },
          {
            'sample_name' => 'DEA103A540',
            'well_location' => 'N02'
          },
          {
            'sample_name' => 'DEA103A561',
            'well_location' => 'O02'
          },
          {
            'sample_name' => 'DEA103A583',
            'well_location' => 'P02'
          },
          {
            'sample_name' => 'DEA103A621',
            'well_location' => 'A03'
          },
          {
            'sample_name' => 'DEA103A542',
            'well_location' => 'B03'
          },
          {
            'sample_name' => 'DEA103A578',
            'well_location' => 'C03'
          },
          {
            'sample_name' => 'DEA103A587',
            'well_location' => 'D03'
          },
          {
            'sample_name' => 'DEA103A550',
            'well_location' => 'E03'
          },
          {
            'sample_name' => 'DEA103A564',
            'well_location' => 'F03'
          },
          {
            'sample_name' => 'DEA103A559',
            'well_location' => 'G03'
          },
          {
            'sample_name' => 'DEA103A569',
            'well_location' => 'H03'
          },
          {
            'sample_name' => 'DEA103A593',
            'well_location' => 'I03'
          },
          {
            'sample_name' => 'DEA103A588',
            'well_location' => 'J03'
          },
          {
            'sample_name' => 'DEA103A536',
            'well_location' => 'K03'
          },
          {
            'sample_name' => 'DEA103A558',
            'well_location' => 'L03'
          },
          {
            'sample_name' => 'DEA103A617',
            'well_location' => 'M03'
          },
          {
            'sample_name' => 'DEA103A546',
            'well_location' => 'N03'
          },
          {
            'sample_name' => 'DEA103A611',
            'well_location' => 'O03'
          },
          {
            'sample_name' => 'DEA103A554',
            'well_location' => 'P03'
          },
          {
            'sample_name' => 'DEA103A616',
            'well_location' => 'A04'
          },
          {
            'sample_name' => 'DEA103A563',
            'well_location' => 'B04'
          },
          {
            'sample_name' => 'DEA103A555',
            'well_location' => 'C04'
          },
          {
            'sample_name' => 'DEA103A584',
            'well_location' => 'D04'
          },
          {
            'sample_name' => 'DEA103A581',
            'well_location' => 'E04'
          },
          {
            'sample_name' => 'DEA103A601',
            'well_location' => 'F04'
          },
          {
            'sample_name' => 'DEA103A576',
            'well_location' => 'G04'
          },
          {
            'sample_name' => 'DEA103A591',
            'well_location' => 'H04'
          },
          {
            'sample_name' => 'DEA103A592',
            'well_location' => 'I04'
          },
          {
            'sample_name' => 'DEA103A600',
            'well_location' => 'J04'
          },
          {
            'sample_name' => 'DEA103A594',
            'well_location' => 'K04'
          },
          {
            'sample_name' => 'DEA103A580',
            'well_location' => 'L04'
          },
          {
            'sample_name' => 'DEA103A551',
            'well_location' => 'M04'
          },
          {
            'sample_name' => 'DEA103A552',
            'well_location' => 'N04'
          },
          {
            'sample_name' => 'DEA103A544',
            'well_location' => 'O04'
          },
          {
            'sample_name' => 'DEA103A553',
            'well_location' => 'P04'
          },
          {
            'sample_name' => 'DEA103A623',
            'well_location' => 'A05'
          },
          {
            'sample_name' => 'DEA103A572',
            'well_location' => 'B05'
          },
          {
            'sample_name' => 'DEA103A595',
            'well_location' => 'C05'
          },
          {
            'sample_name' => 'DEA103A567',
            'well_location' => 'D05'
          },
          {
            'sample_name' => 'DEA103A610',
            'well_location' => 'E05'
          },
          {
            'sample_name' => 'DEA103A614',
            'well_location' => 'F05'
          },
          {
            'sample_name' => 'DEA103A556',
            'well_location' => 'G05'
          },
          {
            'sample_name' => 'DEA103A549',
            'well_location' => 'H05'
          },
          {
            'sample_name' => 'DEA103A571',
            'well_location' => 'I05'
          },
          {
            'sample_name' => 'DEA103A619',
            'well_location' => 'J05'
          },
          {
            'sample_name' => 'DEA103A566',
            'well_location' => 'K05'
          },
          {
            'sample_name' => 'DEA103A533',
            'well_location' => 'L05'
          },
          {
            'sample_name' => 'DEA103A547',
            'well_location' => 'M05'
          },
          {
            'sample_name' => 'DEA103A585',
            'well_location' => 'N05'
          },
          {
            'sample_name' => 'DEA103A620',
            'well_location' => 'O05'
          },
          {
            'sample_name' => 'DEA103A606',
            'well_location' => 'P05'
          },
          {
            'sample_name' => 'DEA103A590',
            'well_location' => 'A06'
          },
          {
            'sample_name' => 'DEA103A577',
            'well_location' => 'B06'
          },
          {
            'sample_name' => 'DEA103A599',
            'well_location' => 'C06'
          },
          {
            'sample_name' => 'DEA103A622',
            'well_location' => 'D06'
          },
          {
            'sample_name' => 'DEA103A539',
            'well_location' => 'E06'
          },
          {
            'sample_name' => 'DEA103A598',
            'well_location' => 'F06'
          },
          {
            'sample_name' => 'DEA103A560',
            'well_location' => 'G06'
          },
          {
            'sample_name' => 'DEA103A589',
            'well_location' => 'H06'
          },
          {
            'sample_name' => 'DEA103A535',
            'well_location' => 'I06'
          },
          {
            'sample_name' => '[ Empty ]',
            'well_location' => 'J06'
          },
          {
            'sample_name' => 'DEA103A565',
            'well_location' => 'K06'
          },
          {
            'sample_name' => '[ Empty ]',
            'well_location' => 'L06'
          },
          {
            'sample_name' => 'DEA103A545',
            'well_location' => 'M06'
          },
          {
            'sample_name' => '[ Empty ]',
            'well_location' => 'N06'
          },
          {
            'sample_name' => 'DEA103A615',
            'well_location' => 'O06'
          },
          {
            'sample_name' => '[ Empty ]',
            'well_location' => 'P06'
          }
        ];

  is_deeply($file_creator->_samples, $samples, 'Creates the samples data correctly');
}

1;