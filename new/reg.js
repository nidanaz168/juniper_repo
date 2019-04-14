var gtype="reg"; 
var current_debug_div = "summarydet";
var current_debug_div = "summarydet";
$(document).ready(function() {
        $(".tabLink").each(function(){
            tabeId = $(this).attr('id');
            if(tabeId.search(/summary/i) >=0)
            {
                $(this).addClass("selected");
                reg_display(tabeId);
            }
      $(this).click(function(){
        tabeId = $(this).attr('id');
        $(".tabLink").removeClass("selected");
        $(this).addClass("selected");
        reg_display(tabeId);
        return false;
      });
    });
        $(".aratabLink").each(function(){
            tabeId = $(this).attr('id');
            if(tabeId.search(/MMX/i) >=0)
            {
                $(this).addClass("selected");
                submenu_display();
            }
      $(this).click(function(){
        tabeId = $(this).attr('id');
        $(".tabLink").removeClass("selected");
        $(this).addClass("selected");
        reg_display(tabeId);
        return false;
      });
    });
    })

function reg_display(reg)
{
	 url =  "http://eabu-systest-db.juniper.net/Regression/"+reg+".html";
	    //updateObjectIframe(url,"display1");
		id = reg+"det";
		//Hide the previous one 
		previd = 	document.getElementById(current_debug_div);
		if(previd != null)
		{
			previd.style.display="none";
		}
		divobj = document.getElementById(id);
		if(divobj != null)
		{
		divobj.style.display="block";	
		current_debug_div = id;
		}
}
function get_report(rep)
{
	url = "";
	if(rep.search(/TPM/i) >=0)
	{
		url = "http://systest.juniper.net/entity/suite/index.mhtml";

	}
	else if(rep.search(/RM/i) >=0)
	{
		url = "http://systest.juniper.net/regressman/ui";
	}
	else if(rep.search(/DR/i) >=0)
	{
		url = "http://systest.juniper.net/ti/webapp/dr/main_dr/index.mhtml";
	}
	else if(rep.search(/Create Report/i) >=0)
	{
		url = "http://eabu-systest-db.juniper.net/Regression/reg_report.html";
	}
	else if(rep.search(/View Report/i) >=0)
	{
		url = "http://eabu-systest-db.juniper.net/Regression/main_report.html";
	}
	else if(rep.search(/Compare Report/i) >=0)
	{
		url = "http://eabu-systest-db.juniper.net/Regression/regression_compare.html";
	}
	 updateObjectIframe(url,"display");
}
function updateObjectIframe(which,div){
    ele = document.getElementById(div);
    document.getElementById(div).innerHTML = '<'+'object id="main" style="overflow:hidden;height:20000px;width:2000px;" name="main" type="text/html" data="'+which+'"><\/object>';
}
function showDataEntry(func)
{
	    /*if(func == "reg")
		{
			id = document.getElementById('reginput');
			id1 = document.getElementById('debuginput');
			id.style.display='block';
			id1.style.display='none';
		}
		else*/ if(func == 'new_debug')
		{
			id = document.getElementById('debuginput');
			id.style.display='block';
			id1 = document.getElementById('rel_select');
			id1.style.display='none';
			id2 = document.getElementById('rel_select_compare');
			id2.style.display='none';
			id5 = document.getElementById('comp_display');
			id5.style.display='none';
			id3 = document.getElementById('container');
        	id3.style.display='none';
        	id4 = document.getElementById('summarydet');
        	id4.style.display='none';
			//id2 = document.getElementById('display_link');
			//id2.style.display='none';
			//id1 = document.getElementById('reginput');
			//id1 = document.getElementById('tagrelease');
			//id.style.display='block';
			//id1.style.display='block';
			//id1.style.display='none';
		}
		else if(func == 'old_debug')
		{
			id = document.getElementById('rel_select');
			id1 = document.getElementById('debuginput');
			id2 = document.getElementById('rel_select_compare');
			id.style.display='block';
			id1.style.display='none';
			id2.style.display='none';
			id5 = document.getElementById('comp_display');
			id5.style.display='none';
			id3 = document.getElementById('container');
            id3.style.display='none';
            id4 = document.getElementById('summarydet');
            id4.style.display='none';
			//id2 = document.getElementById('display_link');
			//id2.style.display='block';
		}
		else if(func == 'compare')
		{
			id = document.getElementById('rel_select');
			id.style.display='none';
			id1 = document.getElementById('rel_select_compare');
			id1.style.display='block';
			id2 = document.getElementById('debuginput');
			id2.style.display='none';
			id3 = document.getElementById('container');
        	id3.style.display='none';
        	id4 = document.getElementById('summarydet');
        	id4.style.display='none';
			id5 = document.getElementById('comp_display');
            id5.style.display='block';
		}
		/*
		else
		{
			id = document.getElementById('tagrelease');
			id.style.display='block';
		}*/
}

