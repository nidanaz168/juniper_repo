<?php
$release = $_GET['release'];
$function = $_GET['function'];
$function = preg_replace('/\//',"-",$function);
$buff = "";
    $dblinks = file_get_contents("/var/www/html/CI_Report/data/".$release."debuglinks", FILE_USE_INCLUDE_PATH);
    $breakdown = file_get_contents("/var/www/html/CI_Report/data/".$release."_".$function."_failbreakdown_table", FILE_USE_INCLUDE_PATH);
$buff .= "<br><h1>Failure Breakdown</h1>".$breakdown;
print $buff;
?>
