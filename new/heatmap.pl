#!/usr/bin/perl
use HTML::TableExtract;
use Data::Dumper;
use DBI;
use POSIX;
### Db connection 
my $hostname = 'eabu-systest-db.juniper.net';
my $user = "postgres";
my $pass = "postgres";
my $port = "5432";
my $dsn = "dbi:Pg:database=eabu_rod;host=$hostname;port=$port";
my $dbh = DBI->connect($dsn,$user,$pass)
                or die "Couldn't connect to database ".DBI->errstr;
# DB-RM
my $db_rm = DBI->connect("dbi:Pg:database=systest_live;host=ttpgdb.juniper.net;port=$port", "ext_ft_dr_gui_rw", 'ext_ft_dr_gui_rw') or die "Could not connect to DB".DBI->errstr; 

$release = $ARGV[0];
$releasemap = $ARGV[0];
$func = $ARGV[1];
$event_id = $ARGV[2];
if($func =~ /PTX/)
{
	$func = "TPTX";
}
### get the rules
@events = split(",",$event_id);
@drids = ();
$result_id = "";
$today = `date "+%Y-%m-%d"`;
foreach $e(@events)
{
#my $eid_query= "select a.result_id,b.regression_exec_id from er_regression_result a,er_regression_result b where (a.name='$e' and a.parent_result_id='0') and (a.result_id=b.parent_result_id or a.result_id=b.result_id)";
my $eid_query= "select result_id from er_regression_result where (name='$e' and parent_result_id='0')";
my @res =db_get_all_rows($eid_query);
push @drids , $res[0]->{result_id}
}
#($drs) = $rules =~ /:(.*)/;
#@drids = split(",",$drs);
%test_hash = ();
my %test_id_mapping = ();
foreach $dr(@drids)
{
=cut
	my @result_ids = db_get_all_rows("select result_id from er_debug_exec where result_id in (select result_id from er_regression_result where result_id in ($dr) or parent_result_id in ($dr) order by result_id) group by result_id order by result_id");
foreach my $result_id (@result_ids) {       
	my @scripts_result = db_get_all_rows("select a.test_id,a.test_exec_id,b.debug_exitcode,b.prs from test_exec a, er_debug_exec b where result_id=$result_id->{result_id} and a.test_exec_id=b.test_exec_id and b.display_flag=1");  
	foreach my $line (@scripts_result) {
	$test_id_mapping{$line->{test_id}} = $line->{test_exec_id};
	}
}
=cut
print "$dr \n";
	
	$out  = `wget -o log -O out --http-user=sooraj --http-password=King_123 http://systest.juniper.net/ti/webapp/dr/debug_dr/view/gen_tl9000_report.mhtml?result_id=$dr&trans=remove`;
$te = HTML::TableExtract->new( attribs => { id => "table1" } );
 $te->parse_file("out");
 foreach $ts ($te->tables) {
	@rc = 	$ts->rows;
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
					if(($row->[$i] =~ /P/) && ($test_id !~ /^$/)) #### Pass
					{
						$test_hash{$test_id}{result} = "PASS";
						 $test_hash{$test_id}{prs} = "";
						$stat_found = 1;
					}
					elsif(($row->[$i] =~ /F/) && ($test_id !~ /^$/)) #### Faile
					{
						$test_hash{$test_id}{result} = "FAIL";
						($prs) = $row->[$i] =~ /F(.*)/;
						$test_hash{$test_id}{prs} = $prs;
						$stat_found = 1;
					}
					elsif(($row->[$i] =~ /-/) && ($test_id !~ /^$/)) #### To be debugged
					{
						if($stat_found == 0)
						{
							$test_hash{$test_id}{result} = "DEBUG";
						}
					}
				}
			}

   }
 }
 }
my $prstring = "";
 my @testids = keys %test_hash;
$c = @testids;
open(F,">>$func"."_tid");
foreach(@testids)
{
	print F "$_\n";
}
close(F);
my $crieteria = join(",",@testids);
 $crieteria = "(".$crieteria.")";
 my $query = "select category,area,subarea,test_id from script_owner where test_id in $crieteria";
 my $sth=$dbh->prepare($query);
