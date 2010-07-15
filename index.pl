#!/usr/bin/perl

use warnings;
use strict;

use CGI;
use DBI;
use DBD::mysql;

#setup stuff for the forms
my $form=new CGI;
my $title=CGI::escapeHTML($form->param("title"));
my $align=CGI::escapeHTML($form->param("align"));
my $photo=CGI::escapeHTML($form->param("photo"));

#setup all the data for the database, this bit will eventually be replaced by minPost's setting package when merged
my $platform = "mysql";
my $database = "perl";
my $host = "localhost";
my $port = "3306";
my $tablename = "pl_site";
my $user = "root";
my $pw = "speeddyy5";
my $dsn = "dbi:$platform:$database:$host:$port";
my $connect = DBI->connect($dsn, $user, $pw) or die "Couldn't connect to database!" . DBI->errstr;

#update the title and alignment SQL query
my $sth = $connect->prepare_cached(<<"SQL");
UPDATE pl_site
SET title = ?, align = ?, photo = ?
WHERE id = '0'
SQL

#if there is a new title thats been typed in, enter it into the database along with the alignment
if ($title){
$sth->execute($title, $align, $photo);
}

my  $cm_id, $cm_title, $cm_align, $cm_photo

#get the title and alignment to use for the page
my $query_handle = $connect->prepare_cached("SELECT * FROM $tablename ORDER BY id desc");
$query_handle->execute();
$query_handle->bind_columns(undef, $cm_id, $cm_title, $cm_align, $cm_photo);

print "Content-Type: text/html\n\n";

#then place the info in the page
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
<div class="header" align="$cm_align" style="background:url($cm_photo);">
<h1 class="fancy_head">$cm_title</h1>
<pre>$title $align</pre>
</div>
abc
}

print<<"abc";
<div id="hide">
<form action=index.pl method=post>
<table border=0 cellpadding=0 cellspacing=0>
<tr><td>Title:</td><td> <input type=text size=20 name=title></td></tr>
<tr><td>Align:</td><td> <select name=align>
 <option value="left">Left</option>
 <option value="center">Center</option>
 <option value="right">Right</option>
</select></td></tr>
<tr><td>Photo:</td><td><select name=photo>
abc

my @files = <images/headers/*>;
foreach my $file (@files) {
print <<"ABC";
 <option value="$file">$file</option>
ABC
}

print<<"abc";
</td></tr>
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
