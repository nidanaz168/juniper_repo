<?php
	$pr  = $_GET['testid'];
	#$out  = shell_exec("./getreport.pl \"$pr\"" );
        $out  = shell_exec("python3 RPR_tool.py \"$pr\"" );
	print "$out";
?>
