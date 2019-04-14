function updateObjectIframe(which,div){
    ele = document.getElementById(div);
    document.getElementById(div).innerHTML = '<'+'object id="main" style="overflow:hidden;height:200000px;width:6000px" name="main" type="text/html" data="'+which+'"><\/object>';
}
function create_angular_gauge(div,min,max,currentvalue)
{
	name = div+"_id";
    var chart = new FusionCharts("/fusion/FusionWidgets_Website/Charts/AngularGauge.swf", name, "250", "130", "0", "0" );
    chartstr = "<chart manageResize='1' origW='350' origH='200'  palette='0' bgAlpha='0' bgColor='FFFFFF' lowerLimit='"+min+"' upperLimit='"+max+"'  showBorder='0' basefontColor='FFFFFF' chartTopMargin='5' chartBottomMargin='5' toolTipBgColor='FFFFFF' gaugeFillRatio='3' pivotRadius='8' gaugeOuterRadius='120' gaugeInnerRadius='70%' gaugeOriginX='175' gaugeOriginY='170' trendValueDistance='5' tickValueDistance='3' manageValueOverlapping='1' autoAlignTickValues='1'>";
    val = max/3;
	val = Math.floor( val );
    chartstr += "<colorRange><color minValue='0' maxValue='"+val+"' code='FF654F'/>";
    second = val+val;
    chartstr +="<color minValue='"+val+"' maxValue='"+second+"' code='F6BD0F'/>";
    chartstr +="<color minValue='"+second+"' maxValue='"+max+"' code='8BBA00'/>";
	
    chartstr += "</colorRange><dials><dial value='"+currentvalue+"' rearExtension='10' baseWidth='10'/></dials><annotations><annotationGroup id='Grp1' showBelow='1' showShadow='0'><annotation type='rectangle' x='$chartStartX+5' y='$chartStartY+5' toX='$chartEndX-5' toY='$chartEndY-5' radius='10' fillColor='FFFFFF,FFFFFF' showBorder='0' /></annotationGroup></annotations><styles><definition><style name='RectShadow' type='shadow' strength='3'/><style name='trendvaluefont' type='font' bold='1' borderColor='FFFFFF'/></definition><application><apply toObject='Grp1' styles='RectShadow' /><apply toObject='Trendvalues' styles='trendvaluefont' /></application></styles></chart>"
    chart.setXMLData( chartstr );
            chart.render(div);
}                         