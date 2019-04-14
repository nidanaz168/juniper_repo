var respcontent;
function updateObjectIframe(which,div){
    ele = document.getElementById(div);
    document.getElementById(div).innerHTML = '<'+'object id="main" style="overflow:hidden;height:200000px;width:6000px" name="main" type="text/html" data="'+which+'"><\/object>';
}
function create_angular_gauge(div,min,max,currentvalue)
{
	name = div+"_id";
    var chart = new FusionCharts("/fusion/FusionWidgets_Website/Charts/AngularGauge.swf", name, "250", "130", "0", "1" );
    chartstr = "<chart manageResize='1' origW='350' origH='200'  palette='2' bgAlpha='0' bgColor='FFFFFF' lowerLimit='"+min+"' upperLimit='"+max+"'  showBorder='0' basefontColor='000000' chartTopMargin='5' chartBottomMargin='5' toolTipBgColor='009999' gaugeFillMix='{dark-10},{light-170},{dark-10}' gaugeFillRatio='3' pivotRadius='8' gaugeOuterRadius='120' gaugeInnerRadius='70%' gaugeOriginX='175' gaugeOriginY='170' trendValueDistance='5' majorTMNumber='5' adjustTM='0' tickValueDecimals='0' tickValueDistance='3' manageValueOverlapping='1' autoAlignTickValues='1'>";
    val = max/3;
	val = Math.floor( val );
    chartstr += "<colorRange><color minValue='0' maxValue='"+val+"' code='A9D0F5'/>";
    /*second = val+val;
    chartstr +="<color minValue='"+val+"' maxValue='"+second+"' code='F6BD0F'/>";
    chartstr +="<color minValue='"+second+"' maxValue='"+max+"' code='8BBA00'/>";*/
	
    chartstr += "</colorRange><dials><dial value='"+currentvalue+"' rearExtension='10' baseWidth='10'/></dials><annotations><annotationGroup x='175' y='120' showBelow='0'scaleText='1'><annotation type='text' y='20' label='"+currentvalue+"' fontColor='000000' fontSize='14' bold='1'/></annotationGroup></annotations><styles><definition><style name='RectShadow' type='shadow' strength='3'/><style name='trendvaluefont' type='font' bold='1' borderColor='FFFFDD'/></definition><application><apply toObject='Grp1' styles='RectShadow' /><apply toObject='Trendvalues' styles='trendvaluefont' /></application></styles></chart>";
    chart.setXMLData( chartstr );
            chart.render(div);
}                         
function create_line_graph(div, /* Div name */
						xmlfile, /* Full xml file path to be loaded in the graph */
						ajaxflag /* Ajax flag to indicate the request need ajax/not */
						)
{
		if(ajaxflag)
		{
			str = ajaxrequest("/EABU-MMX-TEST-GOALS/libs/readfile.php?file="+xmlfile);
			var chart_trend_af = new FusionCharts("/fusion/FusionCharts_Website/FusionCharts_Website/Charts/MSLine.swf", "ChartId", "450", "300");
                   chart_trend_af.setDataXML(respcontent);
                   chart_trend_af.render(div);     
		}
}
function create_line_graph_size(div, /* Div name */
						xmlfile, /* Full xml file path to be loaded in the graph */
						ajaxflag, /* Ajax flag to indicate the request need ajax/not */
						w,
						h
						)
{
		if(ajaxflag)
		{
			str = ajaxrequest("/EABU-MMX-TEST-GOALS/libs/readfile.php?file="+xmlfile);
			var chart_trend_af = new FusionCharts("/fusion/FusionCharts_Website/FusionCharts_Website/Charts/MSLine.swf", "ChartId", w, h);
                   chart_trend_af.setDataXML(respcontent);
                   chart_trend_af.render(div);     
		}
}

function create_3dbar_graph(div, /* Div name */
                        xmlfile, /* Full xml file path to be loaded in the graph */
                        ajaxflag /* Ajax flag to indicate the request need ajax/not */
                        )
{
        if(ajaxflag)
        {
            str = ajaxrequest("/EABU-MMX-TEST-GOALS/libs/readfile.php?file="+xmlfile);
            var chart_trend_af = new FusionCharts("/fusion/FusionCharts_Website/FusionCharts_Website/Charts/Column3D.swf", "ChartId", "450", "300", "0", "0");
                   chart_trend_af.setDataXML(respcontent);
                   chart_trend_af.render(div);
        }
}
function create_pie_graph(div, /* Div name */
						xmlfile, /* Full xml file path to be loaded in the graph */
						ajaxflag /* Ajax flag to indicate the request need ajax/not */
						)
{
		if(ajaxflag)
		{
			str = ajaxrequest("/EABU-MMX-TEST-GOALS/libs/readfile.php?file="+xmlfile);
			var chart_trend_af = new FusionCharts("/fusion/FusionCharts_Website/FusionCharts_Website/Charts/Pie3D.swf", "ChartId", "450", "300");
                   chart_trend_af.setDataXML(respcontent);
                   chart_trend_af.render(div);     
		}
}

function create_multiseriesbar_graph(div, /* Div name */
                        xmlfile, /* Full xml file path to be loaded in the graph */
                        ajaxflag /* Ajax flag to indicate the request need ajax/not */
                        )
{
        if(ajaxflag)
        {
            str = ajaxrequest("/EABU-MMX-TEST-GOALS/libs/readfile.php?file="+xmlfile);
            var chart_trend_af = new FusionCharts("/fusion/FusionCharts_Website/FusionCharts_Website/Charts/MSColumn3D.swf","ChartId", "450", "300", "0", "0");
                   chart_trend_af.setDataXML(respcontent);
                   chart_trend_af.render(div);
        }
}
function create_multiseriesbar_graph_with_size(div, /* Div name */
                        xmlfile, /* Full xml file path to be loaded in the graph */
                        ajaxflag, /* Ajax flag to indicate the request need ajax/not */
						w, /* Width */
						h /* Heighr */
                        )
{
        if(ajaxflag)
        {
            str = ajaxrequest("/EABU-MMX-TEST-GOALS/libs/readfile.php?file="+xmlfile);
            var chart_trend_af = new FusionCharts("/fusion/FusionCharts_Website/FusionCharts_Website/Charts/MSColumn3D.swf","ChartId", w, h, "0", "0");
                   chart_trend_af.setDataXML(respcontent);
                   chart_trend_af.render(div);
        }
}
function create_multicollinedualY_graph(div, /* Div name */
                        xmlfile, /* Full xml file path to be loaded in the graph */
                        ajaxflag /* Ajax flag to indicate the request need ajax/not */
                        )
{
        if(ajaxflag)
        {
            str = ajaxrequest("/EABU-MMX-TEST-GOALS/libs/readfile.php?file="+xmlfile);
            var chart_trend_af = new FusionCharts("/fusion/FusionCharts_Website/FusionCharts_Website/Charts/MSColumn3DLineDY.swf","ChartId", "450", "300", "0", "0");
                   chart_trend_af.setDataXML(respcontent);
                   chart_trend_af.render(div);
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
            return (respcontent);
                    }

                );
}                      	
					 