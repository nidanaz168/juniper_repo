
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
var heatmap=0;
var heatmapfunc="heat_MMX";
var prrelease="bug_12.1";
var current_debug_div = "summarydet";
							 
$(document).ready(function() {
$("#main").tabs();  
//$("#configinput").show();
$("#report-sub").show();
$("#config-sub").tabs();
            $("#configinput").hide();
            $("#display").show();



$("#report-sub").tabs();  
	$("#display").html("<h1>TBD</h1>");
	$('#main').bind('tabsselect', function(event, ui) {
        var str = String(ui.tab);
        if(str.search(/config/i) >=0)
        {
			$("#configinput").show();
			$("#report-sub").hide();
			$("#config-sub").show();
			$("#display").hide();
			$("#archive_data").hide();
			$("#heatdisplay").hide();
			$("#heatcontents").hide();
			$("#functiontab").hide();
			$("#firstpassconfiginput").hide();
			$("#bugreleasetab").hide();
		}
        if(str.search(/report_/i) >=0)
        {
			$("#report-sub").show();
			$("#config-sub").hide();
			$("#configinput").hide();
			$("#display").show();
			$("#archive_data").hide();
			$("#heatdisplay").hide();
			$("#heatcontents").hide();
			$("#functiontab").hide();
			$("#firstpassconfiginput").hide();
			$("#bugreleasetab").hide();
			getreleasereport("12.3Pre-R3");
			heatmap=0;
		}
        if(str.search(/passper_/i) >=0)
        {
			$("#report-sub").hide();
			$("#config-sub").hide();
			$("#configinput").hide();
			$("#display").show();
			$("#heatdisplay").hide();
			$("#archive_data").hide();
			$("#heatcontents").hide();
			$("#functiontab").show();
			$("#firstpassconfiginput").hide();
			$("#bugreleasetab").hide();
			heatmap=4;
			getfirstpassper("MMX");
		}
        if(str.search(/prstats_/i) >=0)
        {
			$("#report-sub").hide();
			$("#config-sub").hide();
			$("#configinput").hide();
			$("#display").show();
			$("#archive_data").hide();
			$("#heatdisplay").hide();
			$("#heatcontents").hide();
			$("#functiontab").hide();
			$("#bugreleasetab").show();
			$("#firstpassconfiginput").hide();
			heatmap=5;
			getprdata(prrelease);
		}
        if(str.search(/tbeddata_/i) >=0)
        {
			$("#report-sub").show();
			$("#config-sub").hide();
			$("#configinput").hide();
			$("#display").show();
			$("#archive_data").hide();
			$("#heatdisplay").hide();
			$("#heatcontents").hide();
			$("#functiontab").css({ top: '180px' });
			$("#functiontab").show();
			$("#firstpassconfiginput").hide();
			$("#bugreleasetab").hide();
			heatmap=3;
			gettbeddata(actrel,"MMX");
		}
        if(str.search(/swbehaviour_/i) >=0)
        {
			$("#report-sub").show();
			$("#config-sub").hide();
			$("#configinput").hide();
			$("#display").show();
			$("#archive_data").hide();
			$("#heatdisplay").hide();
			$("#heatcontents").hide();
			$("#functiontab").hide();
			$("#firstpassconfiginput").hide();
			$("#bugreleasetab").hide();
			heatmap=2;
			getswbehaviour(actrel);
		}
        if(str.search(/heatmap_/i) >=0)
        {
			$("#report-sub").show();
			$("#config-sub").hide();
			$("#configinput").hide();
			$("#display").hide();
			$("#heatcontents").show();
			$("#heatdisplay").show();
			$("#archive_data").hide();
			$("#functiontab").css({ top: '180px' });
			$("#functiontab").show();
			$("#firstpassconfiginput").hide();
			$("#bugreleasetab").hide();
			heatmap=1;
			tmprel=actrel.replace(/-/,'\.');
			getheatmap(tmprel,heatmapfunc);
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
		active = $("#active").val();
		debug_start = $("#debug_start").val();
		debug_end = $("#debug_end").val();
		if(debug_end=="") { alert("Please input valid value for Date");$("#debug_end").val("2099-01-01");return;}
		if(debug_start=="") { alert("Please input valid value for Date");$("#debug_start").val("2099-01-01");return;}
		$("#configinput").fadeTo("slow", 0.33);
        Popup.showModal('modal',null,null,{'screenColor':'#99ff99','screenOpacity':.6});
		url = "http://eabu-systest-db.juniper.net/Regression/report/libs/saveregression.php?release="+release+"&dr_names="+dr_names+"&script_planned="+script_planned+"&function="+functionval+"&planned_release="+planned_release+"&active="+active+"&debugstart="+debug_start+"&debugend="+debug_end;
		 $.ajax({
    url:url,
     async:true,
    success:function(returnedContent){
		$("#configinput").fadeTo("slow", 1.33);
		Popup.hide('modal');
		}
		});
	});
	$('#fpcreateconfig').click(function() {
		release = $("#fprelease").val();
		if(hasWhiteSpace(release)) { alert("The release string should not contain White spaces");return;}
		if(release.search(/_/i) >=0) { alert("The release string should not contain Under Score");return;}
		dr_ids = $("#dr_ids").val();
		functionval = $("#fpfunction").val();
		planned_release = $("#fpplanned_release").val();
		milestone = $("#fpmilestone").val();
		$("#firstpassconfiginput").fadeTo("slow", 0.33);
        Popup.showModal('modal',null,null,{'screenColor':'#99ff99','screenOpacity':.6});
		url = "/Regression/report/new/libs/savefpconfig.php?release="+release+"&dr_ids="+dr_ids+"&function="+functionval+"&planned_release="+planned_release+"&milestone="+milestone;
		 $.ajax({
    url:url,
     async:true,
    success:function(returnedContent){
		$("#firstpassconfiginput").fadeTo("slow", 1.33);
		Popup.hide('modal');
		}
		});
	});
	$("#selrel").change(function() {
			selrel = $("#selrel").val();
			selfunct = $("#selfunct").val();
		url = "http://eabu-systest-db.juniper.net/Regression/report/libs/getreleasevals.php?release="+selrel+"&function="+selfunct;
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
		url = "http://eabu-systest-db.juniper.net/Regression/report/libs/getreleasevals.php?release="+selrel+"&function="+selfunct;
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
	$("#fpselrel").change(function() {
			selrel = $("#fpselrel").val();
			selfunct = $("#fpselfunct").val();
			selmile = $("#fpselmile").val();
		url = "http://eabu-systest-db.juniper.net/Regression/report/new/libs/getmilestone.php?release="+selrel+"&function="+selfunct+"&milestone="+selmile;
		$.ajax({
    url:url,
     async:false,
    success:function(returnedContent){
		var arr = returnedContent.split("&");
		$("#fprelease").val(arr[0]);
		$("#fpfunction").val(arr[1]);
		$("#dr_ids").val(arr[2]);
		$("#fpplanned_release").val(arr[3]);
		$("#fpmilestone").val(arr[4]);
        }
        });
	});
	$("#fpselfunct").change(function() {
			selrel = $("#fpselrel").val();
			selfunct = $("#fpselfunct").val();
			selmile = $("#fpselmile").val();
		url = "http://eabu-systest-db.juniper.net/Regression/report/new/libs/getmilestone.php?release="+selrel+"&function="+selfunct+"&milestone="+selmile;
		$.ajax({
    url:url,
     async:false,
    success:function(returnedContent){
		var arr = returnedContent.split("&");
		$("#fprelease").val(arr[0]);
		$("#fpfunction").val(arr[1]);
		$("#dr_ids").val(arr[2]);
		$("#fpplanned_release").val(arr[3]);
		$("#fpmilestone").val(arr[4]);
        }
        });
	});
	$("#fpselmile").change(function() {
			selrel = $("#fpselrel").val();
			selfunct = $("#fpselfunct").val();
			selmile = $("#fpselmile").val();
		url = "http://eabu-systest-db.juniper.net/Regression/report/new/libs/getmilestone.php?release="+selrel+"&function="+selfunct+"&milestone="+selmile;
		$.ajax({
    url:url,
     async:false,
    success:function(returnedContent){
		var arr = returnedContent.split("&");
		$("#fprelease").val(arr[0]);
		$("#fpfunction").val(arr[1]);
		$("#dr_ids").val(arr[2]);
		$("#fpplanned_release").val(arr[3]);
		$("#fpmilestone").val(arr[4]);
        }
        });
	});
	$('#config-sub').bind('tabsselect', function(event, ui) {
        var str = String(ui.tab);
		if(str.search(/regconfig/i) >=0)
		{
			$("#configinput").show();
			$("#firstpassconfiginput").hide();
		}
		if(str.search(/firstpassconfig/i) >=0)
		{
			$("#configinput").hide();
			$("#firstpassconfiginput").show();
		}
		});
		



	$('#report-sub').bind('tabsselect', function(event, ui) {
        var str = String(ui.tab);
		arr = str.split("#");
		if(heatmap == 0)
		{
			arr1 = arr[1].split("_");
			actrel = arr1[0];
			getreleasereport(arr1[0]);
		}
		else if(heatmap == 1)
		{
			arr1 = arr[1].split("_");
			actrel = arr1[0];
			tmprel = arr1[0];
			tmprel=tmprel.replace(/-/,'\.');
			getheatmap(tmprel,heatmapfunc);
		}
		else if (heatmap == 2)
		{
			arr1 = arr[1].split("_");
			actrel = arr1[0];
            getswbehaviour(arr1[0]);
		}
		else if(heatmap == 3)
		{
			arr1 = arr[1].split("_");
			actrel = arr1[0];
            gettbeddata(arr1[0],"MMX");
		}
    });
	$("#selrelar").change(function() {
			selrel = $("#selrelar").val();
			actrel = selrel;
	if(heatmap == 0)
	{
			selrel=selrel.replace(/\./g,'-'); 
			selrel = "archives_"+selrel;
	getreleasereport(selrel);
	}
	else
	{
		getheatmap(selrel,heatmapfunc);
	}
	});
	$(".headerlink").live("click",function()
	{
			id =$(this).attr("id");
			$(".headerlink").each(function()
			{
				$(this).removeClass("current");
			});
				$(this).addClass("current");
			if(heatmap == 1)
			{
				getheatmapmenu(id);
				tmprel = actrel;
				tmprel=tmprel.replace(/-/,'\.');
				getheatmap(tmprel,id);
				heatmapfunc = id;
			}
			if(heatmap == 3)
			{
				arr = id.split("_");
				gettbeddata(actrel,arr[1]);
				heatmapfunc = id;
			}
			if(heatmap == 4)
			{
				arr = id.split("_");
				getfirstpassper(arr[1]);
				heatmapfunc = id;
			}
			if(heatmap == 5)
			{
				getprdata(prrelease);
				heatmapfunc = id;
			}
			
	});
	$(".prrellink").live("click",function()
    {
            id =$(this).attr("id");
			$(".prrellink").each(function()
            {
                $(this).removeClass("current");
            });
                $(this).addClass("current");
			getprdata(id);
			prrelease=id;
	});
	$(".tabLink").live("click",function()
	{
		
			id =$(this).attr("id");
			$(".tabLink").each(function()
			{
				$(this).removeClass("current");
			});
				$(this).addClass("current");
			$("#"+current_debug_div).hide();;
			$("#"+id+"det").show();
			current_debug_div = id+"det";
			
	});
	$('.seldate').datepick({onSelect:function(dates) {
    }
    ,minDate: new Date(2012, 1, 1),dateFormat: 'yyyy-mm-dd'});


		
});								
function getswbehaviour(rel)
{
	url = "http://eabu-systest-db.juniper.net/Regression/report/new/libs/getswbehaviour.php?release="+rel;
        $.ajax({
    url:url,
     async:false,
    success:function(returnedContent){
                            $("#display").html(returnedContent);
	}
	});
}
function gettbeddata(rel,func)
{
	$("#display").html("<center><table><tr><td><div id='firstpass'></div></td></tr><tr><td><div id='runtime'></div></td></tr><tr><td><div id='details'></div></td></tr></table>");

	chartid="fpass";
	var chartobj = getChartFromId(chartid);
	if(chartobj == null)
    {
        chartobj = new FusionCharts("/fusion/FusionCharts_Website/FusionCharts_Website/Charts/ScrollColumn2D.swf", chartid, "1200", "400");
	}
    chartobj.configure("ChartNoDataText", "Loading  Chart Please Wait");
    chartobj.render("firstpass");
    $.ajax({
    url:"http://eabu-systest-db.juniper.net/Regression/report/new/libs/gettbechart.php?release="+rel+"&function="+func+"&type=fpass",
     async:false,
    success:function(returnedContent){
        chartobj.setXMLData(returnedContent);
    }
    });

	chartid="run";
	var chartobj = getChartFromId(chartid);
	if(chartobj == null)
    {
        chartobj = new FusionCharts("/fusion/FusionCharts_Website/FusionCharts_Website/Charts/ScrollColumn2D.swf", chartid, "1200", "400");
	}
    chartobj.configure("ChartNoDataText", "Loading  Chart Please Wait");
    chartobj.render("runtime");
    $.ajax({
    url:"http://eabu-systest-db.juniper.net/Regression/report/new/libs/gettbechart.php?release="+rel+"&function="+func+"&type=runtime",
     async:false,
    success:function(returnedContent){
        chartobj.setXMLData(returnedContent);
    }
    });



	url = "http://eabu-systest-db.juniper.net/Regression/report/new/libs/gettbeddata.php?release="+rel+"&function="+func;
	
        $.ajax({
    url:url,
     async:false,
    success:function(returnedContent){
                            $("#details").html(returnedContent);
							$("#display").css({ top: '260px' });
	}
	});
}
		

function getreleasereport(rel)
{
	disablealltabs();
	actrel = rel;
		//$("#display").css({ top: '170px' });
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
		Popup.showModal('modal',null,null,{'screenColor':'#99ff99','screenOpacity':.6});
     $("#display").html("<center><h1>SUMMARY</h1><div id='regtab' ></div><div id='detailtab' ></div><div id='graphtab' ></div><div id='breaktab' ></div>");
    url = "http://eabu-systest-db.juniper.net/Regression/report/libs/getreleasereport.php?release="+rel;
        $.ajax({
    url:url,
     async:false,
    success:function(returnedContent){
        if(returnedContent.search(/<error>/i) >=0) { $("#regtab").html(returnedContent);;return;}
        else
        {
                            $("#regtab").html(returnedContent);
                            getdetailedreport(rel,"RBU");
        }
	Popup.hide('modal');
    }
    });
		return;
	}
		$("#archive_data").hide();
		$("#display").show();
	 $("#display").html("<center><h1>SUMMARY</h1><div id='regtab' ></div><div id='detailtab' ></div><div id='graphtab' ></div><div id='breaktab' ></div>");
	url = "http://eabu-systest-db.juniper.net/Regression/report/libs/getreleasereport.php?release="+rel;
	Popup.showModal('modal',null,null,{'screenColor':'#99ff99','screenOpacity':.6});
        $.ajax({
    url:url,
     async:false,
    success:function(returnedContent){
		if(returnedContent.search(/<error>/i) >=0) { $("#regtab").html(returnedContent);;return;}
		else
		{
							$("#regtab").html(returnedContent);
							getdetailedreport(rel,"RBU");
		}
	Popup.hide('modal');
	}
	});
	//Details
	//getdetailedreport(rel,"RBU");
}
function getdetailedreport(rel,func)
{
	//Details
	url = "http://eabu-systest-db.juniper.net/Regression/report/libs/getdetailreport.php?release="+rel+"&function="+func;
        $.ajax({
    url:url,
     async:false,
	success:function(returnedContent){
	$("#detailtab").html(returnedContent);
	displaygraphs(rel,func);
	}
	});
	url = "http://eabu-systest-db.juniper.net/Regression/report/libs/getbreakdown.php?release="+rel+"&function="+func;
        $.ajax({
    url:url,
     async:false,
	success:function(returnedContent){
	$("#breaktab").html(returnedContent);
	}
	});
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
    url:"http://eabu-systest-db.juniper.net/Regression/report/libs/getprogress.php?release="+rel+"&type="+func,
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
    url:"http://eabu-systest-db.juniper.net/Regression/report/libs/getchart.php?release="+rel+"&type=firstpass",
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
    url:"http://eabu-systest-db.juniper.net/Regression/report/libs/getchart.php?release="+rel+"&type=overall",
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
    url:"http://eabu-systest-db.juniper.net/Regression/report/libs/getprogress.php?release="+rel+"&type=mmx",
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
    url:"http://eabu-systest-db.juniper.net/Regression/report/libs/getprogress.php?release="+rel+"&type=rpd",
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
    url:"http://eabu-systest-db.juniper.net/Regression/report/libs/getprogress.php?release="+rel+"&type=tx",
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
function getfirstpassper(func)
{
	url = "http://eabu-systest-db.juniper.net/Regression/report/new/libs/getfirstpassper.php?function="+func;
        $.ajax({
    url:url,
     async:false,
    success:function(returnedContent){
			$("#display").css({ top: '260px' });
			$("#display").html(returnedContent);
		}
        });
}
function getprdata(rel)
{
	arr = rel.split("_");
	rel = arr[1];
	rel=rel.replace(/\./g,'-');
	url = "http://eabu-systest-db.juniper.net/Regression/report/new/libs/getprdata.php?release="+rel;
	Popup.showModal('modal',null,null,{'screenColor':'#99ff99','screenOpacity':.6});
        $.ajax({
    url:url,
     async:false,
    success:function(returnedContent){
			$("#display").css({ top: '240px' });
            $("#display").html(returnedContent);
			Popup.hide('modal');
        }
        });
}
function getheatmap(rel,func)
{
	Popup.showModal('modal',null,null,{'screenColor':'#99ff99','screenOpacity':.6});
	url = "http://eabu-systest-db.juniper.net/Regression/report/new/fetch_report.php?release="+rel+"&function="+func;
	$.ajax({
    url:url,
     async:false,
    success:function(returnedContent){
            $("#heatcontents").html(returnedContent);
			Popup.hide('modal');
        }
        });
		
}
function getheatmapmenu(func)
{
	url = "http://eabu-systest-db.juniper.net/Regression/report/new/libs/getheatmapmenu.php?function="+func;
    $.ajax({
    url:url,
     async:false,
    success:function(returnedContent){
            $("#areatab").html(returnedContent);
			
        }
        });	
}
function loadfirstpasschart(release,func)
{
	url = "/Regression/report/new/libs/getfirstpasschart.php?function="+func+"&release="+release;
    $.ajax({
    url:url,
     async:false,
    success:function(returnedContent){
	Popup.showModal('trendschart',null,null,{'screenColor':'#AFDCEC','screenOpacity':.6});
	c="passtrends";
    var passtrends = getChartFromId(c);
    if(passtrends == null)
    {
    passtrends = new FusionCharts("/fusion/FusionCharts_Website/FusionCharts_Website/Charts/Column2D.swf", c, "800", "400");
    }
    passtrends.configure("ChartNoDataText", "Loading  Chart Please Wait");
    passtrends.render("charts");
    passtrends.setXMLData(returnedContent);
        }
        });
}

	
