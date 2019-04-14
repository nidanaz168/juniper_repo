#!/volume/perl/bin/perl

use lib qw(/volume/labtools/lib/);
use SysTest::DB;
use Storable;
use Date::Calc;
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

my $total = -2;
my $tol = -1;
my $reg_img = "";
my $img_loc = "";
my $event_id = $ARGV[0];
my $pl_release = $ARGV[1];
my $releasestr = $ARGV[2];
my $function = $ARGV[3];
#Get the result_id and RM_id
print "\n$event_id\n";
@events = split(",",$event_id);
@res_id = ();
$result_id = "";
$today = `date "+%Y-%m-%d"`;
foreach $e(@events)
{
my $eid_query= "select a.result_id,b.regression_exec_id from er_regression_result a,er_regression_result b where (a.name='$e' and a.parent_result_id='0') and (a.result_id=b.parent_result_id or a.result_id=b.result_id)";
print "$eid_query \n";
my @res =db_get_all_rows($eid_query);
push @res_id,@res;
my %hash_prs;
$result_id .= $res[0]->{result_id}.",";
print "$result_id \n";
}
chop($result_id);
print Dumper(@res_id);
print "$result_id\n";
my @regression_id = ();
foreach my $i (@res_id)
{
  push (@regression_id , $i->{regression_exec_id});     
}
@regression_id = sort { $a <=> $b } @regression_id ;
foreach (@regression_id)
{
 print "\n".$_."\n";
}
my $reg_id = $regression_id[0];
open (FH,"/homes/shanthee/public_html/eng_vp_map.dat");
my @vp_dat = <FH>;
close(FH);
my %hash_vp;
foreach my $line (@vp_dat) {
    chomp($line);
    my @temp = split(",",$line);
    $hash_vp{$temp[0]}=$temp[1];
}
my @P=db_get_all_rows("select exitcode,count(test_id) from test_exec where exitcode in ('ABORT','CONNECT_FAIL','CONNECT_LOST','CORE_PASS','EXPECT_ERRORS','FAIL','IGP_FAIL','LINK_FAIL','PARAMS_FAIL','PASS','TC_RERUN_PASS','TEST_TIMEOUT','UNKNOWN_ERROR','UNTESTED') and regression_exec_id=$reg_id group by exitcode");


