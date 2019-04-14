<?php
$release = $_GET['release'];
$type = $_GET['type'];
#$release = preg_replace('/-/',".",$release);
$buff = "";
if(preg_match('/first/',$type))
{
    $buff = file_get_contents("/var/www/html/CI_Report/data/".$release."_firstpass", FILE_USE_INCLUDE_PATH);
}
else
{
	$buff = file_get_contents("/var/www/html/CI_Report/data/".$release."_pass", FILE_USE_INCLUDE_PATH);
}
print "$buff";
?>
