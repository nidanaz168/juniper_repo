/* This is an auto generted file dont modify */
function cfd_init()
{
	create_angular_gauge('rpathak',0,489,279);
	create_angular_gauge('banuk',0,454,246);
	create_angular_gauge('stanzin',0,590,286);
	create_angular_gauge('total',0,1533,811);
	create_3dbar_graph("problem_level_dist","/homes/rod/public_html/EABU-MMX-TEST-GOALS/data/cfd_severity_dist.xml",1);
	create_3dbar_graph("category_dist","/homes/rod/public_html/EABU-MMX-TEST-GOALS/data/cfd_category_dist.xml",1);
	create_3dbar_graph("customer_dist","/homes/rod/public_html/EABU-MMX-TEST-GOALS/data/cfd_customer_dist.xml",1);
	create_pie_graph("test_area_improve","/homes/rod/public_html/EABU-MMX-TEST-GOALS/data/cfd_test_area_improve.xml",1);
	create_pie_graph("test_escape_reason","/homes/rod/public_html/EABU-MMX-TEST-GOALS/data/cfd_test_escape_reason.xml",1);
	create_line_graph('progress','/homes/rod/public_html/EABU-MMX-TEST-GOALS/data/cfd_progress.xml',1);
$("table").tablesorter({
sortList: [[0,0]]  
});
$("#show_det_graphs").click(function() {
$("#det_graphs").toggle() 
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
$("#addrow").click(function() {
        tr = "<tr><td><img class='newrow' id='"+id+"' src='/EABU-MMX-TEST-GOALS/images/save.png' width=20px height=20px onclick='insertrow("+id+");'/><input id='eengineer"+id+"' /></td>";
        tr += "<td><input id='emanager"+id+"' /></td>";
        tr += "<td><input class='enumber' id='number"+id+"' onblur='getprinfo(this,"+id+");' /></td>";
        tr += "<td id='synopsis"+id+"'></td>";
        tr += "<td id='reportedin"+id+"'></td>";
        tr += "<td id='submitter"+id+"'></td>";
        tr += "<td id='product"+id+"'></td>";
        tr += "<td id='category"+id+"'></td>";
        tr += "<td id='problemlevel"+id+"'></td>";
        tr += "<td>Major-Low</td>";
        tr += "<td id='originator"+id+"'></td>";
        tr += "<td id='arrivaldate"+id+"'></td>";
        tr += "<td id='class"+id+"'></td>";
        tr += "<td id='respmanager"+id+"'></td>";
        tr += "<td id='customer"+id+"'></td>";
        tr += "<td><input id='escripting"+id+"' /></td>";
        tr += "<td><input id='ecomments"+id+"' /</td>";;
        tr += "<td><select id='egnats"+id+"'><option value='YES'>YES</option><option value='NO'>NO</option></select></td>";
        tr += "<td><select id='erc"+id+"'><option value='YES'>YES</option><option value='NO'>NO</option></select></td>";
        tr += "<td><input id='ercplan"+id+"' /></td>";
        tr += "<td><input id='ercclose"+id+"' /></td>";
        tr += "<td><select id='eescripted"+id+"'><option value='NO'>NO</option><option value='YES-NEW'>YES-NEW</option><option  value='YES-EXISTING'>YES-EXISTING</option></select></td>";
        tr += "<td><input id='escriptname"+id+"' /></td>";
        tr += "<td><input id='escriptpath"+id+"' /></td>";
        tr += "<td><input id='eepasslog"+id+"' /></td>";
        tr += "<td><select id='ereviewed"+id+"'><option value='YES'>YES</option><option value='NO'>NO</option><option value='IN-PROGRESS'>IN-PROGRESS</option></select></td>";
        tr += "<td><select id='eetrans"+id+"'><option value='COMPLETED'>COMPLETED</option><option value='SUBMITED'>SUBMITED</option><option value='IN-PROGRESS'>IN-PROGRESS</option></td>";
        $('#cfddetails tr:first').after(tr);
        id++;
    });}  
