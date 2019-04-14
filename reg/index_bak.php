<?php 
     $rand = rand();
?>
<html lang="en">

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <title>.: NPI Monitor :.</title>
  <link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
  <link href='//fonts.googleapis.com/css?family=Droid+Sans' rel='stylesheet' type='text/css' />
  <link rel="stylesheet" href="css/font-awesome.min.css" type="text/css" />
  <link rel="stylesheet" href="css/fonts/fontawesome-webfont.ttf?v=4.3.0" type="text/css" />
  <link rel="stylesheet" href="css/main.css?v=<?=$rand?>" type="text/css" />
  <link rel="stylesheet" href="css/rpt-phase2.css" type="text/css" />
  <link rel="stylesheet" href="css/ag-grid.css?v=<?=$rand?>" type="text/css" />
  <link rel="stylesheet" href="css/style.css?v=<?=$rand?>" type="text/css" />

  <style>

#header{
  border-bottom: 3px solid #10aeff;
}

.releaseForm hr{
  border-top: 1px dotted #ededed;
}

  body{
    color:#000;
  }
#labnol label{
  padding-right:10px;
}
#labnol{
  height:100px;
  width: 100%;
  margin:0;
}

#frmHolder{
  position: relative;
  width:50%;
  margin:0 auto;
  border-bottom-left-radius: 15px;
  border-bottom-right-radius: 15px;
  background: #e8e8e8;
  padding:10px;
  border:0px;
  -webkit-box-shadow: 1px 1px 2px 0px rgba(0,0,0,0.75);
  -moz-box-shadow: 1px 1px 2px 0px rgba(0,0,0,0.75);
  box-shadow: 1px 1px 2px 0px rgba(0,0,0,0.75);
}

#upArrow a{
  display: block;
}
#upArrow{
  text-align: center;
  padding: 5px;
  width: 25%;
  margin: 0 auto;
  border-bottom: 2px solid #7c7c7c;
  background: #2baeff;
  border-bottom-left-radius: 20px;
  border-bottom-right-radius: 20px;
}

.lhtype{
  line-height: 35px;
  display: block;
}

.button {
  background-color: #333333;
  border: none;
  color: white;
  padding: 12px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 16px;
  margin: 16px 2px;
  width: 50px;
  height: 50px;
}

.roundbutton {border-radius: 50%;}
.bold{
  font-weight: bold;
}

#containerLoader{
  position: absolute;
  width: 100%;
  height: 100%;
  background: #3d3d3d;
  z-index: 1000;
  top: 0;
  left: 0;
  border-bottom-right-radius: 15px;
  border-bottom-left-radius: 15px;
  opacity: 0.3;
  display: none;
}

.dn{
  display: none;
}

#main{
  height: 150px;
}

#my-nav {
    width: 100%;
    z-index: 100;
    margin-left: 20px;
    margin-bottom: 0;
    padding-left: 0;
    list-style: none;
    background: #2c2c2c;

}

.bodybg{
  overflow-y: auto;
  background: #f5f5f5;
  -webkit-box-shadow: -3px 1px 3px 0px rgba(0,0,0,0.59);
  -moz-box-shadow: -3px 1px 3px 0px rgba(0,0,0,0.59);
  box-shadow: -3px 1px 3px 0px rgba(0,0,0,0.59);
}

#my-nav li.active a{
  display: block;
  z-index: 1000;
  background: #f5f5f5;
  color:#000 !important;
  font-weight: bold;
}

#my-nav .nav-pills>li>a{
  border-radius: 0;
  color: #fff;
}
#my-nav .nav-pills>li>a:hover, #my-nav .nav-pills>li>a:active{
  color: #3d3d3d;
}

.articleHeader{
    color: #2a6496;
    border-bottom: 1px dotted #000;
    font-weight: bold;
    background: #efefef;
    display: block;
    font-family: arial,verdana;
    padding: 10px;
}

.userHolder{
    z-index: 1000;
    margin: 0px -20px 4px 20px;
    margin-left: -20x;
    background: #373737;
    padding: 10px 10px 20px;
    color:#fff !important;
}

.cboth{
    display: block;
    clear: both;
    margin:5px 0;
}

.aCenter{
  text-align: center;
}

