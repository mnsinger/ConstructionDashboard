    <script>
    
    	projectid = "${projectid}";
    	farList = jQuery.parseJSON('${farList}');
    	
    	//console.log(projectid);
    	//console.log(farList);
    	
    	if (farList.length > 0) {
    	
	    	tableString = '<br><table id="farSpreadsheet${projectidrnd}" class="tablesorter" style="width:80%;margin:auto;"></table>';
	    	$(tableString).appendTo("#farSpreadsheetDiv${projectidrnd}");
	    	
	    	headerString = '<tr><th>Fund Number</th><th>Fund Name</th><th>Fund Source</th><th>Approved FARs</th><th>Pending FARs</th><th>Total FARs</th></tr>'
		    $("#farSpreadsheet${projectidrnd}").prepend('<thead></thead>');
		    $("#farSpreadsheet${projectidrnd}").append('<tbody></tbody>');
		    $("#farSpreadsheet${projectidrnd}").find('thead').append(headerString);
		    
		    $.each( farList, function( i, far ) {
		    	
				bodyString  = "<tr class='tableRow'>";
				bodyString += "<td class='col0'>" + far.fundnumber + "</td>";
				bodyString += "<td class='col1'>" + far.fundname + "</td>";
				bodyString += "<td class='col2'>" + far.fundsource + "</td>";
				bodyString += "<td class='col3'>$" + far.approvedfars.formatMoney(2) + "</td>";
				bodyString += "<td class='col4'>$" + far.pendingfars.formatMoney(2) + "</td>";
				bodyString += "<td class='col5'>$" + (far.approvedfars + far.pendingfars).formatMoney(2) + "</td></tr>";
				$("#farSpreadsheet${projectidrnd} tbody").append(bodyString);
						    	
		    });
	    	
		    $('<br><br>').appendTo("#farSpreadsheetDiv${projectidrnd}");
		    
		    $('#farSpreadsheet${projectidrnd}').tablesorter({
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
    		$('<p>None</p>').appendTo("#farSpreadsheetDiv${projectidrnd}");
    	}
    	
		/* ---------------- Start Bar Chart ---------------- */
		
		//var p = fundSourceMap[0].fundSourceMap;
    	var pieChartOuter = [ ['Column Label', '', { role: "style" }] ];
    	var colors = ["color:#3366cc", "color:#dc3912", "color:#ff9900", "color:#109618",  "color:#990099", "color:#b87333", "color:#c0c0c0"];
    	
    	var pieChartInfo = new Array(2);
    	pieChartInfo[0] = 'Estimated Total Project Cost (ETPC)';
    	pieChartInfo[1] = parseFloat('${etpc}');
    	pieChartInfo[2] = colors[0];
    	pieChartOuter.push(pieChartInfo);
    	
    	var pieChartInfo = new Array(2);
    	pieChartInfo[0] = 'Approved Funding Authorization Requests (FARs)';
    	pieChartInfo[1] = parseFloat('${totalApprovedFARs}');
    	pieChartInfo[2] = colors[1];
    	pieChartOuter.push(pieChartInfo);
    	
    	var pieChartInfo = new Array(2);
    	pieChartInfo[0] = 'Pending Funding Authorization Requests (FARs)';
    	pieChartInfo[1] = parseFloat('${totalPendingFARs}');
    	pieChartInfo[2] = colors[2];
    	pieChartOuter.push(pieChartInfo);
    	
    	var pieChartInfo = new Array(2);
    	pieChartInfo[0] = 'FAR Variance \n(ETPC - Approved FARs)';
    	pieChartInfo[1] = parseFloat('${etpc}') - parseFloat('${totalApprovedFARs}');
    	pieChartInfo[2] = colors[3];
    	pieChartOuter.push(pieChartInfo);
    	
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
		
		var chart = new google.visualization.ColumnChart(document.getElementById("projectColChartDiv${projectidrnd}"));
		chart.draw(view, options);
		
		/* ---------------- End Bar Chart ---------------- */

	    
    </script>
    <div style="margin:auto"><b>${projectid} - ${projectname}</b><br><br></div>
    <table style="width:95%;border-collapse:collapse;border:0px solid black;margin:auto;">
    	<tr>
    		<td style="border-collapse:collapse;border:1px solid black;">
				<br>
				<table style="width:100%;text-align:left;border:0px solid darkorange;padding:5px;">
					<tbody>
						<tr>
						    <td width="33%"><b>Project ID: </b><br><input value="${projectid}" class="input-show"></td>
							<td width="33%"><b>Project Name: <br><input value="${projectname}" class="input-show"></td>
							<td width="33%"><b>Project Address: <br><input value="${address}" class="input-show"></td>
						</tr>
						<tr>
							<td><b>Project Phase: </b><br><input value="${projectphase}" class="input-show"></td>
							<td><b>Project Location: </b><br><input value="${location}" class="input-show"></td>
							<td><b>Project Fund Source: <br><input value="${fundsource}" class="input-show"></td>
						</tr>
						<!-- tr>
						  	<td><b>Project Fund Source: </b><br><input id="MSKSeniorProjectManager${projectidrnd}"  class="input-show"></td>
							<td><b>Engineer: </b><br><input id="engineer${projectidrnd}" class="input-show"></td>
							<td><b>Cost Center: </b><br><input id="costCenter${projectidrnd}"  class="input-show"></td>
						</tr-->
						<tr>
						 	<td><b>Project Manager: </b><br><input value="${pmname}"  class="input-show"></td>
							<td><b>Project Start: </b><br><input value="${projectstart}"  class="input-show"></td>
							<td><b>Beneficial Occupancy: </b><br><input value="${beneficialocc}"  class="input-show"></td>
						</tr>
						<tr>
							<td></td> 
							<td></td>
							<td></td>
					    </tr>
					</tbody>
				</table><br>
    		</td>
    	</tr>
    	<tr>
    		<td style="border-collapse:collapse;border:1px solid black;">
				<br>
				<b style="margin:auto;">Funding Authorization Requests</b><br>
				<div id="farSpreadsheetDiv${projectidrnd}"></div>
    		
    		</td>
    	</tr>
    	<tr>
    		<td style="border-collapse:collapse;border:1px solid black;">
				<br>
				<b style="margin:auto;">Project Budget & Cost</b><br>
				<div id="projectColChartDiv${projectidrnd}"></div>
    		
    		</td>
    	</tr>
    </table>