<html>
<head>
    <title>ROUTING & SWITCHING REGRESSION REPORT</title>
    <link rel="stylesheet" href="css/style.css" type="text/css"/>
    <link rel="stylesheet" href="css/page1.css" type="text/css"/>
    <link rel="stylesheet" href="table.css" type="text/css"/> 
    <link href="css/jquery-ui.css" rel="stylesheet" type="text/css"/>
    <script language="javascript" type="text/javascript" src="/EABU-MMX-TEST-GOALS/js/jquery.js">
    <script src="jquery.min.js"></script>
     <script src="jquery-ui.min.js"></script> 
    <script language="javascript" type="text/javascript" src="/EABU-MMX-TEST-GOALS1/js/jQueryRotate.min.js"></script>
    <script language="javascript" type="text/javascript" src="/EABU-MMX-TEST-GOALS1/js/jgauge-0.3.0.a3.js"></script>
    <script type='text/javascript' src='/EABU-MMX-TEST-GOALS/js/jquery.tablesorter.js'></script>
    <script type='text/javascript' src='/EABU-MMX-TEST-GOALS/js/picnet.table.filter.min.js'></script>
    <script type='text/javascript' src='/EABU-MMX-TEST-GOALS/js/filter.js'></script>
    <script language='JavaScript' src='/fusion/FusionWidgets_Website/Charts/FusionCharts.js'></script>   
    <script type="text/javascript" src="js/jquery.datepick.js"></script>
    <script language='JavaScript' src='/fusion/FusionWidgets_Website/Charts/FusionChartsExportComponent.js'></script>
<?php
    echo "<script src='js/inc.js?" . filemtime('js/inc.js') . "'></script>";
    echo "<script src='utility_new.js?" . filemtime('utility_new.js') . "'></script>";
?>
    <script src="popup.js"></script>
    <link rel="stylesheet" href="/RLIPRReports/monthly_prod/stylesheets/jquery.treetable.css" />
    <link rel="stylesheet" href="jquery.treetable.theme.default.css" />

<script src="/RLIPRReports/monthly_prod/js/jquery.treetable.js"></script>
    <!-- for Date picker -->
    <style type="text/css">
        @import "css/jquery.datepick.css";
    </style>     
</head>
<body >                    
<div style='position:fixed;width:100%;z-index: 1;height:100%;' id="mainDiv">
    <div id="header">
        <center><h2>ROUTING & SWITCHING REGRESSION REPORT</h2></center>
</div>
<div  id="main">
    <ul>
        <li id="summaryReport"><a  href="#summary_disp" onclick="showSummaryReport()"><span>Summary Reports</span></a></li> 
        <li id="report"><a  href="#report_disp" onclick="showDetailedReport()"><span>Detailed Reports</span></a></li> 
        <li id="config"><a  href="#config_disp" onclick="showConfiguration()"><span>Configuration</span></a></li>
    </ul>
</div>
<div id="report-sub" style="display:none;">
    <ul style="display: none;" id="tabnav">
        <?php
        $divs = "";
        $flag = 0;
        $selrel = "";
        $actrel = "";
        if(isset($_GET['release']))
        {
            $passedrelease = $_GET['release'];
            $actrel = $passedrelease;
            $passedrelease = preg_replace('/\./','-',$passedrelease);
        }
        $dbh = pg_connect("host=eabu-systest-db password =postgres dbname=regression user=postgres");
         if (!$dbh) {
             die("Error in connection: " . pg_last_error());
        }
            $flag = 0;
            $query = "select release from releases where active='yes' order by releases";   /* get the distinct release */
            // $query = "select upper(release) as release from releases where active='yes' group by upper(release) order by release";   /* get the distinct release */

            $result = pg_query($dbh, $query);
            while ($row = pg_fetch_array($result)) {    
                $relstr = $row[0];
                $relstr = preg_replace('/\./','-',$relstr); 
            print "<li class='reptab' id='$relstr'><a  href='#".$relstr."_disp'><span>$row[0]</span></a></li>";
            $divs .= "<div style='display:none;'id='$relstr"."_disp'></div>";
            if($flag == 0){ $selrel = $relstr;$flag=1;}
        }
        print "<script>var actrel=\"$actrel\";$(document).ready(function() {";
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
<div id='config_disp' style='display:none;'></div>
<div id='report_disp' style='display:none;'></div>


<div id='summary_disp'>
    
    <iframe src="https://jdiregression.juniper.net/autotools/reg/" style="width:100%;height:90%;" frameborder="0"></iframe>


</div>


<div id='report_sum_disp' style='display:none;'></div>
<div id='archives_disp' style='display:none;'></div>

<center>
    <div id='archive_data' style='width:100%;top:200px;left:10px;display: none;z-index:200;padding:10px;background: #cdcdcd;'>
        <?php
        print "<center> Select Archived Release: <select class='selrelar' id='selrelar' name='selrelar'>\n";
        $query = "select release from releases where active='no' order by release";   /* get the distinct release */
        // $query = "select upper(release) as release from releases where active='no' group by upper(release) order by release"; /* get the distinct release */

            $result = pg_query($dbh, $query);
            while ($row = pg_fetch_array($result)) {
            print "<option name='$row[0]'>$row[0]</option>";
            }
            print "</select></div>";
        print $divs;
        ?>
    </div>
