<?php
$release = $_GET['release'];
$function = $_GET['function'];
$milestone = $_GET['milestone'];
$dbh = pg_connect('host=eabu-systest-db password =postgres.juniper.net dbname=regression user=postgres password=postgres');
        if (!$dbh)
            die("Error in connection: " . pg_last_error());
$str =""; 
$query = "select * from fpconfig where releasename='$release' and function='$function' and milestone='$milestone'";   /* get the distinct release */
    $result = pg_query($dbh, $query);
	$count = 0;
    while ($row = pg_fetch_array($result)) {
		$str .= $row[0]."&";
		$str .= $row[1]."&";
		$str .= $row[2]."&";
		$str .= $row[3]."&";
		$str .= $row[4]."&";
		$count++;
	}
	if($count == 0) { $str="$release& & & & & & &";}
		
print "$str";
?>