#pageInitial .maincontent {
    padding: 10px;
}

#pageInitial{
    width: 100%;
    margin: 0px auto;
    height: 300px;
    background: #fff;
}
#pageInitial .maincontent h1 {
    margin: 0 auto;
    border-bottom: 1px dotted #000;
}

#pageInitial .maincontent h1 {
    margin: 0 auto;
    border-bottom: 1px dotted #000;
}

#pageInitial h1{
  font-size: 20px;
}
#pageInitial blockquote{
  font-size: 15px;
}


  </style>
</head>
<body onresize="bodyResize()">
  <div id="wrapper" class="" >
    <div class="page-content-wrapper"> 
      <div id="header">
        <div id="top-nav">
          <center><span class="title-jdi text-white">NPI Monitor</span></center>

        </div>
      </div>
    </div>


    <div class="content section-wrap" style='padding: 35px 10px 10px 5px !important; position: relative; height:100%;'>


        <div id="main">
          <div class="row-fluid">
            <div class="col-md-12 releaseForm">

              <div id="frmHolder">
                <div id="containerLoader"></div>
                <form id="labnol" name="labnol" onsubmit="return getData();">
                  <div class="row-fluid">

                    <div class="form-group col-md-3">
                      <label class="bold">Select Type:</label>
                      <label class="lhtype"><input type="radio" value="summary" id="summary" name="exectype" checked onclick="handleClick(this)"> Summary</label>
                      <label class="lhtype"><input type="radio" value="fullreport" id="fullreport" name="exectype" onclick="handleClick(this)"> Full Report</label>
                    </div>


                    <div class="form-group col-md-3">
                        <label for="selNPI" class="bold">Search By:</label>
                        <select class="form-control" id="selNPI" style="display:block;width:100%;" disabled="disabled">
                        </select>
                    </div>
                    <div class="form-group col-md-4">
                        <label for="releasename" class="bold">Select Release:</label>
                        <select class="form-control" id="releasename" style="display:block;width:100%;">
                        </select>
                    </div>
                    <div class="form-group col-md-2" style="text-align: center;">
                        <button class="button roundbutton" type="submit"><span class="txt">GO</span><i class="fa fa-refresh fa-spin dn"></i></button>
                    </div>

                  </div>



                </form>
              </div>
              <input style="float:right;background-color: #337ab7 ;margin-bottom:10px;margin-right:5px;" type='button' value='Export All NPI-Script Excel' class='btn btn-primary' id='exportbtn' onclick="window.location.href='https://jdiregression.juniper.net/autotools/dev/npimonitor/apis/exportexcel.php'" />

                <div id="upArrow">
                  <a href="javascript:void(0)" class="closebtn" onclick="showhideTopNav(this)"><i class="arrow up"></i></a>
                </div>
              <hr/>

              <div id="showhide"></div>
         
            </div>
          </div>
        </div>

        <div id="pageContainer" class="dn">

          <div class="row-fluid">
            <div class="col-md-12 bodybg">

            </div>
          </div>

        </div>

        <div id="pageInitial">

<div class="maincontent"> <h1>About NPI Monitor</h1> <blockquote> Ths Tool, displays overview of NPI results. It shows the data based on scripts that are executed / Pass / Fail for a particular release/Platform.</blockquote> </div>


        </div>
      <!-- </div> -->

    </div>
 
    <div class="page-loader">
        <!-- <i class="icon close">&times;</i> -->
        <p class="still-working">Few more Seconds. I am working on it&hellip;</p>
    </div>



  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
  <script src="js/bootbox.min.js"></script>
  <script src="js/underscore-min.js"></script>
  <script src="js/ag-grid-enterprise.min.js"></script>

  <script src="js/typeahead.bundle.js"></script>
  <script src="js/jquery.accordion.js"></script>
  <script src="js/inc.js"></script>
  <script src="js/index.js"></script>


<script src="js/FileSaver.js"></script>
<script src="js/tableexport.js"></script>

<script>

