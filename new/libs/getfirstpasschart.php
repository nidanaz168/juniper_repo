<?php
$function = $_GET['function'];
$release = $_GET['release'];
$buff = "";
$function = preg_replace('/\s+/','_',$function);
$chart = "<chart palette='2' caption='First Pass' xAxisName='Milestones' yAxisName='First Pass %' showValues='1' decimals='0' formatNumberScale='0'>";


$dbh = pg_connect('host=eabu-systest-db password =postgres.juniper.net dbname=regression user=postgres password=postgres');
        if (!$dbh)
            die("Error in connection: " . pg_last_error());
$query = "select ord from firstpassorder where function='$function'";
$result = pg_query($dbh, $query);
$ord = "";
while ($row = pg_fetch_array($result)) {
    $ord = $row[0];
}
$ordarr = explode(",",$ord);

$str ="";
/* Make the table header */
$query = "select passstr from firstpassres where function='$function' and release ='$release'";
    $result = pg_query($dbh, $query);
    while ($row = pg_fetch_array($result)) {
	$str .= $row[0];
	}
$str = preg_replace('/<\/td><\/tr>/',"",$str);
$arr = explode("</td><td>",$str);
array_shift($arr);
$count = 0;
foreach ($arr as $pass)
{
	$chart .= "<set label='$ordarr[$count]' value='$pass' />";
	$count++;
}
$chart .= "<styles><definition><style name='myAnim' type='animation' param='_yScale' start='0' duration='1'/></definition><application><apply toObject='VLINES' styles='myAnim' /></application></styles></chart>";
print "$chart";
?>
