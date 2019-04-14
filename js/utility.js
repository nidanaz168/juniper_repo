/*** Document ready function  executed at first *****/
var respcontent;
$(document).ready(function() {
    $("#tabs").tabs();
		/*$("#ff").css("background-color","#F79F81");
            $("#etrans").css("background-color","#F7D358");
            $("#cfd").css("background-color","#58D3F7");
            $("#cp").css("background-color","#F7819F");
            $("#cs").css("background-color","#86B404");	*/
			getpage("ff");
	$("table").tablesorter({
	sortList: [[0,1]]  
	});
    $('#tabs').bind('tabsselect', function(event, ui) {
     // Objects available in the function context:
    var str = String(ui.tab);
    if(str.search(/ff/i) >=0)
    {
            $("#ff").addClass("selected-tab");
			//$("#selection").css("background-color","#F79F81");
            $("#etrans").removeClass("selected-tab");
            $("#cfd").removeClass("selected-tab");
            $("#cp").removeClass("selected-tab");
            $("#cs").removeClass("selected-tab");
			getpage("ff");
    }
    if(str.search(/etrans/i) >=0)
    {
            $("#ff").removeClass("selected-tab");
            $("#etrans").addClass("selected-tab");
			//$("#selection").css("background-color","#F7D358");
            $("#cfd").removeClass("selected-tab");
            $("#cp").removeClass("selected-tab");
            $("#cs").removeClass("selected-tab");
			getpage("etrans");
    }
    if(str.search(/cfd/i) >=0)
    {
            $("#ff").removeClass("selected-tab");
            $("#etrans").removeClass("selected-tab");
            $("#cfd").addClass("selected-tab");
			//$("#selection").css("background-color","#58D3F7");
            $("#cp").removeClass("selected-tab");
            $("#cs").removeClass("selected-tab");
			getpage("cfd");
    }
    if(str.search(/cp/i) >=0)
    {
            $("#ff").removeClass("selected-tab");
            $("#etrans").removeClass("selected-tab");
            $("#cfd").removeClass("selected-tab");
            $("#cp").addClass("selected-tab");
			//$("#selection").css("background-color","#F7819F");
            $("#cs").removeClass("selected-tab");
    }
    if(str.search(/cs/i) >=0)
    {
            $("#ff").removeClass("selected-tab");
            $("#etrans").removeClass("selected-tab");
            $("#cfd").removeClass("selected-tab");
            $("#cp").removeClass("selected-tab");
            $("#cs").addClass("selected-tab");
			//$("#selection").css("background-color","#86B404");
    }

    });
  });          
function getpage(tab)
{
	var div;
	if(tab.search(/ff/i) >=0)
	{
		updateObjectIframe("http://eabu-systest-db.juniper.net/EABU-MMX-TEST-GOALS1/data/index.mhtml","ff-disp");
		
	}
	if(tab.search(/etrans/i) >=0)
	{
		
		updateObjectIframe("http://eabu-systest-db.juniper.net/EABU-MMX-TEST-GOALS/data/etrans.mhtml","etrans-disp");
	}
	if(tab.search(/cfd/i) >=0)
	{
		
		updateObjectIframe("http://eabu-systest-db.juniper.net/EABU-MMX-TEST-GOALS/data/cfddetails.html","cfd-disp");
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
function insertrow()
{
	alert("insert");
	$("#summary").prepend("<tr><td>sooraj</td></tr>");
}
			
	
	

function updateObjectIframe(which,div){
    ele = document.getElementById(div);
    document.getElementById(div).innerHTML = '<'+'object id="main" style="overflow:hidden;height:200000px;width:6000px" name="main" type="text/html" data="'+which+'"><\/object>';
}      
function create_angular_gauge(div,min,max,currentvalue)
{
	var chart = new FusionCharts("/fusion/FusionWidgets_Website/Charts/AngularGauge.swf", "ChartId", "350", "200", "0", "1" );
	chartstr = "chart manageResize='1' origW='350' origH='200'  palette='2' bgAlpha='0' bgColor='FFFFFF' lowerLimit='0' upperLimit='100' numberSuffix='%' showBorder='0' basefontColor='FFFFDD' chartTopMargin='5' chartBottomMargin='5' toolTipBgColor='009999' gaugeFillMix='{dark-10},{light-70},{dark-10}' gaugeFillRatio='3' pivotRadius='8' gaugeOuterRadius='120' gaugeInnerRadius='70%' gaugeOriginX='175' gaugeOriginY='170' trendValueDistance='5' tickValueDistance='3' manageValueOverlapping='1' autoAlignTickValues='1'>";
	val = max/3;
	chartstr += "<colorRange><color minValue='0' maxValue='"+val+"' code='FF654F'/>";
	second = val+val;
	chartstr +="<color minValue='"+val+"' maxValue='"+second+"' code='F6BD0F'/>";
	chartstr +="<color minValue='"+second+"' maxValue='"+max+"' code='8BBA00'/>";
	chartstr += "</colorRange><dials><dial value='"+currentvalue+"' rearExtension='10' baseWidth='10'/><dials><dial value='72' rearExtension='10' baseWidth='10'/></dials><trendpoints><point startValue='62' displayValue='Average' useMarker='1' markerRadius='8' dashed='1' dashLen='2' dashGap='2'  /></trendpoints><annotations><annotationGroup id='Grp1' showBelow='1' showShadow='1'><annotation type='rectangle' x='$chartStartX+5' y='$chartStartY+5' toX='$chartEndX-5' toY='$chartEndY-5' radius='10' fillColor='009999,333333' showBorder='0' /></annotationGroup></annotations><styles><definition><style name='RectShadow' type='shadow' strength='3'/><style name='trendvaluefont' type='font' bold='1' borderColor='FFFFDD'/></definition><application><apply toObject='Grp1' styles='RectShadow' /><apply toObject='Trendvalues' styles='trendvaluefont' /></application></styles></chart>"
	chart.setXMLData( chartstr );
            chart.render(div); 	
}
