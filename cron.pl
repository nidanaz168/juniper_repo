#!/volume/perl/bin/perl

use lib qw(/volume/labtools/lib/);
use lib qw(/volume/perl/5.8.9/lib/site_perl/5.8.9/);
use SysTest::DB;
use Storable;
use Data::Dumper;
set_dsn('pg_regressd');
my $dlmt = ":&:";
my $hostname = 'jdi-reg-tools';
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
$lock = "regreport_lock";
$time  = `date`;
my $recipients="nidanaz\@juniper.net";
if (-e $lock){
        print "lock exists, exiting script !!!";
        `mail -s "Lock exists  at $time for /var/www/html/CI_Report/regreport_lock" "$recipients" <<EOF`;
        exit;
}else{
        open(F,">$lock");
        `chmod 777 /var/www/html/CI_Report/$lock`;
         `mail -s "Cron executed at $time for regression report" "$recipients" <<EOF`;
}
$cond = "";
if($ARGV[0] !~ /^$/){
$cond = "and release in ('$ARGV[0]')";
}
`rm -rf /var/www/html/CI_Report/*nida.txt`;
#$query = " select release from releases where release in ('18.1X1.2'); ";   #### get the Active releases
$query = " select release from releases where active='yes' $cond; ";   #### get the Active releases
print $query;
    my $sth=$dbh->prepare($query);
    $sth->execute;
     my $r=$sth->fetchall_arrayref({});
	$c= 0;
    foreach my $ar(@{$r})
    {
		$relstr  = $ar->{release};
                $relstr =~ s/\./-/g;
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
				$logfile = "$ar1->{releasename}"."_"."$ar1->{function}".'_nida.txt';
				print "perl  report.pl \'$ar1->{drnames}\' \'$ar1->{plannedrelease}\' \'$ar1->{releasename}\'  \'$ar1->{function}\'\n";
				$data = `perl  report.pl \'$ar1->{drnames}\' \'$ar1->{plannedrelease}\' \'$ar1->{releasename}\' \'$ar1->{function}\' > $logfile`;
		                print $data;
                }
	}
`rm -rf /var/www/html/CI_Report/$lock`;

$buffer .= "</li></div>";
#### Now open the report file for EABU-MMX-TEST-GOALS 2012
open(F,">testgoals.txt");
print F $buffer;
close(F);

