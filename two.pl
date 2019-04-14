#!/usr/bin/perl
use lib qw(/volume/labtools/lib/);
use SysTest::DB;
use Storable;
use Data::Dumper;
use LWP::Simple;
use HTTP::Request;
use HTML::TableExtract;
set_dsn('pg_regressd');
@allprs = `/usr/local/bin/query-pr 1405625-1  --format '"%s:&:&:%Q:&:&:%80.80s:&:&:%s:&:&:%s:&:&:%s:&:&:%s:&:&:%s:&:&:%s:&:&:%s:&:&:%s:&:&:%s:&:&:%s:&:&:" Number Arrival-Date Synopsis Reported-In Class Category Blocker Planned-Release Problem-Level Dev-Owner Responsible Originator State'`;
print "@allprs\n";
