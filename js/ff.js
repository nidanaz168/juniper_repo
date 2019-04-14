/*** Document ready function  executed at first *****/
var respcontent;
$(document).ready(function() {
$("table").tablesorter({
	sortList: [[0,1]]  
	});
});
function getpage(tab)
{
	var div;
	if(tab.search(/ff/i) >=0)
	{
		str = ajaxrequest("libs/getpage.php?type="+tab);
		$("#ff-disp").html(respcontent);
		
	}
}
function ajaxrequest(url)
{
	ajaxObj = $.ajax({
        url : url,
        async:false,
         });              
		ajaxObj.complete(
         function(content) {
           respcontent = content.responseText;
			return respcontent;
                    }

                );       
}
			
	
	

function plotff()
{
	ajaxObj = $.ajax({
        url : "../libs/plot.php?type=ff",
		async:false,
         });

        ajaxObj.complete(
         function(content) {
           str = content.responseText;
               var chart_trend_af = new FusionCharts("/PRINFO/AF/Charts/FCF_MSLine.swf", "ChartId", "450", "300");
                   chart_trend_af.setDataXML(str);
                   chart_trend_af.render("ffgraph");

                    }

                );                        
}
function plotexec()
{
	ajaxObj = $.ajax({
         url : "../libs/plot.php?type=exec",
			async:false,
             });

            ajaxObj.complete(
           function(content) {
          str = content.responseText;
         var exec = new FusionCharts("/PRINFO/AF/Charts/FCF_MSLine.swf", "ChartId", "450", "300");
             exec.setDataXML(str);
             exec.render("exgraph");
                    }

                );                        
}