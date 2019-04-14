<?php

// These functions are defined by Karthik
//******************************************************************************
// Function to select record from the table
//******************************************************************************
function singlefield($fields,$table,$cond="")
{
  global $conn;
  $query = "select ".$fields." from ". $table;
    if(!($cond==""))
      $query = $query." where ".$cond;
      // echo "\n".$query."\n";

    $result    = $conn->query($query);
    $z="";
    if(mysqli_num_rows($result)>0)
    { 
      $row=mysqli_fetch_object($result);
      $z = $row->$fields;
    }
    mysqli_free_result($result);
    return $z;
}

function setQuery($query){
    global $conn;
    $z = $conn->query($query);
    // echo "\n\n".$query."<br/>";
    // // echo mysql_error();
    // $z = $conn->insert_id;
    return $z;

}

function getusername($user_id)
{
  global $conn;
  $query = "select username from auth_user where id='".$user_id."'";
  $result    = $conn->query($query);
  $z="";
  if(mysqli_num_rows($result)>0)
  { 
    $row=mysqli_fetch_object($result);
    $z = $row->username;
  }
  mysqli_free_result($result);
  return $z;
}

function getUsernameByAccessToken($accesstoken)
{
  $username = singlefield("username","oauth","accesstoken='".$accesstoken."'");
  return $username;
}
  
function singlerec($fields,$table,$cond="")
{
  global $conn;
  $query = "select ".$fields." from ". $table;
  if(!($cond==""))
  $query = $query." where ".$cond." LIMIT 1";
  // echo $query."<br/>" ;

  // $result = mysqli_query($query);
  // $result = $conn->query($query);

  $rs_id = $conn->query($query);
  $result = mysqli_fetch_object($rs_id);

  return $result;
}


function result_countrows($fields,$table,$cond="")
{
  global $conn;
  $query = "select ".$fields." from ". $table;
  if(!($cond==""))
  $query = $query." where ".$cond;
  //echo $query;

  $result = $conn->query($query);
  $row_cnt = $result->num_rows;
  return $row_cnt;
}


function selectqry_resultobj($fields,$table,$cond="")
{
    global $conn;
    $query = "select ".$fields." from ". $table;

    if(!($cond==""))
      $query = $query." where ".$cond;
    // echo $query;

    $result = $conn->query($query);

    return $result;
}

function selectrec($fields,$table,$cond="")
{
    global $conn;
    $a = array();
    $query = "select ".$fields." from ". $table;
    if(!($cond==""))
        $query = $query." where ".$cond;


  // echo "<br/>".$query."\n";

    $result = $conn->query($query);

    $numrows   = mysqli_num_rows($result);
    $numfields = mysqli_num_fields($result);

    $i=$j=0;

    while ($i < $numrows)
    {
        while($j < $numfields)
        {
            mysqli_data_seek($result,$i);
            /* fetch row */
            $row = $result->fetch_row();
            $a[$i][$j] =$row[$j] ;
            $j++;
        }
        $i++;
        $j=0;
    }
    
    mysqli_free_result($result);

    return $a;
}


function insertrec($table,$fields,$value)
{
    global $conn;
    if(is_array($value))
      $value = implode(",", $value);
    else
      $value = "(".$value.")";
   
// echo $value;


    $query = "insert into `".$table ."` (". $fields .") VALUES ". $value;
    $z = $conn->query($query);
    // echo "\n\n".$query."<br/>";
    // echo mysql_error();
    $z = $conn->insert_id;
    return $z;
  
}

function copyrow($table,$fields,$value)
{
    global $conn;
    if(is_array($value))
      $value = implode(",", $value);
    else
      $value = "(".$value.")";
   
// echo $value;


    $query = "insert into `".$table ."` (". $fields .") ". $value;
    $z = $conn->query($query);
    // echo "\n\n".$query."<br/>";
    // echo mysql_error();
    $z = $conn->insert_id;
    return $z;
  
}

