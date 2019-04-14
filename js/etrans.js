/*** Document ready function  executed at first *****/
var respcontent;
$(document).ready(function() {
$("table").tablesorter({
	sortList: [[0,1]]  
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