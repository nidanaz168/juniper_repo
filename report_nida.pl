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
my $dlmt = ":&:";
my $hostname = 'eabu-systest-db';
my $user = "postgres";
my $pass = "postgres";
my $port = "5432";
my $dsn = "dbi:Pg:database=regression;host=$hostname;port=$port";
my $dbh = DBI->connect($dsn,$user,$pass)
                or die "Couldn't connect to database ".DBI->errstr;
			set_dsn('readonly',{ user=>'readonly',host=>'ttpgdb.juniper.net', port=>6553});

my $dsn1 = "dbi:Pg:database=milestones;host=$hostname;port=$port";
my $dbh1 = DBI->connect($dsn1,$user,$pass)
                or die "Couldn't connect to database ".DBI->errstr;
my $total = -2;
my $tol = -1;
my $reg_img = "";
my $img_loc = "";
my $event_id = $ARGV[0];
my $pl_release = $ARGV[1];
my $releasestr = $ARGV[2];
my $function = $ARGV[3];
my $opnblkrsql = "";

$q = "delete from reg_openblocker_details where release = '$releasestr' and function = '$function'";
my $sth=$dbh->prepare($q);
$sth->execute;

### get the build date
$bd = getbuilddate($pl_release);
print  "BD=$bd\n";
if($bd =~ /^$/) ## if the build date is null take the first debug date
{
    $bd  = getfirstdebugdate($releasestr);
    print "$bd \n";
}
#Get the result_id and RM_id
@events = split(",",$event_id);
@res_id = ();
$result_id = "";
$today = `date "+%Y-%m-%d"`;
foreach $e(@events)
{
$e =~ s/\s+//g;

my $eid_query= "select result_id from er_regression_result where (name= '$e' and parent_result_id='0')";
print $eid_query."\n";

@res = db_get_all_rows($eid_query);
foreach $r(@res)
{
	push @res_id , $r->{result_id}
}
}
print "@res_id \n";
##### Now from the TL9000 Page pull out the summary for these Debug ids #####################################
$totalexecuted = 0;
$totaltcexecuted = 0;
$totalpassed=0;
$totaltcpassed=0;
$totalfailed=0;
$totaltcfailed=0;
$totalpending=0;
$totaldebug=0;
$totalcompleted=0;
$totalfirstrunscript = 0;
$totalfirstrunpass = 0;
$totalrespindebug = 0;
$totalrespindebugpending = 0;
%outstandingprs =  (count => 0,prs => '');
%outstandingprhash = ();
%allprs = ();
%allprshash = ();
%dbg_brk_hash = ();
	%script_hit = ();
$debug_id_str = "";

$cred = `cat /opt/Dashboard/data/test-engineering/project/password/password`;
@credentials = split(/@@/,$cred);

our $userid = $credentials[0];
our $password = $credentials[1];
our $paswdunix = $credentials[2];

foreach $debugid(@res_id)
{
	print "$debugid \n";
	$url = "wget -o log -O out.$$ --http-user=$userid --no-check-certificate --http-password=\"$password\" \"https://systest.juniper.net/ti/webapp/dr/debug_dr/index.mhtml?mode=5:7:0&result_id=$debugid\"";
	print "$url \n";
	$debug_id_str .= "$debugid,";
    $out  = `$url`;
    $out = `grep  -a "First Run Raw Pass Rate.*(excluding transition scripts)" out.$$`;
	($scriptstats) = $out =~ /\((.*?)\)/;
	($firstrunpass) = $scriptstats =~ /(.*)\//;
	($firstrunscript) = $scriptstats =~ /\/(.*)/;
	chomp($firstrunscript);
	chomp($firstrunpass);
	$totalfirstrunscript += $firstrunscript;
	$totalfirstrunpass += $firstrunpass;

	$out  = `wget -o log -O out.$$ --http-user=$userid --no-check-certificate --http-password=\"$password\" "https://systest.juniper.net/ti/webapp/dr/debug_dr/view/gen_tl9k_report_summary.mhtml?result_id=$debugid"`;
	$out = `grep -a -m 1 "ACTUAL PASS" out.$$`;
	($actualpass) = $out =~ /=(.*)%/;
	$out = `grep -a -m 1 "Unique Script count" out.$$`;
	($uniqscriptcount) = $out =~ /=(.*)/;
	chomp($uniqscriptcount);
	$totalexecuted += $uniqscriptcount;
	$out = `grep -a -m 1 "Unique (latest respin) Pass count" out.$$`;
	($uniqpasscount) = $out =~ /=(.*)/;
	chomp($uniqpasscount);
	$totalpassed += $uniqpasscount;
	$out = `grep -a -m 1 "Unique (latest respin) Failure count (including pending)" out.$$`;
	($uniqfailcount) = $out =~ /=(.*)/;
        @tempo1234 = db_get_all_rows("select count\(*\) from er_debug_exec where debug_exitcode='-' and result_id in \(select result_id from er_regression_result where \(result_id = $debugid or parent_result_id=$debugid or merge_result_id=$debugid\)\) and display_flag=1");
        $pending_debugs=$tempo1234[0]->{count};
        $failedscripts = $uniqfailcount-$pending_debugs;
#	($failedscripts) = $out =~ /- <\/b>(.*)/;
	chomp($failedscripts);
	$totalfailed += $failedscripts;
	$out = `grep -a -m 1 "Scripts failed Due to PRs -" out.$$`;
	##### Sooraj Test case statistics ####################
	$out = `grep -a -m 1 "Total Number of Testcases count" out.$$`;
	($uniqtccount) = $out =~ /=(.*)/;
	$totaltcexecuted += $uniqtccount;
	$out = `grep -a -m 1 "Total Number of Testcases Pass" out.$$`;
	($uniqtcpasscount) = $out =~ /=(.*)/;
	$totaltcpassed += $uniqtcpasscount;
	$out = `grep -a -m 1 "Total Number of Testcases Fail" out.$$`;
	($uniqtcfailcount) = $out =~ /=(.*)/;
	$totaltcfailed += $uniqtcfailcount;
			
	###### to find debug get it from other page #############################
	$out  = `wget -o log -O fdbg.$$ --http-user=$userid --no-check-certificate --http-password=\"$password\" "https://systest.juniper.net/ti/webapp/dr/debug_dr/index.mhtml?result_id=$debugid&mode=5:0:0"`;
	#####  We can do this by parsing the HTML table which is having the PR Details #############################
    $te = HTML::TableExtract->new(attribs => { id => summary } );
    $te->parse_file("fdbg.$$");
    foreach $ts ($te->tables) {
    @rc =   $ts->rows;
    @cc = $ts->columns;
    $rcnt = @rc;
    $ccnt = @cc;
    $cnt = 0;
    $t = $ts->rows->[0];
    if($t->[0] !~ /OWNER/) { next;}
    foreach $row ($ts->rows) {
        if($row->[0] !~ /TOTAL/) { next;}
        $actualdebug = $row->[1];
        $pendingdebugs = $row->[2];
        }
   }
	
	#$out = `grep -a -m 1 "Scripts pending debugging -" out`;
	#($pendingdebugs) = $out =~ /- <\/b>(.*)/;
	chomp($pendingdebugs);
	chomp($actualdebug);
	#$totalpending += $pendingdebugs;
	#$totaldebug += $actualdebug;
	#$completed = $actualdebug - $pendingdebugs;
	#$totalcompleted += $completed;
	#print " $totalpending,$totaldebug,$totalcompleted \n";
	
	####### Get the PR Details now #################################
	######### For this first the TL9000 table need to be parsed
	#####  We can do this by parsing the HTML table which is having the PR Details #############################
	$te = HTML::TableExtract->new(attribs => { border => "1" } );
	$te->parse_file("out.$$");
	foreach $ts ($te->tables) {
    @rc =   $ts->rows;
    @cc = $ts->columns;
    $rcnt = @rc;
    $ccnt = @cc;
    $cnt = 0;
	$t = $ts->rows->[0];
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
		$outstandingprs{count}++;
		$outstandingprs{prs} .= "$pr," ;
		$outstandingprhash{$pr} = 1;
        }
   }
	#### Now get the All prs from the  debug page ########################
	##### This is there in another URL ###################################
	$url = "wget -o log -O prs.$$ --http-user=$userid --no-check-certificate --http-password=\"$password\" \"https://systest.juniper.net/ti/webapp/dr/debug_dr/index.mhtml?mode=0:1:0&result_id=$debugid\"";
        print "hit = $url \n";
	$all_prs  = `$url`;
	$te = HTML::TableExtract->new(attribs => { id => "table1" } );
	$te->parse_file("prs.$$");
	foreach $ts ($te->tables) {
    @rc =   $ts->rows;
    @cc = $ts->columns;
    $rcnt = @rc;
    $ccnt = @cc;
    $cnt = 0;
    foreach $row ($ts->rows) {
        if($row->[0] =~ /PR/) { next;}
        $pr = $row->[0];
        chomp($pr);
        $pr =~ s/N|n//g;
        $pr =~ s/O|o//g;
        $pr =~ s/-//g;
        if($pr =~ /^$/) { next;}
        if(exists $allprshash{$pr}) { next;}
        $allprs{count}++;
        $allprs{prs} .= "$pr," ;
        $allprshash{$pr} = 1;
		$script_hit{$pr} = $row->[10];
        }
   }
	#### Now get ther reression failure break down table #####################
	#### It is again picked from Debug page #####################################
	$url = "wget -o log -O debugbreak.$$ --http-user=$userid --no-check-certificate --http-password=\"$password\" \"https://systest.juniper.net/ti/webapp/dr/debug_dr/index.mhtml?mode=0:0:2&result_id=$debugid\"";
	$dbg_brk  = `$url`;
	$te = HTML::TableExtract->new(attribs => { id => "table1" } );
    $te->parse_file("debugbreak.$$");
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
		if(!exists $dbg_brk_hash{$cat}) { $dbg_brk_hash{$cat} = $count;}
		else { $dbg_brk_hash{$cat} += $count;}
        }
   }
	####### Get the Respin Data
	$url = "wget -o log -O respin.$$ --http-user=$userid --no-check-certificate --http-password=\"$password\" \"https://systest.juniper.net/ti/webapp/dr/debug_dr/index.mhtml?mode=0:0:0&result_id=$debugid\"";
	$dbg_brk  = `$url`;
	$te = HTML::TableExtract->new(attribs => { id => table1 } );
    $te->parse_file("respin.$$");
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
			$totalpending += $row->[8];
			$totaldebug += $row->[1];
			$completed = $totaldebug - $totalpending;
			$totalcompleted = $completed;
		next;}
        $respindebug += $row->[1];
        $respinpending += $row->[8];
		$totalrespindebug = $respindebug; 
		$totalrespindebugpending = $respinpending;
        }
   }
	
	
		
$out  = `wget -o log -O out --http-user=$userid --no-check-certificate --http-password=\"$password\" http://www-systest.juniper.net/ti/webapp/dr/debug_dr/view/gen_tl9000_report.mhtml?result_id=$debugid&trans=remove`;
print "wget -o log -O out.$$ --http-user=$userid --no-check-certificate --http-password=\"$password\" http://www-systest.juniper.net/ti/webapp/dr/debug_dr/view/gen_tl9000_report.mhtml?result_id=$debugid&trans=remove\n";
$te = HTML::TableExtract->new( attribs => { id => "table1" } );
 $te->parse_file("out.$$");
 foreach $ts ($te->tables) {
    @rc =   $ts->rows;
    @cc = $ts->columns;
    $rcnt = @rc;
    $ccnt = @cc;
    $cnt = 0;
   foreach $row ($ts->rows) {
       my $test_id = "";
       $stat_found = 0;
            for($i=0;$i<$ccnt;$i++)
            {
				chomp($row->[$i]);$row->[$i] =~ s/\s//g;
                if($i == 0) ###### Scenario
                {
                    ($test_id) = $row->[$i] =~ /Stable_(.*?)_/;  ## For MMX This holds good
                    if($test_id =~ /^$/)
                    {
                        $test_id = getTestIdFromScriptName($row->[$i]); ### For Other

                    }
                }

                if($i > 1) ### Means Executing Status Column
                {
					
                    if(($row->[$i] =~ /F/)) #### Faile
                    {
                        $test_hash{$test_id}{result} = "FAIL";
                        ($prs) = $row->[$i] =~ /F(.*)/;
                        $test_hash{$test_id}{prs} = $prs;
                        $stat_found = 1;
                    }
					else
					{
						$test_hash{$test_id}{result} = "PASS";
                        ($prs) = $row->[$i] =~ /F(.*)/;
                        $test_hash{$test_id}{prs} = $prs;
                        $stat_found = 1;
					}
                }
            }

   }
 }
}	
$query = "delete from script_pr where release='$releasestr' and function='$function'";
print $query;
my $sth=$dbh->prepare($query);
$sth->execute;
foreach $tid(keys %test_hash)
{
	if($tid =~ /^$|^\s+$/) { next;}
	$query = "insert into script_pr values('$releasestr','$tid','$test_hash{$tid}{prs}','$function')";
$sth=$dbh->prepare($query);
$sth->execute;
}

