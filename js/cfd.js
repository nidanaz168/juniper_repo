/*** Document ready function  executed at first *****/
var respcontent;
$(document).ready(function() {
$("table").tablesorter({
	sortList: [[0,1]]  
	});
$(".edit").click(function() {
		id = $(this).attr('id');
		cls = $("#"+id).attr("class");
		if(cls.search(/save/i) >= 0) /*** Save Clicked *****/
		{
			saverow(id);
		}
		else
		{
			createeditrow(id);
		}
		});
$(".save").click(function() {
			alert("save me");
			alert($(this).attr("count"));
		});
$("#showhide").click(
function()
{
$("#cfddetails").toggle();
	ajaxObj = $.ajax({
        url : "../libs/getpage.php?type=cfd",
		async:false,
         });

        ajaxObj.complete(
         function(content) {
           str = content.responseText;
			$("#cfddetails").html(str);
			}
			);
	});
});                         

function plotetrans(release)
{
	ajaxObj = $.ajax({
        url : "../libs/plot.php?type=etrans&release="+release,
		async:false,
         });

        ajaxObj.complete(
         function(content) {
           str = content.responseText;
               var chart_trend_etrans = new FusionCharts("/PRINFO/AF/Charts/FCF_MSLine.swf", "ChartId", "1400", "500");
                   chart_trend_etrans.setDataXML(str);
					div = "etransgraph_"+release;
                   chart_trend_etrans.render(div);

                    }

                );                        
}
function createeditrow(id)
{
	$("#"+id).attr("src","../images/save.png");
    $("#"+id).addClass("save");
    $("#"+id).attr("count",id);
	/*** Get existing scripting value ****/
	scripting = $("#scripting"+id).text();
	$("#scripting"+id).html("<input id='escripting"+id+"' value='"+scripting+"' />");

	/*** Get existing comments value ****/
    comments = $("#comments"+id).text();  
	$("#comments"+id).html("<input id='ecomments"+id+"' value='"+comments+"'/>");

	/*** Get existing gnats stats value ****/	
	gnats = $("#gnats"+id).text();
	$("#gnats"+id).html("<select id='egnats"+id+"'><option value='YES'>YES</option><option value='NO'>NO</option></select>");
	$("#egnats"+id).val(gnats);

	/*** Get existing rc stats value ****/
	rc = $("#rc"+id).text();
	$("#rc"+id).html("<select id='erc"+id+"'><option value='YES'>YES</option><option value='NO'>NO</option></select>");
	$("#erc"+id).val(gnats);

	/*** Get existing rcplan stats value ****/
	rcplan = $("#rcplan"+id).text();
	$("#rcplan"+id).html("<input id='ercplan"+id+"' value='"+rcplan+"' />");

/*** Get existing rcclose stats value ****/
    rcclose = $("#rcclose"+id).text();        
	$("#rcclose"+id).html("<input id='ercclose"+id+"' value='"+rcclose+"' />");

	/*** Get existing scripted stats value ****/
	scripted =  $("#scripted"+id).text();
	$("#scripted"+id).html("<select id='escripted"+id+"'><option value='NO'>NO</option><option value='YES-NEW'>YES-NEW</option><option value='YES-EXISTING'>YES-EXISTING</option></select>");
	$("#escripted"+id).val(scripted);


	//$("#scriptname"+id).html("<input id='escriptname"+id+"' />");
	//$("#scriptpath"+id).html("<input id='escriptpath"+id+"' />");

	/*** Get existing reviewed stats value ****/
    reviewed =  $("#reviewed"+id).text();  
	$("#reviewed"+id).html("<select id='ereviewed"+id+"'><option value='YES'>YES</option><option value='NO'>NO</option><option value='IN-PROGRESS'>IN-PROGRESS</option></select>");
	$("#ereviewed"+id).val(reviewed);

	etrans = $("#etrans"+id).text();
	$("#etrans"+id).html("<select id='eetrans"+id+"'><option value='COMPLETED'>COMPLETED</option><option value='SUBMITED'>SUBMITED</option><option value='IN-PROGRESS'>IN-PROGRESS</option></select>");
	$("#eetrans"+id).val(etrans);

	/*** Get existing improve stats value ****/
	improve =  $("#improve"+id).text();
	$("#improve"+id).html("<input id='eimprove"+id+"' value='"+improve+"' />");

	/*** Get existing rccstatus stats value ****/
	rccstatus = $("#rccstatus"+id).text();
	$("#rccstatus"+id).html("<select id='erccstatus"+id+"'><option value='COMPLETED'>COMPLETED</option><option value='PENDING'>PENDING</option></select>");
		$("#erccstatus"+id).val(rccstatus);
}
function saverow(id)
{
		number = $("#number"+id).text();
		scripting = $("#escripting"+id).val();
		comments = $("#ecomments"+id).val();
		gnats = $("#egnats"+id+" :selected").text();
		rc = $("#erc"+id+" :selected").text();
		rcplan = $("#ercplan"+id).val();
		rcclose = $("#ercclose"+id).val();
		scripted = $("#escripted"+id+" :selected").text();
		reviewed = $("#ereviewed"+id+" :selected").text();
		etrans = $("#eetrans"+id+" :selected").text();
		improve = $("#improve"+id).val();
		rccstatus = $("#erccstatus"+id+" :selected").text();
		url = "../libs/savecfddb.php?number="+number+"&scripting="+scripting+"&comments="+comments+"&gnats="+gnats+"&rc="+rc+"&rcplan="+rcplan+"&rcclose="+rcclose+"&scripted="+scripted+"&reviewed="+reviewed+"&etrans="+etrans+"&improve="+improve+"&rccstatus="+rccstatus;
		alert(url);
		ajaxObj = $.ajax({
        url : url,
        async:false,
         });

        ajaxObj.complete(
         function(content) {
           str = content.responseText;
			$("#"+id).attr("src","../images/edit.png");
			$("#scripting"+id).html(scripting);
			$("#comments"+id).html(comments);
			$("#gnats"+id).html(gnats);
			$("#rc"+id).html(rc);
			$("#rcplan"+id).html(rcplan);
			$("#rcclose"+id).html(rcclose);
			$("#scripted"+id).html(scripted);
			$("#reviewed"+id).html(reviewed);
			$("#etrans"+id).html(etrans);
			$("#improve"+id).html(improve);
			$("#rccstatus"+id).html(rccstatus);

                    }

                );      

}