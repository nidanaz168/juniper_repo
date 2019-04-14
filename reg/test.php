
<?php 
    include('header.php');
    $rand = rand();
?>
<html lang="en">

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <title>.: Regression Data :.</title>
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
  .jira-grid  .ag-cell[col-id="releasename"],
  .jira-grid  .ag-cell[col-id="ag-Grid-AutoColumn"]{
    text-align: left;
  }
  #header{
    border-bottom: 3px solid #e5d297;
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
    height:310px;
    width: 100%;
    margin:0;
  }

  #frmHolder{
    position: relative;
    width:80%;
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
    background: #e5d297;
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
    height: 360px;
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
    height: 100%;
    margin: 0px auto;
    min-height: 200px;
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

  textarea {
    resize: none;
  }

  #myConfirmation .form-group .col-sm-8{
    padding-top: 7px;
  }


  .mainpill{
    width: 100%;
    margin: 0 auto;
    background: #a8a8a8;
  }


  .mainpill.nav-pills>li>a {
    padding: 10px 15px;
    margin-right: 3px;
    background-color: #e6e6e6;
    color: #737373;
    /*    -o-text-shadow: 0 1px 1px #fff 1px 1px #fff;
    -moz-text-shadow: 0 1px 1px #fff 1px 1px #fff;
    -ms-text-shadow: 0 1px 1px #fff 1px 1px #fff;
    -webkit-text-shadow: 0 1px 1px #fff 1px 1px #fff;
    text-shadow: 0 1px 1px #fff 1px 1px #fff;
    -o-box-shadow: inset 0 -8px 7px -9px rgba(0,0,0,.4);
    -ms-box-shadow: inset 0 -8px 7px -9px rgba(0,0,0,.4);
    -moz-box-shadow: inset 0 -8px 7px -9px rgba(0,0,0,.4);
    -webkit-box-shadow: inset 0 -8px 7px -9px rgba(0,0,0,.4);
    box-shadow: inset 0 -8px 7px -9px rgba(0,0,0,.4);*/
    -moz-transition-duration: .15s;
    -o-transition-duration: .15s;
    -webkit-transition-duration: .15s;
    transition-duration: .15s;
  }

  .mainpill.nav-pills>li>a, .mainpill.nav-pills>li.active a {
    border-radius: 0;
    border-top:3px solid #e6e6e6;

  }

  .mainpill.nav-pills>li.active a {
    background: #fff;
    border-top: 3px solid #3379b7;
    color: #3379b7;
  }

  .mainpill .tab-content {
    background-color: #f5f5f5;
    padding: 20px;
    padding-top: 10px;
    -ms-box-sizing: border-box;
    -moz-box-sizing: border-box;
    -webkit-box-sizing: border-box;
    box-sizing: border-box;
    border-radius: 0 4px 4px 4px;
  }

  .mainpill .tab-content {
    overflow: auto;
  }

  #showhide>.tab-content{
    background: #fff;
    padding:10px;
  }

  .tab-content{
    height:75%;
  }

  .bold-class{
    font-weight:bold;
  }

  .tab-pane{
    padding:20px;
  }

  #menu1tab, #menu2tab{
    width:100%;
  }


  #beta{
    position: absolute;
    width: 100px;
    background: #ff0000;
    color: #fff;
    font-weight: bold;
    font-size: 12px;
    top: 20px;
    -ms-transform: rotate(-45deg);
    -webkit-transform: rotate(-45deg);
    transform: rotate(50deg);
    height: 16px;
    z-index: 5000;
    text-align: center;
    right: -26px;
    box-shadow: -1px 4px 5px #0e0e0e;

  }

  .rCount {
    padding: 2px 10px;
    font-size: 14px;
    font-weight: bolder;
    background: #efefef;
    /* clear: both; */
    width: 30%;
    text-align: center;
    color: #373737;
    border: 1px dotted #5f5f5f;
    margin-left: 50%;
    left: -15%;
    position: absolute;
  }
  .bg-green {
    background-color: #d5f1d5 !important;
    background-image: linear-gradient(to bottom, #f7fdf7, #e8f7e8);
  }
  .ag-header-cell-text{
    white-space: normal;
  }
  .ag-floating-filter-input{
    color: #333;
  }


</style>
</head>
<body onresize="bodyResize()">
  <div id="beta">BETA</div>
  <div id="wrapper" class="" >
    <div class="page-content-wrapper"> 
      <div id="header">
        <div id="top-nav">
          <center><span class="title-jdi text-white">Regression Data</span></center>

        </div>
      </div>
    </div>


    <div class="content section-wrap" style='padding: 35px 10px 10px 5px !important; position: relative; height:100%;'>

<!--
        <div id="main">
          <div class="row-fluid">
            <div class="col-md-12 releaseForm">

              <div id="frmHolder">
                <div id="containerLoader"></div>

                  <form method="POST" id="labnol" name="labnol" enctype="multipart/form-data">
                    <div class="row-fluid">

                        <fieldset>

                          <div class="col-md-5">
                          
                            <div class="form-group">
                              <label for="textinput">Request By</label>  
                              <input id="textinput" name="textinput" type="text" placeholder="Requested By" value="<?php echo $uid;?>" class="form-control input-md" readonly="readonly">
                            </div>

                            <div class="form-group">
                              <label for="txtfunctions">Select Function</label>
                              <select id="txtFunctions" name="txtfunctions" class="form-control">
                                  <option value="ACX">ACX</option>
                                  <option value="TPTX">TPTX</option>
                                  <option value="MMX">MMX</option>
                              </select>
                            </div>


                            <div class="form-group">
                              <label for="txt_hdesc">Hardware Description</label>
                              <textarea class="form-control"  id="txt_hdesc" name="txt_hdesc" cols="50" placeholder="Enter Description"></textarea>
                            </div>

                          
                            <div class="form-group">
                              <label for="txt_serial">Serial Number</label>  
                              <input id="txt_serial" name="txt_serial" type="text" placeholder="Serial Number" class="form-control input-md">
                            </div>
                          </div>

                          <div class="col-md-5">
                          
                            <div class="form-group">
                              <label for="txtPurpose">Purpose of Request</label>  
                              <input id="txtPurpose" name="txtPurpose" type="text" placeholder="Enter Purpose" class="form-control input-md">
                            </div>

                            <div class="form-group">
                              <label for="txtGLO">GLO of the faulty device</label>  
                              <input id="txtGLO" name="txtGLO" type="text" placeholder="Enter GLO ticket" class="form-control input-md">
                            </div>


                          
                            <div class="form-group">
                              <label for="txtRootCause">Root cause of Failure</label>
                              <textarea class="form-control"  id="txtRootCause" name="txtRootCause" cols="50" placeholder="Enter Root Cause"></textarea>
                            </div>

                          
                            <div class="form-group">
                              <label for="txt_serial">Is RMA raised</label>  
                              

                            <label class="radio-inline" for="radios-0">
                              <input type="radio" name="radios" id="radios-0" value="1" checked="checked" onchange="showhideRMA(1)">Yes
                            </label> 
                            <label class="radio-inline" for="radios-1">
                              <input type="radio" name="radios" id="radios-1" value="2" onchange="showhideRMA(0)">No
                            </label>

                            <div id="rmayes">
                              <input id="txtRMA" name="txtRMA" type="text" placeholder="Enter RMA ticket ID" class="form-control input-md">
                            </div>

                            </div>
                          </div>

                          <div class="form-group col-md-2" style="text-align: center;top:235px;">
                              <button class="button roundbutton" type="submit"><span class="txt">GO</span><i class="fa fa-refresh fa-spin dn"></i></button>
                          </div>

                        </fieldset>


                    </div>
                  </form>
              </div>


                <div id="upArrow">
                  <a href="javascript:void(0)" class="closebtn" onclick="showhideTopNav(this)"><i class="arrow up"></i></a>
                </div>
              <hr/>

              <div id="showhide"></div>
         
            </div>
          </div>
        </div>
-->
        <div id="pageContainer" class="dn">

          <div class="row-fluid">
            <div class="col-md-12 bodybg">

            </div>
          </div>

        </div>

        <div id="pageInitial">



        <ul class="nav nav-pills mainpill">
            <li class="active"><a href="#menu1" data-toggle="tab">Details</a></li>
            <li class=""><a href="#home" data-toggle="tab">About</a></li>
        </ul>


        <div class="tab-content maintabs">
          <div id="home" class="tab-pane fade">
                <div id="exTab1"> 


                  <div class="maincontent"> <h1>About Regrssion Data</h1> <blockquote> About the page.</blockquote> </div>


                </div>
          </div>
          <div id="menu1" class="tab-pane fade in active">
            <div class="clearfix mb10">
              <button class="btn-default pull-left mr10" id="collapse-all">Collapse All</button>
              <button class="btn-default pull-left" id="expand-all">Expand All</button>
              <!-- <h4 class="rCount"></h4> -->

              <button class="pull-right btn btn-dark-blue ml15 summary-export-btn_0"><img title="Export" src="img/excel-icon.png" alt="" height="20px"> Export to CSV</button>
            </div>


            <div id="menu1tab" class="jira-grid"></div>
              
          </div>
        </div>



        </div>
      <!-- </div> -->

    </div>
 
    <div class="page-loader">
        <!-- <i class="icon close">&times;</i> -->
        <p class="still-working">Few more Seconds. I am working on it&hellip;</p>
    </div>



<div id="myConfirmation" class="modal fade" role="dialog">
  <div class="modal-dialog">
    <div class="form-horizontal">
    <!-- Modal content-->
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Order Summary</h4>
      </div>
      <div class="modal-body">


        <div class="form-group">
          <label class="control-label col-sm-4">Requested By:</label>
          <div class="col-sm-8">
            <span id="fortextinput"></span>
          </div>
        </div>

        <div class="form-group">
          <label class="control-label col-sm-4">Purpose of Request:</label>
          <div class="col-sm-8">
            <span id="fortxtPurpose"></span>
          </div>
        </div>

        <div class="form-group">
          <label class="control-label col-sm-4">Function Selected:</label>
          <div class="col-sm-8">
            <span id="fortxtfunctions"></span>
          </div>
        </div>

        <div class="form-group">
          <label class="control-label col-sm-4">GLO of the faulty device:</label>
          <div class="col-sm-8">
            <span id="fortxtGLO"></span>
          </div>
        </div>

        <div class="form-group">
          <label class="control-label col-sm-4">Hardware Description:</label>
          <div class="col-sm-8">
            <span id="fortxt_hdesc"></span>
          </div>
        </div>

        <div class="form-group">
          <label class="control-label col-sm-4">Root cause of Failure:</label>
          <div class="col-sm-8">
            <span id="fortxtRootCause"></span>
          </div>
        </div>

        <div class="form-group">
          <label class="control-label col-sm-4">Serial Number:</label>
          <div class="col-sm-8">
            <span id="fortxt_serial"></span>
          </div>
        </div>

        <div class="form-group">
          <label class="control-label col-sm-4">RMA raised:</label>
          <div class="col-sm-8">
            <span id="forradios"></span><br/>
            Ticket ID: <span id="fortxtRMA"></span>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-warning" data-dismiss="modal">Review Order</button>
        <button type="button" class="btn btn-primary" onclick="confirmOrder()">Confirm Order</button>
      </div>
    </div>
    </div>
  </div>
</div>



  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
  <script src="js/bootbox.min.js"></script>
  <script src="js/underscore-min.js"></script>
  <script src="js/ag-grid-enterprise.16.min.js"></script>

  <script src="js/typeahead.bundle.js"></script>
  <script src="js/jquery.accordion.js"></script>
  <script src="js/inc.js"></script>
  <script src="js/index.js"></script>


<script src="js/FileSaver.js"></script>
<script src="js/tableexport.js"></script>

<script>

$(document).ready(function(){

    loadReports();
    $(".mainpill.nav-pills a").click(function(){
        $(this).tab('show');
    });
});



function loadReports(){


    showPageLoader();
    $.ajax({
        url: "apis/orders.php?op=grid_data&user="+localStorage.getItem("engineer"),
        type:'get',
        dataType: 'json',
        success: function(dataSet){
          mainData = dataSet;
          var target="#menu1";
          if(target=="#menu1" || target=="#menu2"){
            showTabData(target);
          }
          hidePageLoader();
        }
      });


}

function showhideRMA(x){
  if(x==0){
    $("#txtRMA").hide();
  }
  else
    $("#txtRMA").show().focus();
}

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
		// $(".bodybg, #pageInitial").height(wHt-90);
		// $("#grid0").height(wHt-210);
	}
	else{
		frmHeight = $("#frmHolder").innerHeight();

		// $(".bodybg,#pageInitial").height(wHt-208);
		// $("#grid0").height(wHt-328);
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
      // $("#main").css("height","360px");
  }
  else{
    $("#frmHolder").slideUp("fast",function(){
      $(obj).find("i").addClass("down").removeClass("up");
      bodyResize();
    });
      // $("#main").css("height","30px");
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

  if($("#txtPurpose").val()==""){
    bootbox.alert("Please enter Purpose",function(){
      setTimeout(function () { 
          obj = $("#txtPurpose");
          $(obj).focus(); 
      }, 0); 
    });
    return false;
  }

  if($("#txtFunctions").val()==""){
    bootbox.alert("Please select function",function(){
      setTimeout(function () { 
          obj = $("#txtFunctions");
          $(obj).focus(); 
      }, 0); 
    });
    return false;
  }

  if($("#txtGLO").val()==""){
    bootbox.alert("Please enter GLO Ticket",function(){
      setTimeout(function () { 
          obj = $("#txtGLO");
          $(obj).focus(); 
      }, 0); 
    });
    return false;
  }

  if($("#txt_hdesc").val()==""){
    bootbox.alert("Please enter Hardware Description",function(){
      setTimeout(function () { 
          obj = $("#txt_hdesc");
          $(obj).focus(); 
      }, 0); 
    });
    return false;
  }

  if($("#txtRootCause").val()==""){
    bootbox.alert("Please enter root cause",function(){
      setTimeout(function () { 
          obj = $("#txtRootCause");
          $(obj).focus(); 
      }, 0); 
    });
    return false;
  }

  if($("#txt_serial").val()==""){
    bootbox.alert("Please enter serial number",function(){
      setTimeout(function () { 
          obj = $("#txt_serial");
          $(obj).focus(); 
      }, 0); 
    });
    return false;
  }

  
  if($("input:radio[name=radios]:checked").val()=="1" && $("#txtRMA").val()==""){
    bootbox.alert("Please enter RMA Ticket ID",function(){
      setTimeout(function () { 
          obj = $("#txtRMA");
          $(obj).focus(); 
      }, 0); 
    });
    return false;
  }

  showSummary();


  return false;
}


