<html>
<head>
<title>WELCOME PAGE</title>
<style type="text/css">
body {
	background-image: url('http://crunchify.com/bg.png');
}
</style>
<script>

function createCSLF(){
	 $("head").append('<meta name="_csrf" content="${_csrf.token}"/>');
	 $("head").append('<meta name="_csrf_header" content="${_csrf.headerName}"/>');
	   
	   
	 var token = $("meta[name='_csrf']").attr("content");
	 var header = $("meta[name='_csrf_header']").attr("content");
	 $(document).ajaxSend(function(e, xhr, options) {
	    xhr.setRequestHeader(header, token);
	 }); 
	 
}

$(document).ready(function () {
	
	createCSLF();
	
});

</script>
</head>
<body>${message}
 
	<br>
	<br>
	<div style="font-family: verdana; padding: 10px; border-radius: 10px; font-size: 12px; text-align:center;">
 
		Spring MCV Tutorial by <a href="http://crunchify.com">Crunchify</a>.
		Click <a
			href="http://crunchify.com/category/java-web-development-tutorial/"
			target="_blank">here</a> for all Java and <a
			href='http://crunchify.com/category/spring-mvc/' target='_blank'>here</a>
		for all Spring MVC, Web Development examples.<br>
	</div>
</body>
</html>
