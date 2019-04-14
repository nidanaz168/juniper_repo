<?php
$release = $_GET['release'];
$buff = "";
	if(fopen("/homes/rod/public_html/Regression/report/new/data/prdata/".$release."_prdata", 'r')){
    $pass = file_get_contents("/homes/rod/public_html/Regression/report/new/data/prdata/".$release."_prdata", FILE_USE_INCLUDE_PATH);
	print "$pass";
	}
	else
	{
		print "<br><h1> NO SUCH REGRESSION REOPORT AVAILABLE";
	}
?>
