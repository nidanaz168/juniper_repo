<?php
$release = $_GET["release"];
$func= $_GET["function"];
$arr = explode("_",$func);
$func = $arr[1];
$command = "cat /homes/rod/public_html/Regression/report/new/heatmap/$func"."_Debug_".$release.".html";
$out = shell_exec($command);
	echo $out;
?>
