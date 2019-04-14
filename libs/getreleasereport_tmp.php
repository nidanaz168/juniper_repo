<?php
$release = $_GET['release'];
#$release = preg_replace('/-/',".",$release);
$buff = "";
error_reporting(0);
if(fopen("/homes/rod/public_html/Regression/report/data/".$release."_table", 'r')){
        $buff = file_get_contents("/homes/rod/public_html/Regression/report/data/".$release."_table", FILE_USE_INCLUDE_PATH);
	$dblinks = file_get_contents("/homes/rod/public_html/Regression/report/data/".$release."debuglinks", FILE_USE_INCLUDE_PATH);
    }
    else
    {
        print "<br><h1><error> NO SUCH REGRESSION REPORT AVAILABLE /homes/rod/public_html/Regression/report/data/".$release."_table";
    }
print $buff."<br>".$dblinks;
?>
