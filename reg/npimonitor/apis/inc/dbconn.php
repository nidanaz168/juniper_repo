<?php

//MySQL Database connecction

//MySQL Database connecction

if(isset($_SERVER['SERVER_NAME']))
	$currentDomain = preg_replace('/www\./i', '', $_SERVER['SERVER_NAME']);
else
	$currentDomain = "";


if($currentDomain=="localhost"){
	$username = "root";
	$password = "root";
	$hostname = "localhost"; 
	$dbname = "planner-dev"; 
}
else{
	// $username = "root";
	// $password = "root";
	// $hostname = "eabu-systest-db.juniper.net"; 
	// $dbname = "planner_stage"; 
	
	$username = "regression";
	$password = "regression";
	$hostname = "localhost"; 
	$dbname = "planner1"; 
}

// $username = "regression";
// $password = "regression";
// $hostname = "localhost"; 
// $dbname = "planner"; 

// Create connection
$conn = new mysqli($hostname, $username, $password, $dbname);
// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}


//Postgres Database connection


	// $host = "ttbg-pgb-01.juniper.net"; 
	// $port = "port=6553";
	// $user = "table_family_ro"; 
	// $pass = "table_family_ro"; 
	// $db = "systest_live_readonly"; 

	$host = "tt-db.juniper.net";
	$port = "port=6553";
	$user = "readonly";
	$pass = "readonly";
	$db = "systest_live_readonly";

/* For console Login*/
	$tUsername = 'rajkarthik';
	$tPassword = 'Muruga@3';

/* For Web Login*/
	$wUsername = 'rajkarthik';
	$wPassword = 'Muruga@3';



?>