function insertrec_update($table,$fields,$value,$onduplicate)
{
    global $conn;

    if(is_array($value))
      $value = implode(",", $value);
    else
      $value = "(".$value.")";


    //silently ignores the insert instead of updating or inserting a row when you have a unique index
    $query = "insert into `".$table ."` (". $fields .") VALUES ". $value;


    if(isset($onduplicate))
      $query .=" ON DUPLICATE KEY UPDATE ".$onduplicate;

    // echo "<br/>\n".$query."\n<br/>";
    $z = $conn->query($query);
    // echo mysql_error();
    $z = $conn->insert_id;
    return $z;
  
}

function insertrec_ignore($table,$fields,$value)
{
    global $conn;

    if(is_array($value))
      $value = implode(",", $value);
    else
      $value = "(".$value.")";

    //silently ignores the insert instead of updating or inserting a row when you have a unique index
    $query = "insert IGNORE into `".$table ."` (". $fields .") VALUES ". $value;
    $z = $conn->query($query);

    // if($isprint==1)
    //   echo $query."\n";
    // exit();
    // echo mysql_error();
    // $lastUpdatedId = $conn->insert_id;
    return $z;
  
}

function insertandgetautoincrid($table,$fields,$value)
{
    global $conn;
    $lastUpdatedId =0;
    $query = "insert into `".$table ."` (". $fields .") VALUES (". $value .")";
    $z = $conn->query($query);
    //echo $query;
    //echo mysql_error();
    if($z)
      $lastUpdatedId = $conn->insert_id;
    return $lastUpdatedId;
  
}

function updaterec($tabname,$fieldname,$newval,$cond)
{
    global $conn;
    $query = "UPDATE ".$tabname." SET ". $fieldname." = ". $newval;
    if(!($cond==""))
      $query = $query." where ".$cond;
      //echo $query;
    $z = $conn->query($query);
    return $z;
}

function updaterecs($table,$col_val, $cond)
{
  global $conn;

  $query = "UPDATE ".$table." SET ".$col_val;

  if(!($cond==""))
      $query = $query." where ".$cond;



  
  // echo "<br/>".$query."<br/>";
  $result=$conn->query($query);
  //echo mysql_error();
  return $result;

}

function softdeleterec($table,$updatefields,$cond="")
{
  global $conn;
  
  $query = "update `".$table."` set ".$updatefields;
  if(!($cond==""))
      $query = $query." where ".$cond;
    
  $z    = $conn->query($query);

  return $z;
}

function hardDeleterecs($table,$cond="",$maintable=""){

  global $conn;

  if($cond=="")
    $query = "delete ".$maintable." from ".$table;
  else
    $query = "delete ".$maintable." from ".$table." WHERE ".$cond;

    // echo $query;


  $z    = $conn->query($query);

  return $z;


}

function deleterec($table,$field,$value,$type="pending")
{
  global $conn;
    //$query = "delete from `".$table."` WHERE `".$field."` = '".$value."'";
    //   echo $query;
  if($type=="delete")
  {
    //$query="update `".$table."` set deleted='a' where `".$field."` = '".$value."'";  //a - approved by admin
    $query = "delete from `".$table."` WHERE `".$field."` = '".$value."'";
  }
  else if($type=="pending")
  {
    $query="update `".$table."` set deleted='y' where `".$field."` = '".$value."'";
  }
  else if($type=="restore")
  {
    $query="update `".$table."` set deleted='n' where `".$field."` = '".$value."'";
  }
  // echo $query;
  // exit();

    $z    = $conn->query($query);

    return $z;
}

