<?php
$release = $_GET['release'];
$function = $_GET['function'];
$dr_ids = $_GET['dr_ids'];
$planned_release = $_GET['planned_release'];
$milestone = $_GET['milestone'];
if(preg_match('/PTX/',$function))
{
	$function="TPTX";
}
$dbh = pg_connect('host=eabu-systest-db password =postgres.juniper.net dbname=regression user=postgres password=postgres');
        if (!$dbh)
            die("Error in connection: " . pg_last_error());
$query = "select count(*) from fpconfig where releasename='$release' and function='$function' and  milestone='$milestone'";   /* get the distinct release */
    $result = pg_query($dbh, $query);
	$count = 0;
    while ($row = pg_fetch_array($result)) {
		$count = $row[0];
	}
	if($count == 0)  ////insert
	{
		$query = "insert into fpconfig values('$release','$function','$dr_ids','$planned_release','$milestone')";
		$result = pg_query($dbh, $query);
		if (!$result) 
			die("Error in SQL query: " . pg_last_error());
	}
	else //update
	{
			$query = "update fpconfig set releasename='$release',function='$function',drids='$dr_ids',plannedrelease='$planned_release' ,milestone='$milestone' where releasename='$release' and function='$function' and  milestone='$milestone'";
			$result = pg_query($dbh, $query);
        if (!$result) 
			die("Error in SQL query: " . pg_last_error());
    }
		
#$res = shell_exec("/homes/rod/public_html/Regression/report/report.pl $dr_names $planned_release \"$release\" $function");
?>
