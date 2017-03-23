    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
    <script>
    
    	projectid = "${projectid}";
    	farList = jQuery.parseJSON('${farList}');
    	
    	console.log(projectid);
    	console.log(farList);
    	
    	headerString = '<tr><th>Fund Number</th><th>Fund Name</th><th>Fund Source</th><th>Approved FARs</th><th>Pending FARs</th><th>Total FARs</th></tr>'
	    $("#farSpreadsheet").prepend('<thead></thead>');
	    $("#farSpreadsheet").append('<tbody></tbody>');
	    $("#farSpreadsheet").find('thead').append(headerString);
	    
	    $.each( farList, function( i, far ) { 
	    	
			bodyString  = "<tr class='tableRow'>";
			bodyString += "<td class='col0'>" + far.fundnumber + "</td>";
			bodyString += "<td class='col1'>" + far.fundname + "</td>";
			bodyString += "<td class='col2'>" + far.fundsource + "</td>";
			bodyString += "<td class='col3'>" + far.approvedfars + "</td>";
			bodyString += "<td class='col4'>" + far.pendingfars + "</td>";
			bodyString += "<td class='col5'>" + (far.approvedfars + far.pendingfars) + "</td>";
			$("#farSpreadsheet tbody").append(bodyString);
	    	
	    });
    	
	    $('#farSpreadsheet').tablesorter({
	        theme: 'blue',
	        showProcessing: true,
	        headerTemplate: '{content} {icon}',
	        widgets: ['zebra'],
	        widgetOptions: {
	            filter_useParsedData: true
	        }
	        
	    });

    	
    </script>
    <div style="margin:auto"><b>${projectid} - ${projectname}</b></div>
    <table style="width:100%;border-collapse:collapse;border:0px solid black;">
    	<tr>
    		<td style="border-collapse:collapse;border:1px solid black;">
				<br>
				<table style="width:100%;text-align:left;border:0px solid darkorange;">
					<tbody>
						<tr>
						    <td width="33%">Project Phase:          <br><input id="projectPhase" class="input-show"></td>
							<td width="33%">Facilities Department:  <br><input id="facilitiesDepartment" class="input-show"></td>
							<td width="33%">Building:               <br><input id="building" class="input-show"></td>
						</tr>
						<tr>
							<td>Construction Type:  <br><input id="constructionType" class="input-show"></td>
							<td>Director:           <br><input id="MSKDirector" role="textbox" class="input-show"></td>
							<td>Architect:          <br><input id="architect" role="textbox"  class="input-show"></td>                                             
						</tr>
						 <tr>
						  	<td>Senior Project Manager:  <br><input id="MSKSeniorProjectManager"  class="input-show"></td>
							<td>Engineer:                <br><input id="engineer" class="input-show"></td>
							<td>Cost Center:             <br><input id="costCenter"  class="input-show"></td>
						</tr>
						<tr>
						 	<td>Project Manager:          <br><input id="MSKProjectManager"  class="input-show"></td>
							<td>Construction Manager:     <br><input id="constructionManager"  class="input-show"></td>
							<td>Cost Center Description:  <br><input id="costCenterDescription"  class="input-show"></td>
						</tr>
						<tr>
							<td></td> 
							<td></td>
							<td></td>
					    </tr>
					</tbody>
				</table>    		
    		</td>
    	</tr>
    	<tr>
    		<td style="border-collapse:collapse;border:1px solid black;margin:auto;">
				<br>
				<div id="spreadsheet"></div>
				<table id="farSpreadsheet" class="tablesorter" style="width:80%">
					
				</table><br>
    		
    		</td>
    	</tr>
    </table>