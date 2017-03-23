<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Construction Projects Dashboard</title>
  <link rel="icon" 
      type="image/png" 
      href="<%=request.getContextPath() %>/images/company.png">
  <link rel="stylesheet" href="<%=request.getContextPath() %>/CSS/jquery-ui.css" type="text/css" />
  <link rel="stylesheet" href="<%=request.getContextPath() %>/CSS/theme.blue.css" type="text/css" />
  <link rel="stylesheet" href="<%=request.getContextPath() %>/CSS/style.css">
  <!--  FREE ICONS: https://www.iconfinder.com/free_icons -->
  <!-- Fugue Icons: http://p.yusukekamiyamane.com/icons/attribution/ -->
  
  <script type="text/javascript" src="<%=request.getContextPath() %>/JS/jquery-3.1.1.min.js"></script>
  <script type="text/javascript" src="<%=request.getContextPath() %>/JS/jquery-ui.min.js"></script>
  <script type="text/javascript" src="<%=request.getContextPath() %>/JS/dashboard.js"></script>
  
  <!-- Google Charts -->
  <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
  
  <script type="text/javascript" src="<%=request.getContextPath() %>/JS/jquery.tablesorter.combined.js"></script>
  
  <script>
  
	  // Shorthand for $( document ).ready()
	  $( function() {
		  
		var projectList;
		var tabsDict    = { "Project Dashboard": 1 };
		var tabsDictVis = { "Project Dashboard": 'vis' };
		var tline = [];
		  
		$.ajax({
			url:   'getProjects',
					type: 'POST',
					cache: false,
					data:{  username: "${loggedInUser}"
					},
					beforeSend: function( xhr ) {
						
					},
					success: function (data) {
						
						projectList = jQuery.parseJSON(data);
						locationMap = projectList.splice(-1, 1);
						fundSourceMap = projectList.splice(-1, 1);
						phaseMap = projectList.splice(-1, 1);
						
						
						initMap();
						loadPieCharts();
					    $('#projectSpreadsheet').tablesorter({
					        theme: 'blue',
					        showProcessing: true,
					        headerTemplate: '{content} {icon}',
					        headers: { 
					        	2:{filter:false},3:{filter:false},4:{filter:false},5:{filter:false},6:{filter:false},7:{filter:false},8:{filter:false},9:{filter:false}			        
					        }, 
					        widgets: ['filter', 'zebra'],
					        widgetOptions: {
					            filter_useParsedData: true
					        }
					        
					    });
					}
		});
		  
	    var tabTitle = $( "#tab_title" ),
	      tabContent = $( "#tab_content" ),
	      //tabTemplate = "<li><a href='#[href]'>#[label]</a> <span class='ui-icon ui-icon-close' role='presentation'>Remove Tab</span></li>",
	      tabTemplate = "<li><a href='#[href]'><img src='<%=request.getContextPath() %>/images/#[image]' class='tab-image' valign='middle'>#[label]</a> <span class='ui-icon ui-icon-close' role='presentation'>Remove Tab</span></li>",
	      tabCounter = 3;
	 
	    var tabs = $( "#tabs" ).tabs();
	    tabs.find( ".ui-tabs-nav" ).sortable({
	        axis: "x",
	        stop: function() {
	          tabs.tabs( "refresh" );
	        }
	    });
	 
	    // Modal dialog init: custom buttons and a "close" callback resetting the form inside
	    var dialog = $( "#dialog" ).dialog({
	      autoOpen: false,
	      modal: true,
	      buttons: {
	        Add: function() {
	          addTab();
	          $( this ).dialog( "close" );
	        },
	        Cancel: function() {
	          $( this ).dialog( "close" );
	        }
	      },
	      close: function() {
	        form[ 0 ].reset();
	      }
	    });
	 
	    // AddTab form: calls addTab function on submit and closes the dialog
	    var form = dialog.find( "form" ).on( "submit", function( event ) {
	      addTab();
	      dialog.dialog( "close" );
	      event.preventDefault();
	    });
	 
	    // Actual addTab function: adds new tab using the input from the form above
	    function addTab() {
	      var label = tabTitle.val() || "Tab " + tabCounter,
	        id = "tabs-" + tabCounter,
	        li = $( tabTemplate.replace( /#\[href\]/g, "#" + id ).replace( /#\[label\]/g, label ) ),
	        tabContentHtml = tabContent.val() || "Tab " + tabCounter + " content.";
	 
	      tabs.find( ".ui-tabs-nav" ).append( li );
	      tabs.append( "<div id='" + id + "'><p>" + tabContentHtml + "</p></div>" );
	      tabs.tabs( "refresh" );
	      tabCounter++;
	    }
	 
	    // use window to make it global
	    window.addTab1 = function(label, image) {
	        var id = "tabs-" + tabCounter,
	          //li = $( tabTemplate.replace( /#\[href\]/g, "#" + id ).replace( /#\[label\]/g, label ).replace( /#\[id\]/g, id ) ),
	          li = $( tabTemplate.replace( /#\[href\]/g, "#" + id ).replace( /#\[label\]/g, label ).replace( /#\[image\]/g, image ) ),
	          tabContentHtml;
	        
	        // tab prev loaded and not closed
	        if (tabsDictVis[label] == 'vis' && tabsDict[label] > 0) {
	        	$( "#ui-id-" + tabsDict[label] ).trigger('click');
		        window.scrollTo(0, 0);
	        }
	        // tab prev loaded but closed
	        else if (tabsDictVis[label] == 'hid' && tabsDict[label] > 0) {
	        	
	        	// append tab with existing id (other instances simply add new tab with new id number) 
		        tabs.find( ".ui-tabs-nav" ).append( "<li><a href='#tabs-" + tabsDict[label] + "' id='ui-id-" + tabsDict[label] + "'><img src='<%=request.getContextPath() %>/images/" + image + "' class='tab-image' valign='middle'>" + label + "</a> <span class='ui-icon ui-icon-close' role='presentation'>Remove Tab</span></li>" );
		        //tabs.find( ".ui-tabs-nav" ).append( "<li><a href='#tabs-" + tabsDict[label] + "' id='ui-id-" + tabsDict[label] + "'>" + label + "</a> <span class='ui-icon ui-icon-close' role='presentation'>Remove Tab</span></li>" );
		        tabs.tabs( "refresh" );
		        $( "#ui-id-" + tabsDict[label] ).trigger('click');
		        window.scrollTo(0, 0);
	        	
	        }
	        // open project tab
	        else if (image == 'building-hedge.png') {
		  		$.ajax({
					url:   'getProject',
							contentType: "application/json; charset=utf-8",
							data:{  username: "${loggedInUser}", projectid: label },
							success: function (data) {
								tabContentHtml = data;
								
						        tabs.find( ".ui-tabs-nav" ).append( li );
						        tabs.append( "<div id='" + id + "'><p>" + tabContentHtml + "</p></div>" );
						        tabs.tabs( "refresh" );
						        $( "#ui-id-" + tabCounter ).trigger('click');
						        tabsDict[projectid] = tabCounter;
						        window.scrollTo(0, 0);
						        tabCounter++;
								
							}
				});

	        }
	        else if (label == 'All Projects Report') {
	        	alert('Under Construction');
	        }
	        else {
	        	var url;
	        	if (label == 'Vendor Prime Dashboard') {
	        		url = 'getVendorsPrime';
			  		/*$.ajax({
						url:   'getVendorsPrime',
								contentType: "application/json; charset=utf-8",
								data:{  username: "${loggedInUser}" },
								success: function (data) {
									tabContentHtml = data;
									
							        tabs.find( ".ui-tabs-nav" ).append( li );
							        tabs.append( "<div id='" + id + "'><p>" + tabContentHtml + "</p></div>" );
							        tabs.tabs( "refresh" );
							        $( "#ui-id-" + tabCounter ).trigger('click');
							        tabsDict[label] = tabCounter;
							        window.scrollTo(0, 0);
							        tabCounter++;
									
								}
					});*/
		        }
		        else if (label == 'Vendor Subcontractor Dashboard') {
		        	url = 'getVendorsSub';
			  		/*$.ajax({
						url:   'getVendorsSub',
								contentType: "application/json; charset=utf-8",
								data:{  username: "${loggedInUser}" },
								success: function (data) {
									tabContentHtml = data;
									
							        tabs.find( ".ui-tabs-nav" ).append( li );
							        tabs.append( "<div id='" + id + "'><p>" + tabContentHtml + "</p></div>" );
							        tabs.tabs( "refresh" );
							        $( "#ui-id-" + tabCounter ).trigger('click');
							        tabsDict[label] = tabCounter;
							        window.scrollTo(0, 0);
							        tabCounter++;
									
								}
					});*/
		        }
			    else if (label == 'Project Manager Dashboard') {
			    	url = 'getPms';
			  		/*$.ajax({
						url:   'getPms',
								contentType: "application/json; charset=utf-8",
								data:{  username: "${loggedInUser}" },
								success: function (data) {
									tabContentHtml = data;
									
							        tabs.find( ".ui-tabs-nav" ).append( li );
							        tabs.append( "<div id='" + id + "'><p>" + tabContentHtml + "</p></div>" );
							        tabs.tabs( "refresh" );
							        $( "#ui-id-" + tabCounter ).trigger('click');
							        tabsDict[label] = tabCounter;
							        window.scrollTo(0, 0);
							        tabCounter++;
									
								}
					});*/
		        }
		        $.ajax({
					url: url,
					contentType: "application/json; charset=utf-8",
					data:{  username: "${loggedInUser}" },
					success: function (data) {
						tabContentHtml = data;
						
				        tabs.find( ".ui-tabs-nav" ).append( li );
				        tabs.append( "<div id='" + id + "'><p>" + tabContentHtml + "</p></div>" );
				        tabs.tabs( "refresh" );
				        $( "#ui-id-" + tabCounter ).trigger('click');
				        tabsDict[label] = tabCounter;
				        window.scrollTo(0, 0);
				        tabCounter++;
						
					}
				});

	        }
	        tabsDictVis[label] = 'vis';
	   
	    }
	    
	    // AddTab button: just opens the dialog
	    $( "#add_tab" )
	      .button()
	      .on( "click", function() {
	        dialog.dialog( "open" );
	      });
	 
	    // Close icon: removing the tab on click
	    tabs.on( "click", "span.ui-icon-close", function() {
	      var panelId = $( this ).closest( "li" ).remove().attr( "aria-controls" );
	      
	      // removed by me //
	      //$( "#" + panelId ).remove();
	      // removed by me //
	      
	      // added by me //
	      $ ( '#' + panelId ).hide();
	      var removeTabFromDict = $( this ).closest( "li" )[0].children[0].innerText.trim();
	      tabsDictVis[removeTabFromDict] = 'hid';
	      //delete tabsDict[removeTabFromDict];
	      // added by me //
	      
	      tabs.tabs( "refresh" );
	    });
	 
	    tabs.on( "keyup", function( event ) {
	      if ( event.altKey && event.keyCode === $.ui.keyCode.BACKSPACE ) {
	        var panelId = tabs.find( ".ui-tabs-active" ).remove().attr( "aria-controls" );
	        $( "#" + panelId ).remove();
	        tabs.tabs( "refresh" );
	      }
	    });
	    
		function initMap() {
			var center = {lat: 35.4527669, lng: -96.3448548}; 
			window.map = new google.maps.Map(document.getElementById('map'), {
				zoom: 4,
				maxZoom: 16,
				center: center
			});
	        
		    var image = {
	 		  url: '<%=request.getContextPath() %>/images/company.png',
	 		  size: new google.maps.Size(64, 64),
	 		  origin: new google.maps.Point(0, 0),
	 		  anchor: new google.maps.Point(32, 0),
	 		  scaledSize: new google.maps.Size(50, 50)
			};
		    
		    var markers = [];
			var flag1=0;
			$.each( projectList, function( i, project ) {
				
				/* MAP START */
				
				var latlng = project.latlng.split(',');
				var position = new google.maps.LatLng(latlng[0], latlng[1]);
				
				var contentString = '<a href="javascript:addTab1(\'' + project.projectid + '\', \'building-hedge.png\');">' + project.projectname + '</div>';
				
			    var infowindow = new google.maps.InfoWindow({
					content: contentString
				});
			    
		        var marker = new google.maps.Marker({
					position: position,
					map: map,
					icon: image,
					title: project.projectname
		        });
		          
				marker.addListener('click', function() {
				    infowindow.open(map, marker);
				});
		          
				markers.push(marker);
				
				//marker.setMap(map);
				
				/* MAP END */
				
				/* TABLE START */

				bodyString = "<tr class='tableRow'>";
				bodyString += "<td class='col0' onClick=\"javascript:addTab1('" + project.projectid + "', 'building-hedge.png');\">" + project.projectid + "</td>";
				bodyString += "<td class='col1'>" + project.projectname + "</td>";
				bodyString += "<td class='col1'>" + project.pmname + "</td>";
				bodyString += "<td class='col2'>" + project.fundsource + "</td>";
				bodyString += "<td class='col3'>" + project.projectphase + "</td>";
				bodyString += "<td class='col4'>" + project.location + "</td>";
				bodyString += "<td class='col5'>" + '$' + project.totalfars.toFixed(2).replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,"); + "</td>";
				bodyString += "<td class='col6'>" + '$' + project.etpc.toFixed(2).replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");  + "</td>";
				bodyString += "<td class='col7'>" + project.projectstart + "</td>";
				bodyString += "<td class='col8'>" + project.beneficialocc + "</td>";
				
				if (flag1 == 0) {
					headerString = "<tr><th data-placeholder='Filter on Project ID...'>Project ID</th><th data-placeholder='Filter on Project Name...'>Project Name</th><th>Project Manager</th><th>Fund Source</th><th>Project Phase</th><th>Location</th><th>Total FARs</th><th>ETPC</th><th>Project Start</th><th>Beneficial Occupancy</th></tr>";
				    $("#projectSpreadsheet").prepend('<thead></thead>');
				    $("#projectSpreadsheet").append('<tbody></tbody>');
				    $("#projectSpreadsheet").find('thead').append(headerString);
					flag1 = 1;					
				}
				$("#projectSpreadsheet tbody").append(bodyString);
				
				/* TABLE END */
				
				/* TIMELINE START */
				
				if (i < 3) {
					
					var  tl = [];
					tl[0] = project.projectid;
					tl[1] = project.projectname;
					tl[2] = new Date( project.projectstart.substring(0,4), project.projectstart.substring(5,7) - 1, project.projectstart.substring(8) );
					tl[3] = new Date( project.beneficialocc.substring(0,4), project.beneficialocc.substring(5,7) - 1, project.beneficialocc.substring(8) );
					
					tline.push(tl);

				}
				
				/* TIMELINE END */
				
			});
			
			var markerClusterOptions = { gridSize:10, maxZoom:8, minimumClusterSize:1, imagePath:'https://developers.google.com/maps/documentation/javascript/examples/markerclusterer/m' };
			
			markerCluster = new MarkerClusterer(map, markers, markerClusterOptions);
			
			var latlng = {lat: 40.7731295, lng: -73.957734};

			map.setCenter(latlng);
	  	  
		}
		  
		function loadPieCharts() {
			  
			/* GOOGLE API REFERENCE */
			
			/* https://developers.google.com/chart/interactive/docs/reference */
			
		    // google.charts.load("current", {packages:["corechart"]});
		    google.charts.load('current', {'packages':['timeline', 'corechart']});
		    google.charts.setOnLoadCallback(drawChart);
		    
		    function drawChart() {
		    	
		    	
				var container = document.getElementById('timeline');
				var chart = new google.visualization.Timeline(container);
				var dataTable = new google.visualization.DataTable();
				
				dataTable.addColumn({ type: 'string', id: 'Project' });
				dataTable.addColumn({ type: 'string', id: 'Name' });
				dataTable.addColumn({ type: 'date', id: 'Start' });
				dataTable.addColumn({ type: 'date', id: 'End' });
				
				/*dataTable.addRows([
				  [ 'Washington', new Date(1789, 3, 30), new Date(1797, 2, 4) ],
				  [ 'Adams',      new Date(1797, 2, 4),  new Date(1801, 2, 4) ],
				  [ 'Jefferson',  new Date(1801, 2, 4),  new Date(1809, 2, 4) ]]);*/
				  
			    dataTable.addRows(tline);  
				
				var options = {
				        //titleTextStyle: { bold: true },
				        //height: 380,
				        bar: {groupWidth: "50%"},
				        legend: { position: "none" },
				      };
				      
				chart.draw(dataTable, options);
				
				/* ---------------- */
		      
		    	var p = phaseMap[0].phaseMap;
		    	var pieChartOuter = [ ['Phase', 'Count'] ];			
		    	for (var key in p) {
		    		if (p.hasOwnProperty(key)) {
		    			var pieChartInfo = new Array(2);
		    			pieChartInfo[0] = key;
		    			pieChartInfo[1] = p[key];
		    			pieChartOuter.push(pieChartInfo);
		    		}
		    	}
		    	
		    	var data = google.visualization.arrayToDataTable(pieChartOuter);
				
				var options = {
				  //title: 'Construction Projects By Phase',
			      //width: 380,
			      //height: 380,
				  is3D: false,
				  //legend: 'none',
				};
				
				var chart = new google.visualization.PieChart(document.getElementById('piechart'));
				chart.draw(data, options);
				
				/* ---------------- */
				
				var p = fundSourceMap[0].fundSourceMap;
		    	var pieChartOuter = [ ['Fund Source', '', { role: "style" }] ];
		    	var colors = ["color:#3366cc", "color:#dc3912", "color:#ff9900", "color:#109618",  "color:#990099", "color:#b87333", "color:#c0c0c0"];
		    	var c=0;
		    	for (var key in p) {
		    		if (p.hasOwnProperty(key)) {
		    			var pieChartInfo = new Array(2);
		    			pieChartInfo[0] = key;
		    			pieChartInfo[1] = p[key];
		    			pieChartInfo[2] = colors[c];
		    			pieChartOuter.push(pieChartInfo);
		    			c++;
		    		}
		    	}
		    	
		    	data = google.visualization.arrayToDataTable(pieChartOuter);
				
				var view = new google.visualization.DataView(data);
				view.setColumns([0, 1,
				                 { calc: toCurrency,
				                   sourceColumn: 1,
				                   type: "string",
				                   role: "annotation" },
				                 2]);
		    	function toCurrency(dataTable, rowNum){
			    	return '$' + dataTable.getValue(rowNum, 1).formatMoney(2);
			    }
				
				var options = {
				  //title: "Funding by Source",
				  //width: '100%',
				  width: "100%",
				  //height: 380,
				  //bar: {groupWidth: "95%"},
				  vAxis: {format: "currency"},
				  legend: { position: "none" },
				};
				
				var chart = new google.visualization.ColumnChart(document.getElementById("columnchart"));
				chart.draw(view, options);
				
				/* --------------- */
				
		    	var p = locationMap[0].locationMap;
		    	var pieChartOuter = [ ['Location', 'Count'] ];			
		    	for (var key in p) {
		    		if (p.hasOwnProperty(key)) {
		    			var pieChartInfo = new Array(2);
		    			pieChartInfo[0] = key;
		    			pieChartInfo[1] = p[key];
		    			pieChartOuter.push(pieChartInfo);
		    		}
		    	}
		    	
		    	var data = google.visualization.arrayToDataTable(pieChartOuter);
				
				var options = {
				  //title: 'Construction Projects By Phase',
			      //width: 380,
			      //height: 380,
				  is3D: false,
				  //legend: 'none',
				};
				
				var chart = new google.visualization.PieChart(document.getElementById('piechart_location'));
				chart.draw(data, options);
				
				/* ---------------- */
				
		    }
		  
		}
	    
	    $( "#menu1" ).click(function() {
	        $('#menu1dd').toggle();
	        $('#menu2dd').hide();
	    });
	    
	    $( "#menu2" ).click(function() {
	        $('#menu1dd').hide();
	        $('#menu2dd').toggle();
	    });
	    
	    $( "#menu1dd" ).menu();
	    $( "#menu2dd" ).menu();
	
	    $( "#dd1-1" ).click(function() {
	    	var label = "Project Dashboard";
	        addTab1(label, 'monitor-window-3d.png');
	        $('#menu1dd').hide();
	    });
	    
	    $( "#dd1-2" ).click(function() {
	    	var label = "Project Manager Dashboard";
		    addTab1(label, 'monitor-window-flow.png');
	        $('#menu1dd').hide();
	    });
	    
	    $( "#dd1-3" ).click(function() {
	    	var label = "Vendor Prime Dashboard";
		    addTab1(label, 'user-business.png');
	        $('#menu1dd').hide();
	    });
	    
	    $( "#dd1-4" ).click(function() {
	    	var label = "Vendor Subcontractor Dashboard";
		    addTab1(label, 'user-green.png');
	        $('#menu1dd').hide();
	    });
	    
	    $( "#dd1-5" ).click(function() {
			window.location = window.location.href;
	    });
	    
	    $( "#dd2-1" ).click(function() {
	    	var label = "All Projects Report";
		    addTab1(label);
	        $('#menu2dd').hide();
	    });
	    
	    $( "#resetMap" ).click(function() {
			var latlng = {lat: 40.7731295, lng: -73.957734};

			map.setCenter(latlng);
			map.setZoom(4);

	    });
	    
	  	//This must be a hyperlink
	    $("#exportProjectSpreadsheet").on('click', function (event) {
	    	
	        exportTableToExcel.apply(this, ['#projectSpreadsheet', 'ProjectSummarySpreadsheet.xls']);
	        
	        // IF CSV, don't do event.preventDefault() or return false
	        // We actually need this to be a typical hyperlink
	    });


	    
	    $(document).mouseup(function (e)
	    		{
	    		    var container = $( "#menu1dd" );

	    		    if (!container.is(e.target) // if the target of the click isn't the container...
	    		        && container.has(e.target).length === 0) // ... nor a descendant of the container
	    		    {
	    		        container.hide();
	    		    }
	    		    
	    		    container = $( "#menu2dd" );

	    		    if (!container.is(e.target) // if the target of the click isn't the container...
	    		        && container.has(e.target).length === 0) // ... nor a descendant of the container
	    		    {
	    		        container.hide();
	    		    }
	    		    
	    		});
	  
	  });
	  
  </script>
</head>
<body>
	 <div style="margin-top:1em;width:95%; margin:auto;">
	 	<div id="menu1" class="menu-buttons" style="float: left;"><img src="<%=request.getContextPath() %>/images/monitor-window.png" class="tab-image" valign="middle"> Dashboards <img src="<%=request.getContextPath() %>/images/asc.png" valign="middle"></div>
	 	<div id="menu2" class="menu-buttons" style="margin-left: 207px;"><img src="<%=request.getContextPath() %>/images/application-table.png" class="tab-image" valign="middle"> Reports <img src="<%=request.getContextPath() %>/images/asc.png" valign="middle"></div>
	 	
		 <ul id="menu1dd" role="menu" tabindex="0" class="ui-menu ui-widget ui-widget-content ui-menu-icons" aria-activedescendant="ui-id-8" style="position:fixed;display:none;z-index:1;">
		  <li class="ui-menu-item">
		    <div id="dd1-1" tabindex="-1" role="menuitem" class="ui-menu-item-wrapper" style="text-indent:20px;"><span class="menu-item menu-item-1"></span>Project Dashboard</div>
		  </li>
		  <li class="ui-menu-item">
		    <div id="dd1-2" tabindex="-1" role="menuitem" class="ui-menu-item-wrapper" style="text-indent:20px;"><span class="menu-item menu-item-2"></span>Project Manager Dashboard</div>
		  </li>
		  <li class="ui-menu-item">
		    <div id="dd1-3" tabindex="-1" role="menuitem" class="ui-menu-item-wrapper" style="text-indent:20px;"><span class="menu-item menu-item-3"></span>Vendor Prime Dashboard</div>
		  </li>
		  <li class="ui-menu-item">
		    <div id="dd1-4" tabindex="-1" role="menuitem" class="ui-menu-item-wrapper" style="text-indent:20px;"><span class="menu-item menu-item-4"></span>Vendor Subcontractor Dashboard</div>
		  </li>
		  <li class="ui-menu-item">
		    <div id="dd1-5" tabindex="-1" role="menuitem" class="ui-menu-item-wrapper" style="text-indent:20px;"><span class="menu-item menu-item-6"></span>Sign Out</div>
		  </li>
		</ul> 
	
		<ul id="menu2dd" role="menu" tabindex="0" class="ui-menu ui-widget ui-widget-content ui-menu-icons" aria-activedescendant="ui-id-08" style="margin-left: 207px;position:fixed;display:none;z-index:1;">
		  <li class="ui-menu-item">
		    <div id="dd2-1" tabindex="-1" role="menuitem" class="ui-menu-item-wrapper" style="text-indent:20px;"><span class="menu-item menu-item-5"></span>All Projects Report</div>
		  </li>
		</ul> 
	 	
	 	
	</div>
	


<div id="dialog" title="Tab data">
  <form>
    <fieldset class="ui-helper-reset">
      <label for="tab_title">Title</label>
      <input type="text" name="tab_title" id="tab_title" value="Tab Title" class="ui-widget-content ui-corner-all">
      <label for="tab_content">Content</label>
      <textarea name="tab_content" id="tab_content" class="ui-widget-content ui-corner-all">Tab content</textarea>
    </fieldset>
  </form>
</div>
 
    <script src="https://developers.google.com/maps/documentation/javascript/examples/markerclusterer/markerclusterer.js"></script>
    <script async defer src="https://maps.googleapis.com/maps/api/js?key=AIzaSyA-Y928yj3PSrVGH97T9_xBbwF9cMiCsh0"></script>
 
 
<br>
<!-- button id="add_tab" class="ui-button ui-corner-all ui-widget">Add Tab</button-->
 
<div id="tabs">
  <ul>
    <li><a href="#tabs-1"><img src="<%=request.getContextPath() %>/images/monitor-window-3d.png" class="tab-image" valign="middle"> Project Dashboard</a> <span class="ui-icon ui-icon-close" role="presentation">Remove Tab</span></li>
  </ul>
  
  <div id="tabs-1" style="min-width:1244px;"><p>

    <table style="width:100%;min-width:1200px;border-collapse:collapse;border:0px solid black;">
    	<tr>
    		<td colspan="3" style="width:100%;border-collapse:collapse;border:1px solid black;"><a id="resetMap">Reset Map</a><div id="map"></div></td>
   		</tr>
   		<tr>
   			<td colspan="3" style="width:100%;border-collapse:collapse;border:1px solid black;"><br><b>Timeline of upcoming projects</b><br><br><div id="timeline"     style="width:90%;height:200px;margin:auto;vertical-align:bottom;"><br><br></div></td>
   		</tr>
    	<tr>
    		<td style="width:33%;border-collapse:collapse;border:1px solid black;padding:20px;"><b>Construction Projects by Phase</b><br><br><div id="piechart"    style="width:90%;height:80%;margin:auto;"></div></td>
    		<td style="width:33%;border-collapse:collapse;border:1px solid black;"><b>Funding by Source</b><br><br><div id="columnchart"              style="width:90%;height:80%;margin:auto;"></div></td>
    		<td style="width:33%;border-collapse:collapse;border:1px solid black;"><b>Construction Projects by Location</b><br><br><div id="piechart_location"    style="width:90%;height:80%;margin:auto;"></div></td>
    	</tr>
    	<tr>
    		<td colspan = "3" style="border-collapse:collapse;border:1px solid black;">
				<br><table id="projectSpreadsheet" class="tablesorter" style="width:90%;margin:auto;"></table>
    			<br><a href="#" id="exportProjectSpreadsheet" class="exportTableButton">Export Table data into Excel</a><br><br>
    		</td>
    	</tr>
    </table>
    
    
  </p></div>
  
</div>
 
 
</body>
</html>