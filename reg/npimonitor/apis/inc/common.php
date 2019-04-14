<?php
session_start();
//mail Settings
date_default_timezone_set("Asia/Kolkata"); 
ini_set('memory_limit', '1256M');

include_once "dbconn.php";
include_once "function.php";

function array_pluck($array, $key) {
  return array_map(function($v) use ($key)	{
    return is_object($v) ? $v->$key : $v[$key];
  }, $array);
}

function getEventIDs($relID){
	$fromCond = "gantt_import_step1 a, gantt_import_step2 b, gantt_import_step2_details c";
	$whereCond = "b.import_step1_id=a.id and b.id=c.step2_id and a.release_id=".$relID;
	$rows = singlerec("group_concat(c.regression_id) as regID",$fromCond,$whereCond);

	$eventIDs = $rows->regID;

	return $eventIDs;
}

function add_days( $days, $from_date = null ) {
    date_default_timezone_set('Asia/Kolkata');

    if ( is_numeric( $from_date ) ) { 
        $new_date = $from_date; 
    } else { 
        $new_date = time();
    }

    // Timestamp is the number of seconds since an event in the past
    // To increate the value by one day we have to add 86400 seconds to the value
    // 86400 = 24h * 60m * 60s
    $new_date += $days * 86400;

    return $new_date;
}

function getReleaseIDByArray($array,$name,$id=1){

	// print_r($array);

	// exit();

	foreach($array as $key => $value){

		if($value[$id] == $name)
	  		$z = $value[0];

	}


	return $z;

}

function autoRegression($profileName, $event_name, $envVar, $domains, $username){



	// $profileName = "RPT_REG_MMX_173_FULL";

	// $event_name = "CBR_Tools_Check";
	// $envVar = '"DEPLOY_PHASE=3"';
	// $domains = "'rpt-reg-vmx-plat1-dt'";

	// $username = "ameethmd";

		// global $host;
		// global $port;
		// global $db;
		// global $user;
		// global $pass;


	// $host = "ttbg-pgb-01.juniper.net"; 
	// $port = "port=6553";
	// $user = "table_family_ro"; 
	// $pass = "table_family_ro"; 
	// $db = "systest_live_readonly"; 



	$dbh = pg_connect("host=ttbg-pgb-01.juniper.net port=6553 dbname=systest_live_readonly user=table_family_ro password=table_family_ro ");

	if (!$dbh) {
		die("Error in connection ".pg_last_error());
	}


	$query = "SELECT array_to_string(array(select regression_id from regression where name in (".$profileName.")),', ')"; 
	// echo $query;
	$res = pg_query($dbh, $query) or die("Cannot execute query: $query\n");
	$val = pg_fetch_result($res, 0, 0);

	pg_close($dbh);

	$profileID = $val;


	$str = "perl /homes/shanthee/create_rmv2_event -event_name '".$event_name."' -profile ".$profileID." -domains ".$domains." -script_env ".$envVar." -result_contact='".$username."' -logged_user '".$username."'";


	// $str = "perl /volume/labtools/bin/create_rmv2_event -event_name '".$event_name."' -profile ".$profileID." -domains ".$domains." -script_env ".$envVar."";

	// echo "\n\n".$str."\n\n\n";
	

	$output = shell_exec($str);

	$searchfor  = 'Regression_exec_id :';	
	$pattern = preg_quote($searchfor, '/');
	// finalise the regular expression, matching the whole line
	$pattern = "/^.*$pattern.*\$/m";
	// search, and store all matching occurences in $matches
	if(preg_match_all($pattern, $output, $matches)){
		$temp = implode("\n", $matches[0]);
	 	preg_match('/(?<name>\w+) : (?<digit>\d+)/', $temp, $matches);	
	  	$retVal = $matches[2];	
	}
	else{
	   $retVal =  "No matches found";
	}


	return $retVal;

}

