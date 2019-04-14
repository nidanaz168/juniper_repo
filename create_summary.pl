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
$hash = ();
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
		$query1 = "select function,scriptplanned,scriptexecuted,firstrunpassrate,overallpassrate,allprs,blockerprs,function from regressionreport where releasename='$release'";
		my $sth1=$dbh->prepare($query1);
		$sth1->execute;
		my $r1=$sth1->fetchall_arrayref({});
		foreach my $ar1(@{$r1})
		{
				### Execute the report creation
				$hash{$release}{$ar1->{function}}{scriptplanned} = $ar1->{scriptplanned};
				$hash{$release}{$ar1->{function}}{scriptexecuted} = $ar1->{scriptexecuted};
				$hash{$release}{$ar1->{function}}{firstrunpassrate} = $ar1->{firstrunpassrate};
				$hash{$release}{$ar1->{function}}{overallpassrate} = $ar1->{overallpassrate};
				$hash{$release}{$ar1->{function}}{allprs} = $ar1->{allprs};
				$hash{$release}{$ar1->{function}}{blockerprs} = $ar1->{blockerprs};
	
		}
	}
$header="<tr><th>Function</th><th>Script Planned</th><th>Script Executed</th><th>First Run Pass</th><th>Overall Pass</th><th>All Prs</th><th>Blocker PRs</th></tr></thead>";
$masterbuff ="";
foreach $rel(sort keys %hash)
{
	#$buffer = "<div class=\"panel\" title=\"Panel 2\"><div class=\"wrapper\"><table><thead><tr><th colspan=7>$rel</th></tr>";
	$buffer = "<li><table class='table-bordered table-small' border=1 style='width:100%;'><thead><tr><th colspan=7>$rel</th></tr>";
	$buffer1 = "";	
	foreach $function(keys %{$hash{$rel}})
	{
		$buffer1 .= "<tr><th>$function</th><td>$hash{$rel}{$function}{scriptplanned}</td><td>$hash{$rel}{$function}{scriptexecuted}</td><td>$hash{$rel}{$function}{firstrunpassrate}</td><td>$hash{$rel}{$function}{overallpassrate}</td><td>$hash{$rel}{$function}{allprs}</td><td>$hash{$rel}{$function}{blockerprs}</td></tr>\n";
	}
	$buffer1 .= "</table></li>\n";
	$masterbuff .= $buffer.$header.$buffer1;
}
open(SUM,">exec_summary");
print SUM $masterbuff;
close(SUM);
	
		
	


