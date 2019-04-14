<?php
$function = $_GET['function'];
$buff = "";
$function = preg_replace('/\s+/','_',$function);
if(preg_match('/TPTX/',$function)) { $function = "T/TX/PTX";}
$dbh = pg_connect('host=eabu-systest-db password =postgres.juniper.net dbname=regression user=postgres password=postgres');
        if (!$dbh)
            die("Error in connection: " . pg_last_error());
$str ="";
/* Make the table header */
$query = "select ord from firstpassorder where function='$function'";
$result = pg_query($dbh, $query);
$ord = "";
while ($row = pg_fetch_array($result)) {
	$ord = $row[0];
}
$ord = preg_replace('/,/','</th><th>',$ord);
$ord = "<table style='width:70%;'><thead><tr><th>Release</th><th>".$ord."</tr></thead>";
	
$query = "select passstr from firstpassres where function='$function' order by release";
    $result = pg_query($dbh, $query);
    $count = 0;
    while ($row = pg_fetch_array($result)) {
	$ord .= $row[0];
	}
$ord .= "</table>";
print "$ord";
?>