function getAllReleases(){
	$releasesArray = array();
	$rows = selectrec("id,name,start,release_color,is_manual","releases","isactive=1 and (`relid_main`!=0 or is_manual=1)");

	foreach ($rows as $key => $row) {
		$releasesArray[$row[0]]["id"] = $row[0];
		$releasesArray[$row[0]]["name"] = $row[1];
		$releasesArray[$row[0]]["date"] = $row[2];
		$releasesArray[$row[0]]["color"] = $row[3];
		$releasesArray[$row[0]]["is_manual"] = $row[4];
	}

	return $releasesArray;

}
function getCompleteReleases(){
	$releasesArray = array();
	$rows = selectrec("id,name,start,release_color,is_manual","releases","isactive=1");

	foreach ($rows as $key => $row) {
		$releasesArray[$row[0]]["id"] = $row[0];
		$releasesArray[$row[0]]["name"] = $row[1];
		$releasesArray[$row[0]]["date"] = $row[2];
		$releasesArray[$row[0]]["color"] = $row[3];
		$releasesArray[$row[0]]["is_manual"] = $row[4];
	}

	return $releasesArray;

}

function download($name){
	$file = $name;
	// 	echo $name;
	// exit();

	if (file_exists($file)) {
	    header('Content-Description: File Transfer');
	    header('Content-Type: application/octet-stream');
	    header('Content-Disposition: attachment; filename='.basename($file));
	    header('Content-Transfer-Encoding: binary');
	    header('Expires: 0');
	    header('Cache-Control: must-revalidate');
	    header('Pragma: public');
	    header('Content-Length: ' . filesize($file));
	    ob_clean();
	    flush();
	    readfile($file);
	    exit;
	}
}


function getAllFunctions(){
	$functionsArray = array();
	$rows = selectrec("id,name","functions","isactive=1");

	foreach ($rows as $key => $row) {
		$functionsArray[$row[0]]["id"] = $row[0];
		$functionsArray[$row[0]]["name"] = $row[1];
	}

	return $functionsArray;

}
function getAllTestbeds(){
	$testbedsArray = array();
	$rows = selectrec("id,name","testbeds","isactive=1");

	foreach ($rows as $key => $row) {
		$testbedsArray[$row[0]]["id"] = $row[0];
		$testbedsArray[$row[0]]["name"] = $row[1];
	}

	return $testbedsArray;

}

function getTestbedIDsByScenarioName($scenario){

	// echo $profile;

	$rows = selectrec("B.domain_id,B.domain_name,round(sum(runtime)/60/24,2) AS runtime","script_runtime A,scenario_domain B","A.scenario=B.scenario and A.scenario_name in('".$scenario."') group by B.domain_id limit 1");

	$result = array();
	foreach($rows as $row){
		$result[] = array($row[0],$row[1],$row[2]);
	}

	return $result;
	// exit();
}

// function getTestbedIDsByEventID($eventID){

// 	// echo $profile;

// 	$templateID = singlefield("template_id",)

// 	$rows = selectrec("B.domain_id,B.domain_name,round(sum(runtime)/60/24,2) AS runtime","script_runtime A,scenario_domain B","A.scenario=B.scenario and A.profile='".$profile."' group by B.domain_id");

// 	$result = array();
// 	foreach($rows as $row){
// 		$result[] = array($row[0],$row[1],$row[2]);
// 	}

// 	return $result;
// 	// exit();
// }

function getTestbedIDsByProfileName($profile){

	// echo $profile;

	$rows = selectrec("B.domain_id,B.domain_name,round(sum(runtime)/60/24,2) AS runtime","script_runtime A,scenario_domain B","runtime!=0 and A.scenario=B.scenario and A.profile='".$profile."' group by B.domain_id");

	$result = array();
	foreach($rows as $row){
		$result[] = array($row[0],$row[1],$row[2]);
	}

	return $result;
	// exit();
}

