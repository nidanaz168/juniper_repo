<?php
$release = $_GET['release'];
$function = $_GET['function'];
$function = preg_replace('/\//',"-",$function);
$buff = "";
    $breakdown = file_get_contents("/homes/rod/public_html/Regression/report/data/".$release."_".$function."_failbreakdown_table", FILE_USE_INCLUDE_PATH);
print "<br><h1>Failure Breakdown</h1>".$breakdown;
?>