$(document).ready(function(){

    $.ajax({
      type: "GET",
      url: "apis/index_bak.php?action=getdefaultdata",
      contentType: "application/json; charset=utf-8",
      dataType: "json",
      success: function(data) {
          npis = data.npis;
          str="<option value=''>Select NPI</option>";
          $.each(npis,function(i,npi){
            str+="<option value='"+npi+"'>"+npi+"</option>";
          });

          $("#selNPI").html(str);

          releases = data.releases;

          str="<option value=''>Select Releases</option>";
          $.each(releases,function(i,release){
            str+="<option value='"+release+"'>"+release+"</option>";
          });

          $("#releasename").html(str);
      }
    });
})


function handleClick(obj) {

  if($(obj).val()=="summary"){
    $("#selNPI").attr("disabled","disabled");
    $("#releasename").removeAttr("disabled");
  }
  else{
    $("#selNPI").removeAttr("disabled");
    $("#releasename").removeAttr("disabled");
  }
}



function bodyResize(){
	wHt = window.innerHeight;

	if($("#frmHolder").css("display")=="none"){
		frmHeight = 0;
		$(".bodybg, #pageInitial").height(wHt-90);
		$("#grid0").height(wHt-210);
	}
	else{
		frmHeight = $("#frmHolder").innerHeight();

		$(".bodybg,#pageInitial").height(wHt-208);
		$("#grid0").height(wHt-328);
	} 

	// frmHeight = frmHeight+($("#header").height()+60);
	// innerBodyHeight = wHt-frmHeight;
	// debugger;
	// // alert(innerBodyHeight + " "+wHt+" "+frmHeight);
	// alert(innerBodyHeight)
 //  	$(".bodybg").height(innerBodyHeight);

}


function showhideTopNav(obj){

if($("#frmHolder").css("display")=="none"){
    $("#frmHolder").slideDown("fast",function(){
      $(obj).find("i").addClass("up").removeClass("down");
      bodyResize();
    });
    $("#main").css("height","150px");
}
else{
  $("#frmHolder").slideUp("fast",function(){
    $(obj).find("i").addClass("down").removeClass("up");
    bodyResize();
  });
    $("#main").css("height","30px");
}



}


function showContainerLoader(){
  $(".roundbutton .txt").fadeOut(function(){
    $(".roundbutton .fa-spin").removeClass("dn").parent().trigger("blur");
    // $(".roundbutton").attr("disabled","disabled");
  });

  $("#containerLoader").fadeIn();
}
function hideContainerLoader(){
  $(".roundbutton .fa-spin").addClass("dn");
  $(".roundbutton .txt").show();
    // $(".roundbutton").removeAttr("disabled");

  $("#containerLoader").fadeOut("fast");
}

var globalJSONdata= "";

function getData(){

  val = $('input[name=exectype]:checked').val();

  npi = $("#selNPI").val();
  release = $("#releasename").val();

  if((val=="summary") && (release=="")){
    bootbox.alert("Please Select Release",function(){
      setTimeout(function () { 
          $('#releasename').focus(); 
      }, 0); 
    });
    return false;
  }

  else if((val=="fullreport") && ((npi=="") || (release=="") )){
    if(npi==""){
      obj = $("#selNPI");
      str = "NPI";
    }
    else{
      obj = $("#releasename");
      str = "Release";
    }

    bootbox.alert("Please Select "+str,function(){
      setTimeout(function () { 
          $(obj).focus(); 
      }, 0); 
    });

    return false;
  }
  else{

    showContainerLoader();

    $.ajax({
      type: "GET",
      url: "apis/index_bak.php?action=getfulldata&exec="+document.labnol.exectype.value+"&npi="+npi+"&release="+release,
      contentType: "application/json; charset=utf-8",
      dataType: "json",
      success: function(metaData) {
      	
        $("#pageContainer").removeClass("dn");
      	$("#pageInitial").addClass("dn");
      	globalJSONdata = metaData;


        loadData(metaData);
var rowsCount = gridOptions1.api.rowModel.rowsToDisplay.length;
         $('.rcount span').html(rowsCount);
         $('[data-toggle="popover"]').popover({container:'body'});
         $('[data-toggle="popover"]').click(function(){$(this).popover('hide');});
        hideContainerLoader();
      }
    });

  }

  return false;
}


function changeData(obj){
	index = $(obj).val();
	loadData(index);
}

