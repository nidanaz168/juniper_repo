<?php
$release = $_GET['release'];
$type = $_GET['type'];
$buff = "";
$release = preg_replace('/\./','-',$release);
$type = preg_replace('/\//','-',$type);
    $buff = file_get_contents("/homes/rod/public_html/Regression/report/data/".$release."_".$type."_graph", FILE_USE_INCLUDE_PATH);
print "$buff";
?>
