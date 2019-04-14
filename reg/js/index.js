agGrid.LicenseManager.setLicenseKey("Juniper_Networks_Site_1Devs13_March_2018__MTUyMDg5OTIwMDAwMA==d26749c899061d3d41179b1732e4ece7");

var allDebugIDS = {};

function loadReports(){
	showPageLoader();
	$.ajax({
		url: "apis/orders.php?op=grid_data&user="+localStorage.getItem("engineer"),
		type:'get',
		dataType: 'json',
		success: function(dataSet){
			mainData = dataSet;
			var target="#menu1";

			allreleases = mainData.allreleases;
			$.each(allreleases,function(i,release){
				_releases = release.releasename;
				_releases = _releases.replace(/\-/g,"_");
				_releases = _releases.replace(/\./g,"_");
				
				allDebugIDS[_releases] = release.debugids;

			})
			
			if(target=="#menu1" || target=="#menu2"){
				showTabData(target);
			}
			console.log(allDebugIDS);
			hidePageLoader();
		}
	});
}

function bodyResize(){
	wHt = window.innerHeight;

	if($("#frmHolder").css("display")=="none"){
		frmHeight = 0;
	}
	else{
		frmHeight = $("#frmHolder").innerHeight();
	} 
}

$("#labnol").submit(function(event) {
	event.preventDefault();
	getData();
});

// $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
// 	var target = $(e.target).attr("href") // activated tab
// 	if(target=="#menu1" || target=="#menu2"){
// 		showTabData(target);
// 	}
// });

Number.prototype.pad = function(size) {
	var s = String(this);
	while (s.length < (size || 2)) {s = "0" + s;}
	return s;
}

var gridOptions;

