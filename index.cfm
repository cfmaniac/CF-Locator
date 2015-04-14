
<cfoutput>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>CFLocator</title>
    <meta content="IE=edge,chrome=1" http-equiv="X-UA-Compatible">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">
    <base href="">




    
    <link rel="stylesheet" type="text/css" href="assets/lib/bootstrap3/dist/css/bootstrap.css">
    <link rel="stylesheet" href="assets/lib/DataTables-1.10.2/media/css/datatables.Bootstrap.css">
    <link rel="stylesheet" type="text/css" href="assets/lib/bootstrap3/dist/css/bootstrap.css">
    <link rel="stylesheet" href="assets/lib/FontAwesome/css/font-awesome.css">
    <link rel="stylesheet" type="text/css" href="assets/lib/bootstrap3/dist/css/bootstrap-switch.css">
    <link href="assets/stylesheets/smoothness/jquery-ui-1.8.19.custom.css" rel="stylesheet">
    <script src="assets/lib/jquery-1.11.1.min.js" type="text/javascript"></script>
    <script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/jquery-ui.min.js"></script>
    <script src="assets/javascripts/site.js" type="text/javascript"></script>
    <script src="assets/lib/ckeditor/ckeditor.js" type="text/javascript"></script>
    <script src="assets/lib/bootstrap3/js/bootstrap-switch.js"></script>
   
    <script type="text/javascript" src="assets/lib/DataTables-1.10.2/media/js/jquery.dataTables.min.js"></script>
    <script type="text/javascript" src="assets/lib/DataTables-1.10.2/media/js/dataTables.bootstrap.js"></script>
    <script type="text/javascript" src="assets/lib/iconselect/iconselect.js"></script>
    <script type="text/javascript" src="assets/lib/iconselect/iscroll.js"></script>
    <link rel="stylesheet" type="text/css" href="assets/stylesheets/theme.css">

    <!-- Le HTML5 shim, for IE6-8 support of HTML5 elements -->
    <!--[if lt IE 9]>
      <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->

    
  </head>

  <!--[if lt IE 7 ]> <body class="ie ie6"> <![endif]-->
  <!--[if IE 7 ]> <body class="ie ie7 "> <![endif]-->
  <!--[if IE 8 ]> <body class="ie ie8 "> <![endif]-->
  <!--[if IE 9 ]> <body class="ie ie9 "> <![endif]-->
  <!--[if (gt IE 9)|!(IE)]><!--> 
  <body class=""> 
  <!--<![endif]-->
    
