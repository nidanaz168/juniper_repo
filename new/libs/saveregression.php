<?php
$release = $_GET['release'];
$function = $_GET['function'];
$script_planned = $_GET['script_planned'];
$dr_names = $_GET['dr_names'];
$planned_release = $_GET['planned_release'];
$active = $_GET['active'];
$debugstart = $_GET['debugstart'];
$debugend = $_GET['debugend'];
$dbh = pg_connect('host=eabu-systest-db password =postgres.juniper.net dbname=regression user=postgres password=postgres');
        if (!$dbh)
            die("Error in connection: " . pg_last_error());
$query = "select count(*) from regressionreport where releasename='$release' and function='$function'";   /* get the distinct release */
    $result = pg_query($dbh, $query);
	$count = 0;
    while ($row = pg_fetch_array($result)) {
		$count = $row[0];
	}
	if($count == 0)  ////insert
	{
		$query = "insert into regressionreport values('$release','$function',$script_planned,'$dr_names','$planned_release',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'$debugstart','$debugend')";
		$result = pg_query($dbh, $query);
		if (!$result) 
			die("Error in SQL query: " . pg_last_error());
	}
	else //update
	{
			$query = "update regressionreport set releasename='$release',function='$function',scriptplanned='$script_planned',drnames='$dr_names',plannedrelease='$planned_release' ,debugstart='$debugstart',debugend='$debugend' where releasename='$release' and function='$function'";
			$result = pg_query($dbh, $query);
        if (!$result) 
			die("Error in SQL query: " . pg_last_error());
    }
		
$query = "select count(*) from releases where release='$release'";   /* get the distinct release */
    $result = pg_query($dbh, $query);
	$count = 0;
    while ($row = pg_fetch_array($result)) {
		$count = $row[0];
	}
	if($count == 0)  ////insert
	{
		$query = "insert into releases values('$release','$active')";
		$result = pg_query($dbh, $query);
		if (!$result) 
			die("Error in SQL query: " . pg_last_error());
	}
	else //update
	{
			$query = "update releases set active='$active' where release='$release'";
			$result = pg_query($dbh, $query);
        if (!$result) 
			die("Error in SQL query: " . pg_last_error());
    }
//now trigger the report generation
print "/homes/rod/public_html/Regression/report/report_v4.pl $dr_names $planned_release $release $function";
$res = shell_exec("/homes/rod/public_html/Regression/report/report.pl $dr_names $planned_release \"$release\" $function");
?>