function getTestbedIDsByProfileName1($profile, $fdate){

	// $profile = "'JUNOS-DAILY-5.2','JUNOS-DAILY-5.3'";
	// TestbedID - TestbedName

	global $host;
	global $port;
	global $db;
	global $user;
	global $pass;


	$con = pg_connect("host=$host $port dbname=$db user=$user password=$pass")
    or die ("Could not connect to server\n"); 

	//Get all the Active Testbeds names
	$activeRows = selectrec("(quote(domain))","active_testbeds","active=1");
	$aN = "";

	foreach ($activeRows as $activeNames) {
		$aN .= $activeNames[0].",";
	}

	// echo $aN;
	// exit();


	$aN = substr($aN, 0, -1);

	//Get all TestbedIDs and Testbed Names and Save in Array
	$testbeds = selectrec("id,name","testbeds","name in (".$aN.")");
    $testbedArray = array();
    foreach ($testbeds as $testbed) {
    	$testbedArray[$testbed[0]] = $testbed[1];
    }

	// print_r($testbedArray);


	//Get all the Testbed IDs based on Profile Name
	// $query = "select distinct a.testbed_id,c.name,d.name,d.start,d.finish,d.status from scenario_testbed a,regression_scenario b,regression c,regression_exec d where a.scenario_id = b.scenario_id and b.regression_id = c.regression_id and c.regression_id = d.regression_id and a.is_domain=true and c.name in(".$profile.");";


	// $query = "select distinct a.testbed_id,((sum(e.runtime)/60)/60) from scenario_testbed a,regression_scenario b, regression c, regression_exec d, test e, scenario_test f where a.scenario_id = b.scenario_id and b.regression_id = c.regression_id and b.scenario_id = f.scenario_id and a.scenario_id = f.scenario_id and f.test_id = e.test_id and c.regression_id = d.regression_id and a.is_domain=true and c.name in(".$profile.") group by a.testbed_id;";


	// $query = "select c.testbed_id,round(sum(a.runtime)/86400::numeric,2) as runtime_days from test a, scenario_test b, scenario_testbed c, regression_scenario d,regression_exec e, regression f where d.regression_id=e.regression_id and e.regression_id=f.regression_id and d.scenario_id=c.scenario_id and c.is_domain=true and b.scenario_id=c.scenario_id and b.test_id=a.test_id and f.name in(".$profile.") group by c.testbed_id order by sum(a.runtime)";

	// $query = "select c.testbed_id,round(sum(a.runtime)/86400::numeric,2) as runtime_days from test a, scenario_test b, scenario_testbed c, regression_scenario d,regression_exec e, regression f where d.regression_id=e.regression_id and e.regression_id=f.regression_id and d.scenario_id=c.scenario_id and c.is_domain=true and b.scenario_id=c.scenario_id and b.test_id=a.test_id and f.name in(".$profile.") group by c.testbed_id  order by sum(a.runtime) ";

	$query = "select c.testbed_id, round(sum(a.runtime)/86400::numeric,2) as runtime_days from test a, scenario_test b, scenario_testbed c, regression_scenario d, regression e where d.regression_id=e.regression_id and e.name in(".$profile.") and d.scenario_id=c.scenario_id and c.is_domain=true and b.scenario_id=c.scenario_id and b.test_id=a.test_id group by c.testbed_id order by sum(a.runtime)";

	// select c.testbed_id, (a.runtime)/86400::numeric as runtime_days from test a, scenario_test b, scenario_testbed c, regression_scenario d, regression e where d.regression_id=e.regression_id and e.name in('RPT_REG_SERVICES_141_ETRANS_SCG') and d.scenario_id=c.scenario_id and c.is_domain=true and b.scenario_id=c.scenario_id and b.test_id=a.test_id

	// echo $query."\n\n\n\n";

	$rs = pg_query($con, $query) or die("Cannot execute query: $query\n");

	$result = array();
	while ($row = pg_fetch_row($rs)) {

		//If exits in the allowed testbed list then only add it. else dont add it.
		if(isset($testbedArray[$row[0]])){
			// echo $testbedArray[$row[0]]." == ".$row[1]."\n";
			$result[] = array($row[0],$row[1],$fdate,$testbedArray[$row[0]]);
		}
	}

		// print_r($result);

		// exit();
		return $result; //Return the JSON Array
}

