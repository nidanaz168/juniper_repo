var isLoaderVisible = false;

agGrid.LicenseManager.setLicenseKey("Juniper_Networks_Site_1Devs_31_October_2017__MTUwOTQwODAwMDAwMA==038f1a6883b4b4741e1d091fcf55b194");
 
function showPageLoader(){
	if( !isLoaderVisible ){
		isLoaderVisible = true;
		$('body').css({
				// 'position': 'fixed',
				'width': '100%'
				});
		$('.page-loader').fadeIn('fast');
		loaderTimeout = setTimeout(function(){
				$('.page-loader').animate({'opacity': '0.95'}, 'slow').find('.close').fadeIn();
				$('.still-working').animate({'top':'15px', 'opacity': '0.9'},'slow');
				}, 2500);
	}
} 

function hidePageLoader(){
	if( isLoaderVisible ){
		clearTimeout(loaderTimeout);
		$('body').css({
				// 'position': 'static',
				'width': 'auto'
				});
		$('.page-loader').find('.close').fadeOut();
		$('.page-loader').animate({'opacity': '0.8'}).fadeOut('fast');
		$('.still-working').css({'top':'99%', 'opacity': '0'});
		isLoaderVisible = false;
	}
}
$(function() {
		

		

});

function generateReport(){


	$("#showhide").hide("slow");
	showPageLoader();
	  ajaxURL = 'api/index.php?action=generatereport&relname='+$("#release").val();
	// ajaxURL = "api/tempjson.php";
	var request = $.ajax({
		type: 'GET',
		cache: false,
		url: ajaxURL,
		dataType: "JSON"
	});

	request.done(function(data) {

		$("#showhide").show("slow");
		console.log(data)
		tab1 = data[0];
		tab2 = data[1];
		tab3 = data[2];
		tab4 = data[3];
		//adding new graph
		tab5 = data[4];
		//tab5 = data[4];

		$("#exTab1 h4").html(tab1.name);
		$("#exTab2 h4").html(tab2.name);
		$("#exTab3 h4").html(tab3.name);
		//$("#exTab4 h4").html(tab4.name);

		loadData("#exTab1",tab1,"a", '50%');
		loadData("#exTab2",tab2,"b", '50%');
		loadData("#exTab3",tab3,"c", '50%');
		//loadData("#exTab4",tab4,"d", '50%');

		loadSCurve("#exTab4",tab4);
		loadHist("#exTab5",tab5);


		hidePageLoader();
    	$('.tid').DataTable({
    		"paging": false,
    		"ordering": true,
    		"searching": true,
		"aaSorting": [],
		//"order": [],
                "oSearch": {"bSmart": false},
    		"search": {
    			"smart": false,
    			"regex": false
    		},
               "order": []
                  
                });
    });
	return false;
}