$sth->execute;
my $r=$sth->fetchall_arrayref({});
my %script_hash = ();
my %module_stats = ();
$c = @{$r};
print "Total count $c \n";
foreach my $ar(@{$r})
{
	if($test_hash{$ar->{test_id}}{result} =~ /PASS/)   ### Passed ones
	{
		if(!defined($script_hash{$ar->{category}}{$ar->{area}}{$ar->{subarea}}))
            {   $script_hash{$ar->{category}}{$ar->{area}}{$ar->{subarea}}{passcount} = 1; $script_hash{$ar->{category}}{$ar->{area}}{$ar->{subarea}}{count} = 1;
                 $script_hash{$ar->{category}}{$ar->{area}}{$ar->{subarea}}{testids} = "$ar->{test_id}:$test_id_mapping{$ar->{test_id}},";
             }
             else
            {
                     $script_hash{$ar->{category}}{$ar->{area}}{$ar->{subarea}}{passcount}++;
                      $script_hash{$ar->{category}}{$ar->{area}}{$ar->{subarea}}{count}++;
                    $script_hash{$ar->{category}}{$ar->{area}}{$ar->{subarea}}{testids} .= "$ar->{test_id}:$test_id_mapping{$ar->{test_id}},";
              }
		 if(!defined($module_stats{$ar->{category}}))
               {
                   $module_stats{$ar->{category}}{passcount} = 1;
                   $module_stats{$ar->{category}}{count} = 1;
               }
               else
               {
                   $module_stats{$ar->{category}}{passcount}++;
                    $module_stats{$ar->{category}}{count}++;
                }
            } ### Pssed
			elsif($test_hash{$ar->{test_id}}{result} =~ /FAIL/)  ## Failed
			{
			$script_hash{$ar->{category}}{$ar->{area}}{$ar->{subarea}}{failedcount}++;
                      $script_hash{$ar->{category}}{$ar->{area}}{$ar->{subarea}}{count}++;
                 $script_hash{$ar->{category}}{$ar->{area}}{$ar->{subarea}}{testids} .= "$ar->{test_id}:$test_id_mapping{$ar->{test_id}},";
				 $script_hash{$ar->{category}}{$ar->{area}}{$ar->{subarea}}{prs} .= " ".$test_hash{$ar->{test_id}}{prs};
				 $t = $test_hash{$ar->{test_id}}{prs};
				 $t =~ s/o|O//g;
                $t =~ s/new|New//g;
                $t =~ s/n|N//g;
                $t =~ s/^\s+//;
                $t =~ s/-//;
                    $t =~ s/\s+$//;
                chomp($t);
                #$prstring .= "Number == \"$t\"|";
				$prstring .= " $t";

               if(!defined($module_stats{$ar->{category}}))
               {
                   $module_stats{$ar->{category}}{failedcount} = 1;
                   $module_stats{$ar->{category}}{count} = 1;
               }
			   else
			   {
			       $module_stats{$ar->{category}}{failedcount}++;
			        $module_stats{$ar->{category}}{count}++;
			    }
		}
		else ### Debugged
		{
				if(!defined($module_stats{$ar->{category}}))
               {
                   $module_stats{$ar->{category}}{debugcount} = 1;
                   $module_stats{$ar->{category}}{count} = 1;
               }
               else
               {
                   $module_stats{$ar->{category}}{debugcount}++;
                    $module_stats{$ar->{category}}{count}++;
				}
		}
}
my %cat_map = ();
my %failed_hash = ();
my %temp_hash = ();
my $buff="";
chop($prstring);
$prstring =~ s/\D/ /g;
my %pr_stats = ();
#$prstring .= ")";
getPRStats($prstring , \%pr_stats);
open(F,">heatmap/$func"."_$releasemap".".dat");
#print Dumper(\%script_hash);
foreach my $cat(keys %script_hash)
{
		if($cat =~ /^$/) { next ;}
        my $cat1 = lc($cat);
        $cat1 .="det";

        $buff .= "<div id='$cat1' style='width:100%;position:absolute;top:50px;left=10px;display:none;'>\n";
        $buff .= "<head><table style='width:100%;' class='select table-bordered table-big' border=1><thead><th>Regression Results Reporting for $cat</th></tr></thead></table><table class='mission table-bordered table-big' border=1><tr><thead><th>
Area</th><th>Sub Area</th><th>Target Script Count</th><th>Actual Execution</th><th>Pass Rate % </th><th>PRs</th>";
        $buff .= "</thead></tr><head>\n";
		foreach my $area(keys %{$script_hash{$cat}})
        {
        my @subs = keys %{$script_hash{$cat}{$area}};
        my $cnt = @subs;
        my $cap_area = uc($area);
        $buff .= "<tr><td rowspan=$cnt>$cap_area</td>\n";
        my $color = "green";
        foreach my $subarea(keys %{$script_hash{$cat}{$area}})
        {
            my $count = getScriptCount($area,$subarea);
			if(defined ($script_hash{$cat}{$area}{$subarea}{prs}))
            {
                ##Check the PRstatus
                my $ret = checkPRStatus($script_hash{$cat}{$area}{$subarea}{prs},$reg_id1);
                if($ret == 1)
                {
                    $color = "red";
                    if(!defined($summary{$cat}{$subarea})) { $summary{$cat}{$subarea} = "RED";}
                }
                elsif($ret == 2)
                {
                    $color = "yellow";
                    if(!defined($summary{$cat}{$subarea})) { $summary{$cat}{$subarea} = "YELLOW";}
                }
                else
                {
                    $color = "green";
                }

            } else { $color = "green";}
            my $cap_subarea = uc($subarea);
            $buff .= "<cat><$cat:$area:$subarea><cat><td>$cap_subarea</td><td>$count</td><td>$script_hash{$cat}{$area}{$subarea}{count}  <a href=javascript:showdetails('http://eabu-systest-db.juniper.net/Regression/get_script_details.php?ids=".$script_hash{$cat}{$area}{$subarea}{testids}."')>Details</a></td>";
            #if(exists $script_hash{$cat}{$area}{$subarea}{passcount}) { $buff .= "<td>$script_hash{$cat}{$area}{$subarea}{passcount}</td>";}
            #else { $buff .= "<td>0</td>"; }
            #if(exists $script_hash{$cat}{$area}{$subarea}{failedcount}) { $buff .= "<td>$script_hash{$cat}{$area}{$subarea}{failedcount}</td>";}
            #else { $buff .= "<td>0</td>"; }
            my $per = ($script_hash{$cat}{$area}{$subarea}{passcount} / $script_hash{$cat}{$area}{$subarea}{count}) * 100;
            my $per1 = floor($per);
             $buff .= "<td>$per1</td>";
             my $prstr = $script_hash{$cat}{$area}{$subarea}{prs};
             $script_hash{$cat}{$area}{$subarea}{prs} =~ s/o|O|n/ /g;
             $script_hash{$cat}{$area}{$subarea}{prs} =~ s/(\w+\s)\1/$1 /g;
             my @t = split(" ",$script_hash{$cat}{$area}{$subarea}{prs});
             my $dispstr = "";
             my $prfordat = "";
             foreach my $t1(@t)
             {
				 if($pr_stats{$t1} > 0 )
				{
                 if($dispstr !~ /$t1/)
                 {
                     $dispstr .= " $t1";
                     $prfordat .= "+$t1";
                 }
				}
             }
             $prstr =~ s/o|n/+/g;
                $buff .= "<td class='$color'><a href='https://gnats.juniper.net/web/default/do-query?adv=0&prs=$prstr".$gnats_column."' target='_blank'>$dispstr</a></td></tr><tr
>\n";
                print F "$cat:$area:$subarea:$color:$prfordat\n";
         }
     }
     $buff .= "</table>";
	$buff .= "</div>";

}
close(F);
        #print Module wise summary
        #### Open the mail file
        open(MAIL,">status_mail.html");
        print MAIL "<html>\n";
        print MAIL "<style type=\"text/css\">\n";
        my $css = `cat mission.css`;
        print MAIL $css;
         print MAIL "</style>\n";
        print MAIL " <link rel='stylesheet' href='http://eabu-systest-db.juniper.net/Regression/mission.css' type='text/css'>\n";
        print MAIL "<table class='mission' ><tr><td style='background-color:#B9C9FE;'> This is a auto generated maildo not reply to this mail </td></tr></table>\n";
        #$buff .= "<div id='summarydet' style='width:100%;position:absolute;top:50px;left=10px;'>\n";
        $buff .= "<div id='summarydet' style='width:100%;'>\n";
        print MAIL "<div id='summarydet' style='width:100%;position:absolute;top:50px;left=10px;'>\n";
              $buff .= "<table class='mission table-bordered table-big' border=1><tr><thead><th colspan=5>Brief Summary of functional areas in regression testing</th></tr>\n";
              print MAIL "<table class='mission'><tr><thead><th colspan=5>Brief Summary of functional areas in regression testing</th></tr>\n";
               $buff .= "<tr><th>Module</th><th>Scripts Executed</th><th>Scripts Passed</th><th>% Pass rate</th><th>To Be Debugged</th></thead></tr>\n";
               print MAIL "<tr><th>Module</th><th>Scripts Executed</th><th>Scripts Passed</th><th>% Pass rate</th><th>To Be Debugged</th></thead></tr>\n";
               my $totalscript = 0;
               my $totalpassed = 0;
               my $totaltobedebugged = 0;
        foreach my $mod(sort keys %module_stats)
        {
			if($mod =~ /^$/) { next ;}
            my $per = ($module_stats{$mod}{passcount}/$module_stats{$mod}{count}) * 100;
            my $per1 = floor($per);
            my $color = "";
            if(($per1 <95) && ($per1 >= 92)) { $color = "yellow";}
             if($per1 < 92) { $color = "red";}
             my $mod1 = uc($mod);
            $buff .= "<tr><td>$mod1</td><td>$module_stats{$mod}{count}</td><td>$module_stats{$mod}{passcount}</td>\n";
            print MAIL "<tr><td>$mod1</td><td>$module_stats{$mod}{count}</td><td>$module_stats{$mod}{passcount}</td>\n";
            #calculate %
             $buff .= "<td class='$color'>$per1</td>\n";
             print MAIL "<td class='$color'>$per1</td>\n";
            if(defined($module_stats{$mod}{debugcount}))
            {
                $buff .= "<td>$module_stats{$mod}{debugcount}</td></tr>\n";
                print MAIL "<td>$module_stats{$mod}{debugcount}</td></tr>\n";
                $totaltobedebugged += $module_stats{$mod}{debugcount};
            }
            else
            {
                 $buff .= "<td>0</td></tr>\n";
                 print MAIL "<td>0</td></tr>\n";
            }
             $totalscript += $module_stats{$mod}{count};
             $totalpassed += $module_stats{$mod}{passcount};
			 }
         my $color="";
		my $totalper = 0;
		if($totalscript > 0)
		{
         $totper = ($totalpassed/$totalscript) * 100;
		}
         my $totper1 = floor($totper);
          if(($totper1 <95) && ($totper1 >= 92)) { $color = "yellow";}
          if($totper1 < 92) { $color = "red";}
         $buff .= "<tr><td><b>Total</td><td><b>$totalscript</td><td><b>$totalpassed</td>\n";
         print MAIL "<tr><td><b>Total</td><td><b>$totalscript</td><td><b>$totalpassed</td>\n";
         $buff .= "<td class='$color'><b>$totper1</td><td>$totaltobedebugged</td></tr>\n";
         print MAIL  "<td class='$color'><b>$totper1</td><td>$totaltobedebugged</td></tr>\n";
          $buff .= "</table>\n";
          print MAIL "</table></div>\n";
          print MAIL "</html>\n";
          close(MAIL);

        my $header = "<table class='mission table-bordered table-big' border=1><thead><tr><th></th><th>Areas in Yellow</th><th>Areas in Red</th></thead></tr>\n";
        my $summarybuffer ="";
        foreach my $cat(keys %summary)
        {
            my $yellow = "";
            my $red = "";
            my $yelowcount = 0;
            my $redcount = 0;
            my $count = keys %{$summary{$cat}};
            $count = $count+1;
            $summarybuffer .= "<tr><td rowspan=$count>$cat</td>\n";

            foreach my $s(keys  %{$summary{$cat}})
            {
                my $s1 = uc($s);
                if($summary{$cat}{$s} =~ /YELLOW/)
                {
                    $yellow .= "<tr><td class='yellow'>$s1</td><td></td></tr>\n";
                }
                if($summary{$cat}{$s} =~ /RED/)
                {
                    $red .= " <tr><td></td><td class='red'>$s1</td></tr>\n";
                }
            }
            $summarybuffer .= $yellow.$red;


        }
		 $buff .= $header;
         $buff .=  $summarybuffer;
         $buff .= "</table>\n";
           $buff .= "</div>\n";





