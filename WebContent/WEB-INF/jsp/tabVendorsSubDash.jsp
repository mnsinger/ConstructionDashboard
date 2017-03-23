    <script>
    
    	subcontractorsList = jQuery.parseJSON('${subcontractorsJSONArray}');
    	
    	//console.log('hi');
    	console.log(subcontractorsList);
    	
    	if (subcontractorsList.length > 0) {
    	
	    	tableString = '<br><table id="subcontractorsTable" class="tablesorter" style="width:80%;margin:auto;"></table>';
	    	$(tableString).prependTo("#vendorSubTableDiv");
	    	
		  	//This must be a hyperlink
		    $("#exportVendorsSubTable").on('click', function (event) {
		    	
		        exportTableToExcel.apply(this, ['#subcontractorsTable', 'VendorsSubListSpreadsheet.xls']);
		        
		        // IF CSV, don't do event.preventDefault() or return false
		        // We actually need this to be a typical hyperlink
		    });
	    	
	    	headerString = '<tr><th>Subcontractor Name</th><th>Subcontractor Number</th><th>Number of Projects</th><th>Approval Letter Sum</th><th>Trades</th></tr>'
		    $("#subcontractorsTable").prepend('<thead></thead>');
		    $("#subcontractorsTable").append('<tbody></tbody>');
		    $("#subcontractorsTable").find('thead').append(headerString);
		    
	    	var columnChartOuter = [ ['Column Label', 'Value', { role: "style" }, { role: 'annotation' }] ];
	    	var colors = ["color:#3366cc", "color:#dc3912", "color:#ff9900", "color:#109618",  "color:#990099", "color:#b87333", "color:#c0c0c0"];
	    	
		    $.each( subcontractorsList, function( i, subcontractor ) {
		    	
		    	var columnChartInfo = new Array(2);
		    	columnChartInfo[0] = subcontractor.subcontractorname;
		    	columnChartInfo[1] = subcontractor.projectcount;
		    	columnChartInfo[2] = colors[i];
		    	columnChartInfo[3] = subcontractor.projectcount;
		    	columnChartOuter.push(columnChartInfo);

		    	
				bodyString  = "<tr class='tableRow'>";
				bodyString += "<td class='subcontractorName'>" + subcontractor.subcontractorname + "</td>";
				bodyString += "<td>" + subcontractor.subcontractorid + "</td>";
				bodyString += "<td style='text-align:right'>" + subcontractor.projectcount + "</td>";
				bodyString += "<td style='text-align:right'>$" + subcontractor.alamount.formatMoney(0) + "</td>";
				bodyString += "<td>" + subcontractor.trades + "</td></tr>";
				$("#subcontractorsTable tbody").append(bodyString);
						    	
		    });
		    
		    $( document ).on( "click", ".subcontractorName", function() {
		    	  //console.log( $(this) );
				console.log( $(this)[0].nextSibling.innerText );
		    	var subcontractorid = $(this)[0].nextSibling.innerText;
		  		$.ajax({
					url:   'getVendorSubDetail',
							contentType: "application/json; charset=utf-8",
							data:{  username: "${loggedInUser}", subcontractorid: subcontractorid },
							success: function (data) {
								console.log(data);
								
								projectList = jQuery.parseJSON(data);
								
								// if detail table does not exist
								if ($('#vendorSubDetailTable').length == 0) { 
									
							    	tableString = '<br><table id="vendorSubDetailTable" class="tablesorter" style="width:80%;margin:auto;"></table>';
							    	$("#vendorSubDetailTableDiv").empty();
							    	$(tableString).appendTo("#vendorSubDetailTableDiv");
							    	
							    	headerString = '<tr><th>Project Number</th><th>Project Name</th><th>Approval Letters</th><th>Change Orders</th><th>Total</th></tr>'
								    $("#vendorSubDetailTable").prepend('<thead></thead>');
								    $("#vendorSubDetailTable").append('<tbody></tbody>');
								    $("#vendorSubDetailTable").find('thead').append(headerString);

								    $.each( projectList, function( i, project ) {
								    	
										bodyString  = "<tr class='tableRow'>";
										bodyString += "<td class='col0' onClick=\"javascript:addTab1('" + project.projectid + "', 'building-hedge.png');\">" + project.projectid + "</td>";
										bodyString += "<td class='col1'>" + project.projectname + "</td>";
										bodyString += "<td class='col2' style='text-align:right'>$" + project.alamount.formatMoney(2) + "</td>";
										bodyString += "<td class='col4' style='text-align:right'>$" + project.changeorderamount.formatMoney(2) + "</td>";
										bodyString += "<td class='col5' style='text-align:right'>$" + (project.alamount + project.changeorderamount).formatMoney(2) + "</td>";
										$("#vendorSubDetailTable tbody").append(bodyString);
												    	
								    });
								    
								    $("<br><br><a href='#' id='exportVendorSubDetailTable' class='exportTableButton'>Export Table data into Excel</a><br><br><br>").appendTo("#vendorSubDetailTableDiv");

								  	//This must be a hyperlink
								    $("#exportVendorSubDetailTable").on('click', function (event) {
								    	
								        exportTableToExcel.apply(this, ['#vendorSubDetailTable', 'VendorSubDetailSpreadsheet.xls']);
								        
								        // IF CSV, don't do event.preventDefault() or return false
								        // We actually need this to be a typical hyperlink
								    });
							    	
								    $('#vendorSubDetailTable').tablesorter({
								        theme: 'blue',
								        showProcessing: true,
								        headerTemplate: '{content} {icon}',
								        widgets: ['zebra'],
								        widgetOptions: {
								            filter_useParsedData: true
								        }
								        
								    });


								}
								
								// detail table does exist
								else {
									
									$("#vendorSubDetailTable > tbody").html("");
									
								    $.each( projectList, function( i, project ) {
								    	
										bodyString  = "<tr class='tableRow'>";
										bodyString += "<td class='col0' onClick=\"javascript:addTab1('" + project.projectid + "', 'building-hedge.png');\">" + project.projectid + "</td>";
										bodyString += "<td class='col1'>" + project.projectname + "</td>";
										bodyString += "<td class='col2' style='text-align:right'>$" + project.alamount.formatMoney(2) + "</td>";
										bodyString += "<td class='col4' style='text-align:right'>$" + project.changeorderamount.formatMoney(2) + "</td>";
										bodyString += "<td class='col5' style='text-align:right'>$" + (project.alamount + project.changeorderamount).formatMoney(2) + "</td>";
										$("#vendorSubDetailTable tbody").append(bodyString);
										$("#vendorSubDetailTable").trigger('update'); 
										
								    });

								}
							}
				});

		    	  
		    });
		    	
		    $('<br><br>').appendTo("#vendorSubTableDiv");
		    
			/* ---------------- Start Bar Chart ---------------- */
			
			//var p = fundSourceMap[0].fundSourceMap;
	    	
	    	vSdata = google.visualization.arrayToDataTable(columnChartOuter);
			
			var vSview = new google.visualization.DataView(vSdata);
			
			var vSoptions = {
			  //title: "Funding by Source",
			  //width: '100%',
			  width: "100%",
			  //height: 380,
			  //bar: {groupWidth: "95%"},
			  vAxis: {format: "short", title: "Number of Projects"},
			  legend: { position: "none" },
			};
			
			var vSchart = new google.visualization.ColumnChart(document.getElementById("subcontractorsColChartDiv"));
	        function vSselectHandler() {
		          var selectedItem = vSchart.getSelection()[0];
		          if (selectedItem) {
		            var selectedValue = vSdata.getValue(selectedItem.row, 0);
		            // filter td elements in table to equal the Vendor Name and trigger a click on that element
		            $('.subcontractorName').filter(function(){
		            	  return $(this)[0].innerText === selectedValue;
		            	}).each(function(){
		            	  $(this).trigger( 'click' );
		            	});
		          }
			    }
					
					// Listen for the 'select' event, and call my function selectHandler() when
					// the user selects something on the chart.
			google.visualization.events.addListener(vSchart, 'select', vSselectHandler);
			vSchart.draw(vSview, vSoptions);
			
			/* ---------------- End Bar Chart ---------------- */

		    
		    $('#subcontractorsTable').tablesorter({
		        theme: 'blue',
		        showProcessing: true,
		        headerTemplate: '{content} {icon}',
		        widgets: ['zebra'],
		        widgetOptions: {
		            filter_useParsedData: true
		        }
		        
		    });

    	}
    	else {
    		console.log("No Vendors");
    		$('<p>None</p>').appendTo("#vendorSubTableDiv");
    	}
	    
    </script>
    <table style="width:95%;border-collapse:collapse;border:0px solid black;margin:auto;">
    	<tr>
    		<td style="border-collapse:collapse;border:1px solid black;">
				<br><b>Subcontractor Vendors</b><br><br><div id="subcontractorsColChartDiv" style="width:90%;height:80%;margin:auto;"></div>
    		</td>
    	</tr>
    	<tr>
    		<td style="border-collapse:collapse;border:1px solid black;">
    			<br><b>List of All Subcontractor Vendors</b><br>
				<div id="vendorSubTableDiv" style="width:90%;height:80%;margin:auto;">
					<br><br><a href="#" id="exportVendorsSubTable" class="exportTableButton">Export Table data into Excel</a><br>
				</div>
				
    		</td>
    	</tr>
    	<tr>
    		<td style="border-collapse:collapse;border:1px solid black;">
    			<br><b>Subcontractor Vendor Detail</b><br>
				<div id="vendorSubDetailTableDiv" style="width:90%;height:80%;margin:auto;"><br>Select a subcontractor from the list above...<br><br></div>
    		</td>
    	</tr>
    </table>