function getTestbedIDsByEventName($events, $fdate){

	// $profile = "'JUNOS-DAILY-5.2','JUNOS-DAILY-5.3'";
	// TestbedID - TestbedName

	global $host;
	global $port;
	global $db;
	global $user;
	global $pass;


	$con = pg_connect("host=$host $port dbname=$db user=$user password=$pass")
    or die ("Could not connect to server\n"); 

	//Get all the Active Testbeds names
	$activeRows = selectrec("(quote(domain))","active_testbeds","active=1");
	$aN = "";

	foreach ($activeRows as $activeNames) {
	$aN .= $activeNames[0].",";
	}

	$aN = substr($aN, 0, -1);

	//Get all TestbedIDs and Testbed Names and Save in Array
	$testbeds = selectrec("id,name","testbeds","name in (".$aN.")");
    $testbedArray = array();
    foreach ($testbeds as $testbed) {
    	$testbedArray[$testbed[0]] = $testbed[1];
    }


	//Get all the Testbed IDs based on Profile Name
	// $query = "select distinct (a.testbed_id),c.name,d.name,d.start,d.finish,d.status from scenario_testbed a,regression_scenario b,regression c, regression_exec d where a.scenario_id = b.scenario_id and b.regression_id = c.regression_id and b.regression_id = d.regression_id and c.regression_id = d.regression_id and a.is_domain=true and d.name in(".$events.");";


	// $query = "select distinct on(a.testbed_id) a.testbed_id,((sum(e.runtime)/60)/60) from scenario_testbed a,regression_scenario b,regression c, regression_exec d,test e , scenario_test f where a.scenario_id = b.scenario_id and b.regression_id = c.regression_id and b.regression_id = d.regression_id and c.regression_id = d.regression_id and b.scenario_id = f.scenario_id and a.scenario_id = f.scenario_id and f.test_id = e.test_id and a.is_domain=true and d.name  in(".$events.") group by a.testbed_id;";


	// $query = "select c.testbed_id,round(sum(a.runtime)/86400::numeric,2) as runtime_days from test a, scenario_test b, scenario_testbed c, regression_scenario d,regression_exec e where d.regression_id=e.regression_id and d.scenario_id=c.scenario_id and c.is_domain=true and b.scenario_id=c.scenario_id and b.test_id=a.test_id and e.name in(".$events.") group by c.testbed_id order by sum(a.runtime) ";



	$query = "select c.testbed_id,round(sum(a.runtime)/86400::numeric,2) as runtime_days from test a, scenario_test b, scenario_testbed c, regression_scenario d,regression_exec e where d.regression_id=e.regression_id and d.scenario_id=c.scenario_id and c.is_domain=true and b.scenario_id=c.scenario_id and b.test_id=a.test_id and e.name in(".$events.") group by c.testbed_id  order by sum(a.runtime) ";

	// echo $query."\n\n\n\n";

	$rs = pg_query($con, $query) or die("Cannot execute query: $query\n");

	$result = array();
	while ($row = pg_fetch_row($rs)) {
			if(isset($testbedArray[$row[0]])){
				// echo $testbedArray[$row[0]]." == ".$row[1]."\n";
				$result[] = array($row[0],$row[1],$fdate);
			}
		}
	// print_r($result);

	// exit();
		return $result; //Return the JSON Array
}


function add_quotes($str) {
    return sprintf("'%s'", $str);
}


function getUserID($engineer){

	insertrec_ignore("auth_user","username,email","'".$engineer."','".$engineer."@juniper.net'");

	return singlefield("id","auth_user","username='".$engineer."'");
}

function getReleaseID($releasename){

	insertrec_ignore("releases","name","'".$releasename."'");

	return singlefield("id","releases","name='".$releasename."'");
}

function getFunctionID($functionname){

	insertrec_ignore("functions","short_name","'".$functionname."'");

	return singlefield("id","functions","short_name='".$functionname."'");
}


