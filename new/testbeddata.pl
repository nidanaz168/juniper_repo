#!/usr/bin/perl
use lib qw(/homes/rod/lib /volume/labtools/eabu/lib/Dashboard /volume/labtools/lib );
use HTML::TableExtract;
use Data::Dumper;
use DBI;
use SysTest::DB;
set_dsn('pg_res');
use POSIX;
### Db connection 
my $hostname = 'eabu-systest-db.juniper.net';
my $user = "postgres";
my $pass = "postgres";
my $port = "5432";
my $dsn = "dbi:Pg:database=regression;host=$hostname;port=$port";
my $dbh = DBI->connect($dsn,$user,$pass)
                or die "Couldn't connect to database ".DBI->errstr;
my $rel = $ARGV[0];
my $function = $ARGV[1];
my $event_id = $ARGV[2];
#Get the result_id and RM_id
print "\n$event_id\n";
@res_id = ();
$result_id = "";
%hash = ();
$today = `date "+%Y-%m-%d"`;
##### get the parent result id
$sql = "select result_id from er_regression_result where (name in('$event_id') and parent_result_id='0')";
@parent = db_get_all_rows($sql);
$parent_id = "";
my %runtime_hash = ();;
foreach $reg(@parent)
{
	$parent_id = $reg->{result_id};
}
	