sub getTestIdFromScriptName
{
    my $scenario_script = shift;
    my $script = "";
    if($scenario_script =~ /\//)
    {
        ($script) = $scenario_script =~ /\/(.*)/;
    }
    else
    {
        ($script) = $scenario_script;
    }
	my $hostname = 'eabu-systest-db';
my $user = "postgres";
my $pass = "postgres";
my $port = "5432";
	my $dsn = "dbi:Pg:database=eabu_rod;host=$hostname;port=$port";
	my $dbh = DBI->connect($dsn,$user,$pass)
                or die "Couldn't connect to database ".DBI->errstr;
    my $query = "select test_id from script_owner where script like '%$script'";
    my $sth=$dbh->prepare($query);
    $sth->execute;
     my $r=$sth->fetchall_arrayref({});
    foreach my $ar(@{$r})
    {
        return $ar->{test_id};
    }
}

chop($debug_id_str);
$prstr = $outstandingprs{prs};
$allprstr = $allprs{prs};
#$allprstr =~ s/,/ /g;
#$prstr =~ s/,/ /g;
$prstr .= " $allprstr";
chomp($prstr);
$prstr =~ s/\s+//g;
$prstr =~ s/,/ /g;
print "prstr is $prstr \n";
if($prstr !~ /^$/)
{
@allprs = `/usr/local/bin/query-pr $prstr  --format '"%s:&:&:%Q:&:&:%80.80s:&:&:%s:&:&:%s:&:&:%s:&:&:%s:&:&:%s:&:&:%s:&:&:%s:&:&:%s:&:&:%s:&:&:%s:&:&:" Number Arrival-Date Synopsis Reported-In Class Category Blocker Planned-Release Problem-Level Dev-Owner Responsible Originator State'`;
}
###### PR Table ###############################
$allbuff = "<br><center><table class='table table-bordered tablesorter table-striped'><thead><tr><th colspan=13>All PR details</th></tr><tr><th>Number</th><th>Arrival-Date</th><th>Synopsis</th><th>Reported-In</th><th>Class</th><th>State</th><th>Problem-Level</th><th>Category</th><th>Blocker</th><th>Dev-Owner</th><th>Responsible</th><th>Originator</th><th>HIT</th></tr><tbody><allprs>";
$blockerbuff = "<br><center><table class='table table-bordered tablesorter table-striped'><col width='20px' /><col width='20px' /><col width='20px' /><thead><tr><th colspan=13>Blocker PR details</th></tr><tr><th>Number</th><th>Arrival-Date</th><th>Synopsis</th><th>Reported-In</th><th>Class</th><th>State</th><th>Problem-Level</th><th>Category</th><th>Blocker</th><th>Dev-Owner</th><th>Responsible</th><th>Originator</th><th>HIT</th></tr><tbody><blockerprs>";
$newbuff = "<br><center><table class='table table-bordered tablesorter table-striped'><thead><tr><th colspan=13>New PR details</th></tr><tr><th>Number</th><th>Arrival-Date</th><th>Synopsis</th><th>Reported-In</th><th>Class</th><th>State</th><th>Problem-Level</th><th>Category</th><th>Blocker</th><th>Dev-Owner</th><th>Responsible</th><th>Originator</th><th>HIT</th></tr><tbody><newprs>";
$blockeropenbuff = "<br><center><table class='table table-bordered tablesorter table-striped'><col width='20px' /><col width='20px' /><col width='20px' /><thead><tr><th colspan=13>Open Blocker PR details</th></tr><tr><th>Number</th><th>Arrival-Date</th><th>Synopsis</th><th>Reported-In</th><th>Class</th><th>State</th><th>Problem-Level</th><th>Category</th><th>Blocker</th><th>Dev-Owner</th><th>Responsible</th><th>Originator</th><th>HIT</th></tr><tbody><openblockerprs>";
$prel = $pl_release;
$prel =~ s/\./\\./g;
%allprhash = ();
%cathash = ();
%blockerprhash = ();
%openblockerprhash = ();
%newprhash = ();
$allcount = 0;
$blockercount = 0;
$nonblockercount = 0;
$openblockercount = 0;
$newcount = 0;
foreach $pr(@allprs)
{
    @tmp = split(":&:&:",$pr);
    $pr = $tmp[0];
    ($ad) = $tmp[1] =~ /(.*)\s+/;
	chomp($tmp[2]);
    $tmp[2] = quotemeta($tmp[2]);

    ($prnumber) = $pr =~ /(.*)-/;
    if(!exists $allprhash{$prnumber})
    {
        $allbuff .= "<tr><td><a href='https://gnats.juniper.net/web/default/$tmp[0]' target='blank'>$tmp[0]</a></td><td>$ad</td><td class='synopsis'>$tmp[2]</td><td class='plrelease'>$tmp[3]</td><td>$tmp[4]</td><td>$tmp[12]</td><td>$tmp[8]</td><td>$tmp[5]</td><td>$tmp[6]</td><td>$tmp[9]</td><td>$tmp[10]</td><td>$tmp[11]</td><td>$script_hit{$prnumber}</td></tr>";








        if(!exists $allprhash{$prnumber})
        {
            $allprhash{$prnumber} = 1;
            $allcount++;
        }
        $cathash{$tmp[5]}++;
    }
    ### Check for Arrival date is more  greater than Build date
    $diff =  getdiff($bd , $ad);

    if($diff > 0)
    {
        if(!exists $newprhash{$prnumber})
        {
			$newbuff .= "<tr><td><a href='https://gnats.juniper.net/web/default/$tmp[0]' target='blank'>$tmp[0]</a></td><td>$ad</td><td class='synopsis'>$tmp[2]</td><td class='plrelease'>$tmp[3]</td><td>$tmp[4]</td><td>$tmp[12]</td><td>$tmp[8]</td><td>$tmp[5]</td><td>$tmp[6]</td><td>$tmp[9]</td><td>$tmp[10]</td><td>$tmp[11]</td><td>$script_hit{$prnumber}</td></tr>";
            $newprhash{$prnumber} = 1;
            $newcount++;
        }

    }
    if(($tmp[7] =~ $prel) && ( $tmp[6] !~ /^$/))
    {
        if(!exists $blockerprhash{$prnumber})
        {
        $blockerbuff .= "<tr><td><a href='https://gnats.juniper.net/web/default/$tmp[0]' target='blank'>$tmp[0]</a></td><td>$ad</td><td class='synopsis'>$tmp[2]</td><td class='plrelease'>$tmp[3]</td><td>$tmp[4]</td><td>$tmp[12]</td><td>$tmp[8]</td><td>$tmp[5]</td><td>$tmp[6]</td><td>$tmp[9]</td><td>$tmp[10]</td><td>$tmp[11]</td><td>$script_hit{$prnumber}</td></tr>";
        $blockerprhash{$prnumber} = 1;
            $blockercount++;
        }
		if($tmp[12] =~ /open|info|analyzed|assigned|awaiting-build|under-analysis|try-fix|need-setup|ready-to-commit|under-review/)
        {
        $blockeropenbuff .= "<tr><td><a href='https://gnats.juniper.net/web/default/$tmp[0]' target='blank'>$tmp[0]</a></td><td>$ad</td><td class='synopsis'>$tmp[2]</td><td class='plrelease'>$tmp[3]</td><td>$tmp[4]</td><td>$tmp[12]</td><td>$tmp[8]</td><td>$tmp[5]</td><td>$tmp[6]</td><td>$tmp[9]</td><td>$tmp[10]</td><td>$tmp[11]</td><td>$script_hit{$prnumber}</td></tr>";
        $openblockerprhash{$prnumber} = 1;
            $openblockercount++;
            $opnblkrsql = "insert into reg_openblocker_details(release,function,prnumber,arrival_date,synopsis,reported_in,class,state,pl,category,blocker,dev_owner,resp,originator,hit) values('$releasestr','$function','$tmp[0]','$ad','$tmp[2]','$tmp[3]','$tmp[4]','$tmp[12]','$tmp[8]','$tmp[5]','$tmp[6]','$tmp[9]','$tmp[10]','$tmp[11]','$script_hit{$prnumber}');\n";
           print $opnblkrsql;
            $sth=$dbh->prepare($opnblkrsql); 
           $sth->execute();
        }

    }
	else
	{
		$nonblockercount++;
	}
}
$query = "delete from regressionprcategories where release='$releasestr' and function='$function'";
$sth=$dbh->prepare($query);
$sth->execute;
foreach $cat(keys %cathash)
{
$query = "insert into regressionprcategories values('$releasestr','$function','$cat',$cathash{$cat})";
$sth=$dbh->prepare($query);
$sth->execute;
}

$plannedscripts = 0;
$query = "select scriptplanned from regressionreport where releasename='$releasestr' and function='$function'";
my $sth=$dbh->prepare($query);
    $sth->execute;
     my $r=$sth->fetchall_arrayref({});
	foreach my $ar(@{$r})
    {
		$plannedscripts = $ar->{scriptplanned};
	}
		

$per_pass = 0;
$per_fail = 0;
	$rawpassrate = 0;
	if($totalexecuted 	>0)
	{
	$per_pass = sprintf "%.2f",($totalpassed / $totalexecuted ) * 100;   ### Changing to executed as per Rahul's input
}  else {
		 #exit;
                $per_pass = 0;
	 }
	$planned_pass = 0;
	if( $plannedscripts > 0)
	{
	$planned_pass = sprintf "%.2f",($totalpassed / $plannedscripts ) * 100;   ### Changing to executed as per Rahul's input
	}
	if($totalexecuted   >0)
	{
	$per_fail = sprintf "%.2f",($totalfailed / $totalexecuted ) * 100;   ### Changing to executed as per Rahul's input
	}
$tcper_pass = 0;
$tcper_fail = 0;
	$rawpassrate = 0;
	if($totaltcexecuted 	>0)
	{
	$tcper_pass = sprintf "%.2f",($totaltcpassed / $totaltcexecuted ) * 100;   ### Changing to executed as per Rahul's input
}  else {
		 #exit;
                $tcper_pass = 0;
	 }
	if($totaltcexecuted   >0)
	{
	$tcper_fail = sprintf "%.2f",($totaltcfailed / $totaltcexecuted ) * 100;   ### Changing to executed as per Rahul's input
	}
	if($totalfirstrunscript > 0)
	{	
		$rawpassrate = sprintf "%.0f",($totalfirstrunpass / $totalfirstrunscript ) * 100;
	}
	if($totaldebug > 0)
	{
		$debugper = sprintf "%.0f",($totalcompleted/$totaldebug) * 100;
	}
	else
	{
		$debugper = sprintf "%.0f",0;
	}
	if(defined($outstandingprs{count})) { $totalprs = $outstandingprs{count};} else { $totalprs = 0;}
	if(defined($allprs{count})) { $totaloutstandingprs = $allprs{count};} else { $totaloutstandingprs = 0;}
##### Respin calculation
$totalrespincompleted = $totalrespindebug - $totalrespindebugpending;
if($totalrespindebug > 0)
{
	$per_respin_debug = sprintf "%.2f",($totalrespincompleted / $totalrespindebug ) * 100;   ### Changing to executed as per Rahul's input
}
else
{
	$per_respin_debug = 0;
}


	

$query = "update regressionreport set scriptexecuted=$totalexecuted,firstrunpassrate=$rawpassrate,overallpassrate=$per_pass,plannedpassrate=$planned_pass,overallfailrate=$per_fail,allprs=$allcount,newprs=$newcount,blockerprs=$blockercount,tobedebugged=$totalpending,totalscriptpassed=$totalpassed,totalscriptfailed=$totalfailed ,totaldebugcount=$totaldebug,completeddebugcount=$totalcompleted,debugper=$debugper,totalfirstrunpass=$totalfirstrunpass,totalfirstrunscript=$totalfirstrunscript,respindebugcount=$totalrespindebug,respincompleteddebug=$totalrespincompleted,respinpendingdebug=$totalrespindebugpending,respincompleteddebugper=$per_respin_debug,openblockerprs=$openblockercount,debugids='$debug_id_str',nonblockerprs=$nonblockercount ,tcexecuted=$totaltcexecuted ,totaltcpassed=$totaltcpassed,totaltcfailed=$totaltcfailed , tcpassrate=$tcper_pass,tcfailrate=$tcper_fail where releasename='$releasestr' and function='$function'";
        my $sth=$dbh->prepare($query);
        $sth->execute;
######## Update the PRs Table ##########################################################
$query = "delete from regressionprs where releasename='$releasestr' and function='$function'";
my $sth=$dbh->prepare($query);
$sth->execute;
$query = "insert into regressionprs values('$releasestr','$function',$totaloutstandingprs,$totalprs,'$allprs{prs}','$outstandingprs{prs}')";
$sth=$dbh->prepare($query);
$sth->execute;

$query = "delete from regression_failure_breakdown where releasename='$releasestr' and function='$function'";
my $sth=$dbh->prepare($query);
$sth->execute;
foreach $br(sort keys %dbg_brk_hash)
{
	$query = "insert into regression_failure_breakdown values('$releasestr','$function','$br',$dbg_brk_hash{$br})";
	$sth=$dbh->prepare($query);
	$sth->execute;
}


##### now Create table and graphs for the report
#### Create table first #######################
### Read the data from the database
#@functions = ('MMX','T/TX/PTX','ACX','BBE','Protocols','ESBU','RPD','JUNOS SW');
@functions = ();

$sqlqry = "select distinct function from regressionreport where releasename in ('$releasestr') order by function asc";
$sqlsth=$dbh->prepare($sqlqry);
$sqlsth->execute;
my $r=$sqlsth->fetchall_arrayref({});
foreach my $ar(@{$r}){
    $f = $ar->{function};
    push(@functions, $f);
}


%hash = ();
###### Initialize the total hash ##############################
$hash{total}{scriptplanned} = 0;
$hash{total}{scriptexecuted} = 0;
$hash{total}{tcexecuted} = 0;
$hash{total}{firstrunpassrate} = 0;
$hash{total}{overallpassrate} = 0;
$hash{total}{plannedpassrate} = 0;
$hash{total}{overallfailrate} = 0;
$hash{total}{tcpassrate} = 0;
$hash{total}{tcfailrate} = 0;
$hash{total}{newprs} = 0;
$hash{total}{allprs} = 0;
$hash{total}{blockerprs} = 0;
$hash{total}{tobedebugged} = 0;
$hash{total}{totaldebugcount} = 0;
$hash{total}{completeddebugcount} = 0;
$hash{total}{debugper} = 0;
$hash{total}{totalscriptfailed} = 0;
$hash{total}{totalscriptpassed} = 0;
$hash{total}{executionrate} = 0;
$hash{total}{totaltcfailed} = 0;
$hash{total}{totaltcpassed} = 0;

##### Routing Total
$hash{routing}{scriptplanned} = 0;
$hash{routing}{scriptexecuted} = 0;
$hash{routing}{tcexecuted} = 0;
$hash{routing}{firstrunpassrate} = 0;
$hash{routing}{overallpassrate} = 0;
$hash{routing}{tcpassrate} = 0;
$hash{routing}{tcfailrate} = 0;
$hash{routing}{plannedpassrate} = 0;
$hash{routing}{overallfailrate} = 0;
$hash{routing}{outstandingprs} = 0;
$hash{routing}{allprs} = 0;
$hash{routing}{newprs} = 0;
$hash{routing}{blockerprs} = 0;
$hash{routing}{totaldebugcount} = 0;
$hash{routing}{completeddebugcount} = 0;
$hash{routing}{debugpedebugper} = 0;
$hash{routing}{totalscriptfailed} = 0;
$hash{routing}{totalscriptpassed} = 0;
$hash{routing}{totaltcfailed} = 0;
$hash{routing}{totaltcpassed} = 0;
$hash{routing}{executionrate} = 0;

##### Switching Total
$hash{switching}{scriptplanned} = 0;
$hash{switching}{scriptexecuted} = 0;
$hash{switching}{tcexecuted} = 0;
$hash{switching}{firstrunpassrate} = 0;
$hash{switching}{overallpassrate} = 0;
$hash{switching}{tcpassrate} = 0;
$hash{switching}{tcfailrate} = 0;
$hash{switching}{plannedpassrate} = 0;
$hash{switching}{overallfailrate} = 0;
$hash{switching}{outstandingprs} = 0;
$hash{switching}{allprs} = 0;
$hash{switching}{newprs} = 0;
$hash{switching}{blockerprs} = 0;
$hash{switching}{totaldebugcount} = 0;
$hash{switching}{completeddebugcount} = 0;
$hash{switching}{debugpedebugper} = 0;
$hash{switching}{totalscriptfailed} = 0;
$hash{switching}{totalscriptpassed} = 0;
$hash{switching}{totaltcfailed} = 0;
$hash{switching}{totaltcpassed} = 0;
$hash{switching}{executionrate} = 0;
$funccount = 0;
$breakcolcount = 2;
$junosfound = 0;
$esbufound = 0;
foreach $func(@functions)
{
	$query = " select scriptplanned,scriptexecuted,firstrunpassrate,overallpassrate,overallfailrate,newprs,allprs,blockerprs,tobedebugged,totalscriptpassed,totalscriptfailed,totaldebugcount,completeddebugcount,debugper,totalfirstrunpass,totalfirstrunscript,respindebugcount,respincompleteddebug,respinpendingdebug,respincompleteddebugper,openblockerprs,debugstart,debugend,plannedpassrate,debugids,tcexecuted,totaltcpassed,totaltcfailed,tcpassrate,tcfailrate from regressionreport where releasename='$releasestr' and function='$func'";
    my $sth=$dbh->prepare($query);
    $sth->execute;
     my $r=$sth->fetchall_arrayref({});
	$c= 0;
	
    foreach my $ar(@{$r})
    {
	#### Calculate execution rate here
	
	$executionrate = 0;	
	if($ar->{scriptplanned} > 0)
	{
	$executionrate = sprintf "%.0f",($ar->{scriptexecuted}/$ar->{scriptplanned})*100;
}
			$hash{$func}{scriptplanned} = $ar->{scriptplanned};
			$hash{$func}{scriptexecuted} = $ar->{scriptexecuted};
			$hash{$func}{tcexecuted} = $ar->{tcexecuted};
			$hash{$func}{firstrunpassrate} = $ar->{firstrunpassrate};
			$hash{$func}{overallpassrate} = $ar->{overallpassrate};
			$hash{$func}{tcpassrate} = $ar->{tcpassrate};
			$hash{$func}{tcfailrate} = $ar->{tcfailrate};
			$hash{$func}{plannedpassrate} = $ar->{plannedpassrate};
			$hash{$func}{overallfailrate} = $ar->{overallfailrate};
			$hash{$func}{debugstart} = $ar->{debugstart};
			$hash{$func}{debugend} = $ar->{debugend};
			$hash{$func}{newprs} = $ar->{newprs};
			$hash{$func}{allprs} = $ar->{allprs};
			$hash{$func}{blockerprs} = $ar->{blockerprs};
			$hash{$func}{openblockerprs} = $ar->{openblockerprs};
			$hash{$func}{tobedebugged} = $ar->{tobedebugged};
			$hash{$func}{totaldebugcount} = $ar->{totaldebugcount};
			$hash{$func}{completeddebugcount} = $ar->{completeddebugcount};
			$hash{$func}{debugper} = $ar->{debugper};
			$hash{$func}{debugids} = $ar->{debugids};
			$hash{$func}{totalscriptfailed} = $ar->{totalscriptfailed};
			$hash{$func}{totalscriptpassed} = $ar->{totalscriptpassed};
			$hash{$func}{totaltcfailed} = $ar->{totaltcfailed};
			$hash{$func}{totaltcpassed} = $ar->{totaltcpassed};
			$hash{$func}{totalfirstrunpass} = $ar->{totalfirstrunpass};
			$hash{$func}{totalfirstrunscript} = $ar->{totalfirstrunscript};
			$hash{$func}{respindebugcount} = $ar->{respindebugcount};
            $hash{$func}{respincompleteddebug} = $ar->{respincompleteddebug};
            $hash{$func}{respinpendingdebug} = $ar->{respinpendingdebug};
            $hash{$func}{respincompleteddebugper} = $ar->{respincompleteddebugper};
			
			$hash{$func}{executionrate} = $executionrate;
			######################## Update Total Hash here ###############################
			$hash{total}{scriptplanned} += $ar->{scriptplanned};
			$hash{total}{scriptexecuted} += $ar->{scriptexecuted};
			$hash{total}{tcexecuted} += $ar->{tcexecuted};
			$hash{total}{firstrunpassrate} += $ar->{firstrunpassrate};
			$hash{total}{overallpassrate} += $ar->{overallpassrate};
			$hash{total}{tcpassrate} += $ar->{tcpassrate};
			$hash{total}{tcfailrate} += $ar->{tcfailrate};
			$hash{total}{plannedpassrate} += $ar->{plannedpassrate};
			$hash{total}{overallfailrate} += $ar->{overallfailrate};
			$hash{total}{debugstart} = "";
			$hash{total}{debugend} = "";
			$hash{total}{newprs} += $ar->{newprs};
			$hash{total}{allprs} += $ar->{allprs};
			$hash{total}{blockerprs} += $ar->{blockerprs};
			$hash{total}{openblockerprs} += $ar->{openblockerprs};
			$hash{total}{tobedebugged} += $ar->{tobedebugged};
			$hash{total}{totaldebugcount} += $ar->{totaldebugcount};
			$hash{total}{completeddebugcount} += $ar->{completeddebugcount};
			$hash{total}{totalscriptfailed} += $ar->{totalscriptfailed};
			$hash{total}{totalscriptpassed} += $ar->{totalscriptpassed};
			$hash{total}{totaltcfailed} += $ar->{totaltcfailed};
			$hash{total}{totaltcpassed} += $ar->{totaltcpassed};
			$hash{total}{totalfirstrunpass} += $ar->{totalfirstrunpass};
			$hash{total}{totalfirstrunscript} += $ar->{totalfirstrunscript};
			$hash{total}{executionrate} += $executionrate ;
			$hash{total}{respindebugcount} += $ar->{respindebugcount};
            $hash{total}{respincompleteddebug} += $ar->{respincompleteddebug};
            $hash{total}{respinpendingdebug} += $ar->{respinpendingdebug};
            $hash{total}{respincompleteddebugper} += $ar->{respincompleteddebugper};
			######################## Update RBU Total Hash here ###############################
			if($func =~ /MMX|PTX|ESBU|BBE|ACX|JUNOS|RPD|ROUTING NPIs|ROUTING VIRTUAL/)
			{
			$hash{routing}{scriptplanned} += $ar->{scriptplanned};
			$hash{routing}{scriptexecuted} += $ar->{scriptexecuted};
			$hash{routing}{tcexecuted} += $ar->{tcexecuted};
			$hash{routing}{firstrunpassrate} += $ar->{firstrunpassrate};
			$hash{routing}{overallpassrate} += $ar->{overallpassrate};
			$hash{routing}{tcpassrate} += $ar->{tcpassrate};
			$hash{routing}{tcfailrate} += $ar->{tcfailrate};
			$hash{routing}{plannedpassrate} += $ar->{plannedpassrate};
			$hash{routing}{overallfailrate} += $ar->{overallfailrate};
			$hash{routing}{debugstart} = "";
			$hash{routing}{debugend} = "";
			$hash{routing}{newprs} += $ar->{newprs};
			$hash{routing}{allprs} += $ar->{allprs};
			$hash{routing}{blockerprs} += $ar->{blockerprs};
			$hash{routing}{openblockerprs} += $ar->{openblockerprs};
			$hash{routing}{tobedebugged} += $ar->{tobedebugged};
			$hash{routing}{totaldebugcount} += $ar->{totaldebugcount};
			$hash{routing}{completeddebugcount} += $ar->{completeddebugcount};
			$hash{routing}{totalscriptfailed} += $ar->{totalscriptfailed};
			$hash{routing}{totalscriptpassed} += $ar->{totalscriptpassed};
			$hash{routing}{totaltcfailed} += $ar->{totaltcfailed};
			$hash{routing}{totaltcpassed} += $ar->{totaltcpassed};
			$hash{routing}{totalfirstrunpass} += $ar->{totalfirstrunpass};
			$hash{routing}{totalfirstrunscript} += $ar->{totalfirstrunscript};
			$hash{routing}{executionrate} += $executionrate ;
			$hash{routing}{respindebugcount} += $ar->{respindebugcount};
                        $hash{routing}{respincompleteddebug} += $ar->{respincompleteddebug};
                        $hash{routing}{respinpendingdebug} += $ar->{respinpendingdebug};
                        $hash{routing}{respincompleteddebugper} += $ar->{respincompleteddebugper};
                        }
			else
			{
			$hash{switching}{scriptplanned} += $ar->{scriptplanned};
			$hash{switching}{scriptexecuted} += $ar->{scriptexecuted};
			$hash{switching}{tcexecuted} += $ar->{tcexecuted};
			$hash{switching}{firstrunpassrate} += $ar->{firstrunpassrate};
			$hash{switching}{overallpassrate} += $ar->{overallpassrate};
			$hash{switching}{tcpassrate} += $ar->{tcpassrate};
			$hash{switching}{tcfailrate} += $ar->{tcfailrate};
			$hash{switching}{plannedpassrate} += $ar->{plannedpassrate};
			$hash{switching}{overallfailrate} += $ar->{overallfailrate};
			$hash{switching}{debugstart} = "";
			$hash{switching}{debugend} = "";
			$hash{switching}{newprs} += $ar->{newprs};
			$hash{switching}{allprs} += $ar->{allprs};
			$hash{switching}{blockerprs} += $ar->{blockerprs};
			$hash{switching}{openblockerprs} += $ar->{openblockerprs};
			$hash{switching}{tobedebugged} += $ar->{tobedebugged};
			$hash{switching}{totaldebugcount} += $ar->{totaldebugcount};
			$hash{switching}{completeddebugcount} += $ar->{completeddebugcount};
			$hash{switching}{totalscriptfailed} += $ar->{totalscriptfailed};
			$hash{switching}{totalscriptpassed} += $ar->{totalscriptpassed};
			$hash{switching}{totaltcfailed} += $ar->{totaltcfailed};
			$hash{switching}{totaltcpassed} += $ar->{totaltcpassed};
			$hash{switching}{totalfirstrunpass} += $ar->{totalfirstrunpass};
			$hash{switching}{totalfirstrunscript} += $ar->{totalfirstrunscript};
			$hash{switching}{executionrate} += $executionrate ;
			$hash{switching}{respindebugcount} += $ar->{respindebugcount};
                        $hash{switching}{respincompleteddebug} += $ar->{respincompleteddebug};
                        $hash{switching}{respinpendingdebug} += $ar->{respinpendingdebug};
                        $hash{switching}{respincompleteddebugper} += $ar->{respincompleteddebugper};
			}
			#elsif($func =~ /ESBU/)
			#{
			#	### For ESBUJUNOSSW and TOTAL
			#	$esbufound = 1;
			#	$breakcolcount+=2;
			#}
		
		
			$c++;
			$funccount++;
			$breakcolcount++;
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
			$hash{$func}{tcexeuted} = 0;
			$hash{$func}{firstrunpassrate} = 0;
			$hash{$func}{overallpassrate} = 0;
			$hash{$func}{tcpassrate} = 0;
			$hash{$func}{tcfailrate} = 0;
			$hash{$func}{plannedpassrate} = 0;
			$hash{$func}{overallfailrate} = 0;
			$hash{$func}{debugstart} = "";
			$hash{$func}{debugend} = "";
			$hash{$func}{newprs} = 0;
			$hash{$func}{allprs} = 0;
			$hash{$func}{blockerprs} = 0;
			$hash{$func}{openblockerprs} = 0;
			$hash{$func}{tobedebugged} = 0;
			$hash{$func}{totaldebugcount} = 0;
			$hash{$func}{debugper} = 0;
			$hash{$func}{completeddebugcount} = 0;
			$hash{$func}{totalscriptfailed} = 0;
			$hash{$func}{totalscriptpassed} = 0;
			$hash{$func}{totaltcfailed} = 0;
			$hash{$func}{totaltcpassed} = 0;
			$hash{$func}{executionreate} = 0;
			$hash{$func}{totalfirstrunpass} = 0;
			$hash{$func}{totalfirstrunscript} = 0;
			$hash{$func}{respindebugcount} = 0;
            $hash{$func}{respincompleteddebug} = 0;
            $hash{$func}{respinpendingdebug} = 0;
            $hash{$func}{respincompleteddebugper} = 0;
	}
}
$breakcolcount+=8;
##### Insert Total Progress###############################
#update the totals
if($hash{total}{totalscriptpassed} > 0)
{
	$hash{total}{overallpassrate} = sprintf "%.2f",($hash{total}{totalscriptpassed}/$hash{total}{scriptexecuted}) * 100;
}
if($hash{total}{totalscriptpassed} > 0)
{
	$hash{total}{plannedpassrate} = sprintf "%.2f",($hash{total}{totalscriptpassed}/$hash{total}{scriptplanned}) * 100;
}
if($hash{total}{totalscriptfailed} > 0)
{
	$hash{total}{overallfailrate} = sprintf "%.2f",($hash{total}{totalscriptfailed}/$hash{total}{scriptexecuted}) * 100;
}
if($hash{total}{totaltcpassed} > 0)
{
	$hash{total}{tcpassrate} = sprintf "%.2f",($hash{total}{totaltcpassed}/$hash{total}{tcexecuted}) * 100;
}
if($hash{total}{totalscriptpassed} > 0)
{
	$hash{total}{plannedpassrate} = sprintf "%.2f",($hash{total}{totalscriptpassed}/$hash{total}{scriptplanned}) * 100;
}
if($hash{total}{totaltcfailed} > 0)
{
	$hash{total}{tcfailrate} = sprintf "%.2f",($hash{total}{totaltcfailed}/$hash{total}{tcexecuted}) * 100;
}
$hash{total}{executionrate} = 0;
if($hash{total}{scriptplanned} > 0)
{
$hash{total}{executionrate} = sprintf "%.0f",($hash{total}{scriptexecuted}/$hash{total}{scriptplanned}) * 100;
}
#$hash{total}{firstrunpassrate} = sprintf "%.2f",($hash{total}{firstrunpassrate} / $funccount);
$hash{total}{debugper} = 0;
if($hash{total}{totaldebugcount} > 0)
{
$hash{total}{debugper} = sprintf "%.0f",($hash{total}{completeddebugcount} / $hash{total}{totaldebugcount}) * 100;
}
$hash{total}{firstrunpassrate} = 0;
if($hash{total}{totalfirstrunscript}  > 0)
{
$hash{total}{firstrunpassrate} = sprintf "%.2f",($hash{total}{totalfirstrunpass} / $hash{total}{totalfirstrunscript}) * 100;
}
if ($hash{total}{respindebugcount}>0) {
$hash{total}{respincompleteddebugper} = sprintf "%.2f",($hash{total}{respincompleteddebug} / $hash{total}{respindebugcount}) * 100;
} else {
$hash{total}{respincompleteddebugper} = 0.00;
}
#update the rbutotal
$hash{routing}{overallpassrate} = 0;
if($hash{routing}{scriptexecuted} > 0)
{
$hash{routing}{overallpassrate} = sprintf "%.2f",($hash{routing}{totalscriptpassed}/$hash{routing}{scriptexecuted}) * 100;
}
$hash{routing}{plannedpassrate} = 0;
if($hash{routing}{scriptplanned} > 0)
{
$hash{routing}{plannedpassrate} = sprintf "%.2f",($hash{routing}{totalscriptpassed}/$hash{routing}{scriptplanned}) * 100;
}
$hash{routing}{overallfailrate} = 0;
if($hash{routing}{scriptexecuted} > 0)
{
$hash{routing}{overallfailrate} = sprintf "%.2f",($hash{routing}{totalscriptfailed}/$hash{routing}{scriptexecuted}) * 100;
}
if($hash{routing}{totaltcpassed} > 0)
{
    $hash{routing}{tcpassrate} = sprintf "%.2f",($hash{routing}{totaltcpassed}/$hash{routing}{tcexecuted}) * 100;
}
if($hash{routing}{totaltcfailed} > 0)
{
    $hash{routing}{tcfailrate} = sprintf "%.2f",($hash{routing}{totaltcfailed}/$hash{routing}{tcexecuted}) * 100;
}

$hash{routing}{executionrate} = 0;
if($hash{routing}{scriptplanned} > 0)
{
$hash{routing}{executionrate} = sprintf "%.0f",($hash{routing}{scriptexecuted}/$hash{routing}{scriptplanned}) * 100;
}
#$hash{routing}{firstrunpassrate} = sprintf "%.2f",($hash{routing}{firstrunpassrate} / $funccount);
$hash{routing}{debugper} = 0;
if($hash{routing}{totaldebugcount} > 0)
{
$hash{routing}{debugper} = sprintf "%.0f",($hash{routing}{completeddebugcount} / $hash{routing}{totaldebugcount}) * 100;
}
$totaldebugrate  = 0;
if($hash{total}{scriptexecuted} > 0)
{
$totaldebugrate =  sprintf "%.2f",($hash{total}{tobedebugged} / $hash{total}{scriptexecuted}) * 100;
}
$rbudebugrate = 0;
if($hash{routing}{scriptexecuted} > 0)
{
$rbudebugrate =  sprintf "%.2f",($hash{routing}{tobedebugged} / $hash{routing}{scriptexecuted}) * 100;
}
$hash{routing}{firstrunpassrate} = 0;
if($hash{routing}{totalfirstrunscript} > 0)
{
$hash{routing}{firstrunpassrate} = sprintf "%.2f",($hash{routing}{totalfirstrunpass} / $hash{routing}{totalfirstrunscript}) * 100;
}
if ($hash{routing}{respindebugcount}>0) {
$hash{routing}{respincompleteddebugper} = sprintf "%.2f",($hash{routing}{respincompleteddebug} / $hash{routing}{respindebugcount}) * 100;
} else {
$hash{routing}{respincompleteddebugper} = 0.00;
}

$hash{switching}{overallpassrate} = 0;
if($hash{switching}{scriptexecuted} > 0)
{
$hash{switching}{overallpassrate} = sprintf "%.2f",($hash{switching}{totalscriptpassed}/$hash{switching}{scriptexecuted}) * 100;
}
$hash{switching}{plannedpassrate} = 0;
if($hash{switching}{scriptplanned} > 0)
{
$hash{switching}{plannedpassrate} = sprintf "%.2f",($hash{switching}{totalscriptpassed}/$hash{switching}{scriptplanned}) * 100;
}
$hash{switching}{overallfailrate} = 0;
if($hash{switching}{scriptexecuted} > 0)
{
$hash{switching}{overallfailrate} = sprintf "%.2f",($hash{switching}{totalscriptfailed}/$hash{switching}{scriptexecuted}) * 100;
}
if($hash{switching}{totaltcpassed} > 0)
{
    $hash{switching}{tcpassrate} = sprintf "%.2f",($hash{switching}{totaltcpassed}/$hash{switching}{tcexecuted}) * 100;
}
if($hash{switching}{totaltcfailed} > 0)
{
    $hash{switching}{tcfailrate} = sprintf "%.2f",($hash{switching}{totaltcfailed}/$hash{switching}{tcexecuted}) * 100;
}

$hash{switching}{executionrate} = 0;
if($hash{switching}{scriptplanned} > 0)
{
$hash{switching}{executionrate} = sprintf "%.0f",($hash{switching}{scriptexecuted}/$hash{switching}{scriptplanned}) * 100;
}
#$hash{switching}{firstrunpassrate} = sprintf "%.2f",($hash{switching}{firstrunpassrate} / $funccount);
$hash{switching}{debugper} = 0;
if($hash{switching}{totaldebugcount} > 0)
{
$hash{switching}{debugper} = sprintf "%.0f",($hash{switching}{completeddebugcount} / $hash{switching}{totaldebugcount}) * 100;
}
$totaldebugrate  = 0;
if($hash{total}{scriptexecuted} > 0)
{
$totaldebugrate =  sprintf "%.2f",($hash{total}{tobedebugged} / $hash{total}{scriptexecuted}) * 100;
}
$rbudebugrate = 0;
if($hash{switching}{scriptexecuted} > 0)
{
$rbudebugrate =  sprintf "%.2f",($hash{switching}{tobedebugged} / $hash{switching}{scriptexecuted}) * 100;
}
$hash{switching}{firstrunpassrate} = 0;
if($hash{switching}{totalfirstrunscript} > 0)
{
$hash{switching}{firstrunpassrate} = sprintf "%.2f",($hash{switching}{totalfirstrunpass} / $hash{switching}{totalfirstrunscript}) * 100;
}
if ($hash{switching}{respindebugcount}>0) {
$hash{switching}{respincompleteddebugper} = sprintf "%.2f",($hash{switching}{respincompleteddebug} / $hash{switching}{respindebugcount}) * 100;
} else {
$hash{switching}{respincompleteddebugper} = 0.00;
}

$query= "delete from daily_regression_progress where day='$today' and release='$releasestr' and function='ALL'";
            $sth=$dbh->prepare($query);
            $sth->execute;

$query = "insert into daily_regression_progress values('$releasestr','ALL','$today',$hash{total}{executionrate},$hash{total}{overallpassrate},$hash{total}{overallfailrate},0,$totaldebugrate)";
$sth=$dbh->prepare($query);
            $sth->execute;
$query= "delete from daily_regression_progress where day='$today' and release='$releasestr' and function='RBU'";
            $sth=$dbh->prepare($query);
            $sth->execute;

$query = "insert into daily_regression_progress values('$releasestr','RBU','$today',$hash{routing}{executionrate},$hash{routing}{overallpassrate},$hash{routing}{overallfailrate},0,$rbudebugrate)";
$query= "delete from daily_regression_progress where day='$today' and release='$releasestr' and function='SWIT'";
            $sth=$dbh->prepare($query);
            $sth->execute;
$query = "insert into daily_regression_progress values('$releasestr','SWIT','$today',$hash{switching}{executionrate},$hash{switching}{overallpassrate},$hash{switching}{overallfailrate},0,$rbudebugrate)";
$sth=$dbh->prepare($query);
            $sth->execute;

####### Get the PR Details now #################################
######### For this first the TL9000 table need to be parsed
$relstrforprogress = $releasestr;
$releasestr =~ s/\./-/g;
open(F,">/homes/rod/public_html/Regression/report/data/$releasestr"."_table") or warn "not able to open file";
my $releasestr_table =  "$releasestr"."_table";
`chmod 755 /homes/rod/public_html/Regression/report/data/$releasestr_table`;
print "/homes/rod/public_html/Regression/report/data/$releasestr"."_table";
### updated time
# Get the Last refreshed time
    $final = "/homes/rod/public_html/Regression/report/data/$releasestr"."_table";
        $out = `ls -l --full-time $final`;
            ($year123,$month123,$date123,$time123) = $out =~ /([0-9]+)-([0-9]+)-([0-9]+)\s([0-9:]+)/;
                ($hour,$minute) = $time123 =~ /([0-9]+):([0-9]+):([0-9]+)/;
                    $updated = "<div><font  style='font-weight:bold;' size=2 face='Trebuchet MS, Verdana, Arial, Helvetica, sans-serif'>Last Refreshed :$year123-$month123-$date123 $hour:$minute<br>Click on the Column Header to display Details";
$table ="<center><table><thead><tr><th>$updated</th></thead></tr></table>";
#$table .="<center><table><thead><tr><th>Regression Start $start</th>";
#$table .="<th>Regression End $finish</th></tr></thead></table>";
$table .= "<center><table style='hieght:100%;width:95%' class='table table-bordered table-striped'><thead><tr><th colspan=2>Regression Phases</th><th>Matrices</th>";
$planned = "<th class='summary'>Total Script Planned</th>";
$executed = "<th class='summary'>Total Script Executed </th>";
$tcexecuted = "<tr><th class='phases' rowspan=5>Test Cases</th><th class='summary'>Total Testcases Executed </th>";
$executedper = "<tr><th class='summary' >Execution %</th>";
$firstpassper = "<tr><th class='summary'>First Run Pass % </th>";
$pass = "<tr><th class='phases' rowspan=5>Scripts</th><th class='summary'>Total Scripts Passed</th>";
$fail = "<tr><th class='summary'>Total Scripts Failed</th>";
$pending = "<tr><th class='summary'>Pending Debug Count </th>";
$totaldebug = "<th class='summary'>Total Debug Count </th>";
$completeddebug = "<tr><th class='summary'>Completed Debug Count </th>";
$completionper = "<tr><th class='summary'>Completed Debug  % </th>";
$dbgstart = "<tr><th rowspan=6 class='phases'>Initial Debug</th><th class='summary'>Debug Start</th>";
$dbgend = "<tr><th class='summary'>Debug End</th>";
$tcpass = "<th class='summary'>Total Testcases Passed</th>";
$tcfail = "<th class='summary'>Total Testcases Failed</th>";
##### REspin
$respindpending = "<tr><th class='summary' class='phases'>Pending Debug Count </th>";
$respintotal = "<tr><th rowspan=4 class='phases'>Respin Debug</th><th class='summary'>Total Debug Count </th>";
$respincompleted = "<tr><th class='summary'>Completed Debug Count </th>";
$respincompletedper = "<tr><th class='summary'>Completed Debug  % </th>";

$passper = "<tr><th class='summary'>Pass % [Execution]</th>";
$tcpassper = "<tr><th class='summary'>Pass % [Execution]</th>";
$planpassper = "<tr><th class='summary'>Pass % (Planned)</th>";
$failper = "<tr><th class='summary'>Overall Fail % [SW PRs] </th>";
$tcfailper = "<tr><th class='summary'>Overall Fail % </th>";
$prs = "<tr><th colspan=6>PR Details</th>";
$openblockerprs = "<th class='summary'>Open Blocker PRs</th>";
$blockerprs = "<th class='summary'>All Blocker PRs</th>";
$newprs = "<tr><th class='summary'>New PRs</th>";
$allprs = "<tr><th class='summary'>All PRs</th>";
$category = "";
$dataset = "<dataset seriesName='First Pass Rate' color='FDC12E' anchorBorderColor='FDC12E' anchorBgColor='FDC12E'>";
$dataset1 = "<dataset seriesName='Overall Pass Rate' color='52D017' anchorBorderColor='52D017' anchorBgColor='52D017'>";
$dataset2 = "<dataset seriesName='Overall Fail Rate' color='E42217' anchorBorderColor='E42217' anchorBgColor='E42217'>";
$funccount = 1;
foreach $func(@functions)
{
	if($hash{$func}{scriptplanned} == 0) { next;}
	$colclass = "col".$funccount;
	$disp = $func;
	if($func =~ /PTX/)  { $disp = "TPTX";} 
	if($func =~ /MMX/)  { $disp = "MMX";} 
	if($func =~ /ESBU/)  { $disp = "Services";} 
	if($func =~ /JUNOS SW/)  { $disp = "Kernel/<br>Mgmt";} 
	if($func =~ /QFX10008/)  { $disp = "QFX10008/<br>QFX10016";} 
	if($func =~ /brackla/i)  { $disp = "$func";}
	if($func =~ /MMX|PTX|ACX|BBE|ESBU|JUNOS|RPD|ROUTING NPIs|ROUTING VIRTUAL/ )

	{
	$table .= "<th><a class='headerlink' id='$funccount' href='javascript:getdetailedreport(\"$releasestr\",\"$func\");'>$disp<a/></th>";
	$planned .= "<td class='$colclass'>$hash{$func}{scriptplanned}</td>";
	$executed .= "<td class='$colclass'>$hash{$func}{scriptexecuted}</td>";
	$tcexecuted .= "<td class='$colclass'>$hash{$func}{tcexecuted}</td>";
	$executedper .= "<td class='$colclass'>$hash{$func}{executionrate}%</td>";
	$firstpassper .= "<td class='$colclass'>$hash{$func}{firstrunpassrate}%</td>";
	$pass .= "<td class='$colclass'>$hash{$func}{totalscriptpassed}</td>";
	$fail .= "<td class='$colclass'>$hash{$func}{totalscriptfailed}</td>";
	$tcpass .= "<td class='$colclass'>$hash{$func}{totaltcpassed}</td>";
	$tcfail .= "<td class='$colclass'>$hash{$func}{totaltcfailed}</td>";
	$passper .= "<td class='$colclass'>$hash{$func}{overallpassrate}%</td>";
	$tcpassper .= "<td class='$colclass'>$hash{$func}{tcpassrate}%</td>";
	$planpassper .= "<td class='$colclass'>$hash{$func}{plannedpassrate}%</td>";
	$failper .= "<td class='$colclass'>$hash{$func}{overallfailrate}%</td>";
	$tcfailper .= "<td class='$colclass'>$hash{$func}{tcfailrate}%</td>";
	$pending .= "<td class='$colclass'>$hash{$func}{tobedebugged}</td>";
	$totaldebug .= "<td class='$colclass'>$hash{$func}{totaldebugcount}</td>";
	$completeddebug .= "<td class='$colclass'>$hash{$func}{completeddebugcount}</td>";
	$completionper .= "<td class='$colclass'>$hash{$func}{debugper}%</td>";
	$dbgstart .= "<td class='$colclass'>$hash{$func}{debugstart}</td>";
	$dbgend .= "<td class='$colclass'>$hash{$func}{debugend}</td>";
	######################## Respin
	$respindpending .= "<td class='$colclass'>$hash{$func}{respinpendingdebug}</td>";
	$respintotal .=  "<td class='$colclass'>$hash{$func}{respindebugcount}</td>";
	$respincompleted .= "<td class='$colclass'>$hash{$func}{respincompleteddebug}</td>";
	$respincompletedper .= "<td class='$colclass'>$hash{$func}{respincompleteddebugper}%</td>";
	
	$blockerprs .= "<td class='$colclass'>$hash{$func}{blockerprs}</td>";
	$openblockerprs .= "<td class='$colclass'>$hash{$func}{openblockerprs}</td>";
	$allprs .= "<td class='$colclass'>$hash{$func}{allprs}</td>";
	$newprs .= "<td class='$colclass'>$hash{$func}{newprs}</td>";
	$category .= "<category label=\"$func\"/> \n";
	$dataset .= "<set value=\"$hash{$func}{firstrunpassrate}\" />\n";
	$dataset1 .= "<set value=\"$hash{$func}{overallpassrate}\" />\n";
	$dataset2 .= "<set value=\"$hash{$func}{overallfailrate}\" />\n";
	$funccount++;
	}
}
#### Add a break
	$table .= "<th class='phases'></th>";
    $planned .= "<th class='phases'></th>";
    $executed .= "<th class='phases'></th>";
    $tcexecuted .= "<th class='phases'></th>";
    $executedper .= "<th class='phases'></th>";
    $firstpassper .= "<th class='phases'></th>";
    $pass .= "<th class='phases'></th>";
    $tcpass .= "<th class='phases'></th>";
    $fail .= "<th class='phases'></th>";
    $tcfail .= "<th class='phases'></th>";
    $passper .= "<th class='phases'></th>";
    $tcpassper .= "<th class='phases'></th>";
    $planpassper .= "<th class='phases'></th>";
    $failper .= "<th class='phases'></th>";
    $tcfailper .= "<th class='phases'></th>";
    $pending .= "<th class='phases'></th>";
	$totaldebug .= "<th class='phases'></th>";
	$completeddebug .= "<th class='phases'></th>";
	$completionper .= "<th class='phases'></th>";
    $allprs .= "<th class='phases'></th>";
    $newprs .= "<th class='phases'></th>";
    $blockerprs .= "<th class='phases'></th>";
    $openblockerprs .= "<th class='phases'></th>";
	$respindpending .= "<th class='phases'></th>";
    $respintotal .=  "<th class='phases'></th>";
    $respincompleted .= "<th class='phases'></th>";
    $respincompletedper .= "<th class='phases'></th>";
    $dbgstart .= "<th class='phases'></th>";
    $dbgend .= "<th class='phases'></th>";
###### Now RBU Totals
	$table .= "<th><a class='headerlink' id='rbu' href='javascript:getdetailedreport(\"$releasestr\",\"RBU\");'>ROUTING<br>TOTALS<a/></th>";
    $planned .= "<td class='colrbu selectedcol'>$hash{routing}{scriptplanned}</td>";
    $executed .= "<td class='colrbu selectedcol'>$hash{routing}{scriptexecuted}</td>";
    $tcexecuted .= "<td class='colrbu selectedcol'>$hash{routing}{tcexecuted}</td>";
    $executedper .= "<td class='colrbu selectedcol'>$hash{routing}{executionrate}%</td>";
    $firstpassper .= "<td class='colrbu selectedcol'>$hash{routing}{firstrunpassrate}%</td>";
    $pass .= "<td class='colrbu selectedcol'>$hash{routing}{totalscriptpassed} </td>";
    $fail .= "<td class='colrbu selectedcol'>$hash{routing}{totalscriptfailed} </td>";
    $tcpass .= "<td class='colrbu selectedcol'>$hash{routing}{totaltcpassed}</td>";
    $tcfail .= "<td class='colrbu selectedcol'>$hash{routing}{totaltcfailed}</td>";
    $passper .= "<td class='colrbu selectedcol'>$hash{routing}{overallpassrate}%</td>";
    $tcpassper .= "<td class='colrbu selectedcol'>$hash{routing}{tcpassrate}%</td>";
    $planpassper .= "<td class='colrbu selectedcol'>$hash{routing}{plannedpassrate}%</td>";
    $failper .= "<td class='colrbu selectedcol'>$hash{routing}{overallfailrate}%</td>";
    $tcfailper .= "<td class='colrbu selectedcol'>$hash{routing}{tcfailrate}%</td>";
    $pending .= "<td class='colrbu selectedcol'>$hash{routing}{tobedebugged}</td>";
	$totaldebug .= "<td class='colrbu selectedcol'>$hash{routing}{totaldebugcount}</td>";
	$completeddebug .= "<td class='colrbu selectedcol'>$hash{routing}{completeddebugcount}</td>";
	$completionper .= "<td class='colrbu selectedcol'>$hash{routing}{debugper}%</td>";
    $blockerprs .= "<td class='colrbu selectedcol'>$hash{routing}{blockerprs}</td>";
    $openblockerprs .= "<td class='colrbu selectedcol'>$hash{routing}{openblockerprs}</td>";
    $allprs .= "<td class='colrbu selectedcol'>$hash{routing}{allprs}</td>";
    $newprs .= "<td class='colrbu selectedcol'>$hash{routing}{newprs}</td>";
	$respindpending .= "<td class='colrbu selectedcol'>$hash{routing}{respinpendingdebug}</td>";
    $respintotal .=  "<td class='colrbu selectedcol'>$hash{routing}{respindebugcount}</td>";
    $respincompleted .= "<td class='colrbu selectedcol'>$hash{routing}{respincompleteddebug}</td>";
    $respincompletedper .= "<td class='colrbu selectedcol'>$hash{routing}{respincompleteddebugper}%</td>";
    $dbgstart .= "<td class='colrbu selectedcol'></td>";
    $dbgend .= "<td class='colrbu selectedcol'></td>";
#### Add a break
	$table .= "<th class='phases'></th>";
    $planned .= "<th class='phases'></th>";
    $executed .= "<th class='phases'></th>";
    $tcexecuted .= "<th class='phases'></th>";
    $executedper .= "<th class='phases'></th>";
    $firstpassper .= "<th class='phases'></th>";
    $pass .= "<th class='phases'></th>";
    $tcpass .= "<th class='phases'></th>";
    $fail .= "<th class='phases'></th>";
    $tcfail .= "<th class='phases'></th>";
    $passper .= "<th class='phases'></th>";
    $tcpassper .= "<th class='phases'></th>";
    $planpassper .= "<th class='phases'></th>";
    $failper .= "<th class='phases'></th>";
    $tcfailper .= "<th class='phases'></th>";
    $pending .= "<th class='phases'></th>";
	$totaldebug .= "<th class='phases'></th>";
	$completeddebug .= "<th class='phases'></th>";
	$completionper .= "<th class='phases'></th>";
    $allprs .= "<th class='phases'></th>";
    $newprs .= "<th class='phases'></th>";
    $blockerprs .= "<th class='phases'></th>";
    $openblockerprs .= "<th class='phases'></th>";
	$respindpending .= "<th class='phases'></th>";
    $respintotal .=  "<th class='phases'></th>";
    $respincompleted .= "<th class='phases'></th>";
    $respincompletedper .= "<th class='phases'></th>";
    $dbgstart .= "<th class='phases'></th>";
    $dbgend .= "<th class='phases'></th>";
foreach $func(@functions)
{
	if($hash{$func}{scriptplanned} == 0) { next;}
	$colclass = "col".$funccount;
	$disp = $func;

	if($func =~ /PTX/)  { $disp = "TPTX";} 
	if($func =~ /MMX/)  { $disp = "MMX";} 
	if($func =~ /ESBU/)  { $disp = "Services";} 
	if($func =~ /JUNOS SW/)  { $disp = "Kernel<br>Mgmt";} 
        if($func =~ /QFX10008/)  { $disp = "QFX10008/<br>QFX10016";}
	if($func =~ /brackla/i)  { $disp = "$func";}
	if($func !~ /MMX|PTX|ESBU|JUNOS|ACX|BBE|RPD|ROUTING NPIs|ROUTING VIRTUAL/)
	{
	$table .= "<th><a class='headerlink' id='$funccount' href='javascript:getdetailedreport(\"$releasestr\",\"$func\");'>$disp<a/></th>";
	$planned .= "<td class='$colclass'>$hash{$func}{scriptplanned}</td>";
	$executed .= "<td class='$colclass'>$hash{$func}{scriptexecuted}</td>";
	$tcexecuted .= "<td class='$colclass'>$hash{$func}{tcexecuted}</td>";
	$executedper .= "<td class='$colclass'>$hash{$func}{executionrate}%</td>";
	$firstpassper .= "<td class='$colclass'>$hash{$func}{firstrunpassrate}%</td>";
	$pass .= "<td class='$colclass'>$hash{$func}{totalscriptpassed}</td>";
	$fail .= "<td class='$colclass'>$hash{$func}{totalscriptfailed}</td>";
	$tcpass .= "<td class='$colclass'>$hash{$func}{totaltcpassed}</td>";
	$tcfail .= "<td class='$colclass'>$hash{$func}{totaltcfailed}</td>";
	$passper .= "<td class='$colclass'>$hash{$func}{overallpassrate}%</td>";
	$tcpassper .= "<td class='$colclass'>$hash{$func}{tcpassrate}%</td>";
	$planpassper .= "<td class='$colclass'>$hash{$func}{plannedpassrate}%</td>";
	$failper .= "<td class='$colclass'>$hash{$func}{overallfailrate}%</td>";
	$tcfailper .= "<td class='$colclass'>$hash{$func}{tcfailrate}%</td>";
	$pending .= "<td class='$colclass'>$hash{$func}{tobedebugged}</td>";
	$totaldebug .= "<td class='$colclass'>$hash{$func}{totaldebugcount}</td>";
	$completeddebug .= "<td class='$colclass'>$hash{$func}{completeddebugcount}</td>";
	$completionper .= "<td class='$colclass'>$hash{$func}{debugper}%</td>";
	$dbgstart .= "<td class='$colclass'>$hash{$func}{debugstart}</td>";
	$dbgend .= "<td class='$colclass'>$hash{$func}{debugend}</td>";
	######################## Respin
	$respindpending .= "<td class='$colclass'>$hash{$func}{respinpendingdebug}</td>";
	$respintotal .=  "<td class='$colclass'>$hash{$func}{respindebugcount}</td>";
	$respincompleted .= "<td class='$colclass'>$hash{$func}{respincompleteddebug}</td>";
	$respincompletedper .= "<td class='$colclass'>$hash{$func}{respincompleteddebugper}%</td>";
	
	$blockerprs .= "<td class='$colclass'>$hash{$func}{blockerprs}</td>";
	$openblockerprs .= "<td class='$colclass'>$hash{$func}{openblockerprs}</td>";
	$allprs .= "<td class='$colclass'>$hash{$func}{allprs}</td>";
	$newprs .= "<td class='$colclass'>$hash{$func}{newprs}</td>";
	$category .= "<category label=\"$func\"/> \n";
	$dataset .= "<set value=\"$hash{$func}{firstrunpassrate}\" />\n";
	$dataset1 .= "<set value=\"$hash{$func}{overallpassrate}\" />\n";
	$dataset2 .= "<set value=\"$hash{$func}{overallfailrate}\" />\n";
	$funccount++;
	}
}
#### Add a break
	$table .= "<th class='phases'></th>";
    $planned .= "<th class='phases'></th>";
    $executed .= "<th class='phases'></th>";
    $tcexecuted .= "<th class='phases'></th>";
    $executedper .= "<th class='phases'></th>";
    $firstpassper .= "<th class='phases'></th>";
    $pass .= "<th class='phases'></th>";
    $tcpass .= "<th class='phases'></th>";
    $fail .= "<th class='phases'></th>";
    $tcfail .= "<th class='phases'></th>";
    $passper .= "<th class='phases'></th>";
    $tcpassper .= "<th class='phases'></th>";
    $planpassper .= "<th class='phases'></th>";
    $failper .= "<th class='phases'></th>";
    $tcfailper .= "<th class='phases'></th>";
    $pending .= "<th class='phases'></th>";
	$totaldebug .= "<th class='phases'></th>";
	$completeddebug .= "<th class='phases'></th>";
	$completionper .= "<th class='phases'></th>";
    $allprs .= "<th class='phases'></th>";
    $newprs .= "<th class='phases'></th>";
    $blockerprs .= "<th class='phases'></th>";
    $openblockerprs .= "<th class='phases'></th>";
	$respindpending .= "<th class='phases'></th>";
    $respintotal .=  "<th class='phases'></th>";
    $respincompleted .= "<th class='phases'></th>";
    $respincompletedper .= "<th class='phases'></th>";
    $dbgstart .= "<th class='phases'></th>";
    $dbgend .= "<th class='phases'></th>";
###### Now SWITCHING Totals
	$table .= "<th><a class='headerlink' id='rbu' href='javascript:getdetailedreport(\"$releasestr\",\"SWIT\");'>SWITCHING<br>TOTALS<a/></th>";
    $planned .= "<td class='colrbu selectedcol'>$hash{switching}{scriptplanned}</td>";
    $executed .= "<td class='colrbu selectedcol'>$hash{switching}{scriptexecuted}</td>";
    $tcexecuted .= "<td class='colrbu selectedcol'>$hash{switching}{tcexecuted}</td>";
    $executedper .= "<td class='colrbu selectedcol'>$hash{switching}{executionrate}%</td>";
    $firstpassper .= "<td class='colrbu selectedcol'>$hash{switching}{firstrunpassrate}%</td>";
    $pass .= "<td class='colrbu selectedcol'>$hash{switching}{totalscriptpassed} </td>";
    $fail .= "<td class='colrbu selectedcol'>$hash{switching}{totalscriptfailed} </td>";
    $tcpass .= "<td class='colrbu selectedcol'>$hash{switching}{totaltcpassed}</td>";
    $tcfail .= "<td class='colrbu selectedcol'>$hash{switching}{totaltcfailed}</td>";
    $passper .= "<td class='colrbu selectedcol'>$hash{switching}{overallpassrate}%</td>";
    $tcpassper .= "<td class='colrbu selectedcol'>$hash{switching}{tcpassrate}%</td>";
    $planpassper .= "<td class='colrbu selectedcol'>$hash{switching}{plannedpassrate}%</td>";
    $failper .= "<td class='colrbu selectedcol'>$hash{switching}{overallfailrate}%</td>";
    $tcfailper .= "<td class='colrbu selectedcol'>$hash{switching}{tcfailrate}%</td>";
    $pending .= "<td class='colrbu selectedcol'>$hash{switching}{tobedebugged}</td>";
	$totaldebug .= "<td class='colrbu selectedcol'>$hash{switching}{totaldebugcount}</td>";
	$completeddebug .= "<td class='colrbu selectedcol'>$hash{switching}{completeddebugcount}</td>";
	$completionper .= "<td class='colrbu selectedcol'>$hash{switching}{debugper}%</td>";
    $blockerprs .= "<td class='colrbu selectedcol'>$hash{switching}{blockerprs}</td>";
    $openblockerprs .= "<td class='colrbu selectedcol'>$hash{switching}{openblockerprs}</td>";
    $allprs .= "<td class='colrbu selectedcol'>$hash{switching}{allprs}</td>";
    $newprs .= "<td class='colrbu selectedcol'>$hash{switching}{newprs}</td>";
	$respindpending .= "<td class='colrbu selectedcol'>$hash{switching}{respinpendingdebug}</td>";
    $respintotal .=  "<td class='colrbu selectedcol'>$hash{switching}{respindebugcount}</td>";
    $respincompleted .= "<td class='colrbu selectedcol'>$hash{switching}{respincompleteddebug}</td>";
    $respincompletedper .= "<td class='colrbu selectedcol'>$hash{switching}{respincompleteddebugper}%</td>";
    $dbgstart .= "<td class='colrbu selectedcol'></td>";
    $dbgend .= "<td class='colrbu selectedcol'></td>";
#### Add a break
	$table .= "<th class='phases'></th>";
    $planned .= "<th class='phases'></th>";
    $executed .= "<th class='phases'></th>";
    $tcexecuted .= "<th class='phases'></th>";
    $executedper .= "<th class='phases'></th>";
    $firstpassper .= "<th class='phases'></th>";
    $pass .= "<th class='phases'></th>";
    $tcpass .= "<th class='phases'></th>";
    $fail .= "<th class='phases'></th>";
    $tcfail .= "<th class='phases'></th>";
    $passper .= "<th class='phases'></th>";
    $tcpassper .= "<th class='phases'></th>";
    $planpassper .= "<th class='phases'></th>";
    $failper .= "<th class='phases'></th>";
    $tcfailper .= "<th class='phases'></th>";
    $pending .= "<th class='phases'></th>";
	$totaldebug .= "<th class='phases'></th>";
	$completeddebug .= "<th class='phases'></th>";
	$completionper .= "<th class='phases'></th>";
    $allprs .= "<th class='phases'></th>";
    $newprs .= "<th class='phases'></th>";
    $blockerprs .= "<th class='phases'></th>";
    $openblockerprs .= "<th class='phases'></th>";
	$respindpending .= "<th class='phases'></th>";
    $respintotal .=  "<th class='phases'></th>";
    $respincompleted .= "<th class='phases'></th>";
    $respincompletedper .= "<th class='phases'></th>";
    $dbgstart .= "<th class='phases'></th>";
    $dbgend .= "<th class='phases'></th>";
###### Now TOTAL Totals
	$table .= "<th><a class='headerlink' id='rbu' href='javascript:getdetailedreport(\"$releasestr\",\"ALL\");'>ROUTING & <br>SWITCHING<br>TOTALS<a/></th>";
    $planned .= "<td class='colrbu selectedcol'>$hash{total}{scriptplanned}</td>";
    $executed .= "<td class='colrbu selectedcol'>$hash{total}{scriptexecuted}</td>";
    $tcexecuted .= "<td class='colrbu selectedcol'>$hash{total}{tcexecuted}</td>";
    $executedper .= "<td class='colrbu selectedcol'>$hash{total}{executionrate}%</td>";
    $firstpassper .= "<td class='colrbu selectedcol'>$hash{total}{firstrunpassrate}%</td>";
    $pass .= "<td class='colrbu selectedcol'>$hash{total}{totalscriptpassed} </td>";
    $fail .= "<td class='colrbu selectedcol'>$hash{total}{totalscriptfailed} </td>";
    $tcpass .= "<td class='colrbu selectedcol'>$hash{total}{totaltcpassed}</td>";
    $tcfail .= "<td class='colrbu selectedcol'>$hash{total}{totaltcfailed}</td>";
    $passper .= "<td class='colrbu selectedcol'>$hash{total}{overallpassrate}%</td>";
    $tcpassper .= "<td class='colrbu selectedcol'>$hash{total}{tcpassrate}%</td>";
    $planpassper .= "<td class='colrbu selectedcol'>$hash{total}{plannedpassrate}%</td>";
    $failper .= "<td class='colrbu selectedcol'>$hash{total}{overallfailrate}%</td>";
    $tcfailper .= "<td class='colrbu selectedcol'>$hash{total}{tcfailrate}%</td>";
    $pending .= "<td class='colrbu selectedcol'>$hash{total}{tobedebugged}</td>";
	$totaldebug .= "<td class='colrbu selectedcol'>$hash{total}{totaldebugcount}</td>";
	$completeddebug .= "<td class='colrbu selectedcol'>$hash{total}{completeddebugcount}</td>";
	$completionper .= "<td class='colrbu selectedcol'>$hash{total}{debugper}%</td>";
    $blockerprs .= "<td class='colrbu selectedcol'>$hash{total}{blockerprs}</td>";
    $openblockerprs .= "<td class='colrbu selectedcol'>$hash{total}{openblockerprs}</td>";
    $allprs .= "<td class='colrbu selectedcol'>$hash{total}{allprs}</td>";
    $newprs .= "<td class='colrbu selectedcol'>$hash{total}{newprs}</td>";
	$respindpending .= "<td class='colrbu selectedcol'>$hash{total}{respinpendingdebug}</td>";
    $respintotal .=  "<td class='colrbu selectedcol'>$hash{total}{respindebugcount}</td>";
    $respincompleted .= "<td class='colrbu selectedcol'>$hash{total}{respincompleteddebug}</td>";
    $respincompletedper .= "<td class='colrbu selectedcol'>$hash{total}{respincompleteddebugper}%</td>";
    $dbgstart .= "<td class='colrbu selectedcol'></td>";
    $dbgend .= "<td class='colrbu selectedcol'></td>";
#### Add a break
	$table .= "<th class='phases'></th>";
    $planned .= "<th class='phases'></th>";
    $executed .= "<th class='phases'></th>";
    $tcexecuted .= "<th class='phases'></th>";
    $executedper .= "<th class='phases'></th>";
    $firstpassper .= "<th class='phases'></th>";
    $pass .= "<th class='phases'></th>";
    $tcpass .= "<th class='phases'></th>";
    $fail .= "<th class='phases'></th>";
    $tcfail .= "<th class='phases'></th>";
    $passper .= "<th class='phases'></th>";
    $tcpassper .= "<th class='phases'></th>";
    $planpassper .= "<th class='phases'></th>";
    $failper .= "<th class='phases'></th>";
    $tcfailper .= "<th class='phases'></th>";
    $pending .= "<th class='phases'></th>";
	$totaldebug .= "<th class='phases'></th>";
	$completeddebug .= "<th class='phases'></th>";
	$completionper .= "<th class='phases'></th>";
    $allprs .= "<th class='phases'></th>";
    $newprs .= "<th class='phases'></th>";
    $blockerprs .= "<th class='phases'></th>";
    $openblockerprs .= "<th class='phases'></th>";
	$respindpending .= "<th class='phases'></th>";
    $respintotal .=  "<th class='phases'></th>";
    $respincompleted .= "<th class='phases'></th>";
    $respincompletedper .= "<th class='phases'></th>";
    $dbgstart .= "<th class='phases'></th>";
    $dbgend .= "<th class='phases'></th>";
$table .= "</tr>";
$planned .= "</tr>";
$executed .= "</tr>";
$tcexecuted .= "</tr>";
$executedper .= "</tr>";
$pending .= "</tr>";
$totaldebug .= "</tr>";
$completeddebug .= "</tr>";
$completionper .= "</tr>";
#respin
$respindpending .= "</tr>";
$respintotal .= "</tr>";
$respincompleted .= "</tr>";
$respincompletedper .= "</tr>";
$dbgstart .= "</tr>";
$dbgend .= "</tr>";

$firstpass .= "</tr>";
$firstpassper .= "</tr>";
$pass .= "</tr>";
$tcpass .= "</tr>";
$passper .= "</tr>";
$tcpassper .= "</tr>";
$planpassper .= "</tr>";
$fail .= "</tr>";
$tcfail .= "</tr>";
$failper .= "</tr>";
$tcfailper .= "</tr>";
$prs .= "</tr>";
$allprs .= "</tr>";
$blockerprs .= "</tr>";
$openblockerprs .= "</tr>";
$newprs .= "</tr>";
$breakcolcount++;
$table .= "<tr><th class='phases' rowspan=4 colspan=2>Execution </th>$planned$executed$executedper$firstpassper";
$table .= "<tr><th colspan=$breakcolcount></th>";
$table .= "<tr><th class='phases' rowspan=12 colspan=1>Debugging </th>$dbgstart$totaldebug$pending$completeddebug$completionper$dbgend";
$table .= "<tr><th height='1' style='background:#58ACFA;' colspan=$breakcolcount></th>";
$table .= "$respintotal$respindpending$respincompleted$respincompletedper";

$table .= "<tr><th colspan=$breakcolcount></th>";
$table .= "<tr><th class='phases' rowspan=12 colspan=1>Final Result</th>$pass$fail$passper$planpassper$failper";
$table .= "<tr><th height='1' style='background:#58ACFA;' colspan=$breakcolcount></th>";
$table .= "$tcexecuted$tcpass$tcfail$tcpassper$tcfailper";
$table .= "<tr><th colspan=$breakcolcount></th>";
$table .= "<tr><th class='phases' rowspan=4 colspan=2>PR Details</th>$openblockerprs$blockerprs$newprs$allprs";
$table .= "</tbody></table>";
#$planned.$executed.$executedper.$firstpassper.$pass.$fail.$pending.$passper.$planpassper.$failper.$prs.$blockerprs.$newprs.$allprs."</tbody></table>";
print F $table;
close(F);
######## Print the  Failure Break Down Table ############################################
$buff = "<center><table class='table table-bordered table-striped'><thead><tr><th>Exit Code</th><th>Count of scripts </th></tr></thead><tbody>";
#$buff = "<center><table><tr><thead>";
$c = 1;
foreach $br(sort keys %dbg_brk_hash)
{
	$buff .= "<tr><th>$br</th><td>$dbg_brk_hash{$br}</td></tr>";
	#$mod = $c % 10;
	#if($mod == 0) {$buff .="</tr><tr>";}
	#$c++;
}
$buff .= "</thead></tbody></table>";
$function_strip = $function;
$function_strip=~ s/\//-/g;
open(F,">/homes/rod/public_html/Regression/report/data/$releasestr"."_".$function_strip."_failbreakdown_table");
print F $buff;
close F;

$allbuff .= "<allprs><allcount>$allcount<allcount>\n";
$allbuff .= "</tbody></table><br>";
$blockerbuff .= "<blockerprs><blockercount>$blockercount<blockercount>";
$nonblockerbuff .= "<nonblockerprs><nonblockercount>$nonblockercount<nonblockercount>";
$blockeropenbuff .= "<openblockerprs><openblockercount>$openblockercount<openblockercount>";
$blockerbuff .= "</tbody></table><br>";
$newbuff .= "<newprs><newcount>$newcount<newcount>";
$newbuff .= "</tbody></table><br>";
open(F,">/homes/rod/public_html/Regression/report/data/$releasestr"."_".$function_strip."_prs_table");
print F $blockeropenbuff.$blockerbuff.$newbuff.$allbuff;
close F;



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
$outprbuff="";
$allprbuff = "<br><center><table class='table table-bordered table-striped'><thead><tr><th colspan=14>All PR details</th></tr><tr><th>Function</th><th>Number</th><th>Arrival-Date</th><th>Synopsis</th><th>Reported-In</th><th>Class</th><th>State</th><th>Problem-Level</th><th>Category</th><th>Blocker</th><th>Dev-Owner</th><th>Responsible</th><th>Originator</th><th>HIT</th></tr><tbody><allprs>";
#$blockerprbuff="<center><table class='table table-bordered table-striped'><thead><tr><th colspan=8>Blocker PR details</th></tr><tr><th>Function</th><th>Number</th><th>Arrival-Date</th><th>Synopsis</th><th>Reported-In</th><th>Class</th><th>State</th><th>Category</th><th>HIT</th></tr>";
$blockerprbuff = "<br><center><table class='table table-bordered table-striped'><thead><tr><th colspan=14>Blocker PR details</th></tr><tr><th>Function</th><th>Number</th><th>Arrival-Date</th><th>Synopsis</th><th>Reported-In</th><th>Class</th><th>State</th><th>Problem-Level</th><th>Category</th><th>Blocker</th><th>Dev-Owner</th><th>Responsible</th><th>Originator</th><th>HIT</th></tr><tbody><blockerprs>";
$openblockerprbuff = "<br><center><table class='table table-bordered table-striped'><thead><tr><th colspan=14>Open Blocker PR details</th></tr><tr><th>Function</th><th>Number</th><th>Arrival-Date</th><th>Synopsis</th><th>Reported-In</th><th>Class</th><th>State</th><th>Problem-Level</th><th>Category</th><th>Blocker</th><th>Dev-Owner</th><th>Responsible</th><th>Originator</th><th>HIT</th></tr><tbody><blockerprs>";
$newprbuff = "<br><center><table class='table table-bordered table-striped'><thead><tr><th colspan=14>New PR details</th></tr><tr><th>Function</th><th>Number</th><th>Arrival-Date</th><th>Synopsis</th><th>Reported-In</th><th>Class</th><th>State</th><th>Problem-Level</th><th>Category</th><th>Blocker</th><th>Dev-Owner</th><th>Responsible</th><th>Originator</th><th>HIT</th></tr><tbody><newprs>";
#### RBU 
$rbuallprbuff = "<br><center><table class='table table-bordered table-striped'><thead><tr><th colspan=14>All PR details</th></tr><tr><th>Function</th><th>Number</th><th>Arrival-Date</th><th>Synopsis</th><th>Reported-In</th><th>Class</th><th>State</th><th>Problem-Level</th><th>Category</th><th>Blocker</th><th>Dev-Owner</th><th>Responsible</th><th>Originator</th><th>HIT</th></tr><tbody><allprs>";
#$rbublockerprbuff="<center><table class='table table-bordered table-striped'><thead><tr><th colspan=8>Blocker PR details</th></tr><tr><th>Function</th><th>Number</th><th>Arrival-Date</th><th>Synopsis</th><th>Reported-In</th><th>Class</th><th>State</th><th>Category</th><th>HIT</th></tr><tbody>";
$rbublockerprbuff = "<br><center><table class='table table-bordered table-striped'><thead><tr><th colspan=14>Blocker PR details</th></tr><tr><th>Function</th><th>Number</th><th>Arrival-Date</th><th>Synopsis</th><th>Reported-In</th><th>Class</th><th>State</th><th>Problem-Level</th><th>Category</th><th>Blocker</th><th>Dev-Owner</th><th>Responsible</th><th>Originator</th><th>HIT</th></tr><tbody><blockerprs>";
$rbuopenblockerprbuff = "<br><center><table class='table table-bordered table-striped'><thead><tr><th colspan=14>Open Blocker PR details</th></tr><tr><th>Function</th><th>Number</th><th>Arrival-Date</th><th>Synopsis</th><th>Reported-In</th><th>Class</th><th>State</th><th>Problem-Level</th><th>Category</th><th>Blocker</th><th>Dev-Owner</th><th>Responsible</th><th>Originator</th><th>HIT</th></tr><tbody><openblockerprs>";
$rbunewprbuff = "<br><center><table class='table table-bordered table-striped'><thead><tr><th colspan=14>New PR details</th></tr><tr><th>Function</th><th>Number</th><th>Arrival-Date</th><th>Synopsis</th><th>Reported-In</th><th>Class</th><th>State</th><th>Problem-Level</th><th>Category</th><th>Blocker</th><th>Dev-Owner</th><th>Responsible</th><th>Originator</th><th>HIT</th></tr><tbody><newprs>";
%totalbreakdown = ();
%rbubreakdown = ();
@temp = @functions;
push @temp,"ALL";
push @temp,"RBU";
push @temp,"SWIT";
foreach $func(@temp)
{

	$disp = $func;
	if($func =~ /PTX/)  { $disp = "TPTX";} 
	if($func =~ /MMX/)  { $disp = "MMX";} 
	if($func =~ /ESBU/)  { $disp = "Services";} 
	if($func =~ /JUNOS SW/)  { $disp = "Kernel/Mgmt";}
	if($func =~ /brackla/i)  { $disp = "$func";} 
$executed_buffer="<dataset seriesName=\"executed\" color=\"#0404B4\" anchorRadius='2' anchorBgColor='0404B4' anchorBorderColor='0404B4' anchorBorderThickness='2'>\n";
$overallpass_buffer="<dataset seriesName=\"overallpass\" color=\"#0B6121\" anchorRadius='2' anchorBgColor='0B6121' anchorBorderColor='0B6121' anchorBorderThickness='2'>\n";
$overallfail_buffer="<dataset seriesName=\"overallfail\" color=\"#8A0808\" anchorRadius='2' anchorBgColor='8A0808' anchorBorderColor='8A0808' anchorBorderThickness='2'>\n";
$tobedebugger_buffer="<dataset seriesName=\"tobedebugged\" color=\"#610B4B\" anchorRadius='2' anchorBgColor='610B4B' anchorBorderColor='610B4B' anchorBorderThickness='2'>\n";
$category = "";
    $query = " select day,scriptexecuted,overallpassrate,overallfailrate,tobedebugged from daily_regression_progress where release='$relstrforprogress' and function='$func' order by day";
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
	if($func =~ /ALL/) { next;}
	###### Open the PRs table for each and get the prrows for each function . this is for Total PRs
	$function_strip = $func;
	$function_strip=~ s/\//-/g;
	$file = "\"/homes/rod/public_html/Regression/report/data/$releasestr"."_".$function_strip."_prs_table\"";
	$prbuff = `cat $file`;
	#($outbuff) = $prbuff =~ /<outstanding>(.*)<outstanding>/;
	($allbuff) = $prbuff =~ /<allprs>(.*)<allprs>/;
	($allcount) = $prbuff =~ /<allcount>(.*)<allcount>/;
	$allbuff =~ s/<tr>?/<tr><td rowspan='$allcount'>$disp<\/td>/;
	($blockerbuff) = $prbuff =~ /<blockerprs>(.*)<blockerprs>/;
	($blockercount) = $prbuff =~ /<blockercount>(.*)<blockercount>/;
	($nonblockercount) = $prbuff =~ /<nonblockercount>(.*)<nonblockercount>/;
	$blockerbuff =~ s/<tr>?/<tr><td rowspan='$blockercount'>$disp<\/td>/;
	($openblockerbuff) = $prbuff =~ /<openblockerprs>(.*)<openblockerprs>/;
	($openblockercount) = $prbuff =~ /<openblockercount>(.*)<openblockercount>/;
	$openblockerbuff =~ s/<tr>?/<tr><td rowspan='$openblockercount'>$disp<\/td>/;
	($newbuff) = $prbuff =~ /<newprs>(.*)<newprs>/;
	($newcount) = $prbuff =~ /<newcount>(.*)<newcount>/;
	$newbuff =~ s/<tr>?/<tr><td rowspan='$newcount'>$disp<\/td>/;
	#$outprbuff .= $outbuff;
	$allprbuff .= $allbuff;
	$blockerprbuff .= $blockerbuff;
	$openblockerprbuff .= $openblockerbuff;
	$newprbuff .= $newbuff;
	### FOR RBU Only
	if($func =~ /MMX|ACX|PTX|BBE|ESBU|JUNOS|RPD|ROUTING NPIs|ROUTING VIRTUAL/)
	{
	($rbuallbuff) = $prbuff =~ /<allprs>(.*)<allprs>/;
    ($rbuallcount) = $prbuff =~ /<allcount>(.*)<allcount>/;
    $rbuallbuff =~ s/<tr>?/<tr><td rowspan='$allcount'>$disp<\/td>/;
    ($rbublockerbuff) = $prbuff =~ /<blockerprs>(.*)<blockerprs>/;
    ($rbublockercount) = $prbuff =~ /<blockercount>(.*)<blockercount>/;
    $rbublockerbuff =~ s/<tr>?/<tr><td rowspan='$rbublockercount'>$disp<\/td>/;
    ($rbuopenblockerbuff) = $prbuff =~ /<openblockerprs>(.*)<openblockerprs>/;
    ($rbuopenblockercount) = $prbuff =~ /<openblockercount>(.*)<openblockercount>/;
    $rbuopenblockerbuff =~ s/<tr>?/<tr><td rowspan='$rbuopenblockercount'>$disp<\/td>/;
    ($rbunewbuff) = $prbuff =~ /<newprs>(.*)<newprs>/;
    ($rbunewcount) = $prbuff =~ /<newcount>(.*)<newcount>/;
    $rbunewbuff =~ s/<tr>?/<tr><td rowspan='$rbunewcount'>$disp<\/td>/;
    #$outprbuff .= $outbuff;
    $rbuallprbuff .= $allbuff;
    $rbublockerprbuff .= $rbublockerbuff;
    $rbuopenblockerprbuff .= $rbuopenblockerbuff;
    $rbunewprbuff .= $newbuff;
	}
	
	###### now get the breakdown######
	$query = "select failure,count from regression_failure_breakdown where releasename='$relstrforprogress' and function='$func'";
	$sth1=$dbh->prepare($query);
	$sth1->execute;
	$r1=$sth1->fetchall_arrayref({});
	foreach my $ar1(@{$r1})
	{
		if(!exists $totalbreakdown{$ar1->{failure}}) { $totalbreakdown{$ar1->{failure}} = $ar1->{count};}
        else { $totalbreakdown{$ar1->{failure}} += $ar1->{count};}
	}
		
}
######## Print the  Failure Break Down Table ############################################
$buff = "<center><table class='table table-bordered table-striped'><thead><tr><th>Exit Code</th><th>Count of scripts </th></tr></thead><tbody>";
#$buff = "<center><table class='table table-bordered table-striped'><tr><thead>";
$rbubreak = "<center><table class='table table-bordered table-striped'><tr><thead>";
$c = 1;
$rbuc = 1;
foreach $br(sort keys %totalbreakdown)
{
    $buff .= "<tr><th>$br</th><td>$totalbreakdown{$br}</td></tr>";
}
$buff .= "</tbody></table>";
open(F,">/homes/rod/public_html/Regression/report/data/$releasestr"."_ALL_failbreakdown_table");
print F $buff;
close(F);
$rbubreak = "<center><table class='table table-bordered table-striped'><thead><tr><th>Exit Code</th><th>Count of scripts </th></tr></thead><tbody>";
$c = 1;
foreach $br(sort keys %rbubreakdown)
{
    $rbubreak .= "<tr><th>$br</th><td>$rbubreakdown{$br}</td></tr>";
}
$rbubreak .= "</tbody></table>";
open(F,">/homes/rod/public_html/Regression/report/data/$releasestr"."_RBU_failbreakdown_table");
print F $rbubreak;
close(F);
$outprbuff = "<center><table class='table table-bordered table-striped'><thead><tr><th colspan=6>Outstanding PR details</th></tr><tr><th>Number</th><th>Arrival-Date</th><th>Synopsis</th><th>Reported-In</th><th>Class</th><th>Category</th></tr><tbody>".$outprbuff."</tbody></table>";
#$allprbuff = "<center><table class='table table-bordered table-striped'><thead><tr><th colspan=6>All PR details</th></tr><tr><th>Number</th><th>Arrival-Date</th><th>Synopsis</th><th>Reported-In</th><th>Class</th><th>Category</th></tr><tbody>".$allprbuff."</tbody></table>";
$allprbuff .= "</tbody></table>";
$blockerprbuff .= "</tbody></table>";
$newprbuff .= "</tbody></table>";
open(F,">/homes/rod/public_html/Regression/report/data/$releasestr"."_ALL_prs_table");
print F $openblockerprbuff.$blockerprbuff.$newprbuff.$allprbuff;

$rbuallprbuff .= "</tbody></table>";
$rbublockerprbuff .= "</tbody></table>";
$rbunewprbuff .= "</tbody></table>";
open(F,">/homes/rod/public_html/Regression/report/data/$releasestr"."_RBU_prs_table");
print F $rbuopenblockerprbuff.$rbublockerprbuff.$rbunewprbuff.$rbuallprbuff;
#print F $rbuopenblockerprbuff.$rbunewprbuff.$rbuallprbuff;
close(F);
#### DEbugid tables
$header = "<center><table class='table table-bordered table-striped'>";
$headerrow = "<tr><th>Function</th>";
$datarow = "<tr><th>Links</th>";
$colcnt = 1;
foreach $func(@functions)
{
    if($hash{$func}{scriptplanned} == 0) { next;}
	$headerrow .= "<td>$func</td>";
	@debugs = split(",",$hash{$func}{debugids});
	$link = "<a href='";
	$flag = 0;
	foreach $d(@debugs)
	{
			if($flag == 0)
			{
				$link .= "https://systest.juniper.net/ti/webapp/dr/debug_dr/index.mhtml?result_id=$d' target='_blank'";
				$flag=1;
			}
			else
			{
				if($flag == 1)
				{		
				$link1 = "https://systest.juniper.net/ti/webapp/dr/debug_dr/index.mhtml?result_id=$d";
					$link .= "onclick=\"window.open('$link1'); ";
					$flag++;
				}
				else
				{
					$link1 = "https://systest.juniper.net/ti/webapp/dr/debug_dr/index.mhtml?result_id=$d";
						$link .= "window.open('$link1'); ";
						$flag++;
				}
			}
		}
		#if($flag > 0) { $link .= "'>Click Here</a>";}
		if($flag == 0) { $link .= "'>Click Here</a>";}
		else{ $link .= "\">Click Here</a>";}
		$datarow .= "<td>$link</td>";
		$colcnt++;
}
$headerrow .= "</tr>";
$datarow .= "</tr>";
$header .="<tr><th colspan=$colcnt>Debug Page Links</th></tr>";
$rbubreak = $header.$headerrow.$datarow."</table>";
if($releasestr =~ /15-1R1/)
{
	$rbubreak .= "<table><tr><th colspan=5>Heat Map</th></tr</table>";
	$rbubreak .= "<tr><td>Functions</td><td>MMX</td><td>T/TX/PTX</td><td>Services</td><td>RPD</td></tr>";
	$rbubreak .= "<tr><td>Links</td><td><a href='http://rbu.juniper.net/RegReport/Debug_15.1R1.html' target='_blank'>Click Here</a></td>";
	$rbubreak .= "<td><a href='http://rbu.juniper.net/RegReport/Debug_TPTX15.1R1.html' target='_blank'>Click Here</a></td>";
	$rbubreak .= "<td><a href='http://rbu.juniper.net/RegReport/Debug_Services15.1R1.html' target='_blank'>Click Here</a></td>";
	$rbubreak .= "<td><a href='http://rbu.juniper.net/RegReport/Debug_RPD15.1R1.html' target='_blank'>Click Here</a></td></tr></table>";
}
open(F,">/homes/rod/public_html/Regression/report/data/$releasestr"."debuglinks");
print F $rbubreak;
close(F);
#print F $rbuopenblockerprbuff.$rbunewprbuff.$rbuallprbuff;
close(F);
#### Now to get the respin data ##########################
foreach $debugid(@res_id)
{
	my $eid_query= "select result_id from er_regression_result where parent_result_id=$debugid";
	my @res =db_get_all_rows($eid_query);
	$query = "delete from  regression_respin where release='$releasestr' and function='$function'";
    $sth=$dbh->prepare($query);
    $sth->execute;
foreach $r(@res)
{
	#### Get the name
	$namequery = "select name from er_regression_result where result_id=$r->{result_id}";
	my @nameres =db_get_all_rows($namequery);
	#### now get th respin status from the execution table ######
	my $respin_query = "select debug_exitcode,prs from er_debug_exec where result_id='$r->{result_id}'";
	my @respinres =db_get_all_rows($respin_query);
	$executed = 0;	
	$failed = 0;	
	$passed = 0;	
	$prs ="";
	%pr_hash = ();
	foreach $respin(@$respinres)
	{
		$executed++;
		if($respin->{debug_exitcode} =~ /PASS/) { $passed++;}
		if($respin->{debug_exitcode} =~ /FAIL/) { $failed++;}
		if($respin->{prs} !~ /^$|^\s+$|-/) {
		$pr = $respin->{prs};
		$pr =~ s/o|n|N|O\s+//g;
		if(!exists $pr_hash{$pr}) { $pr_hash{$pr} = 1;}
		}
			
	}
	$prstr  = join("+",keys %pr_hash);
	$query = "insert into regression_respin values('$releasestr',$r->{result_id},$executed,$passed,$failed,'$prstr','$function','$nameres[0]->{name}')";
	$sth=$dbh->prepare($query);
	$sth->execute;
}
}

`rm -f debugbreak.$$ respin.$$ prs.$$ out.$$ fdbg.$$`;

print "\nDone\n";
sub getbuilddate
{
    my $b = shift;
$query = "select start  from regression_milestone where releasestring='$b'";
my $sth=$dbh1->prepare($query);
    $sth->execute;
     my $r=$sth->fetchall_arrayref({});
	foreach my $ar(@{$r})
    {
		return $ar->{start};
	}
}
sub getdiff
 {
     $start = shift;
     $end = shift;
     ($y1,$m1,$d1) = $start =~ /(\d+)-(\d+)-(\d+)/;
     ($y2,$m2,$d2) = $end =~ /(\d+)-(\d+)-(\d+)/;
     $Dd = Date::Calc::Delta_Days($y1,$m1,$d1, $y2,$m2,$d2);
     return $Dd;
 }
sub getfirstdebugdate
{
    $rel1 = shift;
    $query = "select drnames from regressionreport where releasename='$rel1'";
    my $sth=$dbh->prepare($query);
    $sth->execute;
    my $r=$sth->fetchall_arrayref({});
    $cond = "(";
    foreach my $ar(@{$r})
    {
        @tmp = split(",",$ar->{drnames});
        foreach $t(@tmp)
        {
            $cond .="'$t',";
        }
    }
    chop($cond);
    $cond .= ")";
    $rescond = "(";
    my $q1= "select result_id from er_regression_result where name in $cond and parent_result_id='0'";
print $q1;
    @res = db_get_all_rows($q1);
foreach $r(@res)
{
    $rescond .= "$r->{result_id},"
}
chop($rescond);
$rescond .= ")";
my $q2 = "select  debug_updated from er_debug_exec a, er_regression_result b where (b.result_id in $rescond or b.parent_result_id in $rescond) and a.result_id=b.result_id order by debug_updated limit 1";
@res = db_get_all_rows($q2);
foreach $r(@res)
{
    ($fd) =  $r->{debug_updated} =~ /(.*)\s+/;
    return $fd;
}
}

					
	