if((defined($releasemap)) && ($releasemap !~ /^$/))
{
	print "Writing to file Debug_".$releasemap.".html \n";
    open(F,">heatmap/$func"."_Debug_".$releasemap.".html");
    print F $buff;
    close(F);
}
sub db_get_all_rows {
    my $query = shift;
    my $dbrm = $db_rm->prepare($query);
    $dbrm->execute();
    my $q_out = $dbrm->fetchall_arrayref({});
    $dbrm->finish();
    return @{$q_out};
}
sub getPRStats
{
    my $query = shift;
	print "Query $query \n";
    my $hash = shift;
	#### Get the planned release
	$out = `grep $release: planned_release_map`;
    my ($release1) = $out =~ /:(.*)/;
	chomp($release1);
    $release1 =~ s/\./\\\./g;
    #my @out = `/usr/local/bin/query-pr --expr '($query) & (planned-release ~ "$release1")' --format '"%s :&:&:%s:&:&:%s:&:&:" Number Blocker State'`;
    my @out = `/usr/local/bin/query-pr $query --expr '(planned-release ~ "$release1")' --format '"%s :&:&:%s:&:&:%s:&:&:" Number Blocker State'`;
    foreach my $line(@out)
    {
         my @temp = split(":&:&:",$line);
         my ($pr) = $temp[0] =~ /(.*)-/;
         if(($temp[1] !~ /^$/) && ( $temp[2] =~ /open|info|analyzed/))
         {
             $hash->{$pr}  = 1;
         }
         elsif(  $temp[2] =~ /open|info|analyzed/ )
         {
             $hash->{$pr}  = 2;
         }
         else
         {
             $hash->{$pr}  = 0;
         }
     }
 }
