package regressionreport;
#
#===============================================================================
#
#         FILE:  regressionreport.pm
#
#  DESCRIPTION:  This file is having all the common subroutines require for RegressionReport Tools
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Sooraj,
#      COMPANY:
#      VERSION:  1.0
#      CREATED:  12/10/2010 11:35:30 PM
#     REVISION:  ---
#===============================================================================   


use lib qw(/homes/rpathak/public_html/EABU/Release/PRS/shared /homes/rpathak/public_html/EABU/RLI /volume/labtools/lib /volume/labtools/eabu/lib/Dashboard );
use XML::Simple;
use XML::Hash::LX;
use Data::Dumper;
use POSIX qw/strftime/;	
use Time::Local;
use xmlparse;
use Data::Dumper;
use get_reportees;
use XML::Twig;
use XML::LibXML;
use XML::LibXML::XPathContext; 
use Date::Manip;
use XML::Simple;
use File::stat;
use Date::Manip;
use Time::localtime;
use Switch;
use UNIVERSAL 'isa';
use Stapil;
use Utils;
use DBI;
use JSON;
use Text::CSV::Slurp;
use HTML::HashTable;
use Date::Calc;
use Date::DE qw(holidays);
use Date::Business;
use SysTest::DB;
use Storable;
use Data::Dumper;
use LWP::Simple;
use HTTP::Request;
use HTML::TableExtract;
set_dsn('pg_regressd');

###################################################################
## This function creates a new object of utilities
## Arguments none
## reutrns Object
###################################################################
my $hostname = 'eabu-systest-db.juniper.net';
my $user = "postgres";
my $pass = "postgres";
my $port = "5432";
my $dsn = "dbi:Pg:database=regression;host=$hostname;port=$port";
my $dbh = DBI->connect($dsn,$user,$pass)
                or die "Couldn't connect to database ".DBI->errstr;

