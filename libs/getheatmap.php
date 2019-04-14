<?php
$release = $_GET['release'];
$function = $_GET['function'];
$function = preg_replace('/\//',"-",$function);
$release = preg_replace('/-/',"",$release);
$buff = "";
	if(fopen("/homes/rod/public_html/RegReport/".$release."_".$function.".html", 'r')){
    $prs = file_get_contents("/homes/rod/public_html/RegReport/".$release."_".$function.".html", FILE_USE_INCLUDE_PATH);
	print "<br><center><h1>Heat MAPS</h1>"."<br><br>".$prs;
	}
	else
	{
		print "<br><h1> NO SUCH REGRESSION REOPORT AVAILABLE";
	}
?>