print "$parent_id \n";
$sql = "select regression_exec_id,result_id,parent_result_id from er_regression_result where result_id in (select result_id from er_regression_result where (name in('$event_id') and parent_result_id='0')) or parent_result_id in (select result_id from er_regression_result where (name in('$event_id') and parent_result_id='0'))";
@res_id = db_get_all_rows($sql);
foreach $reg(@res_id)
{
	$regression_exec_id = $reg->{regression_exec_id};
	
my $sql=qq!
SELECT
    testbed.testbed_id,
    testbed.name              AS testbed_name,
    count(testbed.testbed_id) AS cnt,
    to_char(sum(finish - start),'HH24 "Hours" MI "Minutes"')       AS sumtime
FROM
    scenario_exec INNER JOIN testbed on (
        scenario_exec.regression_exec_id = $regression_exec_id
        AND scenario_exec.testbed_id = testbed.testbed_id)
GROUP BY testbed.testbed_id,testbed_name
ORDER BY sumtime desc!;
my @testbed_stat = db_get_all_rows($sql);
#print Dumper(\@testbed_stat);
my @testbed_scenarios = db_get_all_rows("
    SELECT
        scenario_exec.scenario_exec_id,
        scenario_exec.testbed_id,
        scenario_exec.scenario_name,
        scenario_exec.status,
        scenario_exec.result_pass as pass,
        (scenario_exec.result_fail + scenario_exec.result_abort + scenario_exec.result_quit +
        scenario_exec.result_unsupported + scenario_exec.result_noresult) as fail
    FROM scenario_exec WHERE regression_exec_id=$regression_exec_id ORDER BY updated");
#print Dumper(\@testbed_scenarios);
my @run_time = db_get_all_rows("select testbed.name, sum(extract (epoch from test_exec.finish)-extract(epoch from test_exec.start))/3600 as runtime
    from test_exec, scenario_exec, testbed
    where
    testbed.testbed_id=scenario_exec.testbed_id and
    test_exec.scenario_exec_id=scenario_exec.scenario_exec_id and
    test_exec.regression_exec_id=$regression_exec_id group by testbed.name");
#print Dumper(\@run_time);
foreach (@run_time) {
  if($_->{'runtime'}) {
    $runtime_hash{$_->{'name'}}=sprintf("%.2f",$_->{'runtime'});
	print "$runtime_hash{$_->{'name'}} \n";
  } else {
    $runtime_hash{$_->{'name'}}=0;
  }
}



 foreach my $tb (@testbed_stat) {
  if(!exists $hash{$tb->{testbed_name}}{pass}) { $hash{$tb->{testbed_name}}{pass} =0; }
  if(!exists $hash{$tb->{testbed_name}}{fail}) { $hash{$tb->{testbed_name}}{fail} =0; }
  if(!exists $hash{$tb->{testbed_name}}{runtime}) { $hash{$tb->{testbed_name}}{runtime} =0; }
 foreach my $se (@testbed_scenarios) {
 next unless $se->{testbed_id} == $tb->{testbed_id};
  $hash{$tb->{testbed_name}}{pass} += $se->{pass};
  $hash{$tb->{testbed_name}}{fail} += $se->{fail};
	}
	$hash{$tb->{testbed_name}}{runtime} += $runtime_hash{$tb->{testbed_name}};
	}
}
chomp($parent_id);
print "Parent = $parent_id  \n";
###### First Get the First Execution result from the DR page
$url = "wget -o log -O execres --http-user=sooraj --http-password=King_123 \"http://systest.juniper.net/ti/webapp/dr/debug_dr/index.mhtml?owner=ALL&mode=3:2:1&result_id=$parent_id&submit.x=11&submit.y=13\"";
$out  = `$url`;
$te = HTML::TableExtract->new( attribs => { id => "table1" } );
 $te->parse_file("execres");
	foreach $ts ($te->tables) {
    @rc =   $ts->rows;
    @cc = $ts->columns;
    $rcnt = @rc;
    $ccnt = @cc;
    $cnt = 0;
    $t = $ts->rows->[0];
    print " $t->[0] \n";
    if($t->[0] !~ /TESTBED/) { next;}
   foreach $row ($ts->rows) {
        if($row->[0] =~ /TESTBED/) { next;}
        if($row->[0] =~ /TOTAL/) { next;}
        chomp($row->[0]);
        chomp($row->[1]);
        chomp($row->[2]);
        $hash{$row->[0]}->{pass} =  $row->[2];
        $hash{$row->[0]}->{total} = $row->[1];
    }

}
	

##### Get the result after debug from Debug page
chomp($parent_id);
$url = "wget -o log -O tbeddata --http-user=sooraj --http-password=King_123 \"http://systest.juniper.net/ti/webapp/dr/debug_dr/index.mhtml?owner=ALL&result_id=$parent_id&mode=0:5:1\"";
$out  = `$url`;
$te = HTML::TableExtract->new( attribs => { id => "table1" } );
 $te->parse_file("tbeddata");
 foreach $ts ($te->tables) {
    @rc =   $ts->rows;
    @cc = $ts->columns;
    $rcnt = @rc;
    $ccnt = @cc;
    $cnt = 0;
	$t = $ts->rows->[0];
	print " $t->[0] \n";
    if($t->[0] !~ /TESTBED/) { next;}
   foreach $row ($ts->rows) {
		if($row->[0] =~ /TESTBED/) { next;}	
		if($row->[0] =~ /TOTAL/) { next;}	
		chomp($row->[0]);
		chomp($row->[1]);
		chomp($row->[3]);
		$hash{$row->[0]}->{actualpass} =  $hash{$row->[0]}{pass} + ($row->[1] - $row->[3]);
		$hash{$row->[0]}->{fail} = $row->[3];
	}

}
$buffer = "<center><table class='firstpass' style='width:50%'><thead><tr><th>Test Bed Name </th><th>First Pass %</th><th>Actual Pass %</th><th>Run Time (Days/Hour)</th></tr>";
foreach $tbed(sort keys %hash)
{
	$total = $hash{$tbed}{total};
	$per_pass = 0;
	if($total > 0)
	{
		$per_pass = sprintf "%.2f",($hash{$tbed}{pass} / $total ) * 100;
	}
	$per_fail = 0;
	if($total > 0)
	{
		$per_fail = sprintf "%.2f",($hash{$tbed}{fail} / $total ) * 100;
	}
	$actualpassper = 0;
	if($total > 0)
    {
        $actualpassper = sprintf "%.2f",($hash{$tbed}{actualpass} / $total ) * 100;
    }
	if($per_pass > 100) { next;}
	$hash{$tbed}{passper} = $per_pass;
	$hash{$tbed}{actualpassper} = $actualpassper;
	### Convert run time to days or 
	$runtime = 0;
	$runtimestr = "";
	if($hash{$tbed}{runtime} > 24)
	{
		$runtime = $hash{$tbed}{runtime}/24 ;
		$runtime = sprintf "%.2f", $runtime;
		$runtimestr = " $runtime Days";
	}
	else
	{
		$runtime = sprintf "%.2f", $hash{$tbed}{runtime};
		$runtimestr = " $runtime Hours ";
	}
	
	
	$buffer .= "<tr><td>$tbed</td></td><td>$per_pass</td><td>$actualpassper</td><td>$runtimestr</td></tr>";
}
$buffer .= "</table>";
$releasestr = $rel;
$releasestr =~ s/\./-/g;
if($function =~ /PTX/) { $function = "TPTX";}
print "Open File /homes/rod/public_html/Regression/report/new/data/$releasestr"."_".$function."_tbed_table\n";
open(F,">/homes/rod/public_html/Regression/report/new/data/$releasestr"."_".$function."_tbed_table");
print F $buffer;
close(F);
##### now for the charts ##########################
#### First chart by First Pass % ####################################
$chartstr = "<chart caption='First Pass' xAxisName='Test Beds' yAxisName='Pass %' showValues='1' numberPrefix='' useRoundEdges='1' legendBorderAlpha='100' showBorder='0' bgColor='FFFFFF,FFFFFF' >";
$categories = "<categories>";
$dataset = "<dataset seriesName='First Pass %'>";
$datasetact = "<dataset seriesName='Actual Pass %'>";
foreach $tbed( sort{$hash{$b}{passper} <=> $hash{$a}{passper}} (keys %hash)) {
	if($hash{$tbed}{passper} > 100) { next;}
	$categories .= "<category label='$tbed' />";
	$dataset .= "<set label='$tbed' value='$hash{$tbed}{passper}'  />\n";
	$datasetact .= "<set label='$tbed' value='$hash{$tbed}{actualpassper}'  />\n";
}
$categories .= "</categories>";
$dataset .= "</dataset>";
$datasetact .= "</dataset>";
$chartstr .= $categories.$dataset.$datasetact."</chart>";
open(F,">/homes/rod/public_html/Regression/report/new/data/$releasestr"."_".$function."_tbed_fpass_chart");
print F $chartstr;
close(F);
#### chart by Execution time ####################################
$chartstr = "<chart caption='Testbed Usage' xAxisName='Test Beds' yAxisName='Hours' showValues='1' numberPrefix='' useRoundEdges='1' legendBorderAlpha='100' showBorder='0' bgColor='FFFFFF,FFFFFF' >";
$categories = "<categories>";
$dataset = "<dataset seriesName='Usgae Hours'>";
foreach $tbed( sort{$hash{$b}{runtime} <=> $hash{$a}{runtime}} (keys %hash)) {
	$categories .= "<category label='$tbed' />";
    $dataset .= "<set label='$tbed' value='$hash{$tbed}{runtime}'  />\n";
}
$categories .= "</categories>";
$dataset .= "</dataset>";
$chartstr .= $categories.$dataset."</chart>";
open(F,">/homes/rod/public_html/Regression/report/new/data/$releasestr"."_".$function."_tbed_runtime_chart");
print F $chartstr;
close(F);