sub new
{
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}                
###################################################################
## This function  gets the event ids from the systest database for a
## given string of Debug event names
## Arguments comma seperated list of debug names
## reutrns arry of debug id's
###################################################################
sub geteventidsfromeventnames
{
	$slef = shift;
	$event_names = shift;
	@events = split(",",$event_names);
	@res_id = ();
	foreach $e(@events)
	{
		my $eid_query= "select result_id from er_regression_result where (name='$e' and parent_result_id='0')";
		my @res =db_get_all_rows($eid_query);
		push @res_id , $res[0]->{result_id}
	}
	return @res_id;
}
sub getfirstrunpassrate
{
	$self = shift;
	$debugid = shift;
	$url = "wget -o log -O out --http-user=sooraj --http-password=budwiser_1234 \"http://systest.juniper.net/ti/webapp/dr/debug_dr/index.mhtml?mode=5:7:0&result_id=$debugid\"";
    $out  = `$url`;
    $out = `grep  -a "First Run Raw Pass Rate.*(excluding transition scripts)" out`;
    ($scriptstats) = $out =~ /\((.*?)\)/;
    ($firstrunpass) = $scriptstats =~ /(.*)\//;
    ($firstrunscript) = $scriptstats =~ /\/(.*)/;
    chomp($firstrunscript);
    chomp($firstrunpass);
	%hash = ();
	$hash{firstrunpass} = $firstrunpass;
	$hash{firstrunscript} = $firstrunscript;
	return \%hash;
}
sub getcurrentpassrate
{
	$self = shift;
    $debugid = shift;
	$out  = `wget -o log -O out --http-user=sooraj --http-password=budwiser_1234 "http://www-systest.juniper.net/ti/webapp/dr/debug_dr/view/gen_tl9k_report_summary.mhtml?result_id=$debugid"`;
    $out = `grep -a -m 1 "ACTUAL PASS" out`;
    ($actualpass) = $out =~ /=(.*)%/;
    $out = `grep -a -m 1 "Unique Script count" out`;
    ($uniqscriptcount) = $out =~ /=(.*)/;
    chomp($uniqscriptcount);
	%hash = ();
	$hash{uniqscriptcount} = $uniqscriptcount;
    $out = `grep -a -m 1 "Unique (latest respin) Pass count" out`;
    ($uniqpasscount) = $out =~ /=(.*)/;
    chomp($uniqpasscount);
	$hash{uniqpasscount} = $uniqpasscount;
    $out = `grep -a -m 1 "Unique (latest respin) Failure count (including pending)" out`;
    ($uniqfailcount) = $out =~ /=(.*)/;
    $out = `grep -a -m 1 "Scripts failed Due to PRs -" out`;
    ($failedscripts) = $out =~ /- <\/b>(.*)/;
    chomp($failedscripts);
	$hash{failedscripts} = $failedscripts;
	return \%hash;
}
sub getoutstandingprs
{
	$self = shift;
	$debugid = shift;
	$hash = shift;
	$out  = `wget -o log -O fdbg --http-user=sooraj --http-password=budwiser_1234 "http://systest.juniper.net/ti/webapp/dr/debug_dr/index.mhtml?result_id=$debugid&mode=5:0:0"`;
	####### Get the PR Details now #################################
    ######### For this first the TL9000 table need to be parsed
    #####  We can do this by parsing the HTML table which is having the PR Details #############################
    $te = HTML::TableExtract->new(attribs => { border => "1" } );
    $te->parse_file("out");
    foreach $ts ($te->tables) {
    @rc =   $ts->rows;
    @cc = $ts->columns;
    $rcnt = @rc;
    $ccnt = @cc;
    $cnt = 0;
    $t = $ts->rows->[0];
	%outstandingprhash = ();
    if($t->[0] !~ /PR Number/) { next;}
    foreach $row ($ts->rows) {
        if($row->[0] =~ /PR Number/) { next;}
        $pr = $row->[0];
        chomp($pr);
        $pr =~ s/N|n//g;
        $pr =~ s/O|o//g;
        $pr =~ s/-//g;
        if($pr =~ /^$/) { next;}
        if(exists $outstandingprhash{$pr}) { next;}
        $hash->{count}++;
        $hash->{prs} .= "$pr," ;
        $outstandingprhash{$pr} = 1;
        }
   }
}
sub getallprs
{
	$self = shift;
	$debugid = shift;
	$allprs = shift;
	$script_hit = shift;

	$url = "wget -o log -O prs --http-user=sooraj --http-password=budwiser_1234 \"http://systest.juniper.net/ti/webapp/dr/debug_dr/index.mhtml?mode=0:1:0&result_id=$debugid\"";
    $all_prs  = `$url`;
    $te = HTML::TableExtract->new(attribs => { id => "table1" } );
    $te->parse_file("prs");
    foreach $ts ($te->tables) {
    @rc =   $ts->rows;
    @cc = $ts->columns;
    $rcnt = @rc;
    $ccnt = @cc;
    $cnt = 0;
	%allprshash = ();
    foreach $row ($ts->rows) {
        if($row->[0] =~ /PR/) { next;}
        $pr = $row->[0];
        chomp($pr);
        $pr =~ s/N|n//g;
        $pr =~ s/O|o//g;
        $pr =~ s/-//g;
        if($pr =~ /^$/) { next;}
        if(exists $allprshash{$pr}) { next;}
        $allprs->{count}++;
        $allprs->{prs} .= "$pr," ;
        $allprshash{$pr} = 1;
        print "hit $row->[8] \n";
        $script_hit->{$pr} = $row->[8];
        }
   }
}
sub getdebugbreakdown
{
	$self = shift;
	$debugid = shift;
	$dbg_brk_hash = shift;
	$url = "wget -o log -O debugbreak --http-user=sooraj --http-password=budwiser_1234 \"http://systest.juniper.net/ti/webapp/dr/debug_dr/index.mhtml?mode=0:0:2&result_id=$debugid\"";
    $dbg_brk  = `$url`;
    $te = HTML::TableExtract->new(attribs => { id => "table1" } );
    $te->parse_file("debugbreak");
    foreach $ts ($te->tables) {
    @rc =   $ts->rows;
    @cc = $ts->columns;
    $rcnt = @rc;
    $ccnt = @cc;
    $cnt = 0;
    foreach $row ($ts->rows) {
        if($row->[0] =~ /REG EXIT/) { next;}
        $cat = $row->[0];
        $count = $row->[1];
        chomp($cat);chomp($count);
        if(!exists $dbg_brk_hash->{$cat}) { $dbg_brk_hash->{$cat} = $count;}
        else { $dbg_brk_hash->{$cat} += $count;}
        }
	}
}
sub getrespindata
{
	$self = shift;
	$debugid = shift;
	$initial = shift;
	$respin = shift;

	$url = "wget -o log -O respin --http-user=sooraj --http-password=budwiser_1234 \"http://systest.juniper.net/ti/webapp/dr/debug_dr/index.mhtml?mode=0:0:0&result_id=$debugid\"";
    $dbg_brk  = `$url`;
    $te = HTML::TableExtract->new(attribs => { id => table1 } );
    $te->parse_file("respin");
    foreach $ts ($te->tables) {
    @rc =   $ts->rows;
    @cc = $ts->columns;
    $rcnt = @rc;
    $ccnt = @cc;
    $cnt = 0;
    $t = $ts->rows->[0];
    if($t->[0] !~ /JUNOS/) { next;}
    foreach $row ($ts->rows) {
        $cnt++;
        if($row->[0] =~ /TOTAL|JUNOS/) { next;}
        if($cnt == 2) {
            #Tis will be the initial data
            $initial->{totalpending} = $row->[9];
            $initial->{totaldebug} = $row->[1];
        next;}
        $respin->{respindebug} += $row->[1];
        $respin{respinpending} += $row->[9];
        }
   }
}
	
	
