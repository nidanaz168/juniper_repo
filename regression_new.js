
 var funct="create";
var gbu = "psg-eabu";
var syncflag = false;
var gmenu =""; /* Varible holding the menu selected */
var stack = [];
var stack_index = -1;
var stack_pointer=0;
var stack_flag= 0;
var rep_elem_cnt=0;
var exportarr;
var completedexport = [];
var mgractive="";
var myExportComponent;
							 
$(document).ready(function() {
$("#main").tabs();  
//$("#configinput").show();
$("#report-sub").show();
            $("#configinput").hide();
            $("#display").show();
$("#report-sub").tabs();  
	$('#main').bind('tabsselect', function(event, ui) {
        var str = String(ui.tab);
        if(str.search(/config/i) >=0)
        {
			$("#configinput").show();
			$("#report-sub").hide();
			$("#display").hide();
			$("#archive_data").hide();
		}
        if(str.search(/report_/i) >=0)
        {
			$("#report-sub").show();
			$("#configinput").hide();
			$("#display").show();
			$("#archive_data").hide();
		}
		});
	$('#createconfig').click(function() {
		release = $("#release").val();
		if(hasWhiteSpace(release)) { alert("The release string should not contain White spaces");return;}
		if(release.search(/_/i) >=0) { alert("The release string should not contain Under Score");return;}
		dr_names = $("#dr_names").val();
		script_planned = $("#scipt_planned").val();
		functionval = $("#function").val();
		planned_release = $("#planned_release").val();
		if(planned_release =="") {  alert("The planned release string should contain valid values");return;}
		active = $("#active").val();
		debug_start = $("#debug_start").val();
		debug_end = $("#debug_end").val();
		if(debug_end=="") { alert("Please input valid value for Date");$("#debug_end").val("2099-01-01");return;}
		if(debug_start=="") { alert("Please input valid value for Date");$("#debug_start").val("2099-01-01");return;}
		$("#configinput").fadeTo("slow", 0.33);
        Popup.showModal('modal',null,null,{'screenColor':'#99ff99','screenOpacity':.6});
		url = "/Regression/report/libs/saveregression.php?release="+release+"&dr_names="+dr_names+"&script_planned="+script_planned+"&function="+functionval+"&planned_release="+planned_release+"&active="+active+"&debugstart="+debug_start+"&debugend="+debug_end;
		 $.ajax({
    url:url,
     async:true,
    success:function(returnedContent){
		$("#configinput").fadeTo("slow", 1.33);
		Popup.hide('modal');
		}
		});
	});
	$("#selrel").change(function() {
			selrel = $("#selrel").val();
			selfunct = $("#selfunct").val();
		url = "/Regression/report/libs/getreleasevals.php?release="+selrel+"&function="+selfunct;
		$.ajax({
    url:url,
     async:false,
    success:function(returnedContent){
		var arr = returnedContent.split("&");
		$("#release").val(arr[0]);
		$("#function").val(arr[1]);
		$("#scipt_planned").val(arr[2]);
		$("#dr_names").val(arr[3]);
		$("#planned_release").val(arr[4]);
		$("#active").val(arr[7]);
		$("#debug_start").val(arr[5]);
		$("#debug_end").val(arr[6]);
        }
        });
	});
	$("#selfunct").change(function() {
			selrel = $("#selrel").val();
			selfunct = $("#selfunct").val();
		url = "/Regression/report/libs/getreleasevals.php?release="+selrel+"&function="+selfunct;
		$.ajax({
    url:url,
     async:false,
    success:function(returnedContent){
		var arr = returnedContent.split("&");
		$("#release").val(arr[0]);
		$("#function").val(arr[1]);
		$("#scipt_planned").val(arr[2]);
		$("#dr_names").val(arr[3]);
		$("#planned_release").val(arr[4]);
		$("#active").val(arr[7]);
		$("#debug_start").val(arr[5]);
		$("#debug_end").val(arr[6]);
        }
        });
	});
	$('#report-sub').bind('tabsselect', function(event, ui) {
        var str = String(ui.tab);
		arr = str.split("#");
		arr1 = arr[1].split("_");
		getreleasereport(arr1[0]);
    });
	$("#selrelar").change(function() {
			selrel = $("#selrelar").val();
			actrel = selrel;
			selrel=selrel.replace(/\./g,'-'); 
			selrel = "archives_"+selrel;
	getreleasereport(selrel);
	});
	$(".headerlink").live("click",function()
	{
			id =$(this).attr("id");
			$(".selectedcol").each(function()
			{
				$(this).removeClass("selectedcol");
			});
			$(".col"+id).each(function()
			{
				$(this).addClass("selectedcol");
			});
			
	});
	$('.seldate').datepick({onSelect:function(dates) {
    }
    ,minDate: new Date(2012, 1, 1),dateFormat: 'yyyy-mm-dd'});

		
});								
function getreleasereport(rel)
{
	disablealltabs();
		$("#display").css({ top: '170px' });
	i = checkforarchive(rel);
	if(i == 0)
	{
		$("#archives").addClass('selected-tab');
		$("#archives").addClass("ui-state-active ui-tabs-selected");
		//select the release in listbox
		$("#selrelar option").each(function() {
  this.selected = $(this).text() == actrel;
});




	}
	else
	{
	$("#"+rel).addClass('selected-tab');
	$("#"+rel).addClass("ui-state-active ui-tabs-selected");
	}
	if((rel.search(/archives/i) >=0) || (i == 0))
	{
		$("#display").css({ top: '250px' });
		$("#configinput").hide();
		arr = rel.split("_");
		if(arr[1]) { rel = arr[1];}
		if((!rel) || (rel.search(/archives/) >=0 )) {rel = $("#selrelar").val();rel=rel.replace(/\./g,"-"); }
		rel=rel.replace(/\./g,"-");
		$("#archive_data").show();
        $("#display").show();
     $("#display").html("<center><h1>" + rel+" SUMMARY</h1><div id='regtab' ></div><div id='detailtab' ></div><div id='graphtab' ></div><div id='breaktab' ></div>");
    url = "/Regression/report/libs/getreleasereport.php?release="+rel;
        $.ajax({
    url:url,
     async:false,
    success:function(returnedContent){
        if(returnedContent.search(/<error>/i) >=0) { $("#regtab").html(returnedContent);;return;}
        else
        {
                            $("#regtab").html(returnedContent);
                            //getdetailedreport(rel,"RBU");
        }
    }
    });
		return;
	}
		$("#archive_data").hide();
		$("#display").show();
	 $("#display").html("<center><h1>"+rel+" SUMMARY</h1><div id='regtab' ></div><div id='heattab' style='overflow-y: scroll;height: 300px;'></div><div id='detailtab' ></div><div id='graphtab' ></div><div id='breaktab' ></div>");
	url = "/Regression/report/libs/getreleasereport.php?release="+rel;
        $.ajax({
    url:url,
     async:false,
    success:function(returnedContent){
		if(returnedContent.search(/<error>/i) >=0) { $("#regtab").html(returnedContent);;return;}
		else
		{
							$("#regtab").html(returnedContent);
							//getdetailedreport(rel,"RBU");
		}
	}
	});
	//Details
	//getdetailedreport(rel,"RBU");
}
function getdetailedreport(rel,func)
{
}
	
