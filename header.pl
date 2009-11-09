$n_name = $session->param("username");
$n_pass = $session->param("pass");

$queryt = "SELECT * FROM $sitename";
$query_handlet = $connect->prepare($queryt);
$query_handlet->execute();
$query_handlet->bind_columns(\$title);

while($query_handlet->fetch()) {
}

$query_handlet->finish();

$queryl = "SELECT * FROM $links";
$query_handlel = $connect->prepare($queryl);
$query_handlel->execute();
$query_handlel->bind_columns(\$links, \$lnames, \$class);

if ($n_pass eq unix_md5_crypt('joshua', $n_pass) && $n_name eq 'Josh Ashby') {
print <<"ABC";

<html>
<head>
<link rel="stylesheet" type="text/css" href="Resources/Style.css">
<link rel="stylesheet" type="text/css" href="Resources/Header/title.css">
<meta content="text/html; charset=ISO-8859-1" http-equiv="content-type">
<title>$title</title>
<script type="text/javascript" src="Resources/mootools.js"></script>
<script type="text/javascript" src="Resources/slide.js"></script>
<script type="text/javascript" src="Resources/content.js"></script>
</head>
<body>
<table border="0" cellpadding="0" cellspacing="0" width="800px" align="center" height="120">
<tr>
<td>
<div id="wrapper">
	<div id="inner">
		<div id="content1" class="scrolling-content">
			<h1><a href="admin.pl">{Ad}min</a></h1>
			<h2>$n_name</h2>
		</div>
	</div>
</div>
</td>
</tr>
<tr>
<td>
<div id="top">
<ul class="solidblockmenu">

ABC

while($query_handlel->fetch()) {
print "<li><a href=\"$links\" class=\"$class\"><span>$lnames</span></a></li>";
}

print <<"ABC";

</ul>
</div>
<div id="content">
<p1>

ABC

} else {

print <<"ABC";

<html>
<head>
<link rel="stylesheet" type="text/css" href="Resources/Style.css">
<link rel="stylesheet" type="text/css" href="Resources/Header/title.css">
<meta content="text/html; charset=ISO-8859-1" http-equiv="content-type">
<title>$title</title>
<script type="text/javascript" src="Resources/mootools.js"></script>
<script type="text/javascript" src="Resources/slide.js"></script>
<script type="text/javascript" src="Resources/content.js"></script>
</head>
<body>
<table border="0" cellpadding="0" cellspacing="0" width="800px" align="center" height="120">
<tr>
<td>
<div id="wrapper">
	<div id="inner">
		<div id="content1" class="scrolling-content">
			<h1>Welcome Guest</h1>
		</div>
	</div>
</div>
</td>
</tr>
<tr>
<td>
<div id="top">
<ul class="solidblockmenu">

ABC

while($query_handlel->fetch()) {
print "<li><a href=\"$links\" class=\"$class\"><span>$lnames</span></a></li>";
}

print <<"ABC";

</ul>
</div>
<div id="content">
<p1>

ABC

}
$query_handlel->finish();
