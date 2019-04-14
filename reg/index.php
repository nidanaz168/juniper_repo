<html lang="en">

  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>.: Regression Data :.</title>
    <link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <link href='//fonts.googleapis.com/css?family=Droid+Sans' rel='stylesheet' type='text/css' />
    <link rel="stylesheet" href="css/font-awesome.min.css" type="text/css" />
    <link rel="stylesheet" href="css/fonts/fontawesome-webfont.ttf?v=4.3.0" type="text/css" />
    <link rel="stylesheet" href="css/main.css?v=<?=$rand?>" type="text/css" />
    <link rel="stylesheet" href="css/rpt-phase2.css" type="text/css" />
    <link rel="stylesheet" href="css/ag-grid.css?v=<?=$rand?>" type="text/css" />
    <link rel="stylesheet" href="css/style.css?v=<?=$rand?>" type="text/css" />

    <style>
    .jira-grid  .ag-cell[col-id="releasename"],
    .jira-grid  .ag-cell[col-id="ag-Grid-AutoColumn"]{
      text-align: left;
    }
    #header{
      border-bottom: 3px solid #e5d297;
    }

    .releaseForm hr{
      border-top: 1px dotted #ededed;
    }

    body{
      color:#000;
    }
    #labnol label{
      padding-right:10px;
    }
    #labnol{
      height:310px;
      width: 100%;
      margin:0;
    }

    #frmHolder{
      position: relative;
      width:80%;
      margin:0 auto;
      border-bottom-left-radius: 15px;
      border-bottom-right-radius: 15px;
      background: #e8e8e8;
      padding:10px;
      border:0px;
      -webkit-box-shadow: 1px 1px 2px 0px rgba(0,0,0,0.75);
      -moz-box-shadow: 1px 1px 2px 0px rgba(0,0,0,0.75);
      box-shadow: 1px 1px 2px 0px rgba(0,0,0,0.75);
    }

    #upArrow a{
      display: block;
    }
    #upArrow{
      text-align: center;
      padding: 5px;
      width: 25%;
      margin: 0 auto;
      border-bottom: 2px solid #7c7c7c;
      background: #e5d297;
      border-bottom-left-radius: 20px;
      border-bottom-right-radius: 20px;
    }

    .lhtype{
      line-height: 35px;
      display: block;
    }

    .button {
      background-color: #333333;
      border: none;
      color: white;
      padding: 12px;
      text-align: center;
      text-decoration: none;
      display: inline-block;
      font-size: 16px;
      margin: 16px 2px;
      width: 50px;
      height: 50px;
    }

    .roundbutton {border-radius: 50%;}
    .bold{
      font-weight: bold;
    }

    #containerLoader{
      position: absolute;
      width: 100%;
      height: 100%;
      background: #3d3d3d;
      z-index: 1000;
      top: 0;
      left: 0;
      border-bottom-right-radius: 15px;
      border-bottom-left-radius: 15px;
      opacity: 0.3;
      display: none;
    }

    .dn{
      display: none;
    }

    #main{
      height: 360px;
    }

    #my-nav {
      width: 100%;
      z-index: 100;
      margin-left: 20px;
      margin-bottom: 0;
      padding-left: 0;
      list-style: none;
      background: #2c2c2c;

    }

    .bodybg{
      overflow-y: auto;
      background: #f5f5f5;
      -webkit-box-shadow: -3px 1px 3px 0px rgba(0,0,0,0.59);
      -moz-box-shadow: -3px 1px 3px 0px rgba(0,0,0,0.59);
      box-shadow: -3px 1px 3px 0px rgba(0,0,0,0.59);
    }

    #my-nav li.active a{
      display: block;
      z-index: 1000;
      background: #f5f5f5;
      color:#000 !important;
      font-weight: bold;
    }

    #my-nav .nav-pills>li>a{
      border-radius: 0;
      color: #fff;
    }
    #my-nav .nav-pills>li>a:hover, #my-nav .nav-pills>li>a:active{
      color: #3d3d3d;
    }

    .articleHeader{
      color: #2a6496;
      border-bottom: 1px dotted #000;
      font-weight: bold;
      background: #efefef;
      display: block;
      font-family: arial,verdana;
      padding: 10px;
    }

    .userHolder{
      z-index: 1000;
      margin: 0px -20px 4px 20px;
      margin-left: -20x;
      background: #373737;
      padding: 10px 10px 20px;
      color:#fff !important;
    }

    .cboth{
      display: block;
      clear: both;
      margin:5px 0;
    }

    .aCenter{
      text-align: center;
    }

    #pageInitial .maincontent {
      padding: 10px;
    }

    #pageInitial{
      width: 100%;
      height: 100%;
      margin: 0px auto;
      min-height: 200px;
      background: #fff;
    }
    #pageInitial .maincontent h1 {
      margin: 0 auto;
      border-bottom: 1px dotted #000;
    }

    #pageInitial .maincontent h1 {
      margin: 0 auto;
      border-bottom: 1px dotted #000;
    }

    #pageInitial h1{
      font-size: 20px;
    }
    #pageInitial blockquote{
      font-size: 15px;
    }

    textarea {
      resize: none;
    }

    #myConfirmation .form-group .col-sm-8{
      padding-top: 7px;
    }


    .mainpill{
      width: 100%;
      margin: 0 auto;
      background: #a8a8a8;
    }


    .mainpill.nav-pills>li>a {
      padding: 10px 15px;
      margin-right: 3px;
      background-color: #e6e6e6;
      color: #737373;
      /*    -o-text-shadow: 0 1px 1px #fff 1px 1px #fff;
      -moz-text-shadow: 0 1px 1px #fff 1px 1px #fff;
      -ms-text-shadow: 0 1px 1px #fff 1px 1px #fff;
      -webkit-text-shadow: 0 1px 1px #fff 1px 1px #fff;
      text-shadow: 0 1px 1px #fff 1px 1px #fff;
      -o-box-shadow: inset 0 -8px 7px -9px rgba(0,0,0,.4);
      -ms-box-shadow: inset 0 -8px 7px -9px rgba(0,0,0,.4);
      -moz-box-shadow: inset 0 -8px 7px -9px rgba(0,0,0,.4);
      -webkit-box-shadow: inset 0 -8px 7px -9px rgba(0,0,0,.4);
      box-shadow: inset 0 -8px 7px -9px rgba(0,0,0,.4);*/
      -moz-transition-duration: .15s;
      -o-transition-duration: .15s;
      -webkit-transition-duration: .15s;
      transition-duration: .15s;
    }

    .mainpill.nav-pills>li>a, .mainpill.nav-pills>li.active a {
      border-radius: 0;
      border-top:3px solid #e6e6e6;

    }

    .mainpill.nav-pills>li.active a {
      background: #fff;
      border-top: 3px solid #3379b7;
      color: #3379b7;
    }

    .mainpill .tab-content {
      background-color: #f5f5f5;
      padding: 20px;
      padding-top: 10px;
      -ms-box-sizing: border-box;
      -moz-box-sizing: border-box;
      -webkit-box-sizing: border-box;
      box-sizing: border-box;
      border-radius: 0 4px 4px 4px;
    }

    .mainpill .tab-content {
      overflow: auto;
    }

    #showhide>.tab-content{
      background: #fff;
      padding:10px;
    }

    .tab-content{
      height:75%;
    }

    .bold-class{
      font-weight:bold;
    }

    .tab-pane{
      padding:20px;
    }

    #menu1tab, #menu2tab{
      width:100%;
    }


    #beta{
      position: absolute;
      width: 100px;
      background: #ff0000;
      color: #fff;
      font-weight: bold;
      font-size: 12px;
      top: 20px;
      -ms-transform: rotate(-45deg);
      -webkit-transform: rotate(-45deg);
      transform: rotate(50deg);
      height: 16px;
      z-index: 5000;
      text-align: center;
      right: -26px;
      box-shadow: -1px 4px 5px #0e0e0e;

    }

    .rCount {
      padding: 2px 10px;
      font-size: 14px;
      font-weight: bolder;
      background: #efefef;
      /* clear: both; */
      width: 30%;
      text-align: center;
      color: #373737;
      border: 1px dotted #5f5f5f;
      margin-left: 50%;
      left: -15%;
      position: absolute;
    }
    .bg-green {
      background-color: #d5f1d5 !important;
      background-image: linear-gradient(to bottom, #f7fdf7, #e8f7e8);
    }
    .ag-header-cell-text{
      white-space: normal;
    }
    .ag-floating-filter-input{
      color: #333;
    }

    .ag-group-child-count {
        font-weight: bold;
        font-size: 11px;
        text-align: right;
        /*float: right;*/
        color: #6c6c6c;
        margin-right: 2px;
    }


  .bootbox .modal-footer .btn.btn-danger[data-bb-handler="cancel"]{
    float:none !important;
  }

  .glyphicon-archive-alt:before{
    content: "\e028";
  }
/*
  .rel-archive{
    background: url(img/archive.png) no-repeat;
  }*/
  .tooltip{
    /*background: #000 !important;*/
    color:#fff;
    z-index: 30000;
  }

  .tooltip-inner{
    padding:3px 10px;
    background: #000;
    color:#fff;
    border: 0px;
  }

/*  .sdIcon{
    background: #fff;
    border-radius: 50%;
    padding: 3px;
    float: right;
    border: 1px solid #3379b7;
  }*/

  .cellalignleft{
    text-align: left !important;
  }
  
  .fright{
    float: right;
    padding: 1px;
    margin-left: 2px;
    /*border: 1px solid #3379b7;*/
    /*border-radius: 50%;*/
    /*font-size: 15px;*/
    /*background: #fff;*/
    width: 20px;
    text-align: center;
    height: 20px;
  }


@-moz-document url-prefix() {
      .fright.mainIcon {
         margin-top:-19px;
      }
  }


  </style>
  </head>
  <body onresize="bodyResize()">
    <div id="wrapper" class="" >

      <div class="content section-wrap" style='height:100%;'>

        <div id="pageContainer" class="dn">

          <div class="row-fluid">
            <div class="col-md-12 bodybg">

            </div>
          </div>

        </div>

        <div id="pageInitial">

          <div class="tab-content maintabs">

            <div id="menu1" class="tab-pane fade in active">
              <div class="clearfix mb10">
                <button class="btn-default pull-left mr10" id="collapse-all">Collapse All</button>
                <button class="btn-default pull-left" id="expand-all">Expand All</button>
                <input type="text" id="filter-text-box" placeholder="Search..." class="form-control pull-right" style="width:50%" /> 
                <button class="pull-left btn btn-dark-blue ml15 summary-export-btn_0"><img title="Export" src="img/excel-icon.png" alt="" height="20px"> Export to CSV</button>
                <button class="pull-left btn ml15" onclick="masterRefresh()"><i class="fa fa-refresh" style="color:#337ab7"></i> All</button>
              </div>


              <div id="menu1tab" class="jira-grid"></div>

            </div>
          </div>



        </div>

      </div>

      <div class="page-loader">
        <p class="still-working">Few more Seconds. I am working on it&hellip;</p>
      </div>

<!-- 

      <div id="myConfirmation" class="modal fade" role="dialog">
        <div class="modal-dialog">
          <div class="form-horizontal">
            <div class="modal-content">
              <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title">Order Summary</h4>
              </div>
              <div class="modal-body">


                <div class="form-group">
                  <label class="control-label col-sm-4">Requested By:</label>
                  <div class="col-sm-8">
                    <span id="fortextinput"></span>
                  </div>
                </div>

                <div class="form-group">
                  <label class="control-label col-sm-4">Purpose of Request:</label>
                  <div class="col-sm-8">
                    <span id="fortxtPurpose"></span>
                  </div>
                </div>

                <div class="form-group">
                  <label class="control-label col-sm-4">Function Selected:</label>
                  <div class="col-sm-8">
                    <span id="fortxtfunctions"></span>
                  </div>
                </div>

                <div class="form-group">
                  <label class="control-label col-sm-4">GLO of the faulty device:</label>
                  <div class="col-sm-8">
                    <span id="fortxtGLO"></span>
                  </div>
                </div>

                <div class="form-group">
                  <label class="control-label col-sm-4">Hardware Description:</label>
                  <div class="col-sm-8">
                    <span id="fortxt_hdesc"></span>
                  </div>
                </div>

                <div class="form-group">
                  <label class="control-label col-sm-4">Root cause of Failure:</label>
                  <div class="col-sm-8">
                    <span id="fortxtRootCause"></span>
                  </div>
                </div>

                <div class="form-group">
                  <label class="control-label col-sm-4">Serial Number:</label>
                  <div class="col-sm-8">
                    <span id="fortxt_serial"></span>
                  </div>
                </div>

                <div class="form-group">
                  <label class="control-label col-sm-4">RMA raised:</label>
                  <div class="col-sm-8">
                    <span id="forradios"></span><br/>
                    Ticket ID: <span id="fortxtRMA"></span>
                  </div>
                </div>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-warning" data-dismiss="modal">Review Order</button>
                <button type="button" class="btn btn-primary" onclick="confirmOrder()">Confirm Order</button>
              </div>
            </div>
          </div>
        </div>
      </div> -->
    </div>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
    <script src="js/bootbox.min.js"></script>
    <script src="js/underscore-min.js"></script>
    <script src="js/ag-grid-enterprise.16.min.js"></script>

    <script src="js/typeahead.bundle.js"></script>
    <script src="js/jquery.accordion.js"></script>
    <script src="js/FileSaver.js"></script>
    <script src="js/tableexport.js"></script>
    <script src="js/inc.js"></script>
    <script src="js/index_tmp.js?<?=filemtime('js/index.js')?>"></script>

  </body>
</html>