function getReportees($manager){

  // getDashboardConnection();
  global $pgCon;

  if (!preg_match('#^(\'|").+\1$#', $manager) == 1){
    $manager = "'".$manager."'";

  }

  $query = "select * from heirarchy where heirarchy ~".$manager."";

  // echo $query;


  $rs = pg_query($pgCon, $query);
  $str = array($manager);
  while ($row = pg_fetch_array($rs)) {

    // print_r($row[1]);
    // echo '<br /><br />';
    $str[] = "'".$row[1]."'";

  }

  return implode(',',$str);
}


function getSystestliveData($username,$release_name){
  global $host;
  global $port;
  global $db;
  global $user;
  global $pass;

  $dataObj=array();
  $release_name_cond ="";
  $con = pg_connect("host=$host $port dbname=$db user=$user password=$pass")
      or die ("Could not connect to server\n"); 
  if($release_name !=''){
    $release_name_cond = " and d.name ='$release_name' ";
  }
  $query = "select a.test_exec_id,a.debug_script_owner,c.name,d.name from er_debug_exec a ,test_exec b, test c, er_regression_result d where d.result_id=a.result_id and b.test_id=c.test_id and a.test_exec_id=b.test_exec_id and a.debug_script_owner in ('".$username."') $release_name_cond order by a.test_exec_id"; 


  // echo $query."<br><br>";

  $rs = pg_query($con, $query) or die("Cannot execute query: $query\n");
  $releases=array();
  $scripts =array();
  while ($row = pg_fetch_row($rs)) {
    
    $test_exec_id       = $row[0];
    $debug_script_owner = $row[1];
    $testscript_name    = $row[2];
    $release_name       = $row[3];

    $releases[]=$release_name;

    $scripts[] = array("id"=>$test_exec_id, "name"=>$testscript_name/*, "engineer"=>$debug_script_owner*/);
  }
  if($release_name_cond ==''){
    $dataObj["releases"] = implode(",",array_unique($releases));
  }else{
    $dataObj=$scripts;
  }
  pg_close($con);
  return $dataObj;
}

    function selcolumn($tabname)
    {
        global $conn;
        $result = $conn->query("SHOW COLUMNS FROM ".$tabname);
        $count = 0;
        while ($row=mysqli_fetch_row($result))
        {
           $cnt = 0;
           foreach ($row as $item)
           {
               if ($cnt == 0)
               {
                   $cnames[$count] = $item;
                   $cnt++;
                   $count++;
               }
           }
        }
        return $cnames;
    }


    function printtable($fields, $tablename,$file=NULL)
    {
    $filename=isset($file) ? $file : "adminadd";
        $cc = selcolumn($tablename);
        $multable = selectrec($fields,$tablename,"deleted='n'");

        echo "<table width='80%' align='center' border=2><tr bgcolor='#666666' style='color: white'>";
          foreach($cc as $c)
          {
            echo "<td align='center'><b>".strtoupper($c)."</b></td>";
          }
         // echo "<td align='center'>&nbsp;</td>";
          echo "</tr>";


        for ($k=0;$k<=count($multable)-1;$k++)
        {
            echo "<tr>";
            for ($j=0;$j<=count($multable[0])-2;$j++)
            {
                echo "<td align='center'>".$multable[$k][$j]."</td>";
            }
            echo "<td align='center' width='80'>".showbuttons($_SESSION['AUSER'],$multable[$k][0],$filename,0)."</td>";
            echo "</tr>";
        }
        echo "</table>";
    }
    
  function formatdate($datestg,$format="dmY",$sep="/")
  {
    $retdate=$datestg;
    if(strpos($datestg,"-")!==false)
    {
      if(strlen($datestg)>=10)
      {
        $a=split("-",$datestg);
        $year=$a[0];
        $month=$a[1];
        if(strlen($month)<2)
        {
          $month="0".$month;
        }
        $day=substr($a[2],0,2);
        if(strlen($day)<2)
        {
          $day="0".$day;
        }
        if($format=="dmY")
        {
          $retdate=$day.$sep.$month.$sep.$year;
        }
      }
    }
    return $retdate;
  }
  
  
  
  function DateAdd($interval, $number, $date) {

    $date_time_array = getdate($date);
    $hours = $date_time_array['hours'];
    $minutes = $date_time_array['minutes'];
    $seconds = $date_time_array['seconds'];
    $month = $date_time_array['mon'];
    $day = $date_time_array['mday'];
    $year = $date_time_array['year'];

    switch ($interval) {
    
        case 'yyyy':
            $year+=$number;
            break;
        case 'q':
            $year+=($number*3);
            break;
        case 'm':
            $month+=$number;
            break;
        case 'y':
        case 'd':
        case 'w':
            $day+=$number;
            break;
        case 'ww':
            $day+=($number*7);
            break;
        case 'h':
            $hours+=$number;
            break;
        case 'n':
            $minutes+=$number;
            break;
        case 's':
            $seconds+=$number; 
            break;            
    }
       $timestamp= mktime($hours,$minutes,$seconds,$month,$day,$year);
    return $timestamp;
}


