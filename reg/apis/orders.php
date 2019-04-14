<?php
	 //print "hi";

    date_default_timezone_set('Asia/Kolkata');
	//$loginid = $_GET['loginid'];

    error_reporting(E_ALL);
    ini_set("display_erros", 1); 
    ini_set('memory_limit', '-1'); //For override memory limit
    ##### Make the Database connection ##########################
    //$dbh = pg_connect("host=rbu.juniper.net dbname=rtpu user=postgres password=postgres"); 
	// $dbh = pg_connect("host=eabu-systest-db.juniper.net dbname=regression user=postgres password=postgres"); 
	$dbh = pg_connect("host=jdi-reg-tools dbname=regression user=postgres password=postgres");

     if (!$dbh) {
         die("Error in connection11: " . pg_last_error());
    }
	
	if(isset($_GET['op'])){ $op = $_GET['op']; } else { $op ='';}
	
	switch ($op) {
		
		case removerec:


			$user = $_GET["user"];
			$relname = $_GET["relname"];

			$rows="update releases set active='no' where release='".$relname."'";

			$result = pg_query($dbh,$rows);

			$arr = array("status"=>1,"message"=>"updated");

			echo json_encode($arr);
			break;
			
		case processalldr:
			// $relname = $_GET["relname"];
			// $fname = $_GET["fname"];
			// $cond1 = "";

			// if($fname!=""){
			// 	$cond1 = " and function='".$fname."'";
			// }

			// $rows = "select drnames,plannedrelease,releasename,function from regressionreport where releasename='".$relname."'".$cond1;

			$rows = "select release from releases where active='yes' and release!=''";

			$result = pg_query($dbh,$rows);

			$i=$j=0;

			$arr = array();
			while ($row = pg_fetch_array($result,null,PGSQL_ASSOC))  {

				$arr[] = $row["release"];

			}

			$rel = "'".implode("','", $arr)."'";
			$cmd = "cd /var/www/html/CI_Report/reg;python3 reg_report_all.py --rel \"".$rel."\" --func \"\" ";
			// echo $cmd;
			$arr = shell_exec($cmd);
			echo $arr;
			break;
			
		case processalldr_1:
			// $relname = $_GET["relname"];
			// $fname = $_GET["fname"];
			// $cond1 = "";

			// if($fname!=""){
			// 	$cond1 = " and function='".$fname."'";
			// }

			// $rows = "select drnames,plannedrelease,releasename,function from regressionreport where releasename='".$relname."'".$cond1;

			$rows = "select drnames,plannedrelease,releasename,function from regressionreport where releasename in (select release from releases where active='yes') and releasename!=''";

			$result = pg_query($dbh,$rows);

			$i=$j=0;



			while ($row = pg_fetch_array($result,null,PGSQL_ASSOC))  {

				$arr = array();
				$arr["drnames"] = $row["drnames"];
				$arr["plannedrelease"] = $row["plannedrelease"];
				$arr["releasename"] = $row["releasename"];
				$arr["function"] = $row["function"];

				$mainArr["data_open"][] = $arr;

				$str = "report.pl ".$arr["drnames"]." ".$arr["plannedrelease"]." ".$arr["releasename"]." '".$arr["function"]."'";

				// echo $str."\n";
				// exit();

				// shell_exec($str);

			}

			$arr = array("status"=>1,"message"=>"Success");

			echo json_encode($arr);
			break;
			
		case processdr1:
			$relname = $_GET["relname"];
			$fname = $_GET["fname"];
			$cond1 = "";

			if($fname!=""){
				$cond1 = " and function='".$fname."'";
			}

			$rows = "select drnames,plannedrelease,releasename,function from regressionreport where releasename='".$relname."'".$cond1;
			$result = pg_query($dbh,$rows);
			$i=$j=0;

			$tmpArr = array();

			while ($row = pg_fetch_array($result,null,PGSQL_ASSOC))  {

				$arr["releasename"][] = $row["releasename"];
				$arr["function"][] = $row["function"];
			}


			$releases = array_unique($arr["releasename"]);
			$function = array_unique($arr["function"]);

			$releases = "'".implode("','", $releases)."'";
			$function = "'".implode("','", $function)."'";

			if($releases=="''")
				$releases = "";

			if($function=="''")
				$function = "";


			// echo $releases."\n";
			// echo $function;

			$cmd = "cd /var/www/html/CI_Report/reg/;python3 reg_report_all.py --rel \"".$releases."\" --func \"".$function."\" ";
			// echo $cmd;
			// exit();

			$arr = shell_exec($cmd);
			echo $arr;
			break;
	
		case processdr:
			$relname = $_GET["relname"];
			$fname = $_GET["fname"];
			$cond1 = "";

			if($fname!=""){
				$cond1 = " and function='".$fname."'";
			}

			$rows = "select drnames,plannedrelease,releasename,function from regressionreport where releasename='".$relname."'".$cond1;

			$result = pg_query($dbh,$rows);

			$i=$j=0;



			while ($row = pg_fetch_array($result,null,PGSQL_ASSOC))  {

				$arr = array();
				$arr["drnames"] = $row["drnames"];
				$arr["plannedrelease"] = $row["plannedrelease"];
				$arr["releasename"] = $row["releasename"];
				$arr["function"] = $row["function"];

				$mainArr["data_open"][] = $arr;

				$str = "report.pl ".$arr["drnames"]." ".$arr["plannedrelease"]." ".$arr["releasename"]." '".$arr["function"]."'";

				// echo $str;
				// exit();

				shell_exec($str);

			}

			$arr = array("status"=>1,"message"=>"Success");

			echo json_encode($arr);
			break;

		case grid_data:
			//print "in";
			$user = $_GET["user"];

			$mainArr=array();
			$mainArr['coldefs'] = array();


			array_push($mainArr['coldefs'],array("headerName"=>"Release Name", "hide"=>true, "field"=>"releasename", "rowGroup"=>true, "filter"=> "agSetColumnFilter", "cellRenderer"=>"releaseCellRenderer", "width"=>220));
			array_push($mainArr['coldefs'],array("headerName"=>"Function", "field"=>"function", "cellRenderer"=>"renderFunction","cellClass"=>"cellalignleft"));
			array_push($mainArr['coldefs'],array("headerName"=>"Debug End", "field"=>"debugend"));
			array_push($mainArr['coldefs'],array("headerName"=>"Script Planned", "field"=>"scriptplanned", "aggFunc"=>"sum", "enableValue"=>true));
			array_push($mainArr['coldefs'],array("headerName"=>"Script Executed", "field"=>"scriptexecuted", "aggFunc"=>"sum", "enableValue"=>true));
			array_push($mainArr['coldefs'],array("headerName"=>"Total Debug", "field"=>"total_debug", "aggFunc"=>"sum", "enableValue"=>true));
			array_push($mainArr['coldefs'],array("headerName"=>"Completed Debug", "field"=>"completed_debug", "aggFunc"=>"sum", "enableValue"=>true));
			array_push($mainArr['coldefs'],array("headerName"=>"Pending Debug", "field"=>"pending_debug", "aggFunc"=>"sum", "enableValue"=>true));
			array_push($mainArr['coldefs'],array("headerName"=>"Overall Pass Rate", "field"=>"overallpassrate"));
			array_push($mainArr['coldefs'],array("headerName"=>"Open Blocker PRs", "field"=>"openblockerprs", "aggFunc"=>"sum", "enableValue"=>true));


			$rows = "select releasename, string_agg(debugids,',') as debugids from regressionreport where releasename in (select release from releases where active='yes') group by releasename order by releasename";

			$result = pg_query($dbh,$rows);



			while ($row = pg_fetch_array($result,null,PGSQL_ASSOC))  {
				$arr = array();
				$arr["releasename"] = $row["releasename"];
				$arr["debugids"] = $row["debugids"];


				$mainArr["allreleases"][] = $arr;
			}



			$rows="select releasename, function, debugend, scriptplanned, scriptexecuted, totaldebugcount+respindebugcount as total_debug, completeddebugcount+respincompleteddebug as completed_debug, tobedebugged+respinpendingdebug as pending_debug,  overallpassrate, openblockerprs,debugids from regressionreport where releasename in (select release from releases where active='yes') group by releasename, function, scriptplanned, scriptexecuted, total_debug, completed_debug, pending_debug, overallpassrate, openblockerprs, debugend ,debugids order by releasename,function";

			$result = pg_query($dbh,$rows);

			$i=$j=0;



			while ($row = pg_fetch_array($result,null,PGSQL_ASSOC))  {
				$arr = array();
				// $arr["releasename"] = strtoupper($row["releasename"]);
				$arr["releasename"] = $row["releasename"];
				$arr["function"] = $row["function"];
				$arr["debugids"] = $row["debugids"];
				$arr["debugend"] = $row["debugend"];
				$arr["scriptplanned"] = intval($row["scriptplanned"]);
				$arr["scriptexecuted"] = intval($row["scriptexecuted"]);
				$arr["total_debug"] = intval($row["total_debug"]);
				$arr["completed_debug"] = intval($row["completed_debug"]);
				$arr["pending_debug"] = intval($row["pending_debug"]);
				$arr["overallpassrate"] = $row["overallpassrate"];
				$arr["openblockerprs"] = intval($row["openblockerprs"]);

				$mainArr["data_open"][] = $arr;
			}


			echo json_encode($mainArr);


	}
