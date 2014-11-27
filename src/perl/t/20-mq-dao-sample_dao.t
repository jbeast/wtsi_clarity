use strict;
use warnings;

use Test::More tests => 8;
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
  my $sample_json;
  lives_ok { $sample_json = $sample_dao->to_message } 'can serialize sample object';

  # print $sample_json;

  like($sample_json, qr/$lims_id/, 'Lims id serialised correctly');
  lives_ok { wtsi_clarity::mq::dao::sample_dao->thaw($sample_json) }
    'can read json string back';
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
  is($sample_dao->uuid, q{111}, 'Returns the correct uuid of the sample');
}

1;