function GetXmlHttpObject()
{
     if (window.XMLHttpRequest)
  {
  // code for IE7+, Firefox, Chrome, Opera, Safari
        return new XMLHttpRequest();
  }
  if (window.ActiveXObject)
  {
 // code for IE6, IE5
          return new ActiveXObject("Microsoft.XMLHTTP");
  }
   return null;
 }
function fetchreport(type)
{
	//alert('hi');
	
	gtype = type;	
    $("#display").fadeTo("slow",0.25);
	$(".progress").show();
    xmlhttp=GetXmlHttpObject();
	//get the release tag
	rel = document.getElementById("rel");
	relval = rel.value;
	if(type == "reg")
	{
    red = document.getElementById("regid");
    val = red.value;
    url = "http://eabu-systest-db.juniper.net/Regression/fetch_report.php?type=reg&regids="+val+"&release="+relval;
	}
	else if(type == "debugdr")
	{
		did = document.getElementById("debugids");
		val = did.value;
		url = "http://eabu-systest-db.juniper.net/Regression/fetch_report.php?type=debug&debugids="+val+"&release="+relval;
	}
	else if(type == "debugreg")
	{
		did = document.getElementById("dreid");
		val = did.value;
		url = "http://eabu-systest-db.juniper.net/Regression/fetch_report.php?type=dre&regids="+val+"&release="+relval;
	}
	else if(type == "rel")
	{
		did = document.getElementById("rel");
		val = did.value;
		alert(val);
		/*var fso = new ActiveXObject("Scripting.FileSystemObject");
		var FileObject = fso.OpenTextFile("/homes/rod/public_html/Regression/release.txt", 8, false,0); // 8=append, true=create if not exist, 0 = ASCII
		alert(FileObject);
		FileObject.write(val)
		FileObject.close()
		*/

		var xmlhttp = new XMLHttpRequest();
		xmlhttp.open("GET", "/homes/rod/public_html/Regression/release.txt", true);
		xmlhttp.send();
		xmlDoc=xmlhttp.responseXML;

	}
 xmlhttp.onreadystatechange=displayreport;
    xmlhttp.open("GET",url,true);
    xmlhttp.send(null);

}
function displayreport()
{
    if (xmlhttp.readyState==4)
    {
            dis = document.getElementById("display2");
				id = document.getElementById("container");
			if(gtype == "reg")
			{
				id.style.display="none";
				dis.style.display="block";
            dis.innerHTML =  xmlhttp.responseText;
			}
			else if( gtype == "debugdr")
			{
				id.style.display="block";
				 dis.style.display="none";
				 dis1 = document.getElementById("display1");
				 dis1.innerHTML =  xmlhttp.responseText;
				curr = document.getElementById(current_debug_div);
				curr.style.display="block";
			}
			else if( gtype == "debugreg")
			{
				id.style.display="block";
				 dis.style.display="none";
				 dis1 = document.getElementById("display1");
				 dis1.innerHTML =  xmlhttp.responseText;
				curr = document.getElementById(current_debug_div);
				curr.style.display="block";
			}
			 $(".progress").hide();
            $("#display").fadeTo("slow",1.0);
    }
}
function details(area)
{
    if(typeof(dis1) != "undefined"){  dis1.style.display = "none";}
    dis1 = document.getElementById(area);
    dis1.style.position = "fixed";
    dis1.style.top = "50px";
    dis1.style.left = "800px";
    $("#"+area).fadeTo("slow",0.25);
    dis1.style.display = "block";
    dis1.style.width = "600px";
    $("#"+area).fadeTo("slow",1.0);
}
function popreleases()
{
    xmlhttp=GetXmlHttpObject();
		url = "http://eabu-systest-db.juniper.net/Regression/fetch_release.php?type=view";
	xmlhttp.onreadystatechange=fillrel;
    xmlhttp.open("GET",url,true);
    xmlhttp.send(null);
}
function fillrel()
{
    if(xmlhttp.readyState==4)
    {
		dis = document.getElementById("relselect");
        dis.innerHTML =  xmlhttp.responseText;
	}
}
function getstaticnewreport()
{
    $("#display").fadeTo("slow",0.25);
    $(".progress").show();
    var debugids = document.getElementById("debugids").value;
    var rel = document.getElementById("rel_new").value;
    xmlhttp=GetXmlHttpObject();
    url = "http://eabu-systest-db.juniper.net/Regression/fetch_static_reprt.php?release="+rel+"&debugids="+debugids;
    xmlhttp.onreadystatechange=staticrep;
    xmlhttp.open("GET",url,true);
    xmlhttp.send(null);
}
function getstaticreport()
{
    $("#display").fadeTo("slow",0.25);
	$(".progress").show();
	//var ele = document.getElementById('relsel');
    var ele = document.getElementById('relist');
	//alert(ele);
	var selected = ele.options[ele.selectedIndex].value;
    xmlhttp=GetXmlHttpObject();
	url = "http://eabu-systest-db.juniper.net/Regression/fetch_static_reprt.php?release="+selected;
	xmlhttp.onreadystatechange=staticrep;
    xmlhttp.open("GET",url,true);
    xmlhttp.send(null);
}
function staticrep()
{
    if(xmlhttp.readyState==4)
    {
            dis = document.getElementById("display2");
				id = document.getElementById("container");
				id.style.display="block";
				 dis.style.display="none";
				 dis1 = document.getElementById("display1");
				 dis1.innerHTML =  xmlhttp.responseText;
				curr = document.getElementById(current_debug_div);
				curr.style.display="block";
     $("#display").fadeTo("slow",1.0);
	  $(".progress").hide();
	}
	
}
function comparereport()
{
	$("#display").fadeTo("slow",0.25);
	$(".progress").show();
	xmlhttp=GetXmlHttpObject();
	alert('hi');
	url = "http://eabu-systest-db.juniper.net/Regression/compare_status.html";
	if(xmlhttp.onreadystatechange==4){
		id = document.getElementById("container");
		id.style.display="block";
		xmlhttp.open("GET",url,true);
		xmlhttp.send(null);
		$("#display").fadeTo("slow",1.0);
		$(".progress").hide();
	}
}
function showdetails(url)
{
    xmlhttp=GetXmlHttpObject();
	xmlhttp.onreadystatechange=displaylog;
    xmlhttp.open("GET",url,true);
    xmlhttp.send(null);
}	
function displaylog()
{
	if(xmlhttp.readyState==4)
	{
		modal = document.getElementById("modal");
		htmltext =  xmlhttp.responseText;
		htmltext += "<input type=\"button\" value=\"OK\" onClick=\"Popup.hide('modal')\"> \n";
		modal.innerHTML =  htmltext;
		Popup.showModal('modal',null,null,{'screenColor':'#99ff99','screenOpacity':.6});return false;
	}
}
var selected;
    function lookup(inputString,obj) {
        selected = obj.id;
        var suggest = "#"+selected+"suggest";
        var suggestlist = "#"+selected+"suggestlist";
        if(inputString.length == 0) {
            // Hide the suggestion box.
            $(suggest).hide();
        } else {
            if(selected.search(/function/i) >=0)
            {
				rel = $("#relsel").val();
            $.post("rpc.php", {queryString: ""+inputString+"",type: ""+selected+"" , criteria: "",release: ""+rel+"" }, function(data){
                if(data.length >0) {
                    $(suggest).show();
                    $(suggestlist).html(data);
                }
                });
            }
            if(selected.search(/^area/i) >=0)
            {
				rel = $("#relsel").val();
                val = $("#function").val();
            $.post("rpc.php", {queryString: ""+inputString+"",type: ""+selected+"", criteria: ""+val+"",release: ""+rel+"" }, function(data){
                if(data.length >0) {
                    $(suggest).show();
                    $(suggestlist).html(data);
                }
                });
            }
        }
        if(selected.search(/subarea/i) >=0)
            {
				rel = $("#relsel").val();
                val1 = $("#function").val();
                val2 = $("#area").val();
                crit = val1+":"+val2;
            $.post("rpc.php", {queryString: ""+inputString+"",type: ""+selected+"" , criteria: ""+crit+"",release: ""+rel+"" }, function(data){
                if(data.length >0) {
                    $(suggest).show();
                    $(suggestlist).html(data);
                }
                });
            }
 } // lookup
    
    function fill(thisValue) {
        $("#"+selected).val(thisValue);
            var suggest = "#"+selected+"suggest";
        setTimeout("$('"+suggest+"').hide();", 200);
    }
function displaysearch()
{
	$('#search').is(':checked') ? $("#searchcontainer").show() : $("#searchcontainer").hide();
	//$("#searchcontainer").show();
}

function searchreport()
{
     $("#display").fadeTo("slow",0.25);
	  $(".progress").show();
        f = $("#function").val();
        a = $("#area").val();
        sa = $("#subarea").val();
		crit = f+":"+a+":"+sa;	
		rel = $("#relsel").val();
    xmlhttp=GetXmlHttpObject();
		url = "http://eabu-systest-db.juniper.net/Regression/search_report.php?crit="+crit+"&release="+rel;
	xmlhttp.onreadystatechange=fillsearch;
    xmlhttp.open("GET",url,true);
    xmlhttp.send(null);
}
function fillsearch()
{
	if(xmlhttp.readyState==4)
	{
		dis1 = document.getElementById("display1");
		                 dis1.innerHTML =  xmlhttp.responseText;
     $("#display").fadeTo("slow",1.0);
	  $(".progress").hide();

	}
}
	


				




