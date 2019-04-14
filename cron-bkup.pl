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
$buffer = "<div class='main-nav'><ul>";
@functions = ('MMX/ACX','JUNOS SW','RPD','T/TX/PTX');
%hash = ();
$cond = "";
$cond = "and release in ('17.4R1')";
$query = " select release from releases where active='no' $cond; ";   #### get the Active releases
    my $sth=$dbh->prepare($query);
    $sth->execute;
     my $r=$sth->fetchall_arrayref({});
	$c= 0;
    foreach my $ar(@{$r})
    {
		$relstr  = $ar->{release};
                $relstr =~ s/\./-/;
				if($c == 0)
				{
					$buffer .= "<li class='repheaderlink current' id='$relstr'><a href='javascript:;'  title='$ar->{release}'><span>$ar->{release}</span></a></li>\n";
				}
				else
				{
					$buffer .= "<li class='repheaderlink' id='$relstr'><a href='javascript:;'  title='$ar->{release}'><span>$ar->{release}</span></a></li>\n";
				}
				$c++;
			
		$release = $ar->{release};
		####### now select the regression reports
		$query1 = "select drnames,plannedrelease,releasename,function from regressionreport where releasename='$release'";
		my $sth1=$dbh->prepare($query1);
		$sth1->execute;
		my $r1=$sth1->fetchall_arrayref({});
		foreach my $ar1(@{$r1})
		{
				### Execute the report creation
				print "./report.pl \'$ar1->{drnames}\' \'$ar1->{plannedrelease}\' \'$ar1->{releasename}\'  \'$ar1->{function}\'\n";
				$data = `./report.pl \'$ar1->{drnames}\' \'$ar1->{plannedrelease}\' \'$ar1->{releasename}\' \'$ar1->{function}\'`;
		                print $data;
                }
	}
$buffer .= "</li></div>";
#### Now open the report file for EABU-MMX-TEST-GOALS 2012
open(F,">testgoals.txt");
print F $buffer;
close(F);

