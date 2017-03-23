    <script>
    
    	vendorsList = jQuery.parseJSON('${vendorsJSONArray}');
    	
    	if (vendorsList.length > 0) {
    	
	    	tableString = '<br><table id="vendorsTable" class="tablesorter" style="width:80%;margin:auto;"></table>';
	    	$(tableString).prependTo("#vendorsPrimeTableDiv");
	    	
		  	//This must be a hyperlink
		    $("#exportVendorsPrimeTable").on('click', function (event) {
		    	
		        exportTableToExcel.apply(this, ['#vendorsTable', 'VendorsPrimeListSpreadsheet.xls']);
		        
		        // IF CSV, don't do event.preventDefault() or return false
		        // We actually need this to be a typical hyperlink
		    });
	    	
	    	headerString = '<tr><th>Vendor Name</th><th>Vendor Number</th><th>Number of Projects</th><th>Contract Sum</th></tr>'
		    $("#vendorsTable").prepend('<thead></thead>');
		    $("#vendorsTable").append('<tbody></tbody>');
		    $("#vendorsTable").find('thead').append(headerString);
		    
	    	var columnChartOuter = [ ['Column Label', 'Value', { role: "style" }, { role: 'annotation' }] ];
	    	var colors = ["color:#3366cc", "color:#dc3912", "color:#ff9900", "color:#109618",  "color:#990099", "color:#b87333", "color:#c0c0c0"];
	    	
		    $.each( vendorsList, function( i, vendor ) {
		    	
		    	var columnChartInfo = new Array(2);
		    	columnChartInfo[0] = vendor.vendorname;
		    	columnChartInfo[1] = vendor.projectcount;
		    	columnChartInfo[2] = colors[i];
		    	columnChartInfo[3] = vendor.projectcount;
		    	columnChartOuter.push(columnChartInfo);

		    	
				bodyString  = "<tr class='tableRow'>";
				bodyString += "<td class='vendorName'>" + vendor.vendorname + "</td>";
				bodyString += "<td class='col1'>" + vendor.vendorid + "</td>";
				bodyString += "<td class='col2' style='text-align:right'>" + vendor.projectcount + "</td>";
				bodyString += "<td class='col3' style='text-align:right'>$" + vendor.contractamount.formatMoney(0) + "</td></tr>";
				$("#vendorsTable tbody").append(bodyString);
						    	
		    });
		    
		    $( document ).on( "click", ".vendorName", function() {
		    	//console.log( $(this) );
				//console.log( $(this)[0].nextSibling.innerText );
				//console.log( $(this)[0].innerText );
				var vendorName = $(this)[0].innerText;
		    	var vendorid = $(this)[0].nextSibling.innerText;
		  		$.ajax({
					url:   'getVendorPrimeDetail',
							contentType: "application/json; charset=utf-8",
							data:{  username: "${loggedInUser}", vendorid: vendorid },
							success: function (data) {
								//console.log(data);
								
								projectList = jQuery.parseJSON(data);
								
								$( "#primeVendorDetailName" ).html( "<br><i>" + vendorName + "</i>" );
								
								// if detail table does not exist
								if ($('#vendorPrimeDetailTable').length == 0) { 
									
							    	tableString = '<br><table id="vendorPrimeDetailTable" class="tablesorter" style="width:80%;margin:auto;"></table>';
							    	$("#vendorPrimeDetailTableDiv").empty();
							    	$(tableString).appendTo("#vendorPrimeDetailTableDiv");
							    	
							    	headerString = '<tr><th>Project Number</th><th>Project Name</th><th>Contracts</th><th>Amendments</th><th>Change Orders</th><th>Total</th><th>Invoices</th></tr>'
								    $("#vendorPrimeDetailTable").prepend('<thead></thead>');
								    $("#vendorPrimeDetailTable").append('<tbody></tbody>');
								    $("#vendorPrimeDetailTable").find('thead').append(headerString);

								    $.each( projectList, function( i, project ) {
								    	
										bodyString  = "<tr class='tableRow'>";
										bodyString += "<td class='col0' onClick=\"javascript:addTab1('" + project.projectid + "', 'building-hedge.png');\">" + project.projectid + "</td>";
										bodyString += "<td class='col1'>" + project.projectname + "</td>";
										bodyString += "<td class='col2' style='text-align:right'>$" + project.contractamount.formatMoney(2) + "</td>";
										bodyString += "<td class='col3' style='text-align:right'>$" + project.amendmentamount.formatMoney(2) + "</td>";
										bodyString += "<td class='col4' style='text-align:right'>$" + project.changeorderamount.formatMoney(2) + "</td>";
										bodyString += "<td class='col5' style='text-align:right'>$" + (project.contractamount + project.amendmentamount + project.changeorderamount).formatMoney(2) + "</td>";
										bodyString += "<td class='col6' style='text-align:right'>$" + project.invoiceamount.formatMoney(2) + "</td></tr>";
										$("#vendorPrimeDetailTable tbody").append(bodyString);
												    	
								    });
								    
								    $("<br><br><a href='#' id='exportVendorPrimeDetailTable' class='exportTableButton'>Export Table data into Excel</a><br><br><br>").appendTo("#vendorPrimeDetailTableDiv");

								  	//This must be a hyperlink
								    $("#exportVendorPrimeDetailTable").on('click', function (event) {
								    	
								        exportTableToExcel.apply(this, ['#vendorPrimeDetailTable', 'VendorPrimeDetailSpreadsheet.xls']);
								        
								        // IF CSV, don't do event.preventDefault() or return false
								        // We actually need this to be a typical hyperlink
								    });
							    	
								    $('#vendorPrimeDetailTable').tablesorter({
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
									
									$("#vendorPrimeDetailTable > tbody").html("");
									
								    $.each( projectList, function( i, project ) {
								    	
										bodyString  = "<tr class='tableRow'>";
										bodyString += "<td class='col0' onClick=\"javascript:addTab1('" + project.projectid + "', 'building-hedge.png');\">" + project.projectid + "</td>";
										bodyString += "<td class='col1'>" + project.projectname + "</td>";
										bodyString += "<td class='col2' style='text-align:right'>$" + project.contractamount.formatMoney(2) + "</td>";
										bodyString += "<td class='col3' style='text-align:right'>$" + project.amendmentamount.formatMoney(2) + "</td>";
										bodyString += "<td class='col4' style='text-align:right'>$" + project.changeorderamount.formatMoney(2) + "</td>";
										bodyString += "<td class='col5' style='text-align:right'>$" + (project.contractamount + project.amendmentamount + project.changeorderamount).formatMoney(2) + "</td>";
										bodyString += "<td class='col6' style='text-align:right'>$" + project.invoiceamount.formatMoney(2) + "</td></tr>";
										$("#vendorPrimeDetailTable tbody").append(bodyString);
										$("#vendorPrimeDetailTable").trigger('update'); 
										
								    });

								}
							}
				});

		    	  
		    });
		    	
		    $('<br><br>').appendTo("#vendorsPrimeTableDiv");
		    
			/* ---------------- Start Bar Chart ---------------- */
			
			//var p = fundSourceMap[0].fundSourceMap;
	    	
	    	vPdata = google.visualization.arrayToDataTable(columnChartOuter);
			
			var vPview = new google.visualization.DataView(vPdata);
			
			var vPoptions = {
			  //title: "Funding by Source",
			  //width: '100%',
			  width: "100%",
			  //height: 380,
			  //bar: {groupWidth: "95%"},
			  vAxis: {format: "short", title: "Number of Projects"},
			  legend: { position: "none" },
			};
			
			var vPchart = new google.visualization.ColumnChart(document.getElementById("vendorsColChartDiv"));
	        function vPselectHandler() {
	          var selectedItem = vPchart.getSelection()[0];
	          if (selectedItem) {
	            var selectedValue = vPdata.getValue(selectedItem.row, 0);
	            // filter td elements in table to equal the Vendor Name and trigger a click on that element
	            $('.vendorName').filter(function(){
	            	  return $(this)[0].innerText === selectedValue;
	            	}).each(function(){
	            	  $(this).trigger( 'click' );
	            	});
	          }
		    }
				
				// Listen for the 'select' event, and call my function selectHandler() when
				// the user selects something on the chart.
			google.visualization.events.addListener(vPchart, 'select', vPselectHandler);
			vPchart.draw(vPview, vPoptions);
			
			/* ---------------- End Bar Chart ---------------- */

		    
		    $('#vendorsTable').tablesorter({
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
    		//console.log("No Vendors");
    		$('<p>None</p>').appendTo("#vendorsPrimeTableDiv");
    	}
	    
    </script>
    <table style="width:95%;border-collapse:collapse;border:0px solid black;margin:auto;">
    	<tr>
    		<td style="border-collapse:collapse;border:1px solid black;">
				<br><b>Prime Vendors</b><br><br><div id="vendorsColChartDiv" style="width:90%;height:80%;margin:auto;"></div>
    		</td>
    	</tr>
    	<tr>
    		<td style="border-collapse:collapse;border:1px solid black;">
    			<br><b>List of All Prime Vendors</b><br>
				<div id="vendorsPrimeTableDiv" style="width:90%;height:80%;margin:auto;">
					<br><br><a href="#" id="exportVendorsPrimeTable" class="exportTableButton">Export Table data into Excel</a><br>
				</div>
				
    		</td>
    	</tr>
    	<tr>
    		<td style="border-collapse:collapse;border:1px solid black;">
    			<br><b>Prime Vendor Detail</b><div id='primeVendorDetailName'></div>
				<div id="vendorPrimeDetailTableDiv" style="width:90%;height:80%;margin:auto;"><br>Select a vendor from the list above...<br><br></div>
    		</td>
    	</tr>
    </table>