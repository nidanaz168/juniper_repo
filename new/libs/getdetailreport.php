<?php
$release = $_GET['release'];
$function = $_GET['function'];
$function = preg_replace('/\//',"-",$function);
$buff = "";
	if(fopen("/homes/rod/public_html/Regression/report/data/".$release."_".$function."_prs_table", 'r')){
    $prs = file_get_contents("/homes/rod/public_html/Regression/report/data/".$release."_".$function."_prs_table", FILE_USE_INCLUDE_PATH);
	print "<br><h1>PR DETAILS</h1>"."<br><br>".$prs;
	}
	else
	{
		print "<br><h1> NO SUCH REGRESSION REOPORT AVAILABLE";
	}
?>
