agGrid.LicenseManager.setLicenseKey("Juniper_Networks_Site_1Devs13_March_2018__MTUyMDg5OTIwMDAwMA==d26749c899061d3d41179b1732e4ece7");

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
        enableSorting: true,
        enableFilter: true,
        enableColResize: true,
        suppressContextMenu: true,
        suppressSizeToFit:true,
        overlayLoadingTemplate: '<span class="ag-overlay-loading-center">Please wait while your rows are loading</span>',
        overlayNoRowsTemplate: '<span style="padding: 10px; border: 2px solid #444; background: lightgoldenrodyellow;">No Rows To Show</span>',
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
        groupIncludeTotalFooter: false,
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
        },
        isExternalFilterPresent: isExternalFilterPresent,
        doesExternalFilterPass: doesExternalFilterPass
    };

    var gRelease = 'all';

    function isExternalFilterPresent() {
      return gRelease != 'all';
    }

    function doesExternalFilterPass(node) {
      if(gRelease == 'all'){
        return true;
      }
      else if(node.data.releasename.toLowerCase().indexOf(gRelease) > -1){
        return true;
      }
      else{
        return false;
      }
    }

    $("#filter-text-box").keyup(function() {
      gRelease = $('#filter-text-box').val().toLowerCase();
      gridOptions1.api.onFilterChanged();
    });

    /*$("#filter-text-box").keyup(function() {
      obj = this;
      txt = document.getElementById('filter-text-box').value;
      console.log(txt)
      setTimeout(function(){
          if($(obj).val()==""){
            gridOptions1.api.onFilterChanged();
            gridOptions1.api.setFilterModel(null);
            gridOptions1.api.setQuickFilter("");
          }
          else{
            gridOptions1.api.setQuickFilter(txt);        
          }
      },100);
    });*/

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


    // function onFilterTextBoxChanged() {
    //     gridOptions1.api.setQuickFilter(document.getElementById('filter-text-box').value);
    // }

$(document).ready(function(){
	bodyResize();
	loadReports();
	$(".mainpill.nav-pills a").click(function(){
		$(this).tab('show');
	});
});