function getGlobalData(){

	// print_r($_GET);

	// $data = json_encode($_GET['userids'], true);
	$mainArray = array();
	$releasesArray = getCompleteReleases();

	// print_r($releasesArray);


	$functionsArray = getAllFunctions();

	$mainArray["action"] = "importdata";

	if(isset($_GET["user"]))
		$mainArray["engineer"] = $_GET["user"];
	else
		$mainArray["engineer"] = "rajkarthik";

	$userID = singlefield("id","oauth","username='".$mainArray["engineer"]."'");
	//Step 1 Starts 
 
	$tasks = array();
	// $releases = selectrec("release_id,release_date","gantt_import_step1 group by release_id order by release_date desc");
	// $releases = selectrec("DISTINCT(release_id),priority,sanity,cbr,fdt,full","gantt_import_step1 join gantt_import_step2 on gantt_import_step1.id=gantt_import_step2.import_step1_id join gantt_import_step3 on gantt_import_step3.import_step2_id=gantt_import_step2.id","gantt_import_step3.name !='none' order by  gantt_import_step1.release_date desc");

	// $cond1 = "";
	$cond1 = listCompletedRegressions();

	//Remove the release IDs from the completed regressions which are marked as restart=1;
	$relRows = selectrec("release_id","gantt_import_step1","restart=1");
	$relRowArr = array();
	foreach ($relRows as $key => $relRow) {
		$cond1 = removeFromString($cond1, $relRow[0]);
	}



	// echo $cond1;
	// exit();

	if($cond1!="")
		$cond1 = "and b.release_id not in(".$cond1.")";

	$releases = selectrec("DISTINCT(b.release_id),b.priority,b.sanity,b.cbr,b.fdt,b.full,b.manual,b.functions_temp","gantt_import_step1 b, gantt_import_main a","a.id=b.import_main_id and a.user_id=".$userID." ".$cond1." order by release_date desc");
	// print_r($releases);
	// exit();



	foreach ($releases as $key=>$release) {

		$fCond = "a.release_id=".$releasesArray[$release[0]]["id"]." and a.id=b.import_step1_id and b.id=c.step2_id";

		$completedFunctions = singlerec("group_concat(distinct(c.short_name)) as short_name","gantt_import_step1 a, gantt_import_step2 b, gantt_import_step2_details c",$fCond);

		$tasks[$key]["name"] 	= $releasesArray[$release[0]]["name"];
		$tasks[$key]["date"] 	= $releasesArray[$release[0]]["date"];
		$tasks[$key]["id"] 		= $releasesArray[$release[0]]["id"];
		$tasks[$key]["priority"] = $releases[$key][1];
		$tasks[$key]["sanity"] 	= $releases[$key][2];
		$tasks[$key]["cbr"] 	= $releases[$key][3];
		$tasks[$key]["fdt"] 	= $releases[$key][4];
		$tasks[$key]["full"] 	= $releases[$key][5];
		$tasks[$key]["manual"] 	= $releases[$key][6];
		$tasks[$key]["is_childof"] 	= singlefield("is_childof","releases","id=".$releasesArray[$release[0]]["id"]);
		$tasks[$key]["functions"] = $completedFunctions->short_name;
		$tasks[$key]["functions_temp"] = $releases[$key][7];
		
	}

	$existingRegressionCount = 0;
	$cTable = "gantt_import_step2_details a, gantt_import_step2 b, gantt_import_step1 c";
	$cFields = "c.release_id";
	$cCond = "c.id = b.import_step1_id and b.id=a.step2_id group by c.release_id";
	$rows = selectrec($cFields,$cTable,$cCond);


	foreach ($rows as $key => $value) {
		$existingRegressionCount++;
	}
		

	// print_r($tasks);

	// exit();

	$mainArray["regCount"] = $existingRegressionCount;
	$mainArray["step1"]["tasks"] = $tasks;

	//Step 2 Starts 

	$tasks = $evePros = array();

	foreach ($releases as $key => $release) {

		//Get the release ID from step1
		$step1_IDS = singlefield("GROUP_CONCAT(id)","gantt_import_step1","release_id=".$release[0]);

		$functionsList 	= getFunctionsAndProfiles($step1_IDS,$functionsArray);
		$evePro 		= getFunctionsAndProfiles($step1_IDS,$functionsArray,2);

		// print_r($functionsList);

		// $tasks["task_".str_replace(".","_",$releasesArray[$release[0]]["name"])]["checkbox"] = array_unique($functionsList);
		$tasks["task_".$releasesArray[$release[0]]["name"]]["checkbox"] = array_unique($functionsList);

		if($evePro)
		foreach ($evePro as $key=>$eventProfile) {
			// $evePros["task_".str_replace(".","_",$releasesArray[$release[0]]["name"])][$key] = [$eventProfile];
			// $evePros["task_".$releasesArray[$release[0]]["name"]][$key] = utf8_encode($eventProfile);
			$evePros["task_".$releasesArray[$release[0]]["name"]][$key] = $eventProfile;
		}

	}

	$mainArray["step2"]["tasks"] = $tasks;
	// $mainArray["step3"]["tasks"] = $evePros;
	
	// print_r($mainArray);

	// 	exit();
	// $str .= json_encode($tasks)."}";


	// $str .="}";

	// echo $str;
	echo json_encode($mainArray);
}


