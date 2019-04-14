<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Origin, Content-Type');
include "inc/common.php";
ini_set("display_errors", "1");
error_reporting(E_ALL);

if (isset($_POST['action']) && ! empty($_POST['action'])) {
    $action = $_POST['action'];
} elseif (isset($_GET['action']) && ! empty($_GET['action'])) {
    $action = $_GET['action'];
}
elseif(isset($_POST['data'])){

	$data = (json_decode(urldecode($_POST['data']), true));
	$action = $data["action"];
	// echo $action;
}
else{
	// mysql_close($conn);
	// pg_close($con); 
	exit();
}


$action = strtolower($action);
// echo $action;

switch ($action){
	case 'getdefaultdata':
		getDefaultData();
		break;
	case 'getfulldata':
		getFullData();
		break;

}



function getFullData(){
	$dbh = pg_connect("host=jdi.juniper.net dbname=dashboard user=postgres password=postgres");
	$relName = $_GET["release"];
	$npi = $_GET["npi"];
	$summary = $_GET["exec"];
	switch ($summary){
		case 'summary':
			getsummary($relName,$dbh);
			break;
		case 'fullreport':
			getfullReport($relName,$npi,$dbh);
			break;

	}
}



function getquery($relName,$dbh){
	$sql ="select finalrelease from npirelease where mainrelease='$relName'";
	$relstrings = array();
	$result = pg_query($dbh,$sql);
	while ($row = pg_fetch_array($result)){
	    $finalrelease = "$row[0]";
		array_push($relstrings,$finalrelease);
	}
	//$str = join(", ",$relstrings);
	return $relstrings;
} 



function getfullReport($relName,$npi,$dbh){
	$val = getHeaders($relName,$dbh);
	$relstring = getquery($relName,$dbh);
	$str = join(", ",$relstring);
	$sql = "select test_id,$str,scriptpath,profile,junos_version,scenario_id,scenario_path ,sub_area,tech_area,npi,domain from npi_script_details where npi='$npi'";
	$result = pg_query($dbh,$sql);
 	$cDataArray = array();

  	$i=$cTotal=0;
  	$j = 1;
  	$cData = $total = array();
	while ($row = pg_fetch_array($result)){
		$cData[$j]["slno"] = $j;
		$cData[$j]["testid"] = $row['test_id'];

		foreach ($relstring as $key => $value){
			$value1 = strtolower($value);
    		$cData[$j][$value] = $row[$value1];
			
  		}
  		$cData[$j]["scriptpath"] = $row['scriptpath'];
  		$cData[$j]["profile"] = $row['profile'];
  		$cData[$j]["junos_version"] = $row['junos_version'];
  		$cData[$j]["scenario_id"] = $row['scenario_id'];
  		$cData[$j]["scenario_path"] = $row['scenario_path'];
  		$cData[$j]["sub_area"] = $row['sub_area'];
  		$cData[$j]["tech_area"] = $row['tech_area'];
  		$cData[$j]["npi"] = $row['npi'];
  		$cData[$j]["domain"] = $row['domain'];

  		
  		#array_push($cDataArray,$cData);
  		$j++;
  	}

	$cDataArray["headingTxt"]="Full Report for NPI: $npi and Release: $relName";
	$cDataArray["coldefs"]=$val;
	$cDataArray["meta"]=array_values($cData);
	echo json_encode($cDataArray); 
}


function getHeaders($relName,$dbh){
	$sql ="select finalrelease from npirelease where mainrelease='$relName'";
	$relstrings = array("#","Test ID");
	$fieldstring = array("slno","testid");
	$result = pg_query($dbh,$sql);
	$headData = array();
	$mainHeadData = array();
	while ($row = pg_fetch_array($result)){
	    $finalrelease = "$row[0]";
	    array_push($fieldstring,$finalrelease);
	    $finalrelease = str_replace("exitcode","",$finalrelease );
	    $finalrelease = str_replace("_FULL","-FULL",$finalrelease );
	    $finalrelease = str_replace("_",".",$finalrelease );

		array_push($relstrings,$finalrelease);
	}
	array_push($relstrings,"Script Path","Profile","Junos Version","Scenario ID","Scenario Path","Sub Area","Tech Area","NPI","Domain");
	array_push($fieldstring,"scriptpath","profile","junos_version","scenario_id","scenario_path","sub_area","tech_area","npi","domain");

	foreach ($relstrings as $key => $value){
		$headData[$key]["headerName"] = $value;
		$headData[$key]["field"] = $fieldstring[$key];
		if ($key == 0){
			$headData[$key]["width"] = 50;
			$headData[$key]["filter"] = "text";
			$headData[$key]["cellStyle"] = array("text-align" => "center");
		}
		else{
			$headData[$key]["width"] = 100;
			$headData[$key]["filter"] = "text";
		}
	}
	return $headData;
}







function getAllNPIs(){
	$dbh = pg_connect("host=svljdiweb dbname=dashboard user=postgres password=postgres");

	$query ="select distinct npi from npi_script_details order by npi;";

	$result = pg_query($dbh,$query);
	$i=0; 
	$arr = array();
	while ($row = pg_fetch_array($result,null,PGSQL_ASSOC))  {

	  $arr[] = $row['npi'];  

	}

	pg_close($dbh);

	return $arr;
}

