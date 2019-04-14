<?php
	if( $_SERVER['SERVER_NAME'] != 'localhost' ){
	require_once('/var/www/html/simplesamlphp-1.14.9/lib/_autoload.php');
		$as = new SimpleSAML_Auth_Simple('default-sp');
		if (!$as->isAuthenticated()) {
			$as->requireAuth();
		}
		$attributes = $as->getAttributes();
		$uid = '';
		if (isset($attributes['uid'][0])) {
			$uid = $attributes['uid'][0];
		}
		if (session_status() == PHP_SESSION_NONE) {
			session_start();
		}
			 $_SESSION['user'] = $uid;
			 $userid = $uid;
			 setcookie("uid", $uid);
			include('accesstokengenerator.php');
			$version='<div id="version"><span class="badge"><a href="version.php" target="_blank">V 1.1</a></span></div>';
	}else{
  		$uid = "rajkarthik";
	}
	
	setcookie("uid", $uid);
	$userid=$uid;
	$version="1.0";

	function getProjectFolder(){
		$realpath    = $_SERVER['REQUEST_URI'];
		$foldername = explode("/", $realpath);

		if($foldername[2]=="dev")
			$foldername = "/".$foldername[1]."/dev";
		else
			$foldername = "/".$foldername[1];

		$whatIwanted = substr_replace(str_replace($_SERVER['DOCUMENT_ROOT'], '', $realpath), "", -6);

		$actual_link = (isset($_SERVER['HTTPS']) ? "https" : "http") . "://$_SERVER[HTTP_HOST]$foldername";

		return $actual_link;
	}
	$projectFolder = getProjectFolder();

?>