<div class="navbar navbar-inverse navbar-fixed-top">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
            <span class="icon-reorder"></span>
          </button>
          <a class="navbar-brand" href="index.cfm" style="margin-top: -10px;">CF-Locator</a>
        </div>
        
        <div class="hidden-xs">
         
                    
                    
                    
                  
        </div><!--/.navbar-collapse -->
    </div>
    </div>


    <div class="navbar-collapse collapse">
    
    </div>
    
     
    
    <div class="content">
    <div class="row">
        <cfscript>
         param name="rc.radius" default="10";
         param name="rc.meterstomiles" default="1609.34";
         param name="rc.datasource" default="location";
         
         if(cgi.request_method is "post"){
           //rc.Zips = createObject("component", "admin.controllers.zipfinder").zipToLL(zip='#form.zipcode#');
            rc.ZipResults = createObject("component", "com.zipfinder").haversineSearch(zip='#form.zipcode#',radius= '#form.radius#');
            writeOutput('
            <script src="http://maps.google.com/maps/api/js?sensor=false&amp;libraries=geometry&amp;v=3.13"></script>
            <script src="assets/javascripts/WDSMaps.js"></script>');
           }
        </cfscript>
        
        
    </div>   
    <div class="row">
    <cfoutput>
   <div class="col-sm-8 main-content">
   <h2>ZipCode Search </h2>
   
   <div class="row-fluid">
       <form name="bizSearch" method="post" action="index.cfm">
    
    <div class="col-sm-3">
        <div class="form-group">
                    <!-- Text input-->
                    
                    <div class="controls">
                        <input type="text" id="zip" name="zipcode" class="form-control" <cfif isdefined('form.zipcode') and form.zipcode NEQ "">value="#form.zipcode#" <cfelse>placeholder="ZipCode" </cfif> >
                        
                    </div>
        </div>
    </div>
    
    <div class="col-sm-3">
        <div class="form-group">
                    <!-- Text input-->
                    
                    <div class="controls">
                        <select Name="radius" id="radius" class="form-control">
                        <cfloop from=5 to=100 step="5" index=radius>
                        <option value="#radius#" <cfif isdefined('rc.radius') and rc.radius EQ #radius#>selected="selected"</cfif>>#radius# Miles</option>
                        </cfloop>    
                        </select>
                    </div>
        </div>
    </div>
    
    <div class="col-sm-3">
        <div class="form-group">
                    <!-- Text input-->
                    
                   
        </div>
    </div>
    
    <div class="col-sm-3">
        <div class="form-group">
                    <!-- Text input-->
                    
                    <div class="controls">
                        <input type="submit" name="submit" id="submit" value="Search" class="btn btn-success">
                    </div>
        </div>
    </div>
    
    </form>
    <cfif cgi.request_method is "Post">
    <h2>Your Search Results for ZipCode: #form.zipcode# - #numberFormat(rc.ZipResults.recordcount)# Results</h2>   
     <table class="table table-first-column-number data-table display full">
    <thead>
    <tr>
        
    	  <td>Zip</td>
        <td>City</td>
        <td>County</td>
        <td>State</td>
        <td>Distance</td>
        
    </tr>
    </thead>
    <tbody>
	<cfloop query="#rc.ZipResults#">
	
	<tr class="alert-success">
	   
    	<td style="font-weight: bold;"><a href="javascript:WDSMaps.ViewOnMap(#currentrow#);">#zip#</a></td>
      <td>#city#</td>
      <td>#county#</td>
      <td>#state#</td>
      <td>#numberformat(dist, '0.0')#</td>
      
    </tr>
    </cfloop>
    </tbody>
	</table>
    
  
       
    </cfif>
   </div>
   
   </div>
   <div class="col-sm-4 main-content">
     <cfif cgi.request_method is "post">
     <div class="col-sm-12" id="gmap" style="padding: 0; margin-top:1.563em;height: 23.438em;">
     
      <!---Miles to Meters - for Drawing Map Radius--->
      <cfset MapRadius = (#form.radius#*#rc.metersToMiles#)>
      <script>
       var ZipCodes = [
      <cfloop query="rc.ZipResults">
      
      {
        lat: '#rc.ZipResults.latitude#',
        lon: '-#rc.ZipResults.longitude#',
        title: '#rc.ZipResults.zip#',
        html: '<h3>#rc.ZipResults.zip#</h3>#rc.ZipResults.city#, #rc.ZipResults.State#<br>Distance from #form.zipcode#: #numberformat(rc.ZipResults.dist, '0.0')# M',
        <cfif currentrow is "1">
         
            icon: 'http://labs.google.com/ridefinder/images/mm_20_green.png',
            
         type : 'circle',
         circle_options: {
            radius: #mapRadius#
         },
         stroke_options : {
            strokeColor: '##3c763d',
            strokeOpacity: 0.8,
            strokeWeight: 2,
            fillColor: '##d6e9c6',
            fillOpacity: 0.4
         },
        <cfelse>
        
            icon: 'http://labs.google.com/ridefinder/images/mm_20_green.png',
           
         
        </cfif>
        
        animation: google.maps.Animation.DROP
    },
   </cfloop> 
   ];
   
   //The Map:
   var WDSMaps = new WDSMaps({
    locations: ZipCodes,
    map_options:{
    //scrollwheel: false
    }
    }); 
    WDSMaps.Load();    
   </script> 
   
     </cfif>  
   </div>
</cfoutput>
<script>
jQuery(function($){
   
    
    
     
   
	
	
	
	$('table.data-table.full').dataTable( {
            "dom": 'flrtip',
            "order": [ [4,'asc']],
            "paging": true,
            "info": true,
            "scrollY": "375px",
            "pageLength": 50,
            "scrollCollapse": true,
            "lengthMenu": [[10, 25, 50, 75, 100 -1], [10, 25, 50, 75, 100, "All"]],
            "fnDrawCallback": function(o) {
               $('.dataTables_scrollBody').scrollTop(0);
            },
            "language": {
            "lengthMenu": "Display _MENU_ records per page",
            "zeroRecords": "Nothing found - sorry",
            "info": '<span class="alert-success" style="border: 1px solid ##000; width: 25px; height:25px; display:inline-block"></span> = Available <span class="alert-danger" style="border: 1px solid ##000; width: 25px; height:25px; display:inline-block;"></span> = UnAvailable<br>Showing page _PAGE_ of _PAGES_ ',
            "infoEmpty": "No records available",
            "infoFiltered": "(filtered from _MAX_ total records)"
     }   
     });
        
     
});
</script>
    
    
    </div>

        
        <footer>
            <hr>
            <p class="pull-right">CFLocator by <a href="http://wdscreations.com" target="_blank">J Harvey</a></p>
            <p>&copy; 2008-#dateformat(now(), "YYYY")# wdscreations.com</p>
        </footer>
        
    </div>
    
    <script src="assets/lib/bootstrap3/dist/js/bootstrap.js"></script>
    
    <script type="text/javascript">
       
    </script>
    
  </body>
</html>
</cfoutput>