#get the Event Details
my @ALL = db_get_all_rows("select name,value from regression_exec_detail where regression_exec_id in \(select regression_exec_id from er_regression_result where parent_result_id in \($result_id\) or result_id in \($result_id\)\) and \(name=\'base_package\' or name=\'test_string\'\) order by value");
#Event details for TOT OR BR OR MR Regression
my @REL = db_get_all_rows("select distinct(value) from regression_exec_detail where regression_exec_id in \(select regression_exec_id from er_regression_result where parent_result_id in \($result_id\) or result_id in \($result_id\)\) and \(name=\'pkgpath:bg-regress1\' or name=\'pkgpath:sv-regress6\'\) order by value");
print "Success \n";
my @resp_img=();
if ($REL[0]->{value} =~ /\/volume\/ftp\/private\/systest\/(.+)\/2.*\/(.+)/)
{
    $reg_img = $1;
    $img_loc = $REL[0]->{value};
    for ($i =1;$i<=$#REL;$i++)
    {
         $REL[$i]->{value} =~ /\/volume\/ftp\/private\/systest\/(.+)\/2.*\/(.+)/ ;
          push (@resp_img , $2);
    }

}
elsif($REL[0]->{value} =~ /\/volume\/ftp\/private\/systest\/(.+)\/(.+)/)
{
    $1 =~ /(.+\....).*/;
    $reg_img = $1;
    $img_loc = $REL[0]->{value};
    for ($i =1;$i<=$#REL;$i++)
    {
        $REL[$i]->{value} =~ /\/volume\/ftp\/private\/systest\/(.+)\/(.+)/ ;  
        push (@resp_img , $2);
    }
}
#get Start and End Date
my $st = db_get_one_row("select start,finish from regression_exec where regression_exec_id=$reg_id");
print Dumper(@REL);
print "\n$st->{start}\n";
print "\n$st->{finish}\n";

#start time
my $start = substr($st->{start},0,19); 
my $finish = substr($st->{finish},0,19);
print "\n$reg_id\n";

print Dumper(@ALL);
#Check for PB,IB or TOT,MR,BR
if(@ALL)
{
$img_loc = $ALL[($#ALL+1)/2]->{value};
$reg_img = $ALL[0]->{value};

for ( $i =1 ;$i<(($#ALL+1)/2);$i++)
{
 push (@resp_img , $ALL[$i]->{value});  
}
}

my %result =();
# Compute PASS/FAIL/Pending
%result = &gethash_reg($result_id);

#Raw pass calculation
foreach $pi (@P)
{
      my $stitch = $pi->{exitcode};
      $result{$total}{RAW}->{$stitch} = $pi->{count};
}
$result{$total}{RAW_COUNT} = 0;
foreach (keys %{$result{$total}{RAW}})
{
    $result{$total}{RAW_COUNT} += $result{$total}{RAW}->{$_};
}
#printout result HASH
foreach $key (keys %{$result{$total}} )
{
      print "$key ".'== '."$result{$total}->{$key}\n";
}
print "\n\n $reg_img \n $img_loc \n";

my($y,$m,$d) = Date::Calc::Today();
#printing Details.
my $data = '<html><head><title>'.$event_id.'  '.$y.'_'.$m.'_'.$d.'</title><style type="text/css">
            /* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
{margin:0in;
    margin-bottom:.0001pt;
    font-size:12.0pt;
    font-family:"Times New Roman";}

#sample
{
        font-family: "Lucida Sans Unicode", "Lucida Grande", Sans-Serif;
        font-size: 12px;
       border-collapse: collapse;
       border-top: 6px solid #9baff1;
       border-bottom: 6px solid #9baff1;
       border-right: 1px solid #9baff1;
       border-left: 1px solid #9baff1; 
}
#sample th
{
    font-size: 14px;
    text-align:centre;
    font-weight: normal;
    padding: 10px;
    background-color: #d0dafd;
    border-bottom: 2px solid #9baff1;
    color: #039;
}
#sample td
{
        padding: 3px;
        text-align:left;
       color: #2A2AB0;
       border-top: 1px solid #e8edff;
}
.first
{
        background: #d0dafd;
}

    </style>
      <Body>
      <H3>Regression Report for '.$event_id.' </H3>
      <br>
      ';
my $per_pass = sprintf "%.2f",($result{$total}->{ACTUALPASS}/$result{$total}->{ACTUALCOUNT})*100 ;
my $per_fail = sprintf "%.2f",((($result{$total}->{ACTUALFAIL}-$result{$total}->{PENDING})/$result{$total}->{ACTUALCOUNT})*100);
my $per_pend = sprintf "%.2f",($result{$total}->{PENDING}/$result{$total}->{ACTUALCOUNT})*100 ;
my $per_regpass = sprintf "%.2f", ($result{$total}{REG}->{PASS}/$result{$total}->{ACTUALCOUNT})*100;
my $per_rawpass = sprintf "%.2f", ($result{$total}{RAW}->{PASS}/$result{$total}->{RAW_COUNT})*100;
print "$per_pass $per_fail $per_pend $per_regpass $per_rawpass $result{$total}->{ACTUALCOUNT} \n";
##### Get the PR
#query the PR's Filed for this DR event
my @out = db_get_all_rows("select pr,found from er_prs where result_id in \(select result_id from er_regression_result where \(parent_result_id in \($result_id\) or result_id in \($result_id\)\)\) order by pr");

#my @out2 = db_get_all_rows("select test_exec_id,prs from er_debug_exec where result_id in (select result_id from er_regression_result where (parent_result_id=$result_id or result_id=$result_id))");

my @out2 = db_get_all_rows("select a.prs,c.test_id from er_debug_exec a,er_regression_result b,test_exec c where a.test_exec_id=c.test_exec_id and a.result_id = b.result_id and (b.parent_result_id in ($result_id) or b.result_id in ($result_id))");

foreach $line (@out2) {
    $line->{prs} =~ s/o //g;
    $line->{prs} =~ s/O //g;
    $line->{prs} =~ s/n //g;
    $line->{prs} =~ s/N //g;
    if(defined $hash_prs{$line->{prs}}{count}) {
        $hash_prs{$line->{prs}}{count}++;
        $hash_prs{$line->{prs}}{str} .= "<a href=\"http://systest.juniper.net/entity/test/index.mhtml?test_id=$line->{test_id}\" target='_blank'>$line->{test_id}</a> ";
    } else {
        $hash_prs{$line->{prs}}{count} = 1;
        $hash_prs{$line->{prs}}{str} = "<a href=\"http://systest.juniper.net/entity/test/index.mhtml?test_id=$line->{test_id}\" target='_blank'>$line->{test_id}</a> ";
    }
    print "***********************************************$line->{prs} $hash_prs{$line->{prs}}\n";
}
#store all PR's in HASH
my %pr = &hashprs(@out);
print Dumper(\%pr);
$totalopen = 0;
$totalopenblocker=0;
foreach my $found (keys %pr)
{
 foreach my $state ('open','info','analyzed')
 {
     foreach my $num (keys %{$pr{$found}{$state}})
     {
		$totalopen++;
		if($pr{$found}{$state}{$num}{Blocker} !~ /^$/) { $totalopenblocker++;}
			
     }
 }
}

$query = "update regressionreport set scriptexecuted=$result{$total}->{ACTUALCOUNT},firstrunpassrate=$per_rawpass,overallpassrate=$per_pass,overallfailrate=$per_fail,openprs=$totalopen,openblocker=$totalopenblocker,tobedebugged=$result{$total}->{PENDING} where releasename='$releasestr' and function='$function'";
	print "$query \n";
        my $sth=$dbh->prepare($query);
        $sth->execute;

##### now Create table and graphs for the report
#### Create table first #######################
### Read the data from the database
@functions = ('MMX/ACX','Kernel Manageability','RPD','T/TX/PTX');
%hash = ();
foreach $func(@functions)
{
	$query = " select scriptplanned,scriptexecuted,firstrunpassrate,overallpassrate,overallfailrate,openprs,openblocker,tobedebugged from regressionreport where releasename='$releasestr' and function='$func'";
    my $sth=$dbh->prepare($query);
    $sth->execute;
     my $r=$sth->fetchall_arrayref({});
	$c= 0;
    foreach my $ar(@{$r})
    {
			$hash{$func}{scriptplanned} = $ar->{scriptplanned};
			$hash{$func}{scriptexecuted} = $ar->{scriptexecuted};
			$hash{$func}{firstrunpassrate} = $ar->{firstrunpassrate};
			$hash{$func}{overallpassrate} = $ar->{overallpassrate};
			$hash{$func}{overallfailrate} = $ar->{overallfailrate};
			$hash{$func}{openprs} = $ar->{openprs};
			$hash{$func}{openblocker} = $ar->{openblocker};
			$hash{$func}{tobedebugged} = $ar->{tobedebugged};
			$c++;
			##### Delete the row from the daily summary
			$query= "delete from daily_regression_progress where day='$today' and release='$releasestr' and function='$func'";
			$sth=$dbh->prepare($query);
			$sth->execute;
			##### now insert
			if($ar->{scriptexecuted} != 0)
			{
				$tobe_debug_per = sprintf "%.2f",($ar->{tobedebugged}/$ar->{scriptexecuted}) * 100;
			}
			else
			{
				$tobe_debug_per = 0;
			}
			if($ar->{scriptexecuted} != 0)
			{
				$executed_per = sprintf "%.2f",($ar->{scriptexecuted}/$ar->{scriptplanned}) * 100;
			}
			else
			{
				$executed_per = 0;
			}
			$query = "insert into daily_regression_progress values('$releasestr','$func','$today',$executed_per,$ar->{overallpassrate},$ar->{overallfailrate},0,$tobe_debug_per)";
			$sth=$dbh->prepare($query);
			$sth->execute;
	}
	if($c ==0 )
	{
			$hash{$func}{scriptplanned} = 0;
			$hash{$func}{scriptexecuted} = 0;
			$hash{$func}{firstrunpassrate} = 0;
			$hash{$func}{overallpassrate} = 0;
			$hash{$func}{overallfailrate} = 0;
			$hash{$func}{openprs} = 0;
			$hash{$func}{openblocker} = 0;
			$hash{$func}{tobedebugged} = 0;
	}
}
$relstrforprogress = $releasestr;
$releasestr =~ s/\./-/g;
open(F,">/homes/rod/public_html/Regression/report/data/$releasestr"."_table");
### updated time
# Get the Last refreshed time
    $final = "/homes/rod/public_html/Regression/report/data/$releasestr"."_table";
        $out = `ls -l --full-time $final`;
            ($year123,$month123,$date123,$time123) = $out =~ /([0-9]+)-([0-9]+)-([0-9]+)\s([0-9:]+)/;
                ($hour,$minute) = $time123 =~ /([0-9]+):([0-9]+):([0-9]+)/;
                    $updated = "<center><div><font  style='font-weight:bold;' size=2 face='Trebuchet MS, Verdana, Arial, Helvetica, sans-serif'>Last Refreshed :$year123-$month123-$date123 $hour:$minute";
$table ="<table><thead><tr><th>$updated</th></thead></tr></table>";
$table .="<table><thead><tr><th>Regression Start $start</th>";
$table .="<th>Regression End $finish</th></tr></thead></table>";
$table .= "<table style='hieght:100%;'><thead><tr><th>Summary of Totals</th>";
$planned = "<tr><th>Total Script Planned</th>";
$executed = "<tr><th>Total Script Executed </th>";
$tobedebugged = "<tr><th>Total Script To Debug</th>";
$firstpass = "<tr><th>First Run Pass Rate </th>";
$pass = "<tr><th>Overall Pass Rate </th>";
$fail = "<tr><th>Overall Fail Rate </th>";
$prs = "<tr><th colspan=5>PR Details</th>";
$openprs = "<tr><th>Number Of Open PR's </th>";
$category = "";
$dataset = "<dataset seriesName='First Pass Rate' color='FDC12E' anchorBorderColor='FDC12E' anchorBgColor='FDC12E'>";
$dataset1 = "<dataset seriesName='Overall Pass Rate' color='52D017' anchorBorderColor='52D017' anchorBgColor='52D017'>";
$dataset2 = "<dataset seriesName='Overall Fail Rate' color='E42217' anchorBorderColor='E42217' anchorBgColor='E42217'>";
foreach $func(@functions)
{
	if($hash{$func}{scriptplanned} == 0) { next;}
	$table .= "<th>$func</th>";
	$planned .= "<td>$hash{$func}{scriptplanned}</td>";
	$executed .= "<td>$hash{$func}{scriptexecuted}</td>";
	$tobedebugged .= "<td>$hash{$func}{tobedebugged}</td>";
	$firstpass .= "<td>$hash{$func}{firstrunpassrate}</td>";
	$pass .= "<td>$hash{$func}{overallpassrate}</td>";
	$fail .= "<td>$hash{$func}{overallfailrate}</td>";
	$openprs .= "<td>$hash{$func}{openprs} Open ($hash{$func}{openblocker} Blocker)</td>";
	$category .= "<category label=\"$func\"/> \n";
	$dataset .= "<set value=\"$hash{$func}{firstrunpassrate}\" />\n";
	$dataset1 .= "<set value=\"$hash{$func}{overallpassrate}\" />\n";
	$dataset2 .= "<set value=\"$hash{$func}{overallfailrate}\" />\n";
}
$table .= "</tr>";
$planned .= "</tr>";
$executed .= "</tr>";
$tobedebugged .= "</tr>";
$firstpass .= "</tr>";
$pass .= "</tr>";
$fail .= "</tr>";
$prs .= "</tr>";
$openprs .= "</tr>";
$table .= $planned.$executed.$tobedebugged.$firstpass.$pass.$fail.$prs.$openprs."</table>";
print "$table \n";
print F $table;
close(F);
##################### Create Graphs
$dataset .= "</dataset>";
$dataset1 .= "</dataset>";
$dataset2 .= "</dataset>";
$template = `cat /homes/rod/public_html/Regression/report/graph.template`;
$template =~ s/<main>/Raw Pass Rate/g;
$template =~ s/<categories-data>/$category/g;
$template =~ s/<blocker-data>/$dataset/g;
open(F,">/homes/rod/public_html/Regression/report/data/$releasestr"."_firstpass");
print F $template;
close(F);
$template = `cat /homes/rod/public_html/Regression/report/graph.template`;
$template =~ s/<main>/Overall Pass Rate/g;
$template =~ s/<categories-data>/$category/g;
$template =~ s/<blocker-data>/$dataset1$dataset2/g;
open(F,">/homes/rod/public_html/Regression/report/data/$releasestr"."_pass");
print F $template;
close(F);
###### now create the Regerssion progress graphs
foreach $func(@functions)
{
$executed_buffer="<dataset seriesName=\"executed\" color=\"#325232\">\n";
$overallpass_buffer="<dataset seriesName=\"overallpass\" color=\"#ffee22\">\n";
$overallfail_buffer="<dataset seriesName=\"overallfail\" color=\"#787878\">\n";
$tobedebugger_buffer="<dataset seriesName=\"tobedebugged\" color=\"#aabbcc\">\n";
$category = "";
    $query = " select day,scriptexecuted,overallpassrate,overallfailrate,tobedebugged from daily_regression_progress where release='$relstrforprogress' and function='$func' order by day";
	print "$query \n";
    my $sth=$dbh->prepare($query);
    $sth->execute;
     my $r=$sth->fetchall_arrayref({});
    $c= 0;
    foreach my $ar(@{$r})
    {
		$category .="<category label=\"$ar->{day}\"/> \n";
		$executed_buffer .= "<set value=\"$ar->{scriptexecuted}\" />\n";
		$overallpass_buffer .= "<set value=\"$ar->{overallpassrate}\" />\n";
		$overallfail_buffer .= "<set value=\"$ar->{overallfailrate}\" />\n";
		$tobedebugger_buffer .= "<set value=\"$ar->{tobedebugged}\" />\n";
		$c++;
	}
	if($c > 0)
	{
	print "$func $c \n";
	$executed_buffer .= "</dataset>";
	$overallpass_buffer .= "</dataset>";
	$overallfail_buffer .= "</dataset>";
	$tobedebugger_buffer .= "</dataset>";
	$template = `cat /homes/rod/public_html/Regression/report/progress_graph.template`;
	$template =~ s/<categories-data>/$category/g;
	$head = $func." Progress";
	$template =~ s/<main>/$head/g;
	$template =~ s/<blocker-data>/$executed_buffer$overallpass_buffer$overallfail_buffer$tobedebugger_buffer/g;
	$fname = $func;
	$fname =~ s/\//-/g;
	open(F,">/homes/rod/public_html/Regression/report/data/$releasestr"."_".$fname."_graph");
	print F $template;
	close(F);
	}
}
	
	



		
	
			
	

exit;
$data .= '
        <table id="sample">
                    <col class="first" />
        <thead>
        <tr>
        <th colspan=2><B>Regression Summary</B></th>
        </tr>
        </thead>
        </tbody>
        <tr>
        <td>Image Name</td>
        <td> '.$reg_img.'</td>
        </tr>
        <tr>
        <td>Regression start date</td>
        <td> '.$start.'  PDT</td>
        </tr>
        <tr>
        <td>Regression end date</td>
        <td> '.$finish.'  PDT</td>
        </tr>
        <tr>
        <td>Raw pass rate</td>
        <td>'.$per_rawpass.'% ('.$result{$total}{RAW}->{PASS}.'/'.$result{$total}->{RAW_COUNT}.')  --  First run</td>
        </tr>
        <tr>
        <td>Regression pass rate</td>
        <td>'.$per_regpass.'% ('.$result{$total}{REG}->{PASS}.'/'.$result{$total}->{ACTUALCOUNT}.')  --  includes Re-spins if any</td>
        </tr>
        <tr>
        <td>Regression event ID(s)</td>
        <td>';
        for ($i=0;$i<=$#res_id;$i++){    
        $data .='<a href="http://ttsv-rm.juniper.net/cgi-bin/regressman/index.cgi?mode=regression_exec_display&re_id='.$regression_id[$i].'">'.$regression_id[$i].'</a>&nbsp&nbsp';
        }
$data .='</td>
        </tr>
        <tr>
        <td>Image Location </td>
        <td> '.$img_loc.'</td>
        </tr>
        <tr>
        <td>Re-spin Images </td>
        <td> ';
foreach $V (@resp_img){
  $data .=$V.'<br>';}
 $data .='</td>
        </tr>
        </tbody>
        </table>
        <br>
        <table>
        <td valign=top>
        <table id="sample">
            <colgroup>
                    <col class="first" />
            </colgroup>
        <thead>
        <tr>
        <th colspan=2><B>Debug summary</B></th>
        </tr>
        </thead>
        <tbody>
        <tr>
        <td>Total scripts executed</td>
        <td> '.$result{$total}->{ACTUALCOUNT}.'</td>
        </tr>
        <tr>
        <td>Scripts Passed </td>
        <td> '.$result{$total}->{ACTUALPASS}.'    ('.$per_pass.'%) </td>
        </tr>
        <tr>
        <td>Scripts failed due to PR</td>
        <td> '.($result{$total}->{ACTUALFAIL}-$result{$total}->{PENDING}).'    ('.$per_fail.'%)</td>
        </tr>
        <tr>
        <td>Scripts pending debug</td>
        <td> '.$result{$total}->{PENDING}.'     ('.$per_pend.'%)</td>
        </tr>
        </tbody>
        </table>
        </td>
        <td style="padding:0px 0px 0px 10px" valign=top>
        <table id="sample">
            <colgroup>
                    <col class="first" />
                    <col />
                    <col class="first" />
            </colgroup>
        <thead>
        <tr>
        <th colspan=4 ><B>Regression result Breakdown</B></th>
        </tr>
        </thead>
        <tbody>';
        my $j=0;
foreach ('PASS','FAIL','ABORT','PARAMS_FAIL','LINK_FAIL','CONNECT_FAIL','CONNECT_LOST','CORE_PASS','TEST_TIMEOUT','EXPECT_ERRORS','IGP_FAIL','TC_RERUN_PASS','UNKNOWN_ERROR','UNTESTED')
{
    if($result{$total}{REG}->{$_})
    {
    $data .= '<tr>' if ($j%2 == 0);
    $data .='<td>';
    $data .= $_.'</td><td>';
    $data .= $result{$total}{REG}->{$_}.'</td>';
    $data .= '</tr>' if ($j%2 == 1);
    $j++;
    }
}

  $data .='</tbody>
        </table>
        </td>
        <td style="text-align:centre;padding:0px 0px 0px 40px" valign=top><B>Actual Pass rate</B><br/>
        <font size=50>'.$per_pass.'%</font><br/>
        ( '.$result{$total}->{ACTUALPASS}.' / '.$result{$total}->{ACTUALCOUNT}.' )<br/> includes regression and<br/> debug pass
        </td>
        </table
<br><br>
<H3>PR Details</H3>        

  ';    

#PR Display

#query the PR's Filed for this DR event
my @out = db_get_all_rows("select pr,found from er_prs where result_id in \(select result_id from er_regression_result where \(parent_result_id=$result_id or result_id=$result_id\)\) order by pr");

#my @out2 = db_get_all_rows("select test_exec_id,prs from er_debug_exec where result_id in (select result_id from er_regression_result where (parent_result_id=$result_id or result_id=$result_id))");

my @out2 = db_get_all_rows("select a.prs,c.test_id from er_debug_exec a,er_regression_result b,test_exec c where a.test_exec_id=c.test_exec_id and a.result_id = b.result_id and (b.parent_result_id=$result_id or b.result_id=$result_id)");

foreach $line (@out2) {
    $line->{prs} =~ s/O //g;
    $line->{prs} =~ s/n //g;
    $line->{prs} =~ s/N //g;
    if(defined $hash_prs{$line->{prs}}{count}) {
        $hash_prs{$line->{prs}}{count}++;
        $hash_prs{$line->{prs}}{str} .= "<a href=\"http://systest.juniper.net/entity/test/index.mhtml?test_id=$line->{test_id}\" target='_blank'>$line->{test_id}</a> ";
    } else {
        $hash_prs{$line->{prs}}{count} = 1;
        $hash_prs{$line->{prs}}{str} = "<a href=\"http://systest.juniper.net/entity/test/index.mhtml?test_id=$line->{test_id}\" target='_blank'>$line->{test_id}</a> ";
    }
}
#store all PR's in HASH
my %pr = &hashprs(@out);


#Print the PR's
foreach my $found (keys %pr)
{
 $data .='<H4>New PR\'s</H4>' if $found eq 'NEW';
 $data .='</table><br><H4>Old Refered Pr\'s</H4>' if $found eq 'OLD';
#Table Header is added
 &addheader($data);
 foreach my $state ('open','info','feedback','analyzed','monitored','suspended','closed')
 {    
     foreach my $num (keys %{$pr{$found}{$state}})
     {
         #Add row for each PR
         &addrow(\%pr,$data,$found,$state,$num);
     }
 }
}
if(@out)
{
    $data .='</table>';
    $data .='<br><br><table><tr><td bgcolor="#F7656F">Blocker PRs</td></tr></table>';
}
else
{
  $data .='<br><h4>No Pr\'s Found</h4>'
}

$data .='<br>Thanks,<br>--EABU REG TEAM--</body></html>';
open FILE, ">/homes/rod/public_html/".$event_id."_".$y.$m.$d.".html" or die $!;
print FILE $data;
close FILE;

#ready the Mail Object
open(MAIL, "| /usr/sbin/sendmail -oi -t") or die "Error";
print MAIL <<EMAIL_TO_USER;
To:sooraj\@juniper.net
From:sooraj\@juniper.net
Subject: EABU Regression Report for $event_id
Content-Type: text/html; Charset="US-ASCII"
$data
EMAIL_TO_USER
close MAIL;


#send the MAIL.
##$msg->send();


#subroutines Used
sub addrow
{       
    my $p = shift;
    my ($found,$state,$num)=($_[1],$_[2],$_[3]);
    my $prnum = $p->{$found}->{$state}->{$num}->{Number};
    print $prnum."\n";
    @temp = split("-",$prnum);
    $prnum = $temp[0];
    $bg_color='white';
      if($p->{$found}->{$state}->{$num}->{Blocker} ne '')
      {
          if ($p->{$found}->{$state}->{$num}->{State} ne 'closed')
          {
          $bg_color='#F7656F';
          }
      }
#      else
#      {
#          $bg_color='white';
#      }
      $_[0] .= '
        <tr>
        <td valign=top bgcolor='.$bg_color.' style=\'background:'.$bg_color.';padding:1.5pt 3.0pt 1.5pt 3.0pt\'>
        <font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond\'><a href="https://gnats.juniper.net/web/default/'.$p->{$found}->{$state}->{$num}->{Number}.'">'.$p->{$found}->{$state}->{$num}->{Number}.'<o:p></o:p></span></font>
        </td>
        <td valign=top bgcolor='.$bg_color.' style=\'background:'.$bg_color.';padding:1.5pt 3.0pt 1.5pt 3.0pt;word-break:break-all\'>
        <font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond\'>'.$p->{$found}->{$state}->{$num}->{Synopsis}.'<o:p></o:p></span></font></p
        >
        </td>
        <td valign=top bgcolor='.$bg_color.' style=\'background:'.$bg_color.';padding:1.5pt 3.0pt 1.5pt 3.0pt\'>
        <font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond\'>'.$p->{$found}->{$state}->{$num}->{ReportedIn}.'<o:p></o:p></span></font>
        </td>
        <td valign=top bgcolor='.$bg_color.' style=\'background:'.$bg_color.';padding:1.5pt 3.0pt 1.5pt 3.0pt\'>
        <font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond\'>'.$p->{$found}->{$state}->{$num}->{Category}.'<o:p></o:p></span></font></p
        >
        </td>
        <td valign=top bgcolor='.$bg_color.' style=\'background:'.$bg_color.';padding:1.5pt 3.0pt 1.5pt 3.0pt\'>
        <font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond\'>'.$p->{$found}->{$state}->{$num}->{Severity}.'<o:p></o:p></span></font></p
        >
        </td>
        <td valign=top bgcolor='.$bg_color.' style=\'background:'.$bg_color.';padding:1.5pt 3.0pt 1.5pt 3.0pt\'>
        <font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond\'>'.$p->{$found}->{$state}->{$num}->{Blocker}.'<o:p></o:p></span></font>
        </td>
        <td valign=top bgcolor='.$bg_color.' style=\'background:'.$bg_color.';padding:1.5pt 3.0pt 1.5pt 3.0pt\'>
        <font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond\'>'.$p->{$found}->{$state}->{$num}->{Release}.'<o:p></o:p></span></font>
        </td>
        <td valign=top bgcolor='.$bg_color.' style=\'background:'.$bg_color.';padding:1.5pt 3.0pt 1.5pt 3.0pt\'>
        <font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond\'>'.$p->{$found}->{$state}->{$num}->{State}.'<o:p></o:p></span></font>
        </td>
        <td valign=top bgcolor='.$bg_color.' style=\'background:'.$bg_color.';padding:1.5pt 3.0pt 1.5pt 3.0pt\'>
        <font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond\'>'.$p->{$found}->{$state}->{$num}->{Responsible}.'<o:p></o:p></span></font>
        
        </td>
        <td valign=top bgcolor='.$bg_color.' style=\'background:'.$bg_color.';padding:1.5pt 3.0pt 1.5pt 3.0pt\'>
        <font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond\'>'.$p->{$found}->{$state}->{$num}->{Originator}.'<o:p></o:p></span></font>
        </td>
        <td valign=top bgcolor='.$bg_color.' style=\'background:'.$bg_color.';padding:1.5pt 3.0pt 1.5pt 3.0pt\'>
        <font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond\'>'.$hash_prs{$prnum}{count}.'<o:p></o:p></span></font>
        </td>
        <td valign=top bgcolor='.$bg_color.' style=\'background:'.$bg_color.';padding:1.5pt 3.0pt 1.5pt 3.0pt\'>
        <font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond\'>'.$hash_prs{$prnum}{str}.'<o:p></o:p></span></font>
        </td>
        <td valign=top bgcolor='.$bg_color.' style=\'background:'.$bg_color.';padding:1.5pt 3.0pt 1.5pt 3.0pt\'>
        <font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond\'>'.$hash_vp{$p->{$found}->{$state}->{$num}->{Responsible}}.'<o:p></o:p></span></font>
        </td>
        </tr>
        ';
}


#sub to HASH the values
sub hashprs
{
 my @O = @_;

# print Dumper (@O); get the list of PR's
 my $PRS =();
 my %find =();
 foreach (@O)
 {
  push (@PRS,$_->{pr});
  $find{$_->{pr}}->{found} = $_->{found};
 }
# print Dumper(@PRS); Format it to the query 
 my $number = join ("|",@PRS);
 $number=~ s/\|/") | (Number == "/g;
 $number=~ s/^/((Number == "/g;
 $number =~ s/$/"))/g;

print "$number";
# my @P = `/usr/X11R6/bin/query-pr --expr '$number' --format '"%s:&:%s:&:%s:&:%s:&:%s:&:%s:&:%s:&:%s:&:%s:&:%s:&:%s" Number Synopsis Reported-In Category Severity Blocker Release Branch State Responsible Originator'`;
 my @P = `query-pr --expr '$number' --format '"%s:&:%s:&:%s:&:%s:&:%s:&:%s:&:%s:&:%s:&:%s:&:%s:&:%s" Number Planned-Release Synopsis Reported-In Category Problem-Level Blocker Branch State Responsible Originator'`;
#Find the 1st scope of all the PR's
 my @pr1 = ();
 foreach $r (@PRS)
 {
     push (@pr1,(grep /$r-[0-9]+$dlmt$pl_release$dlmt/i, @P));
 }

 my @PR =();
 my $dlmt = ":&:";
 my %pr = ();
#hash the PR's {NEW/OLD}/{PR -States}{PR#}->Deatils
 for(my $i =0;$i<=$#pr1;$i++)
 {
     @PR = split /$dlmt/ , $pr1[$i] ;
     my $prest = $PR[0];
     $prest =~ s/-.*//g;
     print "\n\n$prest";
     $pr{$find{$prest}->{found}}{$PR[8]}{$PR[0]}->{Number} = $PR[0];
     $pr{$find{$prest}->{found}}{$PR[8]}{$PR[0]}->{Synopsis} = $PR[2];
     $pr{$find{$prest}->{found}}{$PR[8]}{$PR[0]}->{ReportedIn} = $PR[3];
     $pr{$find{$prest}->{found}}{$PR[8]}{$PR[0]}->{Category} = $PR[4];
     $pr{$find{$prest}->{found}}{$PR[8]}{$PR[0]}->{Severity} = $PR[5];
     $pr{$find{$prest}->{found}}{$PR[8]}{$PR[0]}->{Blocker} = $PR[6];
     $pr{$find{$prest}->{found}}{$PR[8]}{$PR[0]}->{Release} = $PR[1];
     $pr{$find{$prest}->{found}}{$PR[8]}{$PR[0]}->{Branch} = $PR[7];
     $pr{$find{$prest}->{found}}{$PR[8]}{$PR[0]}->{State} = $PR[8];
     $pr{$find{$prest}->{found}}{$PR[8]}{$PR[0]}->{Responsible} = $PR[9];
     $pr{$find{$prest}->{found}}{$PR[8]}{$PR[0]}->{Originator} = $PR[10];
 }
 return %pr;
}

sub addheader 
{

    $_[0] .= '<table border=0 cellpadding=0 width="100%" bgcolor="#CDCDCD">
              <col width="60" />
              <col width="450" />
              <col width="190" />
              <col width="75" />
              <col width="50" />
              <col width="50" />
              <col width="55" />
              <col width="60" />
              <col width="70" />
              <col width="70" />
              <thead>
              <td bgcolor="#D4DDF1" style=\'border:solid white 1.0pt;background:#D4DDF1;padding:1.5pt 7.0pt 1.5pt 3.0pt\'>
              <b><font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond;font-weight:bold\'>Number<o:p></o:p></span></font></b>
              </td>
              <td bgcolor="#D4DDF1" style=\'border:solid white 1.0pt;background:#D4DDF1;padding:1.5pt 7.0pt 1.5pt 3.0pt\'>
              <b><font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond;font-weight:bold\'>Synopsis<o:p></o:p></span></font></b>
              </td>
              <td bgcolor="#D4DDF1" style=\'border:solid white 1.0pt;background:#D4DDF1;padding:1.5pt 7.0pt 1.5pt 3.0pt\'>
              <b><font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond;font-weight:bold\'>Reported-In<o:p></o:p></span></font></b></p
>
              </td>
              <td bgcolor="#D4DDF1" style=\'border:solid white 1.0pt;background:#D4DDF1;padding:1.5pt 7.0pt 1.5pt 3.0pt\'>
              <b><font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond;font-weight:bold\'>Category<o:p></o:p></span></font></b>
              </td>
              <td bgcolor="#D4DDF1" style=\'border:solid white 1.0pt;background:#D4DDF1;padding:1.5pt 7.0pt 1.5pt 3.0pt\'>
              <b><font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond;font-weight:bold\'>Severity<o:p></o:p></span></font></b>
              </td>
              <td bgcolor="#D4DDF1" style=\'border:solid white 1.0pt;background:#D4DDF1;padding:1.5pt 7.0pt 1.5pt 3.0pt\'>
              <b><font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond;font-weight:bold\'>Blocker<o:p></o:p></span></font></b>
              </td>
              <td bgcolor="#D4DDF1" style=\'border:solid white 1.0pt;background:#D4DDF1;padding:1.5pt 7.0pt 1.5pt 3.0pt\'>
              <b><font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond;font-weight:bold\'>Release<o:p></o:p></span></font></b>
              </td>
              <td bgcolor="#D4DDF1" style=\'border:solid white 1.0pt;background:#D4DDF1;padding:1.5pt 7.0pt 1.5pt 3.0pt\'>
              <b><font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond;font-weight:bold\'>State<o:p></o:p></span></font></b>
              </td>
              <td bgcolor="#D4DDF1" style=\'border:solid white 1.0pt;background:#D4DDF1;padding:1.5pt 7.0pt 1.5pt 3.0pt\'>
              <b><font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond;font-weight:bold\'>Responsible<o:p></o:p></span></font>
              </td>
              <td bgcolor="#D4DDF1" style=\'border:solid white 1.0pt;background:#D4DDF1;padding:1.5pt 7.0pt 1.5pt 3.0pt\'>
              <b><font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond;font-weight:bold\'>Originator<o:p></o:p></span></font></b>
              
              </td>
                <td bgcolor="#D4DDF1" style=\'border:solid white 1.0pt;background:#D4DDF1;padding:1.5pt 7.0pt 1.5pt 3.0pt\'>
              <b><font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond;font-weight:bold\'>Scripts mapped<o:p></o:p></span></font></b>
              
              </td>
              <td bgcolor="#D4DDF1" style=\'border:solid white 1.0pt;background:#D4DDF1;padding:1.5pt 7.0pt 1.5pt 3.0pt\'>
              <b><font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond;font-weight:bold\'>test IDs<o:p></o:p></span></font></b>
              
              </td>
              <td bgcolor="#D4DDF1" style=\'border:solid white 1.0pt;background:#D4DDF1;padding:1.5pt 7.0pt 1.5pt 3.0pt\'>
              <b><font size=4 face=Garamond><span style=\'font-size:11.0pt;font-family:Garamond;font-weight:bold\'>VP<o:p></o:p></span></font></b>
              </td>
              </tr>
              </thead>
              ';

}
sub gethash_reg {
    my ($result_id) = @_;
    print $result_id."\n";

    my$query="
  select
  result_id,
  parent_result_id
  from
  er_regression_result
  where
  result_id in\($result_id\)";

my$d=db_get_one_row($query);

my$id=$d->{parent_result_id};

if($d->{parent_result_id}==0){
        $id=$d->{result_id};
}

 my $query1 = "
      select
      result_id,
      regression_exec_id,
      state,
      name,
      type,
      description,
      reg_status,
      regression_pr,
      owner,
      manual,
      merge_result_id,
      parent_result_id,
      createdby
     from
     er_regression_result
    where
(parent_result_id=$id or result_id=$id)
    order by
    result_id";
               
    my $query2 = "
    select
    a.test_exec_id,
    a.result_id,
    b.name as test_name,
    d.name as scen_name,
    b.synopsis,
    d.scenario_id,
    b.test_id,
    a.debug_exitcode,
    a.debug_log as reg_log,
    a.prs,
    a.reg_script_owner
    from
    er_debug_exec a, test b, test_exec c, scenario d, scenario_exec e
    where
    (c.regression_exec_id =  REG_EXEC_ID
     and a.display_flag = 1
     and c.test_exec_id = a.test_exec_id
     and c.test_id = b.test_id
     and e.scenario_exec_id = c.scenario_exec_id
     and e.scenario_id = d.scenario_id)";

    $query2 = $query2." order by a.test_exec_id";
 my $query2_tmp = $query2;

  my $query3 = "
       select
       a.test_exec_id,
       a.result_id,
       b.name as test_name,
       d.name as scen_name,
       b.synopsis,
       d.scenario_id,
       b.test_id,
       c.exitcode,
       a.reg_script_owner,
       a.reg_log
       from
       er_reg_pass_exec a, test b, test_exec c, scenario d, scenario_exec e
       where
       (c.regression_exec_id =  REG_EXEC_ID
        and c.test_id = b.test_id
        and c.test_exec_id = a.test_exec_id
        and e.scenario_exec_id = c.scenario_exec_id
        and e.scenario_id = d.scenario_id)";
       ###and d.name = 'mpls_multiple_link_protection'

    
       $query3 = $query3." order by a.test_exec_id";
       my $query3_tmp = $query3;

my @fail_id =();
my @pending_id=();
my @pending_name=();
    
       my @d1 = db_get_all_rows($query1);
       my %r;
       my $respin_id = 0;
       my $merge = 0;


    
       my $root = -1; #--- -1 key has all the script info
       my $total= -2; #--- -1 key has total info
       $r{$total}->{PASS} = 0;
       $r{$total}->{PENDING} = 0;
       $r{$total}->{FAIL} = 0;
       $r{$total}->{COUNT} = 0;
       $r{$total}->{TEST_EXECS} ={};

my @p = db_get_all_rows("select exitcode,count(test_id) from test_exec where exitcode in ('ABORT','CONNECT_FAIL','CONNECT_LOST','CORE_PASS','EXPECT_ERRORS','FAIL','IGP_FAIL','LINK_FAIL','PARAMS_FAIL','PASS','TC_RERUN_PASS','TEST_TIMEOUT','UNKNOWN_ERROR','UNTESTED') and regression_exec_id in (select b.regression_exec_id from er_regression_result a,er_regression_result b where a.result_id=$id and (a.result_id=b.parent_result_id or a.result_id=b.result_id)) group by exitcode");

#print Dumper(@p);

foreach $pi (@p)
{
  my $stitch = $pi->{exitcode};
  $r{$total}{REG}->{$stitch} = $pi->{count};
}
$r{$total}{REG_COUNT} = 0;
foreach (keys %{$r{$total}{REG}})
        {
         $r{$total}{REG_COUNT} += $r{$total}{REG}->{$_}; 
        }
print Dumper($r{$total}{REG});

#$r{$total}->{REG_RUN_COUNT} += $p[0]->{count};

  for (my $i=0; $i < (@d1); $i++) { #--- loop till all the respin

        my $tmp = $d1[$i]->{regression_exec_id}." ";

        $query2 =~ s/REG_EXEC_ID/$tmp/;
        $query3 =~ s/REG_EXEC_ID/$tmp/;

    
        #print "F<pre>".$query2."</pre>";
        #print "P<pre>".$query3."</pre>";
        my @d2 = db_get_all_rows($query2);
        $query2 = $query2_tmp;
        #my @d2;
        #my @d3;


        my @d3 = db_get_all_rows($query3);
        $query3 = $query3_tmp;

        #/* Fill the er_regression_result info first... */
        if ($d1[$i]->{merge_result_id} == 0) {
            $respin_id = $d1[$i]->{result_id};
            $merge = 0;
        } else {
            $respin_id = $d1[$i]->{merge_result_id};
            $merge = (@{$r{$respin_id}->{DR_ID}});
        }

        $r{$respin_id}->{DR_ID}[$merge] = $d1[$i]->{result_id};
        $r{$respin_id}->{REG_ID}[$merge] = $d1[$i]->{regression_exec_id};

        if ($d1[$i]->{merge_result_id} == 0) {
            $r{$respin_id}->{REG_INFO} = $d1[$i];
        }

        #---FAIL
        for (my $j=0; $j < (@d2); $j++) {

            #/* Fill the er_debug_exec... */
            my $key = $d2[$j]->{scen_name};
            my $s1 = $d2[$j]->{scenario_id};
            my $t1 = $d2[$j]->{test_id};
            my $r1 = $d2[$j]->{result_id};

            #--- copy the info to hash
            my $cp_flag = 1;
            foreach my $k (keys %{$r{$root}->{VIEW}{$key}}) {

                my $s2 = $r{$root}->{VIEW}{$key}{$k}->{scenario_id};
                my $t2 = $r{$root}->{VIEW}{$key}{$k}->{test_id};
                my $r2 = $r{$root}->{VIEW}{$key}{$k}->{result_id};

                if (($s1 == $s2) && ($t1 == $t2) && ($r1 == $r2)) {
                    $cp_flag = 0;
                }
            }
            if ($cp_flag == 1) {
                my $tmp = $d2[$j]->{test_name};
                push @{$r{$root}->{VIEW}{$key}{$tmp}}, $d2[$j];
                $r{$total}->{COUNT}++;
                $r{$total}->{TEST_EXECS}->{$d2[$j]->{test_exec_id}}->{test_id} = $d2[$j]->{test_id};
                $r{$total}->{TEST_EXECS}->{$d2[$j]->{test_exec_id}}->{scenario_id} = $d2[$j]->{scenario_id};
                if ($d2[$j]->{debug_exitcode} eq "FAIL") {
                    $r{$total}->{FAIL}++;
                    $r{$total}->{TEST_EXECS}->{$d2[$j]->{test_exec_id}}->{result} = 0;
                    push @fail_id , $d2[$j]->{test_id};
                } elsif ($d2[$j]->{debug_exitcode} eq "PASS") {
                    $r{$total}->{PASS}++;
                    $r{$total}->{TEST_EXECS}->{$d2[$j]->{test_exec_id}}->{result} = 1;
                } else {
                  $r{$total}->{PENDING}++;
                  push @pending_id , $d2[$j]->{test_id};
                  push @pending_name , $d2[$j]->{scen_name};
                }
            }

        }

        #---PASS
        for (my $j=0; $j < (@d3); $j++) {

            #/* Fill the er_reg_pass_exec... */
            my $key = $d3[$j]->{scen_name};
            my $s1 = $d3[$j]->{scenario_id};
            my $t1 = $d3[$j]->{test_id};
            my $r1 = $d3[$j]->{result_id};

            #--- copy the info to hash
            my $cp_flag = 1;
            foreach my $k (keys %{$r{$root}->{VIEW}{$key}}) {
                my $s2 = $r{$root}->{VIEW}{$key}{$k}->{scenario_id};
                my $t2 = $r{$root}->{VIEW}{$key}{$k}->{test_id};
                my $r2 = $r{$root}->{VIEW}{$key}{$k}->{result_id};
                if (($s1 == $s2) && ($t1 == $t2) && ($r1 == $r2)) {
                    $cp_flag = 0;
                }
            }
            if ($cp_flag == 1) {
                my $tmp = $d3[$j]->{test_name};
                push @{$r{$root}->{VIEW}{$key}{$tmp}}, $d3[$j];
                $r{$total}->{COUNT}++;
                $r{$total}->{TEST_EXECS}->{$d3[$j]->{test_exec_id}}->{test_id} = $d3[$j]->{test_id};
                $r{$total}->{TEST_EXECS}->{$d3[$j]->{test_exec_id}}->{scenario_id} = $d3[$j]->{scenario_id};
                $r{$total}->{TEST_EXECS}->{$d3[$j]->{test_exec_id}}->{result} = 1;
                $r{$total}->{PASS}++;
            }

        }

    } #--- loop till all the respin

 my $uid=0;
  $r{$total}->{PERCENTHASH} ={};
  $r{$total}->{ACTUALPASS} =0;
  $r{$total}->{ACTUALFAIL} =0;
  $r{$total}->{ACTUALCOUNT} =0;
    foreach my $tx ( sort keys %{$r{$total}->{TEST_EXECS}} ) {
        $uid = "$r{$total}->{TEST_EXECS}->{$tx}->{test_id}"."#"."$r{$total}->{TEST_EXECS}->{$tx}->{scenario_id}";
        $r{$total}->{PERCENTHASH}->{"$uid"} = $r{$total}->{TEST_EXECS}->{$tx}->{result};

    }
 foreach my $res (values %{$r{$total}->{PERCENTHASH}} ) {
             if ($res ==1) {
                 $r{$total}->{ACTUALPASS}++;
                 $r{$total}{ACTUALCOUNT}++;
             } else {
                 $r{$total}->{ACTUALFAIL}++;
                 $r{$total}{ACTUALCOUNT}++;
             }
 }

 if ($r{$total}{COUNT} == 0) {
     $r{$total}{PASS_PERCENTAGE} = 0;
     $r{$total}{ACTUAL_PASS_PERCENTAGE} = 0;
 } else {
     $r{$total}{PASS_PERCENTAGE} = int((($r{$total}{PASS} / $r{$total}{COUNT}) * 100) + .5);
     $r{$total}{ACTUAL_PASS_PERCENTAGE} = int((($r{$total}{ACTUALPASS} / $r{$total}{ACTUALCOUNT}) * 100) + .5);
 }
 $r{$total}{REG_FAIL} = $r{$total}->{ACTUALCOUNT} - $r{$total}{REG_PASS};
 
print "\n\n\n dumping pending list \n";

print Dumper (@pending_id);
print "\n-------------------------------------------\n";
print Dumper (@pending_name);

print "---------------------------------------------\n";
print Dumper (@fail_id);
 return (%r);
 }

