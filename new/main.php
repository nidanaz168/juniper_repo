<html>
<head>
    <title>RBU REGRESSION REPORT</title>
	<link rel="stylesheet" href="../css/style.css" type="text/css"/>
    <link rel="stylesheet" href="../css/page1.css" type="text/css"/>
    <link rel="stylesheet" href="../table.css" type="text/css"/> 
	<link href="../css/jquery-ui.css" rel="stylesheet" type="text/css"/>
	<link href="css/bluetab.css" rel="stylesheet" type="text/css" />
	<script language="javascript" type="text/javascript" src="/EABU-MMX-TEST-GOALS/js/jquery.js">
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4/jquery.min.js"></script>
     <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.7/jquery-ui.min.js"></script> 
    <script language="javascript" type="text/javascript" src="/EABU-MMX-TEST-GOALS1/js/jQueryRotate.min.js"></script>
    <script language="javascript" type="text/javascript" src="/EABU-MMX-TEST-GOALS1/js/jgauge-0.3.0.a3.js"></script>
    <script type='text/javascript' src='/EABU-MMX-TEST-GOALS/js/jquery.tablesorter.js'></script>
    <script type='text/javascript' src='/EABU-MMX-TEST-GOALS/js/picnet.table.filter.min.js'></script>
    <script type='text/javascript' src='/EABU-MMX-TEST-GOALS/js/filter.js'></script>
    <script language='JavaScript' src='/fusion/FusionWidgets_Website/Charts/FusionCharts.js'></script>   
	<script type="text/javascript" src="../js/jquery.datepick.js"></script>
	<script language='JavaScript' src='/fusion/FusionWidgets_Website/Charts/FusionChartsExportComponent.js'></script>
	<script src="utility_new.js"></script>
	<script src="../popup.js"></script>
	<link rel="stylesheet" href="/Regression/mission.css" type="text/css">
		<link rel="stylesheet" href="/Regression/select.css" type="text/css">
		<link rel="stylesheet" type="text/css" href="/Regression/tab.css" />
        <link rel="stylesheet" type="text/css" href="/Regression/tab.css" />
		<script type="text/javascript" src="/Regression/jquery.js"></script>
	<!-- for Date picker -->
    <style type="text/css">
        @import "../css/jquery.datepick.css";
    </style>     
</head>
<body >                    
<div style='position:fixed;width:100%;z-index: 1;'>
	<div id="header">
        <center><h2>RBU REGRESSION REPORT</h2></center>
</div>
<div  id="main"><ul>
<li id="report"><a  href="#report_disp"><span>Reports</span></a></li>
<li id="heatmap"><a  href="#heatmap_disp"><span>Heat Map</span></a></li>
<li id="prstats"><a  href="#prstats_disp"><span>PR Stats</span></a></li>
<li id="swbehaviour"><a  href="#swbehaviour_disp"><span>Software Behaviour</span></a></li>
<li id="tbeddata"><a  href="#tbeddata_disp"><span>Testbed Data</span></a></li>
<li id="passper"><a  href="#passper_disp"><span>Pass %</span></a></li>
<li id="mainconfig"><a  href="#mainconfig_disp"><span>Configuration</span></a></li>
</ul>

</div>
<div  id="config-sub" style='display:none;'><ul>
<li id="regconfig"><a  href="#regconfig_disp"><span>Regression Report</span></a></li>
<li id="firstpassconfig"><a  href="#firstpassconfig_disp"><span>First Pass</span></a></li>
</ul>
</div>


<div  id="report-sub" style='display:none;'><ul>
<?php
$divs = "";
$flag = 0;
$selrel = "";
$actrel = "";
$heatactrel = "";
if(isset($_GET['release']))
{
	$passedrelease = $_GET['release'];
	$actrel = $passedrelease;
	$heatactrel = $passedrelease;
	$passedrelease = preg_replace('/\./','-',$passedrelease);
}
$dbh = pg_connect("host=eabu-systest-db password =postgres dbname=regression user=postgres");
 if (!$dbh) {
     die("Error in connection: " . pg_last_error());
}
	$flag = 0;
	$query = "select release from releases where active='yes'";   /* get the distinct release */
    $result = pg_query($dbh, $query);
    while ($row = pg_fetch_array($result)) {	
		$relstr = $row[0];
		$relstr = preg_replace('/\./','-',$relstr);	
    print "<li class='reptab' id='$relstr'><a  href='#".$relstr."_disp'><span>$row[0]</span></a></li>";
	$divs .= "<div id='$relstr"."_disp'></div>";
	if($flag == 0){ $selrel = $relstr;$flag=1;}
}
print "<script>var actrel=\"$actrel\";var heatactrel=\"$heatactrel\";$(document).ready(function() {";
	if(isset($passedrelease)){
	print "getreleasereport(\"$passedrelease\");";
	}else
	{
	print "getreleasereport(\"$selrel\");";}
	
	 print "})</script>\n";
