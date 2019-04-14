/* This is an auto generted file dont modify */
function false_failure_init()
{
	create_angular_gauge('ffgaugep1',0,550,550);
	create_angular_gauge('ffgauge',0,860,438);
	create_angular_gauge('fpass',0,100,89);
	create_line_graph('ffgraph','/homes/rod/public_html/EABU-MMX-TEST-GOALS/data/ff.xml',1);
	create_line_graph('exgraph','/homes/rod/public_html/EABU-MMX-TEST-GOALS/data/exec.xml',1);
	create_multiseriesbar_graph_with_size('11.4','/homes/rod/public_html/EABU-MMX-TEST-GOALS/data/ff_progress11.4.xml',1,600,400);
	create_multiseriesbar_graph_with_size('12.1','/homes/rod/public_html/EABU-MMX-TEST-GOALS/data/ff_progress12.1.xml',1,600,400);
	create_multiseriesbar_graph_with_size('12.2','/homes/rod/public_html/EABU-MMX-TEST-GOALS/data/ff_progress12.2.xml',1,600,400);
	create_multiseriesbar_graph_with_size('12.3','/homes/rod/public_html/EABU-MMX-TEST-GOALS/data/ff_progress12.3.xml',1,600,400);
$("table").tablesorter({
sortList: [[0,1]]  
});
filter_init();
}
function showstpr()
{
	$("#st-pr-content").toggle();
}          
