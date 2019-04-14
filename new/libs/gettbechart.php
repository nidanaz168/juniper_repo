<?php
$release = $_GET['release'];
$function = $_GET['function'];
$type = $_GET['type'];
#$release = preg_replace('/-/',".",$release);
$buff = "";
error_reporting(0);
if(fopen("/homes/rod/public_html/Regression/report/new/data/".$release."_".$function."_tbed_".$type."_chart", 'r')){
    $buff = file_get_contents("/homes/rod/public_html/Regression/report/new/data/".$release."_".$function."_tbed_".$type."_chart", FILE_USE_INCLUDE_PATH);
    }
    else
    {
        print "<br><h1><error> NO SUCH REGRESSION REPORT AVAILABLE /homes/rod/public_html/Regression/report/new/data/".$release."_"."$function._table";
    }
print $buff;
?>
