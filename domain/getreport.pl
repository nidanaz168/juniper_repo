#! /volume/perl/bin/perl -w
use lib qw(/volume/labtools/lib);
use lib qw(/homes/ravikanth/bin /volume/labtools/lib /volume/labtools/eabu/lib/Dashboard);
#use lib qw(/volume/labtools/lib /homes/sooraj/xmlrpc/Frontier-RPC-0.07b4p1/lib  /homes/rpathak/public_html/EABU/Release/PRS/shared .);
use DBI;
use Data::Dumper;
use Getopt::Long;
use SysTest::DB;

my $db_name="systest_live";
my $db_host="ttpgdb";
#my $db_user="testtool";
#my $db_pass="testtool";
# New user after pgsql8.4 migration
#my $db_user="stable_collection_sync";
#my $db_pass="stable_collection_sync";

#my $dbh=DBI->connect("dbi:Pg:dbname=$db_name;host=$db_host",$db_user,$db_pass);
my $testid = $ARGV[0];
%domain_map = ();
set_dsn('readonly');
#my $query = "select d.name,a.test_id,a.test_exec_id,c.domain_id,a.exitcode from test d,test_exec a, er_regression_result b,scenario_exec c where a.test_id=d.test_id and (b.result_id=$testid or b.merge_result_id=$testid or b.parent_result_id=$testid) and a.regression_exec_id=b.regression_exec_id and a.scenario_exec_id=c.scenario_exec_id and c.exit_code  like '%POST%' group by d.name,a.test_id,a.test_exec_id,c.domain_id,a.exitcode,a.start order by a.test_id,a.start";
@output = db_get_all_rows("select d.name,a.test_id,a.test_exec_id,c.domain_id,a.exitcode from test d,test_exec a, er_regression_result b,scenario_exec c where a.test_id=d.test_id and (b.result_id in ($testid) or b.merge_result_id in ($testid) or b.parent_result_id in ($testid) ) and a.regression_exec_id=b.regression_exec_id and a.scenario_exec_id=c.scenario_exec_id and c.exit_code  like '%POST%' group by d.name,a.test_id,a.test_exec_id,c.domain_id,a.exitcode,a.start order by a.test_id,a.start");
#$sth->execute;
#$r=$sth->fetchall_arrayref({});
#foreach my $ar(@{$r})
foreach (@output) 
{
    if(!exists $exists{$_->{test_id}})
    {
        $domain_map{$_->{domain_id}}{$_->{test_id}}{name} = "$_->{name}";
        $exists{$_->{test_id}} = 1;
        if($_->{exitcode} =~ /^PASS$|TC_RERUN_PASS/) { 
            $domain_map{$_->{domain_id}}{$_->{test_id}}{result} = "PASS";
            $domain_map{$_->{domain_id}}{$_->{test_id}}{exitcode} = "$_->{exitcode}";
        } else { 
            $domain_map{$_->{domain_id}}{$_->{test_id}}{result} = "NOTPASS";
            $domain_map{$_->{domain_id}}{$_->{test_id}}{exitcode} = "$_->{exitcode}";
        }
    }
}
%domain_stats = ();
$totaltc = 0;
$tortalpass = 0;
$mainbuffer = "";
#tbedname mapping
%dommapping = ();
@lines = `cat /homes/rpathak/domain_list`;
foreach $l(@lines)
{
    chomp($l);
    ($name) = $l =~ /(.*),/;
    ($id) = $l =~ /,(.*)/;
    $dommapping{$id}  = $name;
}
foreach $dom (keys %domain_map)
{   
        
    $domain_stats{$dom}{total} = 0;
    $domain_stats{$dom}{pass} = 0;
        $dombuff = "<div id='$dom' class='domain' style='display:none;float:left;margin-left:50px';><table class='mission' id='myTable-$dom'><thead><tr><th>Domain</th><th>test id</th><th>testname</th><th>exitcode</th></tr></thead><tbody>";
    foreach $tc(keys %{$domain_map{$dom}})
    {
            $dombuff .= "<tr><td>$dommapping{$dom}</td><td>$tc</td><td>$domain_map{$dom}{$tc}{name}</td><td>$domain_map{$dom}{$tc}{exitcode}</td></tr>";
        $totaltc++;
        $domain_stats{$dom}{total}++;
        if($domain_map{$dom}{$tc}{result} =~ /^PASS$/)
        {
            $domain_stats{$dom}{pass}++;
            $totalpass++;

        }
    }
    $dombuff .= "</tbody></table></div>";
    $mainbuffer .= $dombuff;
}
$buffer =  "<div id='123' style='float:left;width:500px;'><table id='myTable' width='100%' class='mission' border=1><thead><tr><th>Domain Name</th><th>Total Test</th><th>First Run Pass </th><th>% First Run Pass</th></tr><tbody>";
foreach $dom(keys %domain_stats)
{
    $per = sprintf "%.0f",($domain_stats{$dom}{pass} / $domain_stats{$dom}{total}) * 100;

    $buffer .= "<tr><td><a href='javascript:showscripts(\"$dom\");' >$dommapping{$dom}</a></td><td>$domain_stats{$dom}{total}</td><td>$domain_stats{$dom}{pass}</td><td>$per %</td></tr>"
}
$per = sprintf "%.0f",($totalpass / $totaltc) * 100;
$buffer .= "<tr><td>Total</td><td>$totaltc</td><td>$totalpass</td><td>$per %</td></tr></tbody></table></div>";
print $buffer ;
print $mainbuffer;
