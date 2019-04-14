<?php
$function = $_GET['function'];
$buff = "";
if(preg_match('/MMX/',$function))
{
$buff = "<ul><li class='tabLink current' id='summary'><a href='javascript:;'  title='Summary'><span>Summary</span></a></li><li class='tabLink' id='infra'><a href='javascript:;'  title='Infra'><span>Infra</span></a></li><li class='tabLink' id='interfaces'><a href='#'  title='Interfaces'><span>Interfaces</span></a></li><li class='tabLink' id='protocols'><a href='javascript:;'  title='Protocols'><span>Protocols</span></a></li></ul>";
}
elseif(preg_match('/RPD/',$function))
{
	$buff = "<ul><li class='tabLink current' id='summary'><a href='javascript:;'  title='Summary'><span>Summary</span></a></li><li class='tabLink' id='protocols'><a href='javascript:;'  title='Details'><span>Details</span></a></li></ul>";
}
else
{
	$buff = "<ul><li class='tabLink current' id='summary'><a href='javascript:;'  title='Summary'><span>Summary</span></a></li><li class='tabLink' id='general'><a href='javascript:;'  title='Details'><span>Details</span></a></li></ul>";
}
echo $buff;
?>
