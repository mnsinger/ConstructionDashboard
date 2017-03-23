    <script>
    
		pmList = jQuery.parseJSON('${pmJSONArray}');
		pmName = '${pmName}';
		
    	console.log("pmName: " + pmName);
    	console.log("pmList: " + pmList);
    	
    	if (pmList.length > 0) {
    	
	    	tableString = '<br><table id="pmTable" class="tablesorter" style="width:80%;margin:auto;"></table>';
	    	$(tableString).prependTo("#pmTableDiv");
	    	
		  	//This must be a hyperlink
		    $("#exportPmSpreadsheet").on('click', function (event) {
		    	
		        exportTableToExcel.apply(this, ['#pmTable', 'ProjectManagerSummarySpreadsheet.xls']);
		        
		        // IF CSV, don't do event.preventDefault() or return false
		        // We actually need this to be a typical hyperlink
		    });
	    	
	    	headerString = '<tr><th>Project Manager</th><th>Number of Projects</th><th>ETPC</th><th>Approved FARs</th><th>Pending FARs</th><th>Total FARs</th><th>FAR Variance</th></tr>'
		    $("#pmTable").prepend('<thead></thead>');
		    $("#pmTable").append('<tbody></tbody>');
		    $("#pmTable").find('thead').append(headerString);
		    
	    	var columnChartOuter = [ ['Column Label', 'Value', { role: "style" }, { role: 'annotation' }] ];
	    	var colors = ["color:#3366cc", "color:#dc3912", "color:#ff9900", "color:#109618",  "color:#990099", "color:#b87333", "color:#c0c0c0"];
	    	
		    $.each( pmList, function( i, pm ) {
		    	
		    	var columnChartInfo = new Array(2);
		    	columnChartInfo[0] = pm.pmname;
		    	columnChartInfo[1] = pm.projectcount;
		    	columnChartInfo[2] = colors[i];
		    	columnChartInfo[3] = pm.projectcount;
		    	columnChartOuter.push(columnChartInfo);

		    	
				bodyString  = "<tr class='tableRow'>";
				bodyString += "<td class='col0 pmName' id='" + pm.pmid + "'>" + pm.pmname + "</td>";
				bodyString += "<td class='col1'>" + pm.projectcount + "</td>";
				bodyString += "<td class='col2' style='text-align:right'>$" + pm.etpc.formatMoney(0) + "</td>";
				bodyString += "<td class='col3' style='text-align:right'>$" + pm.approvedfars.formatMoney(0) + "</td>";
				bodyString += "<td class='col4' style='text-align:right'>$" + pm.pendingfars.formatMoney(0) + "</td>";
				bodyString += "<td class='col5' style='text-align:right'>$" + (pm.approvedfars + pm.pendingfars).formatMoney(0) + "</td>";
				bodyString += "<td class='col6' style='text-align:right'>$" + (pm.etpc - pm.approvedfars + pm.pendingfars).formatMoney(0) + "</td></tr>";
				$("#pmTable tbody").append(bodyString);
						    	
		    });
	    	
		    $('<br><br>').appendTo("#pmTableDiv");
		    
		    $( document ).on( "click", ".pmName", function() {
		    	console.log( $(this) );
				//console.log( $(this)[0].nextSibling.innerText );
				//console.log( $(this)[0].innerText );
				var vendorName = $(this)[0].innerText;
		    	var vendorid = $(this)[0].nextSibling.innerText;
		    	var pmid = $(this)[0].id;
		  		$.ajax({
					url:   'getPmDetail',
							contentType: "application/json; charset=utf-8",
							data:{  username: "${loggedInUser}", pmid: pmid },
							success: function (pmData) {
								console.log("SUCCESS: " + pmData);
								
								projectList = jQuery.parseJSON(pmData);
								
								$( "#pmDetailName" ).html( "<br><i>" + vendorName + "</i>" );
								
								// if detail table does not exist
								if ($('#pmDetailTable').length == 0) { 
									
							    	tableString = '<br><table id="pmDetailTable" class="tablesorter" style="width:90%;margin:auto;"></table>';
							    	$("#pmDetailTableDiv").empty();
							    	$(tableString).appendTo("#pmDetailTableDiv");
							    	
									headerString = "<tr><th data-placeholder='Filter on Project ID...'>Project ID</th><th data-placeholder='Filter on Project Name...'>Project Name</th><th>Project Manager</th><th data-placeholder='Filter on Fund Source...'>Fund Source</th><th data-placeholder='Filter on Project Phase...'>Project Phase</th><th data-placeholder='Filter on Location...'>Location</th><th>Total FARs</th><th>ETPC</th><th>Project Start</th><th>Beneficial Occupancy</th></tr>";
								    $("#pmDetailTable").prepend('<thead></thead>');
								    $("#pmDetailTable").append('<tbody></tbody>');
								    $("#pmDetailTable").find('thead').append(headerString);

								    $.each( projectList, function( i, project ) {
								    	
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
										bodyString += "<td class='col8'>" + project.beneficialocc + "</td></tr>";
										$("#pmDetailTable tbody").append(bodyString);
												    	
								    });
								    
								    $("<br><br><a href='#' id='exportPmDetailTable' class='exportTableButton'>Export Table data into Excel</a><br><br><br>").appendTo("#pmDetailTableDiv");

								  	//This must be a hyperlink
								    $("#exportPmDetailTable").on('click', function (event) {
								    	
								        exportTableToExcel.apply(this, ['#pmDetailTable', 'pmDetailSpreadsheet.xls']);
								        
								        // IF CSV, don't do event.preventDefault() or return false
								        // We actually need this to be a typical hyperlink
								    });
							    	
								    $('#pmDetailTable').tablesorter({
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
									
									$("#pmDetailTable > tbody").html("");
									
								    $.each( projectList, function( i, project ) {
								    	
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
										bodyString += "<td class='col8'>" + project.beneficialocc + "</td></tr>";
										$("#pmDetailTable tbody").append(bodyString);
										$("#pmDetailTable").trigger('update'); 
										
								    });

								}
							}
				});

		    	  
		    });
		    	
		    $('<br><br>').appendTo("#vendorsPrimeTableDiv");
		    
			/* ---------------- Start Bar Chart ---------------- */
			
			//var p = fundSourceMap[0].fundSourceMap;
	    	
	    	pMdata = google.visualization.arrayToDataTable(columnChartOuter);
			
			var pMview = new google.visualization.DataView(pMdata);
			
			var pMoptions = {
			  //title: "Funding by Source",
			  //width: '100%',
			  width: "100%",
			  //height: 380,
			  //bar: {groupWidth: "95%"},
			  vAxis: {format: "short", title: "Number of Projects"},
			  legend: { position: "none" },
			};
			
			var pMchart = new google.visualization.ColumnChart(document.getElementById("pmColChartDiv"));
	        function pMselectHandler() {
		          var selectedItem = pMchart.getSelection()[0];
		          if (selectedItem) {
		            var selectedValue = pMdata.getValue(selectedItem.row, 0);
		            // filter td elements in table to equal the Vendor Name and trigger a click on that element
		            $('.pmName').filter(function(){
		            	  return $(this)[0].innerText === selectedValue;
		            	}).each(function(){
		            	  $(this).trigger( 'click' );
		            	});
		          }
			    }
					
			// Listen for the 'select' event, and call my function selectHandler() when
			// the user selects something on the chart.
			google.visualization.events.addListener(pMchart, 'select', pMselectHandler);
			pMchart.draw(pMview, pMoptions);
			
			/* ---------------- End Bar Chart ---------------- */

		    
		    $('#pmTable').tablesorter({
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
    		console.log("No FARs");
    		$('<p>None</p>').appendTo("#pmTableDiv");
    	}
    	
    	// if page is loader by clicking on PM's Name
    	// then load the page with the PM info showing
    	if (pmName.length > 0) {
			$('.pmName').filter(function(){
				  return $(this)[0].innerText === pmName;
				}).each(function(){
				  $(this).trigger( 'click' );
				});
    	}

	    
    </script>
    <table style="width:95%;border-collapse:collapse;border:0px solid black;margin:auto;">
    	<tr>
    		<td style="border-collapse:collapse;border:1px solid black;">
				<br><b>Project Managers</b><br><br><div id="pmColChartDiv" style="width:90%;height:80%;margin:auto;"></div>
    		</td>
    	</tr>
    	<tr>
    		<td style="border-collapse:collapse;border:1px solid black;">
				<br><b>List of All Project Managers</b><br>
				
				<div id="pmTableDiv" style="width:90%;height:80%;margin:auto;">
					<br><br><a href="#" id="exportPmSpreadsheet" class="exportTableButton">Export Table data into Excel</a><br>
				</div>
    		</td>
    	</tr>
    	<tr>
    		<td style="border-collapse:collapse;border:1px solid black;">
    			<br><b>Project Manager Detail</b><div id='pmDetailName'></div>
				<div id="pmDetailTableDiv" style="width:90%;height:80%;margin:auto;"><br>Select a project manager from the list above...<br><br></div>
    		</td>
    	</tr>
    </table>