sub checkPRStatus
{
    my $prs = shift;
    my $dids = shift;
    my $val = 0;
    $prs =~ s/n|o|N|O//g;
    my @prs1 = split(' ',$prs);
    foreach my $p(@prs1)
    {
        if($pr_stats{$p} == 1)
        {
            return 1;
        }
        if($pr_stats{$p} == 2)
        {
            $val = 2;
        }

    }
    return $val;
}

	


	
sub getdrids
{
	my $rule = shift;
	my @ret = ();
	($sub) = $rules =~ /:(.*)/;
	@subrel = split(",",$sub);
	foreach $rel(@subrel)
	{
		$out = `grep $rel release_map`;
		chomp($out);
		($dr) = $out =~ /:(.*)/;
		@tmp = split(",",$dr);
		push @ret , @tmp;
	}
	return @ret;
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
	my $query = "select test_id from script_owner where script like '%$script' and function='$func'";
	my $sth=$dbh->prepare($query);
	$sth->execute;
	 my $r=$sth->fetchall_arrayref({});
	foreach my $ar(@{$r})
	{
		return $ar->{test_id};
	}
}
sub getScriptCount
{
 my $area = shift;
 my $subarea = shift;
  my $query = "select count(*) from script_owner where area='$area' and subarea='$subarea' and function='$func'";
     my $sth=$dbh->prepare($query);
    $sth->execute;
    my $r=$sth->fetchall_arrayref({});
    foreach my $ar(@{$r})
    {
        return $ar->{'count'};
    }

}







$dbh->disconnect();



		

	