function loadData(data){
//debugger;
		showPageLoader();

    headingTxt = data.headingTxt;

 
		row = data;
		str = "";
		
		// $.each(rows,function(i,row){
			// name = row.name.replace(/\./g, '');
			// idval = name.split(' ').join('_');
			str +='<h4 id="" class="articleHeader"></h4>';

			str +='<div class="rcount">#Filtered Count: <span></span></div>';
      str +='<div class="row cboth"><button class="pull-right btn btn-dark-blue ml15 summary-export-btn_0"><img title="Export" src="img/excel-icon.png" alt="" height="20px"> Export to CSV</button></div>'
			str +='<div class="row cboth"> <div id="grid0" class="jira-grid" style="height:'+($(".bodybg").height()-120)+'px"></div></div>'

		// });
		$(".bodybg").html(str); 

    $(".articleHeader").html(headingTxt);

		// $.each(rows,function(i,row){

			var gridDiv1 = document.querySelector('#grid0');

			var columnDefs = row.coldefs;
			var data =[];
			data = row.meta;
      var child = [];

var v;

          $.each(columnDefs,function(k,v){
          //debugger;
            if(v.headerName=='Test ID'){
              v['cellRenderer']=gettestid;
            }
            if(v.headerName=='Scenario ID'){
              v['cellRenderer']=getScenario;
            }

            //if(v.headerName=='TOTAL'){
              //v['cellRenderer']=getPass;
           // }
	if(v.children != undefined){   
		for (var m in v.children){
		v['cellRenderer']=getPass;
		}
	}

/*
data = row.meta;
for (var m in data){
if (data.hasOwnProperty(m)) {
if(v.children != undefined){
if(v.children[m].field == undefined){
break;
}
else if(v.children[m].field != undefined){
var field = v.children[m].field;
	v['cellRenderer']=function(m,field){
return '<a href="https://jdiregression.juniper.net/nidanaz/temp/'+data[m]['npi']+''+field+'.txt" target="_blank">'+data[m][field]+'</a>'
}
}
}
}
}
}*/
//cellRenderer: function(params) {
   //   return '<a href="https://www.google.com" target="_blank">'+ params.value+'</a>'
 // }

             // var arr = v.children;
             // $.each(arr,function(k,m){
             //   if(m.headerName !='npi' ){
             //     m['cellRenderer']=getPass;
             //   }
             // })
            


          })

          
	        gridOptions1 = {
	            columnDefs: columnDefs,
	            rowData: data,
	            enableColResize: true,
                    onFilterChanged:onFilterChanged,
		    onGridReady: function (params) {
                  params.api.sizeColumnsToFit();
              }
	        };

        	new agGrid.Grid(gridDiv1, gridOptions1);

          // gridOptions1.api.sizeColumnsToFit();
          $('.summary-export-btn_0').click(function(){
              val = $('input[name=exectype]:checked').val();
              val = val.toUpperCase()+"_"+$("#releasename").val();
              var params = {
                fileName: val+'.xls'
            };
            gridOptions1.api.exportDataAsExcel(params);
          });

		// });
		
		hidePageLoader();
}


function gettestid(params){
  // console.log(params);

  if(params.value!='')
    return '<a href="https://systest.juniper.net/entity/test/index.mhtml?test_id='+params.value+'" target="_blank">'+params.value+'</a>'; 
  else
    return params.value;
}

function getScenario(params){
  // console.log(params);

  if(params.value!='')
    return '<a href="https://systest.juniper.net/entity/scenario/index.mhtml?scenario_id='+params.value+'" target="_blank">'+params.value+'</a>'; 
  else
    return params.value;
}

function getPass(params){
  // console.log(params);
debugger;
	if(params.value !='' ||params.value != 0 || params.value != undefined )
    		return '<a href="https://jdiregression.juniper.net/nidanaz/temp/'+params.data.npi+''+params.column.colId+'" target="_blank">'+params.value+'</a>'; 
	else
    	return params.value;

}
 

$(document).ready(function(){
  bodyResize();
})

 function onFilterChanged(){
      $('[data-toggle="popover"]').popover({container:'body'});
      $('[data-toggle="popover"]').mouseenter(function(){$(this).popover('show');});
      var rowsCount = gridOptions1.api.rowModel.rowsToDisplay.length;
      $('.rcount span').html(rowsCount);
    }

</script>
</body>
</html>
