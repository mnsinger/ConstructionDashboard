    <script>
    
    	pmList = jQuery.parseJSON('${pmJSONArray}');
    	
    	console.log('hi');
    	console.log(pmList);
    	
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
				bodyString += "<td class='col0'>" + pm.pmname + "</td>";
				bodyString += "<td class='col1'>" + pm.projectcount + "</td>";
				bodyString += "<td class='col2' style='text-align:right'>$" + pm.etpc.formatMoney(0) + "</td>";
				bodyString += "<td class='col3' style='text-align:right'>$" + pm.approvedfars.formatMoney(0) + "</td>";
				bodyString += "<td class='col4' style='text-align:right'>$" + pm.pendingfars.formatMoney(0) + "</td>";
				bodyString += "<td class='col5' style='text-align:right'>$" + (pm.approvedfars + pm.pendingfars).formatMoney(0) + "</td>";
				bodyString += "<td class='col6' style='text-align:right'>$" + (pm.etpc - pm.approvedfars + pm.pendingfars).formatMoney(0) + "</td></tr>";
				$("#pmTable tbody").append(bodyString);
						    	
		    });
	    	
		    $('<br><br>').appendTo("#pmTableDiv");
		    
			/* ---------------- Start Bar Chart ---------------- */
			
			//var p = fundSourceMap[0].fundSourceMap;
	    	
	    	data = google.visualization.arrayToDataTable(columnChartOuter);
			
			var view = new google.visualization.DataView(data);
			
			var options = {
			  //title: "Funding by Source",
			  //width: '100%',
			  width: "100%",
			  //height: 380,
			  //bar: {groupWidth: "95%"},
			  vAxis: {format: "short", title: "Number of Projects"},
			  legend: { position: "none" },
			};
			
			var chart = new google.visualization.ColumnChart(document.getElementById("pmColChartDiv"));
			chart.draw(view, options);
			
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
    </table>