// Functions for older versions of PHP



if ( !function_exists('htmlspecialchars_decode') )
{
    function htmlspecialchars_decode($text)
    {
        return strtr($text, array_flip(get_html_translation_table(HTML_SPECIALCHARS)));
    }
}


function splchars($col)
{
    //$col = str_replace("&amp;lt;", "<", $col); 
   // $col = str_replace("&amp;gt;", ">", $col); 
    $col = str_replace("&quot;", '"', $col); 
  $col = str_replace("'", "&#039;", $col); 
  //$col = str_replace("&squot;", "'", $col); 
  return $col;
}

function unsplchars( $string )
{
  $string = str_replace ( '&amp;', '&', $string );
  $string = str_replace ( '&#039;', '\'', $string );
  $string = str_replace ( '&quot;', '"', $string );
  $string = str_replace ( '&lt;', '<', $string );
  $string = str_replace ( '&gt;', '>', $string );
  return $string;
}


function dateDiff($start, $end) {
  $start_ts = strtotime($start);
  $end_ts = strtotime($end);
  $diff = $end_ts - $start_ts;
  return round($diff / 86400);
}


function pagination($per_page = 10, $page = 1, $url = '', $total){

  $adjacents = "2";

  $page = ($page == 0 ? 1 : $page);
  $start = ($page - 1) * $per_page;

  $prev = $page - 1;
  $next = $page + 1;
  $lastpage = ceil($total/$per_page);
  $lpm1 = $lastpage - 1;

  $pagination = "";
  if($lastpage > 1)
  {
    $pagination .= "<div class='pagination pagination-mini'><ul>";

 if ($page > 1){
      $pagination.= "<li><a href='{$url}$prev'>&laquo;</a></li>";
    // $pagination.= "<li><a href='{$url}$lastpage'>Last</a></li>";
    }

     
    $pagination .= "<li class='details'><span>Page $page of $lastpage</span></li>";
    if ($lastpage < 7 + ($adjacents * 2))
    {
      for ($counter = 1; $counter <= $lastpage; $counter++)
      {


        if ($counter == $page)
          $pagination.= "<li class='current active'><span>$counter</span></li>";
        else
          $pagination.= "<li><a href='{$url}$counter'>$counter</a></li>";
      }
    }
    elseif($lastpage > 5 + ($adjacents * 2))
    {
      if($page < 1 + ($adjacents * 2))
      {
        for ($counter = 1; $counter < 4 + ($adjacents * 2); $counter++)
        {
          if ($counter == $page)
            $pagination.= "<li class='current active'><span>$counter</span></li>";
          else
            $pagination.= "<li><a href='{$url}$counter'>$counter</a></li>";
        }
        $pagination.= "<li class='dot'>...</li>";
        $pagination.= "<li><a href='{$url}$lpm1'>$lpm1</a></li>";
        $pagination.= "<li><a href='{$url}$lastpage'>$lastpage</a></li>";
      }
      elseif($lastpage - ($adjacents * 2) > $page && $page > ($adjacents * 2))
      {
        $pagination.= "<li><a href='{$url}1'>1</a></li>";
        $pagination.= "<li><a href='{$url}2'>2</a></li>";
        $pagination.= "<li class='dot'>...</li>";
        for ($counter = $page - $adjacents; $counter <= $page + $adjacents; $counter++)
        {
          if ($counter == $page)
            $pagination.= "<li class='current active'><span>$counter</span></li>";
          else
            $pagination.= "<li><a href='{$url}$counter'>$counter</a></li>";
        }
        $pagination.= "<li class='dot'>..</li>";
        $pagination.= "<li><a href='{$url}$lpm1'>$lpm1</a></li>";
        $pagination.= "<li><a href='{$url}$lastpage'>$lastpage</a></li>";
      }
      else
      {
        $pagination.= "<li><a href='{$url}1'>1</a></li>";
        $pagination.= "<li><a href='{$url}2'>2</a></li>";
        $pagination.= "<li class='dot'>..</li>";
        for ($counter = $lastpage - (2 + ($adjacents * 2)); $counter <= $lastpage; $counter++)
        {
          if ($counter == $page)
            $pagination.= "<li class='current active'><span>$counter</span></li>";
          else
            $pagination.= "<li><a href='{$url}$counter'>$counter</a></li>";
        }
      }
    }

    if ($page < $counter - 1){
      $pagination.= "<li><a href='{$url}$next'>&raquo;</a></li>";
    // $pagination.= "<li><a href='{$url}$lastpage'>Last</a></li>";
    }else{
    //$pagination.= "<li><a class='current active'>Next</a></li>";
    // $pagination.= "<li><a class='current active'>Last</a></li>";
    }
    $pagination.= "</ul>\n";
  }
  return $pagination;
}


