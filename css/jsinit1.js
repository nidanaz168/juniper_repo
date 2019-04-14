var respcontent;
$(document).ready(function() {
$("#main").tabs();
$("#rep-sub").tabs();
$("#hard-sub").tabs();
$("#regprof-sub").tabs();
$("#goal-sub").tabs();
$("#goal-sub").show();
getpage("teamgoal");
	$('#main').bind('tabsselect', function(event, ui) {
		var str = String(ui.tab);
		if(str.search(/hard/i) >=0)
		{
				$("#rep-sub").hide();
				$("#hard-sub").show();
				$("#regprof-sub").hide();
				$("#goal-sub").hide();
				getpage("mclag");
		}
		if(str.search(/regprof/i) >=0)
		{
				$("#rep-sub").hide();
				$("#hard-sub").hide();
				$("#regprof-sub").show();
				getpage("rel-regprof");
				$("#goal-sub").hide();
		}
		if(str.search(/reports/i) >=0)
		{
				$("#rep-sub").show();
				$("#hard-sub").hide();
				$("#regprof-sub").hide();
				$("#goal-sub").hide();
				getpage("sim");
		}
		if(str.search(/goals_/i) >=0)
		{
				$("#rep-sub").hide();
				$("#hard-sub").hide();
				$("#regprof-sub").hide();
				$("#goal-sub").show();
				getpage("teamgoal");
		}
	}
	);
	$('#rep-sub').bind('tabsselect', function(event, ui) {
		var str = String(ui.tab);
		getpage(str);
	}
	);
	$('#hard-sub').bind('tabsselect', function(event, ui) {
		var str = String(ui.tab);
		getpage(str);
	}
	);
	$('#regprof-sub').bind('tabsselect', function(event, ui) {
		var str = String(ui.tab);
		getpage(str);
	}
	);
	$('#goal-sub').bind('tabsselect', function(event, ui) {
		var str = String(ui.tab);
		getpage(str);
	});
	/**** show the menu on hover *******/
	$("#hardplan").hover(
		function()
		{
			$('ul', this).slideDown(100);
		}
		,
		function()
        {
			$('ul', this).slideUp(100);
        }          
	);
	$("#sin").hover(
		function()
		{
			$('ul', this).slideDown(100);
		}
		,
		function()
        {
			$('ul', this).slideUp(100);
        }          
	);
	$("#regprof").hover(
		function()
		{
			$('ul', this).slideDown(100);
		}
		,
		function()
        {
			$('ul', this).slideUp(100);
        }          
	);


});
function getpage(tab)
{
    if(tab.search(/sim/i) >=0)
    {
		file = "/homes/rod/public_html/EABU-MMX-TEST-GOALS1/data/index.mhtml";
		str = ajaxrequest("libs/readfile.php?file="+file);
		$("#content-display").html(respcontent);
		false_failure_init();

    }
    else if(tab.search(/sin/i) >=0)
    {

        updateObjectIframe("http://eabu-systest-db.juniper.net/EABU-MMX-TEST-GOALS/data/etrans.mhtml","content-display");
    }
    else if(tab.search(/rel-regprof/i) >=0)
    {

		file = "/homes/rod/public_html/EABU-MMX-TEST-GOALS/data/release_regression_profiles.html";
        str = ajaxrequest("libs/readfile.php?file="+file);
        $("#content-display").html(respcontent);
    }
    else if(tab.search(/cust-regprof/i) >=0)
    {

		file = "/homes/rod/public_html/EABU-MMX-TEST-GOALS/data/customer_based_regressions.mhtml";
        str = ajaxrequest("libs/readfile.php?file="+file);
        $("#content-display").html(respcontent);
    }
    else if(tab.search(/time-regprof/i) >=0)
    {

		file = "/homes/rod/public_html/EABU-MMX-TEST-GOALS/data/time_based_regression.html";
        str = ajaxrequest("libs/readfile.php?file="+file);
        $("#content-display").html(respcontent);
    }
    else if(tab.search(/plat-regprof/i) >=0)
    {

		file = "/homes/rod/public_html/EABU-MMX-TEST-GOALS/data/platform_based_regression.html";
        str = ajaxrequest("libs/readfile.php?file="+file);
        $("#content-display").html(respcontent);
    }
    else if(tab.search(/cfdc/i) >=0)
    {

		file = "/homes/rod/public_html/EABU-MMX-TEST-GOALS/data/cfddetails.html";
        str = ajaxrequest("libs/readfile.php?file="+file);
        $("#content-display").html(respcontent);
        cfd_init();     
    }
	else if(tab.search(/mclag/i) >=0)
	{
		file = "/homes/rod/public_html/EABU-MMX-TEST-GOALS/plan/hardening/MCLAG.html"
		str = ajaxrequest("libs/readfile.php?file="+file);
		$("#content-display").html(respcontent);
	}
	else if(tab.search(/reg/i) >=0)
	{
		file = "/homes/rod/public_html/EABU-MMX-TEST-GOALS/data/prinfo.html"
		str = ajaxrequest("libs/readfile.php?file="+file);
		$("#content-display").html(respcontent);
	}
	else if(tab.search(/teamgoal/i) >=0)
	{
		file = "/homes/rod/public_html/EABU-MMX-TEST-GOALS/plan/goals/2012-Team-Goals.htm";
		str = ajaxrequest("libs/readfile.php?file="+file);
        $("#content-display").html(respcontent);
	}
	else if(tab.search(/indgoal/i) >=0)
	{
		file = "/homes/rod/public_html/EABU-MMX-TEST-GOALS/plan/goals/2012-Manager-Goals.htm";
		str = ajaxrequest("libs/readfile.php?file="+file);
        $("#content-display").html(respcontent);
	}


}                      
function updateObjectIframe(which,div){
    ele = document.getElementById(div);
    document.getElementById(div).innerHTML = '<'+'object id="main" style="overflow:hidden;height:200000px;width:1500px" name="main" type="text/html" data="'+which+'"><\/object>';
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
/*** Fore CFD row edit functionality ***************************/
function createeditrow(id)
{
    $("#"+id).attr("src","/EABU-MMX-TEST-GOALS/images/save.png");
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
/*** For saving the CFD Changes to the database *******/
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
        url = "/EABU-MMX-TEST-GOALS/libs/savecfddb.php?number="+number+"&scripting="+scripting+"&comments="+comments+"&gnats="+gnats+"&rc="+rc+"&rcplan="+rcplan+"&rcclose="+rcclose+"&scripted="+scripted+"&reviewed="+reviewed+"&etrans="+etrans+"&improve="+improve+"&rccstatus="+rccstatus;
        ajaxObj = $.ajax({
        url : url,
        async:false,
         });

        ajaxObj.complete(
         function(content) {
           str = content.responseText;
            $("#"+id).attr("src","/EABU-MMX-TEST-GOALS/images/edit.png");
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
function insertrow(id)
{
        engineer = $("#eengineer"+id).val();
        manager = $("#emanager"+id).val();
        number = $("#number"+id).val();
        synopsis = $("#synopsis"+id).text();
        reporetedin = $("#reporetedin"+id).text();
        submitter = $("#submitter"+id).text();
        product = $("#product"+id).text();
        category = $("#category"+id).text();
        problemlevel = $("#problemlevel"+id).text();
        originator = $("#originator"+id).text();
        arrivaldate = $("#arrivaldate"+id).text();
        prclass = $("#class"+id).text();
		customer = $("#originator"+id).text();
        scripting = $("#escripting"+id).val();
        comments = $("#ecomments"+id).val();
        gnats = $("#egnats"+id+" :selected").text();
        rc = $("#erc"+id+" :selected").text();
        rcplan = $("#ercplan"+id).val();
        rcclose = $("#ercclose"+id).val();
        scripted = $("#escripted"+id+" :selected").text();
        reviewed = $("#ereviewed"+id+" :selected").text();
        etrans = $("#eetrans"+id+" :selected").text();
		script_name = $("#escriptname"+id).val();
		script_path = $("#escriptpath"+id).val();
		passlog = $("#eepasslog"+id).val();
        //improve = $("#improve"+id).val();
        //rccstatus = $("#erccstatus"+id+" :selected").text();
        url = "/EABU-MMX-TEST-GOALS/libs/insertcfddb.php?engineer="+engineer+"&number="+number+"&manager="+manager+"&synopsis="+synopsis+"&reportedin="+reporetedin+"&submitterid="+submitter+"&product="+product+"&problem_level="+problemlevel+"&originator="+originator+"&arrival_date="+arrivaldate+"&class="+prclass+"&customer="+customer+"&scripting="+scripting+"&comments="+comments+"&gnats="+gnats+"&rc="+rc+"&rcplan="+rcplan+"&rcclose="+rcclose+"&scripted="+scripted+"&reviewed="+reviewed+"&etrans="+etrans;
        ajaxObj = $.ajax({
        url : url,
        async:false,
         });

        ajaxObj.complete(
         function(content) {
           str = content.responseText;
            $("#"+id).attr("src","/EABU-MMX-TEST-GOALS/images/edit.png");
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
function getcfddetails(mgr)
{
	var	url = "/EABU-MMX-TEST-GOALS/libs/getcfddetails.php?mgr="+mgr;
	ajaxObj = $.ajax({
        url : url,
        async:false,
         });             
		ajaxObj.complete(
			function(content) {
				str = content.responseText;
				$("#cfddetails").show();
				$("#cfddetails").html(str);
				///enable Sorting
				cfd_init();
			}
			);
}
/************************ For getting CFD PR Infor from the server using Gnats ******/
function getprinfo(obj,id)
{
	$("#cfddetails").css({ opacity: 0.2 });
	var	url = "/EABU-MMX-TEST-GOALS/libs/getprdetails.php?pr="+obj.value;
	ajaxObj = $.ajax({
        url : url,
        async:false,
         });             
		ajaxObj.complete(
			function(content) {
				str = content.responseText;
				prarr = str.split(":&:&:");
				$("#synopsis"+id).html(prarr[1]);
				$("#reportedin"+id).html(prarr[2]);
				$("#submitter"+id).html(prarr[3]);
				$("#product"+id).html(prarr[4]);
				$("#category"+id).html(prarr[5]);
				$("#problemlevel"+id).html(prarr[6]);
				$("#originator"+id).html(prarr[7]);
				$("#arrivaldate"+id).html(prarr[8]);
				$("#class"+id).html(prarr[9]);
				$("#customer"+id).html(prarr[10]);
			}
			);
	$("#cfddetails").css({ opacity: 1.0 });
}
	