function getMainReleases(){
	$dbh = pg_connect("host=svljdiweb dbname=dashboard user=postgres password=postgres");

	$query ="select distinct mainrelease from NPIRELEASE order by mainrelease";

	$result = pg_query($dbh,$query);
	$i=0; 
	$arr = array();
	while ($row = pg_fetch_array($result,null,PGSQL_ASSOC))  {
	$arr[] = $row['mainrelease'];  
	}
	pg_close($dbh);
	return $arr;	 
}

function getSummaryHeaders($relName,$dbh){
	$sql ="select finalrelease from npirelease where mainrelease='$relName'";
	$relstrings = array();
	$relstring = getquery($relName,$dbh);
	$fieldstring = array();
	$result = pg_query($dbh,$sql);
	$headData = array();
	$mainHeadData = array();
	$fieldstringhead = array();
	$i=0;
	while ($row = pg_fetch_array($result)){
	    $finalrelease = "$row[0]";
	    #array_push($fieldstring,"pass$i","fail$i","not_exec$i","not_debug$i","na$i");


		$finalrelease = str_replace("exitcode","",$finalrelease);
		$finalrelease1 = str_replace("_FULL","-FULL",$finalrelease );
	    $finalrelease1 = str_replace("_",".",$finalrelease1 );

		array_push($relstrings,"$finalrelease1");

		array_push($fieldstring,"pass@@$finalrelease","fail@@$finalrelease","not_exec@@$finalrelease","not_debug@@$finalrelease","na@@$finalrelease");

		array_push($fieldstringhead,"Pass","Fail","Not_Exec","Not_Debug","NA");
		$i++;
	}

	//print_r $relstrings;
	$headData[0]["headerName"] = "NPI";
	$headData[0]["field"] = "npi";
	$headData[0]["width"] = 100;
	
	$headData[1]["headerName"] = "TOTAL";
        $headData[1]["field"] = "total";
        $headData[1]["width"] = 100;	
	$i = 2;
	$z = 0;
	foreach ($relstrings as $key => $value){
		$n=2;
		$v=0;
		$header = $value;
		$subArray = array();

		for ($v =0; $v < 5 ;$v++) {
			$value1 = $fieldstring[$z];
			//$value1 = str_replace("exitcode","",$value1);
			//$value1 = str_replace("_FULL","-FULL",$value1);
	    	//$value1 = str_replace("_",".",$value1);
			//$value1 = substr($value1, 0, -1);

			$value1 = strtolower($value1);
    		$subArray[$n]["headerName"] = "$fieldstringhead[$z]";
    		$subArray[$n]["field"] = "$value1";
    		$subArray[$n]["cellRendererSelector"] = "getmyURL";
    		if ($v < 2){
    			$subArray[$n]["width"] = 85;
    		}
    		else{
    			$subArray[$n]["width"] = 130;
			}
			$n++;
			$z++;
		}

   		$headData[$i]["headerName"] = $header;
		$headData[$i]["children"] = array_values($subArray);
		$i++;
		
	
	} 

	return $headData;
}


function getsummary($relName,$dbh){
	$val = getSummaryHeaders($relName,$dbh);

	$relstring = getquery($relName,$dbh);
	$fieldval = array();
	#$str = join(" ",$relstring);
	$cDataArray = array();
	$cData = array();
	$joinquery = array();
	$fieldval2 = array();

	foreach ($relstring as $key => $value){
		$passquery = "sum (case when $value ~ 'PASS'  then 1 else 0 end) as pass$value";
		$failquery = "sum (case when $value ~ 'Fail'  then 1 else 0 end) as fail$value";
		$noquery   = "sum (case when $value ~ 'Not Executed' then 1 else 0 end) as not_exec$value";
		$nodebug   = "sum (case when $value ~ 'Debugged' then 1 else 0 end) as not_debug$value";
		$na   = "sum (case when $value ~ 'NA' then 1 else 0 end) as na$value";
		array_push($joinquery,$passquery,$failquery,$noquery,$nodebug,$na);
		array_push($fieldval,"pass".$value,"fail".$value,"not_exec".$value,"not_debug".$value,"na".$value);
		$value = str_replace("exitcode","",$value);
		array_push($fieldval2,"pass@@".$value,"fail@@".$value,"not_exec@@".$value,"not_debug@@".$value,"na@@".$value);

	}

	$str = join(", ",$joinquery);
	$sql = "select distinct npi, count(*) sum , $str from npi_script_details group by npi order by npi";
	$j=0;
	
	$result = pg_query($dbh,$sql);
	while ($row = pg_fetch_array($result)){
		$cData[$j]["npi"] = $row['npi'];
		$cData[$j]["total"] = $row['sum'];
		$m =2;
		$i = 0;
		foreach ($fieldval as $key => $value){
			#$value1 = str_replace("exitcode","",$value);

			$value1 = strtolower($value);
	
			$value2 = str_replace("exitcode","@@",$value1);

    		$cData[$j][$value2] = $row[$value1];
		}
		$j++;
	}

	$cDataArray["headingTxt"] = "Summary Report for Release: $relName ";		 
 	$cDataArray["coldefs"]=array_values($val);
 	$cDataArray["meta"]=$cData;
 	//print_r ($cDataArray);
	echo json_encode($cDataArray); 	
}


function getDefaultData(){
	$arr = array();
	$arr["npis"] = getAllNPIs();
	$arr["releases"] = getMainReleases();

	echo json_encode($arr);
}



?>