?>
<li id="archives"><a  href="#archives_disp"><span>Archives</span></a></li>
</ul>

</div>
<div id='selection' class='ui-tabs-panel ui-widget-content ui-corner-bottom' ></div>
<div id='mainconfig_disp'></div>
<div id='regconfig_disp'></div>
<div id='firstpassconfig_disp'></div>
<div id='swbehaviour_disp'></div>
<div id='passper_disp'></div>
<div id='prstats_disp'></div>
<div id='tbeddata_disp'></div>
<div id='heatmap_disp'></div>
<div id='archives_disp'></div>
<div id='report_disp'></div>
</div>
<center><div id='functiontab' style='position:absolute;width:100%;top:150;height:20px;left:30px;display:none;'>
<div class="page-wrap">
<div class="main-nav">
<ul>
<?php
$query = "select name from functions";   /* get the distinct release */
    $result = pg_query($dbh, $query);
    while ($row = pg_fetch_array($result)) {
	$id = "heat_".$row[0];
	if(preg_match('/MMX/',$row[0]))
	{
		print "<li class='headerlink current' id='$id'><a href='javascript:;'  title='$row[0]'><span>$row[0]</span></a></li>";
    }
	else
	{
		print "<li class='headerlink' id='$id'><a href='javascript:;'  title='$row[0]'><span>$row[0]</span></a></li>";
	}
	}
?>
</ul>
</div>
</div>
</div>

<center><div id='bugreleasetab' style='position:absolute;width:100%;top:150;left:30px;height:20px;display:none;'>
<div class="page-wrap">
<div class="main-nav">
<ul>
<?php
$query = "select distinct(releasename) from fpconfig order by releasename";   /* get the distinct release */
    $result = pg_query($dbh, $query);
    while ($row = pg_fetch_array($result)) {
	$id = preg_replace('/\./',"-",$row[0]);
    $id = "bug_".$id;
    if(preg_match('/12\.1/',$row[0]))
    {
        print "<li class='prrellink current' id='$id'><a href='javascript:;'  title='$row[0]'><span>$row[0]</span></a></li>";
    }
    else
    {
        print "<li class='prrellink' id='$id'><a href='javascript:;'  title='$row[0]'><span>$row[0]</span></a></li>";
    }
    }
?>
</ul>
</div>
</div>
</div>


<center><div id='heatdisplay' style='position:absolute;width:100%;top:220px;left:10px;display:none;'>
<div class="page-wrap">
<div class="main-nav" id='areatab';>
            <ul>
            <li class="tabLink current" id="summary"><a href="javascript:;"  title="Summary"><span>Summary</span></a></li>
            <li class="tabLink" id="infra"><a href="javascript:;"  title="Infra"><span>Infra</span></a></li>
            <li class="tabLink" id="interfaces"><a href="#"  title="Interfaces"><span>Interfaces</span></a></li>
            <li class="tabLink" id="protocols"><a href="javascript:;"  title="Protocols"><span>Protocols</span></a></li>
            </ul>
</div>
</div>
        </div>
        <div id="heatcontents" style='position:absolute;width:100%;top:280px;left:10px;'>
        </div>
<center><div id='archive_data' style='position:absolute;width:100%;top:200px;left:10px;display:none;'>
<?php
print "<center> Select Archived Release: <select class='selrelar' id='selrelar' name='selrelar'>\n";
$query = "select release from releases where active='no'";   /* get the distinct release */
	$result = pg_query($dbh, $query);
    while ($row = pg_fetch_array($result)) {
	print "<option name='$row[0]'>$row[0]</option>";
	}
	print "</select></div>";
print $divs;
?>
</div>
<br><br>
<div id='display' style='position:absolute;width:100%;top:200px;left:10px'></div>
<center><div id='configinput' style='position:absolute;width:100%;top:200px;display:none;'>
<table border=1>
<tr>
    <td>Choose a Function</td>

    <td>
        <select id='selfunct' name="selfunct">
            <option name="MMX">MMX</option>
            <option name="ACX">ACX</option>
            <option name="CE">CE</option>
            <option name="JUNOS SW">JUNOS SW</option>
            <option name="ESBU">ESBU</option>
            <option name="RPD">RPD</option>
            <option name="TX">T/TX/PTX</option>

        </select>
    </td>
<td>Select a release string</td>
<td>
        <select id='selrel' name="selrel">
<?php
	$query = "select release from releases";   /* get the distinct release */
    $result = pg_query($dbh, $query);
    while ($row = pg_fetch_array($result)) {
    print "<option name='$row[0]'>$row[0]</option>";
	}