function loadData(tab,dataArray,uniqueVal, width){
	str = "";
	tabPaneData = "";
	summaryRows = "";
	var tabli = dataArray.name;
	$(tab).find(".tab-content").html("");
	$.each(dataArray.data,function(i,data){

			//Building the Tabs Start ***********************
			headerName = data.name;
			if(i==0){
				isactive = "active";
				active="class='"+isactive+"'";
			}
			else{
				isactive = "";
				active="";
			}

			paneID = "d"+i+""+uniqueVal;
			if(tabli == 'Automated Test Result Summary'){
				var listatus = 'lnocolor';

            	if(data.name=="Full Regressions" || data.name=="FDT"){ 

				 	//if(data.data){
					
				    	//totalKey = findKey(data.data, "Total");
						var totalVal;	
						//if(totalKey!=undefined){
							totalVal = data.topRowData[0].name1;
						//}

                        if (totalVal < 1 )
                            	listatus = 'lgreen';
                        else
                            	listatus = 'lred';
                    //}
                
                     headerName += " <strong>("+totalVal+")</strong>";
				}
                else if(data.name=="Thin Bundle" ){                
					if(data.data){

						failcount=0;
						$.each(data.data,function(k,v){
							if(v.name3=='FAIL'){ 
								failcount=failcount+1;
							}
						})

                        if (failcount < 1 )
                            listatus = 'lgreen';
                        else
                            listatus = 'lred';
                    }

                    headerName += " <strong>("+failcount+")</strong>";
                }

				else{
					if(data.data){

						failcount=0;
						$.each(data.data,function(k,v){
							if(v.name6=='' && v.name4=="FAIL" ){ 
								failcount=failcount+1;
							}
						})

                        if (failcount < 1 )
                            listatus = 'lgreen';
                        else
                            listatus = 'lred';
                    }

                    headerName += " <strong>("+failcount+")</strong>";
				

				}
			      

			      if(data.name=="Tech Area"){

			      }
			      else if (data.name=="FDT Tech Area"){ 
			      }
			      else if (data.name=="FDT"){ 
			      	str+="<li "+active+"><a href='#d1a' data-toggle='tab' class="+listatus+">"+headerName+"</a></li>";
			      }
			      	else{
				str+="<li "+active+"><a href='#"+paneID+"' data-toggle='tab' class="+listatus+">"+headerName+"</a></li>";
			}

            
            }
			else if(tabli == 'Manual Test Result Summary'){
		
				if(data.data){
				//var failcount = data.data.search('FAIL');
                cdnm = findKey(data.data, "FAIL");
                cdnm1 = findKey(data.data, "NA");
                cdnm2 = findKey(data.data, "Improper logs");
                cdnm3 = findKey(data.data, "Untested");
                	if  (cdnm==undefined && cdnm1==undefined  && cdnm3==undefined)
                	       	listatus = 'lgreen';
                	else
                	       	listatus = 'lred';
                }
                // listatus='';
 				str+="<li "+active+"><a href='#"+paneID+"' data-toggle='tab' class="+listatus+">"+headerName+"</a></li>";
			}
			else if(tabli == 'PR Summary'){
	
				if(data.name=="Re-Execution Required"){
					totalCount = Object.keys(data.data).length;
                    if(totalCount > 0)
                            listatus = 'lred'
                    else
                            listatus = 'lgreen';

 
				}
				else{
					totalKey = findKey(data.topRowData, "Total");
					var totalVal;

					if(totalKey!=undefined){
						totalVal = data.topRowData[0].name1;
					}

					if(totalVal!=undefined && totalVal.search('href') > 0) totalVal = totalVal.split('>')[1].match(/\d+/g)[0];
					if(totalVal!=undefined){
						if(totalVal>0)
							listatus = 'lred';
						else
							listatus = 'lgreen'
					}
					
				}


				if(data.name!="Re-Execution Required"){

					if(data.name=="Summary"){
						headerName = "Re-Execution Required";
					}

					if(data.name!="Re-Execution Required")
						headerName += " <strong>("+totalVal+")</strong>";


                	str+="<li "+active+"><a href='#"+paneID+"' data-toggle='tab' class="+listatus+">"+headerName+"</a></li>";
				}

            }
			else
				str+="<li "+active+"><a href='#"+paneID+"' data-toggle='tab'>"+headerName+"</a></li>";


			//Building the Tabs Complete ***********************
			//Add the Sub Tabs here
			$(tab).find("ul").html(str)



			//Building the Table  Start ***********************
			tableHeaders = data.headers;

			if(tableHeaders!=undefined){

				// tableBodyData = data.data;

				
						    /*   var totalVal;

                                                if(totalKey!=undefined){
                                                        totalVal = data.data[totalKey].name1;
                                                        }*/

				//Building the Table  Complete ***********************
				// if(data.name!="Summary"){
					tabPane(tab, paneID, isactive);
				// }
				showData(tabli, paneID, data);
			}
			else{
				url = data.url;
				tabPaneData += tabPaneFrame(paneID, url, isactive);
			}
	});

	
}