function cut_string_using_last($character, $string, $side, $keep_character=true) { 
    $offset = ($keep_character ? 1 : 0); 
    $whole_length = strlen($string); 
    $right_length = (strlen(strrchr($string, $character)) - 1); 
    $left_length = ($whole_length - $right_length - 1); 
    switch($side) { 
        case 'left': 
            $piece = substr($string, 0, ($left_length + $offset)); 
            break; 
        case 'right': 
            $start = (0 - ($right_length + $offset)); 
            $piece = substr($string, $start); 
            break; 
        default: 
            $piece = false; 
            break; 
    } 
    return($piece); 
} 


function CallAPI($method, $url, $data = false){
    $curl = curl_init();

  switch ($method) {
    case "POST":
    curl_setopt($curl, CURLOPT_POST, 1);
    if ($data)
    curl_setopt($curl, CURLOPT_POSTFIELDS, $data);
    break;
    case "PUT":
    curl_setopt($curl, CURLOPT_PUT, 1);
    break;
    default:
    if ($data)
    $url = sprintf("%s?%s", $url, http_build_query($data));
  }

    // Optional Authentication:
    // $username = 'ameethmd';
    // $password = 'VA!@me@26@live1';
    $username = 'rajkarthik';
    $password = 'Muruga@12345';
    
    curl_setopt($curl, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
    curl_setopt($curl, CURLOPT_USERPWD, $username . ":" . $password);

    curl_setopt($curl, CURLOPT_URL, $url);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);

    $result = curl_exec($curl);

    curl_close($curl);

    // echo "<br/>";
    // print_r($result); 
    // echo "<br/>";
}


function removeFromString($str, $item) {
    $parts = explode(',', $str);

    while(($i = array_search($item, $parts)) !== false) {
        unset($parts[$i]);
    }

    return implode(',', $parts);
}


function setBuffer(){
  $sql="set global net_buffer_length=1000000; set global max_allowed_packet=1000000000;";
    setQuery($sql);
}
?>