pg_close($dbh);


function processMail($arr){
	$data="<h2 style='display:block;background:#efefef;padding:5px;'>".$arr["message"]."</h2>";
	$data.="<blockquote><p><strong>Order number :</strong> ".$arr['id']."</p>";
	$data.="<p><strong>Submitter :</strong> ".$arr['requestor']."</p>";
	$data.="<p><strong>Purpose :</strong> ".$arr['purpose']."</p>";
	$data.="<p><strong>Function :</strong> ".$arr['function']."</p>";
	$data.="<p><strong>RMA_Raised :</strong> ".$arr['rma_raised']."</p>";
	$data.="<p><strong>GLO Ticket :</strong> ".$arr['glo_ticket']."</p>";
	$data.="<p><strong>RMA Ticket :</strong> ".$arr['rma_ticket']."</p>";
	$data.="<p><strong>Root Cause :</strong> ".$arr['root_cause']."</p>";

	$data.="<p><strong>Status :</strong> ".$arr['status']."</p>";
	$data.="<p><strong>Desciption :</strong> ".$arr['description']."</p></blockquote>";

	sendmail($data,"New Order");

}
function sendmail($html,$subject){

    // print_r($toArr);
     // echo $html;
     // exit;
    // $tos="rajkarthik@juniper.net, hemants@juniper.net";
    $tos="rpavan@juniper.net, darshanrs@juniper.net";
    // $cc="sowjanya@juniper.net";
    $cc="rajkarthik@juniper.net";
   
    $eol = "\r\n";
    // a random hash will be necessary to send mixed content
    $separator = md5(time());

    $headers  = "MIME-Version: 1.0".$eol;
    $headers .= "From: autotools-noreply@juniper.net".$eol;
    $headers .= "Cc:".$cc." ".$eol;
    // $headers .= "Bcc: rajkarthik@juniper.net".$eol;
    $headers .= "Content-Type: multipart/alternative; boundary=\"$separator\"".$eol;
    $headers .= "--$separator".$eol;
    $headers .= "Content-Type: text/html; charset=utf-8".$eol;
    $headers .= "Content-Transfer-Encoding: base64".$eol.$eol;

    // message body
    $body = rtrim(chunk_split(base64_encode($html)));

    // Send email

    // echo $body;
    // exit();
    if(mail($tos,$subject,$body,$headers)){
        // echo 'Email has sent successfully.';
    }
    else{
        // echo 'Email sending fail.';
    }

}



//print json_encode($final_arr);
/* $myfile = fopen("../data/orders.json", "w") or die("Unable to open file!");
fwrite($myfile, json_encode($final_arr));
fclose($myfile);  */

exit;
?>
</body>
</html>