?>
</select>
</td>
</tr>
</table>


<table border=1>
<tr>
<td>Enter the release for which the report has to be created: </td><td><input id='release' type="text" name="release"></td>
</tr>
<tr>
    <td>Choose a Function</td>

    <td>
        <select id='function' name="function">
            <option name="MMX">MMX</option>
            <option name="ACX">ACX</option>
            <option name="CE">CE</option>
            <option name="JUNOS SW">JUNOS SW</option>
            <option name="ESBU">ESBU</option>
            <option name="RPD">RPD</option>
            <option name="TX">T/TX/PTX</option>

        </select>
    </td>
</tr>
<tr>
    <td>Enter the Number of scripts planned for execution: </td>
    <td><input id='scipt_planned' type="text" name="script_planned"></td>
</tr>
<tr>
    <td>Enter the DR Names (separated by comma): </td>
    <td><input id='dr_names' type="text" name="dr_names"></td>

</tr>
<tr>
    <td>Enter the Planned Release(For PRs): </td>
    <td><input id='planned_release' type="text" name="planned_release"></td>
</tr>
<tr>
    <td>Enter Debug Start Date: </td>
    <td><input class='seldate' id='debug_start' type="text" name="planned_release"></td>
</tr>
<tr>
    <td>Enter Debug End Date: </td>
    <td><input class='seldate' id='debug_end' type="text" name="planned_release"></td>
</tr>
<tr>
    <td>Is release active?</td>

    <td>
        <select id='active' name="active">
            <option name="yes">yes</option>
            <option name="no">no</option>
        </select>
    </td>
</tr>
</table>
<br>
<br>
<input id='createconfig' type="submit" value="Submit">
</div></center>
<center><div id='firstpassconfiginput' style='position:absolute;width:100%;top:200px;display:none;'>
<table border=1>
<tr>
    <td>Choose a Function</td>

    <td>
        <select id='fpselfunct' name="fpselfunct">
            <option name="MMX">MMX</option>
            <option name="ACX">ACX</option>
            <option name="CE">CE</option>
            <option name="JUNOS SW">JUNOS SW</option>
            <option name="ESBU">ESBU</option>
            <option name="RPD">RPD</option>
            <option name="TX">T/TX/PTX</option>

        </select>
    </td>
<td>Select a release string</td>
<td>
        <select id='fpselrel' name="fpselrel">
<?php
	$query = "select distinct(releasename) from fpconfig";   /* get the distinct release */
    $result = pg_query($dbh, $query);
    while ($row = pg_fetch_array($result)) {
    print "<option name='$row[0]'>$row[0]</option>";
	}
?>
</select>
</td>
<td>Select a milestone string</td>
<td>
        <select id='fpselmile' name="fpselmile">
<?php
	$query = "select distinct(milestone) from fpconfig";   /* get the distinct release */
    $result = pg_query($dbh, $query);
    while ($row = pg_fetch_array($result)) {
    print "<option name='$row[0]'>$row[0]</option>";
	}
?>
</select>
</td>
</tr>
</table>


<table border=1>
<tr>
<td>Enter the release for which the report has to be created: </td><td><input id='fprelease' type="text" name="fprelease"></td>
</tr>
<tr>
    <td>Choose a Function</td>

    <td>
        <select id='fpfunction' name="function">
            <option name="MMX">MMX</option>
            <option name="ACX">ACX</option>
            <option name="CE">CE</option>
            <option name="JUNOS SW">JUNOS SW</option>
            <option name="ESBU">ESBU</option>
            <option name="RPD">RPD</option>
            <option name="TX">T/TX/PTX</option>

        </select>
    </td>
</tr>
<tr>
    <td>Enter the DR Ids (separated by comma): </td>
    <td><input id='dr_ids' type="text" name="dr_ids"></td>

</tr>
<tr>
    <td>Enter the MileStone </td>
    <td><input id='fpmilestone' type="text" name="fpmilestone"></td>
</tr>
<tr>
    <td>Enter the Planned Release(For PRs): </td>
    <td><input id='fpplanned_release' type="text" name="planned_release"></td>
</tr>
</table>
<br>
<br>
<input id='fpcreateconfig' type="submit" value="Submit">
</div>
<center><div id='modal'><img src='/Regression/report/images/wait_progress.gif' width='50' height='50'/></div></center>
<center><div style="border:3px solid black; background-color:#9999ff; padding:25px; font-size:150%; text-align:center; display:none;" class='trendscharts' id='trendschart'><img src="/Regression/report/new/images/close.jpg"  width='20' height='20' style="position: absolute; top: 0; right: 0;" onClick="Popup.hide('trendschart')" ><div id='charts'></div></div></center>
</body></html>