function listCompletedRegressions(){

	setQuery("SET SESSION group_concat_max_len = 1000000");

	
	$fields = "group_concat(distinct(c.release_id))";
	$table = "gantt_import_step2_details a, gantt_import_step2 b, gantt_import_step1 c, releases d";
	// $cond = "c.release_id=d.id and c.id = b.import_step1_id and b.id=a.step2_id and c.restart!=1";
	$cond = "c.release_id=d.id and c.id = b.import_step1_id and b.id=a.step2_id";

	$str = singlefield($fields,$table,$cond);

	return $str;


}


function getFunctionsAndProfiles($step1_IDS,$functionsArray,$x=1){


	//Get All Step2 IDs
	$step2IDs = selectrec("id,function_id","gantt_import_step2","import_step1_id in(".$step1_IDS.")");

	// $step2IDs = explode(",",$step2IDs);

	//From the Step2 IDs get the name from Step 3
	$functionIDArray = array();

	foreach ($step2IDs as $key => $step2ID) {
		$functionIDArray[$key] = $functionsArray[$step2ID[1]]["name"];

		$functionID = singlefield("function_id","gantt_import_step2","id=".$step2ID[0]);
		$functionName = $functionsArray[$functionID]["name"];

		$selectValues = singlefield("GROUP_CONCAT(name)","gantt_import_step3","import_step2_id in(".$step2ID[0].") and type=1 and name!='none'");


		if($selectValues!=null)
			$arr[$functionName]["profiles"]["name"] = [$selectValues];

		$selectValues = singlefield("GROUP_CONCAT(name)","gantt_import_step3","import_step2_id in(".$step2ID[0].") and type=2");

		if($selectValues!=null)
			$arr[$functionName]["events"]["name"] = [$selectValues];
	}

	// print_r($arr);
	// exit();

	if($x==1)
		return $functionIDArray;
	else if($x==2){
		if(isset($arr))
		return $arr;
	}
}


function getEventStatus($eventIDs=""){

	// print_r($evArray);
	// $eventIDs = implode(", ",$evArray);
	$url = "https://systest.juniper.net/rmv2/edp/event/search_events?from_date=&to_date=&creator=&domain=&bu_name=&event_status%5B%5D=false&event_status%5B%5D=false&event_status%5B%5D=false&event_status%5B%5D=false&event_status%5B%5D=false&event_status%5B%5D=false&event_status%5B%5D=false&_dc=1509079586509&page=1&start=0&limit=500&event_id=".$eventIDs;

	$result = getJSONURL($url);

	// print_r($result);
	// exit();

	$arr = array();

	foreach ($result->events as $key => $value) {
		$arr[$value->regression_exec_id] = $value->status;
	}
	// print_r($arr);
	
	return $arr;
}



function getJSONURL($url){
	// echo $filename;

	// return;

	// $ch = curl_init('https://puppeteer.juniper.net/cgi-bin/scritch?branch=15.1F6-S7');
	$ch = curl_init($url);

	// $username = 'ameethmd';
	// $password = 'VA!@me@26@live1';
	$username = 'rajkarthik';
	$password = 'Muruga@12345';


	curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
	curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_USERPWD, $username . ":" . $password);

	// Execute
	$result = curl_exec($ch);
	if (!curl_errno($ch)) {

		

		// $info = curl_getinfo($ch);

		$result = strip_tags($result);
		$result = json_decode($result);

		return $result;

	}
	
}


?>