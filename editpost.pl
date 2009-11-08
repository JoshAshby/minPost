#!/usr/bin/perl
################################################
#minPost 0.01 BETA
#minPost is a simple to use (not setup :P)
#minimal CMS. It has a few things in the header.pl
#and this file (iindex.pl) along with the MySQL
#database settings in settings.pl that need
#changed to fit your site. The README has the
#info on the MySQL tables needed.
#
#TODO:
#1)add better comments (done)
#2)get a more universal theme setup
#3)make a way to change the theme
#4)have the title and other info for the site fetched from the database
#5)make a setup script that takes care of the database and settings
#6)clean everything up a bit
#7)make it resistant to code injection
#8)some other things i can't think of right now
#
#Copywrite 2009 by Joshua Ashby
#joshuaashby at joshashby dot com
#joshuaashby@joshashby.com
#http://joshashby.com
#http://github.com/JoshAshby
#licensed under the Creative Commons Non-Commercial License.
#http://creativecommons.org/licenses/by-nc/3.0/us/
################################################
BEGIN {
    my $homedir = ( getpwuid($>) )[7];
    my @user_include;
    foreach my $path (@INC) {
        if ( -d $homedir . '/perl' . $path ) {
            push @user_include, $homedir . '/perl' . $path;
        }
    }
    unshift @INC, @user_include;
}
use DBI;
use DBD::mysql;
use Time::localtime;
use CGI::Session;
use CGI;
use Crypt::PasswdMD5 qw(unix_md5_crypt);

$form=new CGI;
$cmf_post=CGI::escapeHTML($form->param("cmf_post"));
$cmf_name=CGI::escapeHTML($form->param("cmf_name"));
$cmf_title=CGI::escapeHTML($form->param("cmf_title"));
$id=CGI::escapeHTML($form->param("id"));

$session = CGI::Session->load() or die CGI::Session->errstr();

if ($l_name && $l_pass)
{
$session->param('username', $l_name);
my @salt = ( '.', '/', 0 .. 9, 'A' .. 'Z', 'a' .. 'z' );
my $crypthash = unix_md5_crypt($l_pass, gensalt(8));
$session->param('pass', $crypthash);
sub gensalt {
  my $count = shift;
  my $salt;
  for (1..$count) {
    $salt .= (@salt)[rand @salt];
  }
  return $salt;
}
}

if ($session->is_expired)
{
    print $session->header();
    print <<"ABC";

<html>
<head>
</head>
<body>

ABC

    print "Your session timed out! Refresh the screen to start new session!";

    print <<"ABC";

</body>
</html>

ABC
    exit(0);
}

if ($session->is_empty)
{
    $session = $session->new() or die $session->errstr;
}

print $session->header();

do 'settings.pl';

$connect = DBI->connect($dsn, $user, $pw) or die "Couldn't connect to database!" . DBI->errstr;

do 'header.pl';

$n_name = $session->param("username");
$n_pass = $session->param("pass");

if ($n_pass eq unix_md5_crypt('joshua', $n_pass) && $n_name eq 'Josh Ashby') {
if ($id) {

$query = "SELECT $id, title, post  FROM $contentname WHERE id";
$query_handle = $connect->prepare($query);
$query_handle->execute();
$query_handle->bind_columns(\$did, \$dtitle, \$dpost);

print "Welcome, $n_name!<br><br>";

while($query_handle->fetch()) {
}
if ($did eq $id) {

print <<"ABC";

<a href="index.pl">Return to Home</a>
<form action=editpost.pl method=get>
<table width="100%" border=0 cellpadding=0 cellspacing=0>
<tr><td></td><td><input type="hidden" name=id value=$id></td></tr>
<tr><td>Name:</td><td> <input type=text size=30 name=cmf_name></td></tr>
<tr><td>Title:</td><td> <input type=text size=30 name=cmf_title></td></tr>
<tr><td>Post:</td><td>
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
        theme_advanced_toolbar_align : "left"},{
	cleanup_on_startup : false,
	trim_span_elements : false,
	verify_html : false,
	cleanup : false,
	convert_urls : false,
	nowrap : true,
	remove_linebreaks : false,
	convert_fonts_to_spans : false,
	fix_content_duplication: false}];



function tinyfy(settingid,el_id) {
    tinyMCE.settings = tinymceConfigs[settingid];
    tinyMCE.execCommand('mceAddControl', true, el_id);
}
</script>
<script type="text/javascript">
tinyfy(0,'ed1')
</script>
<textarea name=cmf_post id="ed1" style="width:100%">$dpost</textarea>
</td></tr>
<tr><td></td><td><input type=submit border=0 value=\"Update\"></td></tr>
</table>
</form>
<br>

ABC

}

if($cmf_post) {
	$querycmw = "UPDATE $contentname SET name=\"$cmf_name\", title=\"$cmf_title\", post=\"$cmf_post\" WHERE id=$id";
	$query_handlecmw = $connect->prepare($querycmw);
	$query_handlecmw->execute();
	$query_handlecmw->finish();
print <<"ABC";

Post Updated!
<a href="index.pl">Return to the main page</a>

ABC

}
$query_handle->finish();
$connect->disconnect();
}
} else {
print <<"ABC";

You are not logged in. Please login on the <a href="index.pl">home page.</a>

ABC

}

do 'footer.pl'
