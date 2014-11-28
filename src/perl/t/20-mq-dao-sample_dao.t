use strict;
use warnings;

use Test::More tests => 19;
use Test::Exception;

use_ok('wtsi_clarity::mq::dao::sample_dao');

local $ENV{'WTSI_CLARITY_HOME'}= q[t/data/config];

use wtsi_clarity::util::config;
my $config = wtsi_clarity::util::config->new();
my $base_uri = $config->clarity_api->{'base_uri'};

local $ENV{'WTSICLARITY_WEBCACHE_DIR'} = 't/data/mq/dao/sample_dao';
local $ENV{'SAVE2WTSICLARITY_WEBCACHE'} = 0;

{
  my $lims_id = '1234';
  my $sample_dao = wtsi_clarity::mq::dao::sample_dao->new( lims_id => $lims_id);
  isa_ok($sample_dao, 'wtsi_clarity::mq::dao::sample_dao');
}

{
  my $lims_id = 'SYY154A1';
  my $sample_dao = wtsi_clarity::mq::dao::sample_dao->new( lims_id => $lims_id);

  my $artifact_xml;
  lives_ok { $artifact_xml = $sample_dao->_artifact_xml} 'got sample artifacts';
  is(ref $artifact_xml, 'XML::LibXML::Document', 'Got back an XML Document');
}

{
  my $lims_id = 'SYY154A1';
  my $sample_dao = wtsi_clarity::mq::dao::sample_dao->new( lims_id => $lims_id);
  is($sample_dao->_uuid, q{111}, 'Returns the correct uuid of the sample');
  is($sample_dao->_id, q{SYY154A1}, 'Returns the correct id of the sample');
  is($sample_dao->_name, q{111}, 'Returns the correct name of the sample');
  is($sample_dao->_reference_genome, q{Test Reference Genome}, 'Returns the correct reference genome of the sample');
  is($sample_dao->_organism, q{Homo Sapiens}, 'Returns the correct organism of the sample');
  is($sample_dao->_common_name, q{Test Supplier Sample Name}, 'Returns the correct common name of the sample');
  is($sample_dao->_taxon_id, q{9606}, 'Returns the correct taxon id of the sample');
  is($sample_dao->_gender, q{Female}, 'Returns the correct gender of the sample');
  is($sample_dao->_control, q{false}, 'Returns the correct control of the sample');
  is($sample_dao->_supplier_name, q{me}, 'Returns the correct supplier name of the sample');
  is($sample_dao->_public_name, q{Test Supplier Sample Name}, 'Returns the correct public name of the sample');
  is($sample_dao->_donor_id, q{1}, 'Returns the correct donor id of the sample');
}

{
  my $lims_id = 'SYY154A1';
  my $sample_dao = wtsi_clarity::mq::dao::sample_dao->new( lims_id => $lims_id);
  my $sample_json;
  lives_ok { $sample_json = $sample_dao->to_message } 'can serialize sample object';

  like($sample_json, qr/$lims_id/, 'Lims id serialised correctly');
  lives_ok { wtsi_clarity::mq::dao::sample_dao->thaw($sample_json) }
    'can read json string back';
}

1;