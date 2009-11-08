$n_name = $session->param("username");
$n_pass = $session->param("pass");

if ($n_pass eq unix_md5_crypt('joshua', $n_pass) && $n_name eq 'Josh Ashby') {
print "Welcome, $n_name!<br><br>";

print <<"ABC";

<a id="v_toggle" href="#">Post something new</a>
<div id="vertical_slide">
<form action=index.pl method=get>
<table border=0 cellpadding=0 cellspacing=0>
<tr><td>Name*:</td><td> <input type=text size=30 name=cmf_name></td></tr>
<tr><td>Title*:</td><td> <input type=text size=30 name=cmf_title></td></tr>
<tr><td>Post*:</td><td>
<script type="text/javascript" src="tiny_mce/tiny_mce.js"></script>
<script type="text/javascript">
var tinymceConfigs = [ {theme : "advanced",
        mode : "none",
        language : "en",
        height:"200",
        width:"100%",
        theme_advanced_layout_manager : "SimpleLayout",
        theme_advanced_toolbar_location : "top",
        theme_advanced_toolbar_align : "left",
        theme_advanced_buttons1 : "code",
        theme_advanced_buttons2 : "",
        theme_advanced_buttons3 : "" },{ theme : "advanced",
        mode : "none",
        language : "en",
        height:"200",
        width:"100%",
        theme_advanced_layout_manager : "SimpleLayout",
        theme_advanced_toolbar_location : "top",
        theme_advanced_toolbar_align : "left"}];

function tinyfy(settingid,el_id) {
    tinyMCE.settings = tinymceConfigs[settingid];
    tinyMCE.execCommand('mceAddControl', true, el_id);
}
</script>
<script type="text/javascript">
tinyfy(0,'ed1')
</script>
<textarea name=cmf_post id="ed1"></textarea></td></tr>
<tr><td></td><td><input type=submit border=0 value=\"Add\"></td></tr>
</table>
</form>
</div>
<br>

ABC

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

if($cmf_name && $cmf_post && $cmf_title && $n_name eq 'Josh Ashby' && $n_pass eq unix_md5_crypt('joshua', $n_pass)) {
	$querycmn = "SELECT MAX(id) FROM $contentname";
	$query_handlecmn = $connect->prepare($querycmn);
	$query_handlecmn->execute();
	$query_handlecmn->bind_columns(\$cmn_id);

	while($query_handlecmn->fetch()) {
		$cmf_id = $cmn_id + 1;
	}

	$query_handlecmn->finish();

	$years = localtime->year();
	$year = 1900 + $years;
	$day = localtime->mday();
	$months = localtime->mon();
	$month = 1 + $months;
	@cmf_date = ($year, $month, $day);
	$cmn_date = join("-", @cmf_date);

	$querycmw = "INSERT INTO $contentname VALUES ('$cmf_id', '$cmn_date', '$cmf_title', '$cmf_name', '$cmf_post')";
	$query_handlecmw = $connect->prepare($querycmw);
	$query_handlecmw->execute();
	$query_handlecmw->finish();

}


$querycms = "SELECT * FROM $contentname ORDER BY id desc";
$query_handlecms = $connect->prepare($querycms);
$query_handlecms->execute();
$query_handlecms->bind_columns(undef, \$cmsid, \$cmsdate, \$cmstitle, \$cmsname, \$cmspost);

print "<div id=\"accordion\">";

while($query_handlecms->fetch()) {

print <<"ABC"; 

$cmsdate .::. $cmsname<br>
<h4 class=\"toggler\">$cmstitle</h4>
<div class=\"element\">$cmspost<br>
<table>
<tr>
<td>

ABC

if ($n_pass eq unix_md5_crypt('joshua', $n_pass) && $n_name eq 'Josh Ashby') {

print <<"ABC";

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
<td>

ABC

}

print <<"ABC";

<form action=single.pl method=get>
<input type="hidden" name=postid value=$cmsid>
<input type=submit border=0 value=\"View Post\">
</form>
</td> 
</tr>
</table>
</div>

ABC

}

print "</div>";

$query_handlecms->finish();
