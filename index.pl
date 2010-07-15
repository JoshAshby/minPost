#!/usr/bin/perl

use CGI;

$form=new CGI;
$title=CGI::escapeHTML($form->param("title"));
$align=CGI::escapeHTML($form->param("align"));
$edit=CGI::escapeHTML($form->param("edit"));

print "Content-Type: text/html\n\n";

print<<"abc";
<html>
<head>
<link rel="stylesheet" href="css/screen.css" type="text/css" media="screen, projection" />
<title>$title</title>
</head>
<body>
<div class="container">
<div class="span-24_$align">
<h1 class="fancy">$title</h1>
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
</div>
</body>
</html>
abc
