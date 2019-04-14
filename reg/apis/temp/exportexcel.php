<?php

pg_connect("host=svljdiweb  dbname=dashboard user=postgres password=postgres") or die("Couldn't Connect ".pg_last_error()); // Connect to the Database


$select = "SELECT test_id, scriptpath, scenario_path,  npi, tech_area, sub_area FROM npi_script_details order by npi";
$export = pg_query ( $select ) or die ( "Sql error : " . pg_error( ) );
$fields = pg_num_fields ( $export );
$header = "";
$data = "";

for ( $i = 0; $i < 1; $i++ )
{
$header .="S.no" . "\t";
$header .= "Test Id" . "\t";
$header .= "Scriptpath" . "\t";
$header .= "Scenario" . "\t";
$header .= "NPI" . "\t";
$header .= "Tech Area" . "\t";
$header .= "Sub Area" . "\t";
}

$n = 1;
while( $row = pg_fetch_row( $export ) )
{
$line = '';
$line = implode("\t", $row) . "\n";
$data .= "$n\t";
   $data .= trim( $line ) . "\n";
$n++;
}


$data = str_replace( "\r" , "" , $data );

if ( $data == "" )
{
        $data = "\n(0) Records Found!\n";
}

header("Content-type: application/octet-stream");
header("Content-Disposition: attachment; filename=All_Npi_Script_mapping.xls");
header("Pragma: no-cache");
header("Expires: 0");
print "$header\n$data";
?>