$("#labnol").submit(function(event) {
    event.preventDefault();

    getData();



});

function confirmOrder(){

    $("#myConfirmation").modal("hide");

    showContainerLoader();
    $.ajax({
        url: "apis/orders.php?op=add",
        data:$("#labnol").serialize(),
        type:'post',
        dataType: 'json',
        success: function(dataSet){



              hideContainerLoader();

        }
      });

}

function showSummary(){

  $("#fortextinput").html($("#textinput").val());

  $("#fortxtPurpose").html($("#txtPurpose").val());

  $("#fortxtfunctions").html($("#txtFunctions").val());

  $("#fortxtGLO").html($("#txtGLO").val());

  $("#fortxt_hdesc").html($("#txt_hdesc").val());

  $("#fortxtRootCause").html($("#txtRootCause").val());

  $("#fortxt_serial").html($("#txt_serial").val());

  if($("#radios").val()=="1")
    radios = "Yes";
  else
    radios = "No";

  $("#forradios").html(radios);

  $("#fortxtRMA").html($("#txtRMA").val());




  $("#myConfirmation").modal("show")
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
      // str +='<div class="row cboth"><div id="grid0" class="jira-grid" style="height:'+($(".bodybg").height()-120)+'px"></div></div>'
			str +='<div class="row cboth"><div id="grid0" class="jira-grid" style="height:90%"></div></div>'

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




          })

          
	        gridOptions1 = {
	            columnDefs: columnDefs,
	            rowData: data,
	            enableColResize: true,
              // onFilterChanged:onFilterChanged,
              onGridReady: function (params) {
                  params.api.sizeColumnsToFit();
              },
              autoGroupColumnDef:{
                headerName: 'Release Name',
                pinned: 'left',
                width: 150
              }
	        };





        	new agGrid.Grid(gridDiv1, gridOptions1);

          // gridOptions1.api.sizeColumnsToFit();


		// });
		
		hidePageLoader();
}