function tabPane1(paneID, thead, tbody, width, isactive, summaryRows){


	data = '<div class="tab-pane '+isactive+'" id="'+paneID+'">';

	if(summaryRows!="")
		data += summaryRows;

	data += '<table class="table table-striped customtable tid" style="width:'+width+'; margin:0 auto; margin-top: 10px;float: left;">\
	       <thead><tr>'+thead+'</tr></thead>\
	       <tbody>'+tbody+'</tbody>\
	       <tfoot>'+tfoot+'</tfoot>\
	       </table>\
	       </div>';

	return data;
}

function getUrl(params){
		if(params.value!='' && params.value!='-' && params.value!="0"){
				if(params.value.match(/href='([^']*)/)!=null){
					var href = params.value.match(/href='([^']*)/)[1];
					var text = $(params.value).text();
					return '<a href='+href+' target="_blank">'+text+'</a>';
				}else
					return params.value;
			}
			else
				return params.value;
}


function showData(tabli, paneID, data){
	debugger;
	

	if(data.name=="Re-Execution Required"){
		paneID = "d2c";
	}
	else if(data.name=="Tech Area"){
		paneID = "d0a";
	}
	else if(data.name=="FDT Tech Area" || data.name=="FDT"){
		paneID = "d1a";
	}
		
		columnDef =data.headers;

		if( paneID=='d9a' || paneID=='d10a' || paneID=='d5a' || paneID=='d6a' ||  paneID=='d7a' ||paneID=='d8a' ){

			columnDef[6]['cellRenderer']=getUrl;
			// if(paneID=='d3a'){
			// 	columnDef[4]['cellRenderer']=getColor;
			// }
		}else if(paneID=='d0c' || paneID=='d1c'){
				columnDef[1]['cellRenderer']=getUrl;
				columnDef[0]['cellClass']='bold-class';
		}else if(paneID=='d2c'){
				if(data.name!="Summary"){
				columnDef[0]['cellRenderer']=getUrl;
				columnDef[3]['cellRenderer']=getUrl;
			}
		}



		var gridOptions = {
		    columnDefs: columnDef,
		    enableColResize: true,
		    rowData: null,
		    enableSorting: true,
		    enableFilter: true,
		    enableColResize: true
		};

	if(paneID=='d9a' || paneID=='d10a' || paneID=='d5a' || paneID=='d6a' ||  paneID=='d7a' ||paneID=='d8a'){
			gridOptions.getRowStyle = function(params) {
			    if (params.data.name6=='' && params.data.name4=="FAIL") {
			        return { background: '#dd6c6c8f' }
			    }
			}
		}
	else if(paneID=='d2cb' || paneID=='d2c'){
			gridOptions.getRowStyle = function(params) {

			    if (params.data.name1=='not-fixed') {
			        return { background: '#FFFF66' }
			    }
			    else if (params.data.name1=='fixed' || params.data.name1=='addressed-in-other-pr' ) {
			        return { background: '#dd6c6c8f' }
			    }
			}
			}

			// gridOptions.pinnedBottomRowData=createData(1, 'Bottom');


	if(data.name=="Summary" || data.name=="Full Regressions" || data.name=="FDT"){
		var eGridDiv = document.querySelector('#'+paneID+"a");
	} 
	else if(data.name=="Re-Execution Required" ||  data.name=="Tech Area" || data.name=="FDT Tech Area"){
		var eGridDiv = document.querySelector('#'+paneID+"b");
	}
	else{
    	var eGridDiv = document.querySelector('#'+paneID);
	}


new agGrid.Grid(eGridDiv, gridOptions);
	gridOptions.api.setRowData(data.data);
	gridOptions.api.setFloatingTopRowData(data.topRowData);
	gridOptions.api.sizeColumnsToFit();
}




function findKey(obj, value) {
  	var key;
	_.each(obj, function (v1, k1) {
  		_.each(v1, function (v, k) {
	    	if (v === value) {
	      		key = k1;
	    	}
  		});
  });
  return key;
}


