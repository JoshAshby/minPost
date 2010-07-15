#!/usr/bin/perl

use CGI;
use DBI;
use DBD::mysql;

$form=new CGI;
$title=CGI::escapeHTML($form->param("title"));
$align=CGI::escapeHTML($form->param("align"));

$id = 0;

$platform = "mysql";
$database = "perl";
$host = "localhost";
$port = "3306";
$tablename = "pl_site";
$user = "root";
$pw = "speeddyy5";
$dsn = "dbi:$platform:$database:$host:$port";
$connect = DBI->connect($dsn, $user, $pw) or die "Couldn't connect to database!" . DBI->errstr;

$query = "SELECT * FROM $tablename ORDER BY id desc";
   $query_handle = $connect->prepare($query);
   $query_handle->execute();
   $query_handle->bind_columns(undef, \$cm_id, \$cm_title, \$cm_align);

print "Content-Type: text/html\n\n";

while($query_handle->fetch()) {
print<<"abc";
<html>
<head>
<link rel="stylesheet" href="css/screen.css" type="text/css" media="screen, projection" />
<script src="js/jquery.js" type="text/javascript"></script>
<title>$cm_title</title>
</head>
<body>
<div class="container">
<div class="header" align="$cm_align">
<h1 class="fancy">$cm_title</h1>
</div>
<div id="hide">
<form action=index.pl method=post>
<table border=0 cellpadding=0 cellspacing=0>
<tr><td>Title:</td><td> <input type=text size=20 name=title></td></tr>
<tr><td>Align:</td><td> <select name=align>
 <option selected="selected" value="left">Left</option>
 <option value="center">Center</option>
 <option value="right">Right</option>
</select></td></tr>
<tr><td></td><td><input type=submit border=0 value=\"Submit\"></td></tr>
</table>
</form>
</div>
<input type=button id="hide-button" value=\"Edit\">
</div>
<script type="text/javascript">
\$("#hide").slideToggle("slow");
\$("#hide-button").click(function () {
      \$("#hide").slideToggle("slow");
    });
</script>
</body>
</html>
abc
};
$query_handle->finish();

$queryc = "INSERT INTO $tablename VALUES ('$id', '$title', '$align')";
	$query_handlec = $connect->prepare($queryc);
	$query_handlec->execute();
	$query_handlec->finish();

$connect->disconnect();
