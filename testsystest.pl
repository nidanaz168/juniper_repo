#!/usr/bin/perl
use lib qw(/volume/labtools/lib/);
use SysTest::DB;
use Storable;
use Data::Dumper;
use LWP::Simple;
use HTTP::Request;
use HTML::TableExtract;
use Date::Calc;
set_dsn('pg_regressd');

my $eid_query= "select regression_id, name from regression where regression_id in(9305)";
print $eid_query."\n";

@res = db_get_all_rows($eid_query);
foreach $r(@res){

}
