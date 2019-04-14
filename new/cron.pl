#!/usr/bin/perl

use lib qw(/volume/labtools/lib/);
use SysTest::DB;
use Storable;
use Data::Dumper;
set_dsn('pg_regressd');
my $dlmt = ":&:";
my $hostname = 'eabu-systest-db.juniper.net';
my $user = "postgres";
my $pass = "postgres";
my $port = "5432";
my $dsn = "dbi:Pg:database=regression;host=$hostname;port=$port";
my $dbh = DBI->connect($dsn,$user,$pass)
                or die "Couldn't connect to database ".DBI->errstr;


##### now Create table and graphs for the report
#### Create table first #######################
### Read the data from the database
@functions = ('MMX/ACX','JUNOS SW','RPD','T/TX/PTX');
%hash = ();
	$query = " select release from releases where active='yes'";   #### get the Active releases
    my $sth=$dbh->prepare($query);
    $sth->execute;
     my $r=$sth->fetchall_arrayref({});
	$c= 0;
    foreach my $ar(@{$r})
    {
		$release = $ar->{release};
		####### now select the regression reports
		$query1 = "select drnames,plannedrelease,releasename,function from regressionreport where releasename='$release'";
		my $sth1=$dbh->prepare($query1);
		$sth1->execute;
		my $r1=$sth1->fetchall_arrayref({});
		foreach my $ar1(@{$r1})
		{
				### Execute the report creation
				print "./heatmap.pl $ar1->{releasename} \'$ar1->{function}\' $ar1->{drnames} \n";
				`./heatmap.pl $ar1->{releasename} \'$ar1->{function}\' $ar1->{drnames}`;
				#`./heatmap.pl $ar1->{releasename} \'$ar1->{function}\' $ar1->{drnames}`;
				#`./testbeddata.pl $ar1->{releasename} \'$ar1->{function}\' $ar1->{drnames}`;
		}
	}