function displaygraphs(rel,func)
{
	// Now Progress Data
	blkid="mmxchart";
    var blocker = getChartFromId(blkid);
    if(blocker == null)
    {
        blocker = new FusionCharts("/fusion/FusionCharts_Website/FusionCharts_Website/Charts/ScrollLine2D.swf", blkid, "940", "540");
    }
    blocker.configure("ChartNoDataText", "Loading  Chart Please Wait");
    blocker.render("graphtab");
    $.ajax({
    url:"/Regression/report/libs/getprogress.php?release="+rel+"&type="+func,
     async:false,
    success:function(returnedContent){
        blocker.setXMLData(returnedContent);
    }
    });

}
function displayarchivegraphs(rel)
{
	blkid="arfirstpasschart";
    var blocker = getChartFromId(blkid);
    if(blocker == null)
    {
        blocker = new FusionCharts("/fusion/FusionCharts_Website/FusionCharts_Website/Charts/ScrollStackedColumn2D.swf", blkid, "440", "340");
    }
    blocker.configure("ChartNoDataText", "Loading  Chart Please Wait");
    blocker.render("arfirstpass");
    $.ajax({
    url:"/Regression/report/libs/getchart.php?release="+rel+"&type=firstpass",
     async:false,
    success:function(returnedContent){
        blocker.setXMLData(returnedContent);
    }
	});
	blkid="aroverallchart";
    var blocker = getChartFromId(blkid);
    if(blocker == null)
    {
        blocker = new FusionCharts("/fusion/FusionCharts_Website/FusionCharts_Website/Charts/ScrollStackedColumn2D.swf", blkid, "440", "340");
    }
    blocker.configure("ChartNoDataText", "Loading  Chart Please Wait");
    blocker.render("aroverall");
    $.ajax({
    url:"/Regression/report/libs/getchart.php?release="+rel+"&type=overall",
     async:false,
    success:function(returnedContent){
        blocker.setXMLData(returnedContent);
    }
	});
	// Now Progress Data
	blkid="armmxchart";
    var blocker = getChartFromId(blkid);
    if(blocker == null)
    {
        blocker = new FusionCharts("/fusion/FusionCharts_Website/FusionCharts_Website/Charts/ScrollLine2D.swf", blkid, "440", "340");
    }
    blocker.configure("ChartNoDataText", "Loading  Chart Please Wait");
    blocker.render("armmx");
    $.ajax({
    url:"/Regression/report/libs/getprogress.php?release="+rel+"&type=mmx",
     async:false,
    success:function(returnedContent){
        blocker.setXMLData(returnedContent);
    }
    });
blkid="arrpdchart";
    var blocker = getChartFromId(blkid);
    if(blocker == null)
    {
        blocker = new FusionCharts("/fusion/FusionCharts_Website/FusionCharts_Website/Charts/ScrollLine2D.swf", blkid, "440", "340");
    }
    blocker.configure("ChartNoDataText", "Loading  Chart Please Wait");
    blocker.render("arrpd");
    $.ajax({
    url:"/Regression/report/libs/getprogress.php?release="+rel+"&type=rpd",
     async:false,
    success:function(returnedContent){
        blocker.setXMLData(returnedContent);
    }
    });
blkid="artxchart";
    var blocker = getChartFromId(blkid);
    if(blocker == null)
    {
        blocker = new FusionCharts("/fusion/FusionCharts_Website/FusionCharts_Website/Charts/ScrollLine2D.swf", blkid, "440", "340");
    }
    blocker.configure("ChartNoDataText", "Loading  Chart Please Wait");
    blocker.render("artx");
    $.ajax({
    url:"/Regression/report/libs/getprogress.php?release="+rel+"&type=tx",
     async:false,
    success:function(returnedContent){
        blocker.setXMLData(returnedContent);
    }
    });

}
function disablealltabs()
{
	$('.reptab').each(function () {
		$(this).removeClass("ui-state-active ui-tabs-selected");
		$(this).addClass("ui-state-default");
	});
}
function checkforarchive(rel)
{
	found = 0;
	$(".reptab").each(function()
	{
		id = $(this).attr("id");
		if(rel.search(id) == 0) {found = 1;}
	});
	return found;
}
function hasWhiteSpace(s) {
  return /\s/g.test(s);
}
function maketree()
{
$("#example-advanced").treetable({ expandable: true });

      // Highlight selected row
      $("#example-advanced tbody").on("mousedown", "tr", function() {
        $(".selected").not(this).removeClass("selected");
        $(this).toggleClass("selected");
      });

      // Drag & Drop Example Code
      $("form#reveal").submit(function() {
        var nodeId = $("#revealNodeId").val()

        try {
          $("#example-advanced").treetable("reveal", nodeId);
        }
        catch(error) {
          alert(error.message);
        }

        return false;
      });
}
	