$('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
  var target = $(e.target).attr("href") // activated tab
  // alert(target);
  if(target=="#menu1" || target=="#menu2"){
    showTabData(target);
  }
});

Number.prototype.pad = function(size) {
  var s = String(this);
  while (s.length < (size || 2)) {s = "0" + s;}
  return s;
}

function showTabData(tabID){

  dataSet = mainData;
  $(tabID+'tab').html("");

  var gridDiv1 = document.querySelector(tabID+'tab');
  columnDefs = dataSet.coldefs;

  if(tabID=="#menu1")
    data = dataSet.data_open;
  else
    data = dataSet.data_history;


    // $.each(columnDefs,function(k,v){
    //   if(v.headerName=='Script Name'){
    //     v['cellRenderer']=getUrl;
    //   }

    // })


    var gridOptions1 = {
        columnDefs: columnDefs,
        rowData: data,
        enableColResize: true,
        animateRows: true,
        enableRangeSelection: true,
        enableSorting: true,
        enableFilter: true,
        headerHeight: 44,
        // groupRowAggNodes: groupRowAggNodes,
        onGridReady: function (params) {
            var rc = gridOptions1.api.rowModel.rowsToDisplay.length;
            $("#count1").html ("<h4 class='rCount'>Row Count: "+rc+"</h4>");

            var defaultSortModel = [
                    {colId: "debugexit", sort: "asc"}
                ];
            params.api.setSortModel(defaultSortModel);

            $.each($(".ag-header-cell-text"),function(){
              newStr = $(this).html().replace("sum","");
              newStr = newStr.replace("(","");
              newStr = newStr.replace(")","");
              $(this).html(newStr)
            })
        },
        onFilterChanged: function(params) {
            var rc = gridOptions1.api.rowModel.rowsToDisplay.length;
            $("#count1").html ("<h4 class='rCount'>Row Count: "+rc+"</h4>");
        },
        autoGroupColumnDef:{
          headerName: 'Release Name',
          pinned: 'left',
          width: 300
        },
        groupIncludeTotalFooter: true,
        rowClassRules: {
            // row style function
            'bg-green': function(params) {
              if( params.data ){
                var n = params.data.pending_debug;
                return  n == 0;
              }
              else if( params.node.aggData ){
                var n = params.node.aggData.pending_debug;
                return  n == 0;
              }
            }
        }
    };

    $('#expand-all').click(function(){
      gridOptions1.api.expandAll();
    });
    $('#collapse-all').click(function(){
        gridOptions1.api.collapseAll();
    });

// gridOptions1.getRowStyle(params){
//     if (params.data.pending_debug == 0) {
//         return {'background-color': 'yellow'}
//     }
//     return null;
// }


          $('.summary-export-btn_0').click(function(){
            
              var params = {
                fileName: 'reg.xls'
            };
            gridOptions1.api.exportDataAsExcel(params);
          });

    new agGrid.Grid(gridDiv1, gridOptions1);

    gridOptions1.api.sizeColumnsToFit();

}

$(document).ready(function(){
  bodyResize();


})


</script>
</body>
</html>