function showTabData(tabID){

	dataSet = mainData;
	$(tabID+'tab').html("");

	var gridDiv1 = document.querySelector(tabID+'tab');
	columnDefs = dataSet.coldefs;

	if(tabID=="#menu1")
		data = dataSet.data_open;
	else
		data = dataSet.data_history;

	gridOptions = {
		columnDefs: columnDefs,
		rowData: data,
		enableSorting: true,
		enableFilter: true,
		enableColResize: true,
		suppressContextMenu: true,
		suppressSizeToFit:true,
		suppressColumnVirtualisation:true,
		overlayLoadingTemplate: '<span class="ag-overlay-loading-center">Please wait while your rows are loading</span>',
		overlayNoRowsTemplate: '<span style="padding: 10px; border: 2px solid #444; background: lightgoldenrodyellow;">No Rows To Show</span>',
		onGridReady: function (params) {
			var rc = gridOptions.api.rowModel.rowsToDisplay.length;
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
			});

			autoSizeAll();

		},
		onFilterChanged: function(params) {
			var rc = gridOptions.api.rowModel.rowsToDisplay.length;
			$("#count1").html ("<h4 class='rCount'>Row Count: "+rc+"</h4>");
		},
		autoGroupColumnDef:{
			headerName: 'Release Name',
			pinned: 'left',
			width: 300
		},
		groupIncludeTotalFooter: false,
		rowClassRules: {
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
		doesExternalFilterPass: doesExternalFilterPass,
		components: {
			releaseCellRenderer: releaseCellRenderer,
			renderFunction: renderFunction
		}
	};

	function renderFunction(params){

		if(params.data){
			refreshIcon = "<a href='#' onclick=\"processDR('"+params.data.releasename+"','"+params.value+"',this)\" class='fright'  title='Refresh Report for "+params.data.function+"' alt='Refresh Report for "+params.data.function+"' ><i class='fa fa-refresh'></i></a>";
			smartDebuggerIcon = "<a href='#' onclick=\"processSD('"+params.data.debugids+"',this)\" title='Smart Debugger for "+params.data.function+"' alt='Smart Debugger for "+params.data.function+"' class='fright'><img src='img/smartD.png' width='15' class='sdIcon'/></a>";

			return smartDebuggerIcon+refreshIcon+"<a href='javascript:void(0)' onclick='openTabs(this)' rel='"+params.data.debugids+"' title='["+params.data.debugids+"]'>"+params.value+"</a>";
		}
		else
			return params.value;

	}


	function releaseCellRenderer(params){
		if( params.value){
			aText = "";
			if(params.node.aggData.pending_debug==0){
				aText = '<a href="#" data-rel="' + params.value +'" title="Archive Release" alt="Archive Release" class="glyphicon glyphicon-archive-alt fright rel-archive mainIcon"></a>';
			}


				_releases = params.value;
				tabID = _releases.replace(/\./g,"-");

				_releases = _releases.replace(/\-/g,"_");
				_releases = _releases.replace(/\./g,"_");


			// console.log(params.node.aggData.pending_debug);
			refreshIcon = "<a href='#'  onclick=\"processDR('"+params.value+"','',this)\" class='fright mainIcon'  title='Refresh Report for "+params.value+"' alt='Refresh Report for "+params.value+"'><i class='fa fa-refresh'></i></a>";
			smartDebuggerIcon = "<a href='#' onclick=\"processSD('"+allDebugIDS[_releases]+"',this)\" title='Smart Debugger for "+params.value+"' alt='Smart Debugger for ' class='fright mainIcon'><img src='img/smartD.png' width='15' class='sdIcon'/></a>";



			return smartDebuggerIcon+refreshIcon+aText+'<span> <a href="#" onclick="showTab(\''+tabID+'\');">' + params.value +' </span>';
		}
		else
			return '';
	}


	var gRelease = 'all';

	function isExternalFilterPresent() {
		return gRelease != 'all';
	}

	function removeRecord(relname){


		bootbox.confirm({
		  message: "Are you sure you want to Archive <strong>"+relname+"</strong>",
		  buttons: {
		      confirm: {
		          label: 'Yes',
		          className: 'btn-success'
		      },
		      cancel: {
		          label: 'No',
		          className: 'btn-danger'
		      }
		  },
		  callback: function (result) {
		      if(result){

				showPageLoader(); 
				$.ajax({
				  url: "apis/orders.php?op=removerec&relname="+relname+"&user="+localStorage.getItem("engineer"),
				  type:'get',
				  dataType: 'json',
				  success: function(dataSet){
				    loadReports();
				    // hidePageLoader();
				  }
				});            
		      }
		  }
		});


	}

	function autoSizeAll() {
	    var allColumnIds = [];
	    var mainColumnIds = [];
	    var functionColumnIds = [];

	    gridOptions.columnApi.getAllColumns().forEach(function(column) {
	    	if(column.colId=="releasename"){
		    	// console.log(column.colId)
		        mainColumnIds.push(column.colId);
		    }
		    else if(column.colId=="function"){
		    	// console.log(column.colId)
		        functionColumnIds.push(column.colId);
		    }
	    	else{
		    	// console.log(column.colId)
		        allColumnIds.push(column.colId);
		    }
	    });
	    // gridOptions.columnApi.autoSizeColumns(allColumnIds);
	    // gridOptions.api.sizeColumnsToFit();
	    gridOptions.columnApi.setColumnWidth(mainColumnIds,400);
	    gridOptions.columnApi.setColumnWidth(functionColumnIds,180);
	    gridOptions.columnApi.autoSizeColumns(allColumnIds);

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
		gridOptions.api.onFilterChanged();
	});

	$('#expand-all').click(function(){
		gridOptions.api.expandAll();
	});
	$('#collapse-all').click(function(){
		gridOptions.api.collapseAll();
	});

	$('.summary-export-btn_0').click(function(){

		var params = {
			fileName: 'reg.xls',
			allColumns:true,
			skipGroups: true
		};
		gridOptions.api.exportDataAsExcel(params);
	});

	$("#menu1tab").html("");
	new agGrid.Grid(gridDiv1, gridOptions);

	// gridOptions.api.sizeColumnsToFit();

	$('[data-toggle="tooltip"]').tooltip(); 


	$('.rel-archive').click(function(){

		relname = $(this).attr('data-rel');
		
		removeRecord(relname)

	})

	// $('#menu1tab').on('click', '.rel-archive', function(e) {
	// 	e.preventDefault();
	// 	 Act on the event 
	// 	relname = $(this).attr('data-rel');
		
	// 	removeRecord(relname)

	// });

}

function processDR(relname,functionname,obj){

	// debugger;
	
	$(obj).find(".fa-refresh").addClass("fa-spin");
	showPageLoader();
	$.ajax({
		url: "apis/orders.php?op=processdr&relname="+relname+"&fname="+functionname,
		type:'get',
		dataType: 'json',
		success: function(dataSet){
			
			if(dataSet.status==1){
				loadReports();
			}

		}
	});
}

function processSD(sdids,obj){
	window.open('https://jdiregression.juniper.net/autotools/dev/smart-debugger/?#drid='+sdids);
}


function showTab(tabID){
	parent.showRelevantTab(tabID);
}


function openTabs(obj){


	debugids = $(obj).attr("rel");
	debugids = debugids.split(",");
	// console.log(debugids);

	$.each(debugids,function(i,debugid){
		window.open('https://systest.juniper.net/ti/webapp/dr/debug_dr/index.mhtml?result_id='+debugid);

	})


}

$(document).ready(function(){
	bodyResize();
	loadReports();
	$(".mainpill.nav-pills a").click(function(){
		$(this).tab('show');
	});
});
