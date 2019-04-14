<?php
$release = $_GET['release'];
$function = $_GET['function'];
$script_planned = $_GET['script_planned'];
$dr_names = $_GET['dr_names'];
$planned_release = $_GET['planned_release'];
$active = $_GET['active'];
$debugstart = $_GET['debugstart'];
$debugend = $_GET['debugend'];
$rel_tag = $_GET['rel_tag'];
$dbh = pg_connect('host=jdi-reg-tools dbname=regression user=postgres password=postgres');
$dbh1 = pg_connect('host=jdi-reg-tools  dbname=regression user=postgres password=postgres');
if (!$dbh) die("Error in connection: " . pg_last_error());
$query = "select count(*) from regressionreport where releasename='$release' and function='$function'";   /* get the distinct release */
$result = pg_query($dbh, $query);
$count = 0;
while ($row = pg_fetch_array($result)) {
    $count = $row[0];
}


if($count == 0)  ////insert
{
    $query = "insert into regressionreport (releasename,function,scriptplanned,drnames,plannedrelease,scriptexecuted,firstrunpassrate,overallpassrate,overallfailrate,tobedebugged,totalscriptpassed,totalscriptfailed,completeddebugcount,totaldebugcount,debugper,totalfirstrunpass,totalfirstrunscript,newprs,allprs,blockerprs,respindebugcount,respincompleteddebug,respinpendingdebug,respincompleteddebugper,openblockerprs,debugstart,debugend,rel_tag) values('$release','$function',$script_planned,'$dr_names','$planned_release',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'$debugstart','$debugend','$rel_tag')";
    $result = pg_query($dbh, $query);
    if (!$result) 
        die("Error in SQL query: " . pg_last_error());
}
else //update
{
    $query = "update regressionreport set rel_tag='$rel_tag', releasename='$release',function='$function',scriptplanned='$script_planned',drnames='$dr_names',plannedrelease='$planned_release' ,debugstart='$debugstart',debugend='$debugend' where releasename='$release' and function='$function';";
    $result = pg_query($dbh, $query);
    if (!$result)  die("Error in SQL query: " . pg_last_error());
########## added by nida for getting release tag#####################

    $query = "update regressionreport set rel_tag='$rel_tag' where releasename='$release';";
    print $query;
    $result = pg_query($dbh, $query);
#########################################
}

$mainrelmap = array();
$query = "select release,main_release,main_order from regression_report_releasedetails order by main_order asc";
$high = 0;
$result = pg_query($dbh1, $query);		
while ($row = pg_fetch_array($result)) {
    $high = $row[2];
    $mainrelmap[$row[1]] = $row[2];
}
$query = "select count(*) from releases where release='$release'";   /* get the distinct release */
$result = pg_query($dbh, $query);
$count = 0;
while ($row = pg_fetch_array($result)) {
    $count = $row[0];
}
if($count == 0)  ////insert
{
    $query = "insert into releases values ('$release','$active')";
    $result = pg_query($dbh, $query);
    echo "$query";
    if (!$result) 
        die("Error in SQL query: " . pg_last_error());
    $regtype = "Full Regression";
    if(preg_match("/-Sanity/", $release)) $regtype = "Sanity Test";
    else if(preg_match("/^([0-9]+).([0-9]+)R([0-9]+)$/", $release)) $regtype = "Full Regression";
    else if(preg_match("/^([0-9]+).([0-9]+)R([0-9]+)-([0-9a-zA-Z-]+)$/", $release)) $regtype = "Partial Regression";
    $mainrel = "";
    $main_order = "";
    $matches =  array();
    preg_match("/(^[0-9]*.[0-9]*)/", $release, $matches);
    if(preg_match("/DCB|DEV|Dev|dev/", $release)){ $mainrel = "DEV_COMMON"; $main_order = 1; }
    else if(isset($mainrelmap[$matches[1]])){ $mainrel = $matches[1]; $main_order = $mainrelmap[$matches[1]]; }
    else { $mainrel = $matches[1]; $main_order = $high + 1; }

    $query1 = "insert into regression_report_releasedetails(release,releasestring,regtype,gnatsstring,main_release,main_order) values('$release','$release','$regtype','$planned_release','$mainrel','$main_order')";
    $result = pg_query($dbh1, $query1);
}
else //update
{
    $query = "update releases set active='$active' where release='$release'";
    echo "$query";
    $result = pg_query($dbh, $query);
    if (!$result) die("Error in SQL query: " . pg_last_error());
}
//now trigger the report generation
print "perl /var/www/html/CI_Report/report.pl $dr_names $planned_release $release $function";
$res = shell_exec("perl  /var/www/html/CI_Report/report.pl \"$dr_names\" \"$planned_release\" \"$release\" \"$function\"");
echo "result:$res";
?>