</center>

<br><br>

<div id='display' style='width:100%;left:10px;display:none;'></div>

<center>
    <div id='configinput' style='position:absolute;width:100%;top:200px;display:none;z-index:200'>
        <table border=1>
        <tr>
            <td>Choose a Function</td>

            <td>
                <select id='selfunct' name="selfunct">
                    <option name="MMX">MMX</option>
                    <option name="ACX">ACX</option>
                    <option name="BBE">BBE</option>
                    <option name="JUNOS SW">JUNOS SW</option>
                    <option name="ESBU">ESBU</option>
                    <option name="Protocols">Protocols</option>
                    <option name="TX">T/TX/PTX</option>
                    <option name="RPD">RPD</option>
                    <option name="ROUTING VIRTUAL">ROUTING VIRTUAL</option>
                    <option name="ROUTING NPIs">ROUTING NPIs</option>
                    <option name="SWITCHING NPIs">SWITCHING NPIs</option>
                    <option name="SWITCHING VIRTUAL">SWITCHING VIRTUAL</option>
                    <option name="EX-Legacy">EX-Legacy</option>
                    <option name="EX-Mojito">EX-Mojito</option>
                    <option name="EX-Rodnik">EX-Rodnik</option>
                    <option name="QFX-OPUS">QFX-OPUS</option>
                    <option name="QFX-LAVC">QFX-LAVC</option>
                    <option name="Qfabric">Qfabric</option>
                    <option name="OCX">OCX</option>
                    <option name="EX4600">EX4600</option>
                    <option name="EX2300">EX2300</option>
                    <option name="EX3400">EX3400</option>
                    <option name="QFX10002">QFX10002</option>
                    <option name="QFX5200">QFX5200</option>
                    <option name="QFX10008/QFX10016">QFX10008/QFX10016</option>
                    <option name="NFX250">NFX250</option>
                    <option name="V44">V44</option>
                    <option name="B54">B54</option>

                </select>
            </td>
        <td>Select a release string</td>
        <td>
                <select id='selrel' name="selrel">
        <?php
            $query = "select distinct release from releases order by release";   /* get the distinct release */
            // $query = "select upper(release) as release from releases group by upper(release) order by release";   /* get the distinct release */
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
                        <option name="BBE">BBE</option>
                        <option name="JUNOS SW">JUNOS SW</option>
                        <option name="ESBU">ESBU</option>
                        <option name="Protocols">Protocols</option>
                        <option name="TX">T/TX/PTX</option>
                        <option name="RPD">RPD</option>
                        <option name="ROUTING VIRTUAL">ROUTING VIRTUAL</option>
                        <option name="ROUTING NPIs">ROUTING NPIs</option>
                        <option name="SWITCHING NPIs">SWITCHING NPIs</option>
                        <option name="SWITCHING VIRTUAL">SWITCHING VIRTUAL</option>
                        <option name="EX-Legacy">EX-Legacy</option>
                        <option name="EX-Mojito">EX-Mojito</option>
                        <option name="EX-Rodnik">EX-Rodnik</option>
                        <option name="QFX-OPUS">QFX-OPUS</option>
                        <option name="QFX-LAVC">QFX-LAVC</option>
                        <option name="Qfabric">Qfabric</option>
                        <option name="OCX">OCX</option>
                        <option name="EX4600">EX4600</option>
                        <option name="EX2300">EX2300</option>
                        <option name="EX3400">EX3400</option>
                        <option name="QFX10002">QFX10002</option>
                        <option name="QFX5200">QFX5200</option>
                        <option name="QFX10008/QFX10016">QFX10008/QFX10016</option>
                        <option name="NFX250">NFX250</option>
                        <option name="V44">V44</option>
                        <option name="B54">B54</option>

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
    </div>
</center>


<center><div id='modal'><img src='images/wait_progress.gif' width='50' height='50'/></div></center>

<script>
    function showSummaryReport(){
        resetPage();
        $("#summary_disp").show();
        $("#mainDiv").css("height","100%");
        updateQueryStringParam('tab', 'summary');
    }

    function hideSummaryReport(){
        $("#summary_disp").hide();
    }

    function showDetailedReport(){
        hideSummaryReport();
        resetPage();

        $("#report-sub").show();
        $("#tabnav").show();
        $("#display").show();

        setTimeout(function(){
            // $("#archive_data").show();
        },500);
        $("#mainDiv").css("height","auto");
        updateQueryStringParam('tab', 'detail');
    }

    function showConfiguration(){
        hideSummaryReport();
        resetPage();
        $("#configinput").show();
        $("#mainDiv").css("height","auto");
        updateQueryStringParam('tab', 'config');
    }


    function resetPage(){
        $("#mainDiv").css("height","100%");
        $("#display").hide();
        $("#report-sub").hide();
        $("#tabnav").hide();
        $("#archive_data").hide();
        $("#configinput").hide();
    }

    function showRelevantTab(tabID){
        
        showDetailedReport();
        $("#report a").click();

        $("#"+tabID).find("a").click()

    }


</script>


</body></html>
