<?php
$release = $_GET['release'];
$type = $_GET['type'];
#$release = preg_replace('/-/',".",$release);
$buff = "";
if(preg_match('/first/',$type))
{
    $buff = file_get_contents("/homes/rod/public_html/Regression/report/data/".$release."_firstpass", FILE_USE_INCLUDE_PATH);
}
else
{
	$buff = file_get_contents("/homes/rod/public_html/Regression/report/data/".$release."_pass", FILE_USE_INCLUDE_PATH);
}
print "$buff";
?>
