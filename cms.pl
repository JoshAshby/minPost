$n_name = $session->param("username");
$n_pass = $session->param("pass");

if ($n_pass eq unix_md5_crypt('joshua', $n_pass)) {

if ($n_name eq 'Josh Ashby')
{
print "Welcome, $n_name!<br><br>";

print <<"ABC";

<a id="v_toggle" href="#">Post something new</a>
<div id="vertical_slide">
<form action=index.pl method=get>
<table border=0 cellpadding=0 cellspacing=0>
<tr><td>Name*:</td><td> <input type=text size=30 name=cmf_name></td></tr>
<tr><td>Title*:</td><td> <input type=text size=30 name=cmf_title></td></tr>
<tr><td>Post*:</td><td> <textarea type=text rows=3 cols=30 name=cmf_post></textarea></td></tr>
<tr><td></td><td><input type=submit border=0 value=\"Add\"></td></tr>
</table>
</form>
</div>
<br>

ABC

} 
}else{

print <<"ABC";

<a id="v_toggle" href="#">Login</a>
<div id="vertical_slide">
<form action=index.pl method=get>
<table border=0 cellpadding=0 cellspacing=0>
<tr><td>Username:</td><td> <input type=text size=20 name=l_name></td></tr>
<tr><td>Password:</td><td> <input type=text size=20 name=l_pass></td></tr>
<tr><td></td><td><input type=submit border=0 value=\"Login\"></td></tr>
</table>
</form>
</div>
<br>

ABC

}

if($cmf_name && $cmf_post && $cmf_title && $n_name eq 'Josh Ashby' && $n_pass eq unix_md5_crypt('joshua', $n_pass)) {#if you enter both a name and email
	$querycmn = "SELECT MAX(id) FROM $contentname";#connect to the db and get the max id number
	$query_handlecmn = $connect->prepare($querycmn);
	$query_handlecmn->execute();
	$query_handlecmn->bind_columns(\$cmn_id);

	while($query_handlecmn->fetch()) {#get the max id number and add 1 to it, this will be for the next data entry
		$cmf_id = $cmn_id + 1;
	}

	$query_handlecmn->finish();#finish that query

	$years = localtime->year();#this builds the time stamp for the db, in YYMMDD format
	$year = 1900 + $years;
	$day = localtime->mday();
	$months = localtime->mon();
	$month = 1 + $months;
	@cmf_date = ($year, $month, $day);
	$cmn_date = join("-", @cmf_date);

	$querycmw = "INSERT INTO $contentname VALUES ('$cmf_id', '$cmn_date', '$cmf_name', '<h4 class=\"toggler\">$cmf_title</h4><div class=\"element\">$cmf_post</div><br>')";#connect to the
	$query_handlecmw = $connect->prepare($querycmw);#db and add the new data from the form (below)
	$query_handlecmw->execute();
	$query_handlecmw->finish();

}


$querycms = "SELECT * FROM $contentname ORDER BY id desc";#re-read the data including the new data and print it out
$query_handlecms = $connect->prepare($querycms);
$query_handlecms->execute();
$query_handlecms->bind_columns(undef, \$cmsid, \$cmsdate, \$cmsname, \$cmspost);
print "<div id=\"accordion\">";
while($query_handlecms->fetch()) {
	print "$cmsdate .::. $cmsname<br> $cmspost";
if ($n_pass eq unix_md5_crypt('joshua', $n_pass)) {
if ($n_name eq 'Josh Ashby') {
print <<"ABC";

<table height="10px">
<tr>
<td>
<p1>
Post ID: $cmsid
</p1>
</td>
<td>
<form action=editpost.pl method=get>
<input type="hidden" name=id value=$cmsid>
<input type=submit border=0 value=\"Edit\">
</form>
</td>
<td>
<form action=deletepost.pl method=get>
<input type="hidden" name=id value=$cmsid>
<input type=submit border=0 value=\"Delete\">
</form>
</td>
</tr>
</table>

ABC

}}
}
print "</div>";
$query_handlecms->finish();
