<?php
$release = $_GET['release'];
#$release = preg_replace('/-/',".",$release);
$buff = "";
error_reporting(0);
if(fopen("/var/www/html/CI_Report/data/".$release."_table", 'r')){
        $buff = file_get_contents("/var/www/html/CI_Report/data/".$release."_table", FILE_USE_INCLUDE_PATH);
	$dblinks = file_get_contents("/var/www/html/CI_Report/data/".$release."debuglinks", FILE_USE_INCLUDE_PATH);
    }
    else
    {
        print "<br><h1><error> NO SUCH REGRESSION REPORT AVAILABLE /var/www/html/CI_Report/data/".$release."_table";
    }
print $buff."<br>".$dblinks;
?>
