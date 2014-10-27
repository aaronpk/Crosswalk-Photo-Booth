<html>
<head>
<style type="text/css">
body {
	margin: 0;
	width: 0;
}
img {
	width: 1366px;
	top: -100px;
	position: absolute;
}
</style>
<script src="jquery.js"></script>
<script>
function reload() {
  $.getJSON("/file.php", function(data){
  	$("#container img").attr("src", data.filename);
  	setTimeout(reload, 3000);
  });
}

$(function(){

  reload();

});
</script>
</head>
<body>

<div id="container">
	<img src="/photos/DSC_0006.JPG">
</div>

</body>
</html>