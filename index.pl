#!/usr/bin/perl

use warnings;
use strict;

use CGI;
use DBI;
use DBD::mysql;

use CGI::Session;
use Crypt::PasswdMD5 qw(unix_md5_crypt);

#setup stuff for the forms
my $form=new CGI;
my $title=CGI::escapeHTML($form->param("title"));
my $align=CGI::escapeHTML($form->param("align"));
my $photo=CGI::escapeHTML($form->param("photo"));
my $color=CGI::escapeHTML($form->param("color"));

my $name=CGI::escapeHTML($form->param("username"));
my $pass=CGI::escapeHTML($form->param("password"));

my $log=CGI::escapeHTML($form->param("log"));



my $data;

#setup all the data for the database, this bit will eventually be replaced by minPost's setting package when merged
my $platform = "mysql";
my $database = "perl";
my $host = "localhost";
my $port = "3306";
my $info = "pl_site";
my $login = "pl_login";
my $user = "root";
my $pw = "speeddyy5";
my $dsn = "dbi:$platform:$database:$host:$port";
my $connect = DBI->connect($dsn, $user, $pw) or die "Couldn't connect to database!" . DBI->errstr;
my $cm_id;
my $cm_title;
my $cm_align;
my $cm_photo;
my $cm_color;

my $lg_id;
my $lg_pass;
my $lg_salt;
my $lg_user;

my $first = 0;

#update the title and alignment SQL query
my $sth = $connect->prepare_cached(<<"SQL");
UPDATE $info
SET title = ?, align = ?, photo = ?, color = ?
WHERE id = '0'
SQL

my $get_pass = $connect->prepare_cached("SELECT * FROM $login ORDER BY id desc");

my $get_hash = $connect->prepare_cached("SELECT pass FROM $login WHERE 1");

my $sid = $form->cookie("CGISESSID") || undef;
my $session = new CGI::Session(undef, $sid, {Directory=>'/tmp'});
my $cookie = $form->cookie(CGISESSID => $session->id);
print $form->header( -cookie=>$cookie );

my $othersalt;
my $crypthash;

if ($name && $pass){
$session->param('username', $name);
if ($first){
$othersalt = gensalt(8);
$crypthash = unix_md5_crypt('speeddyy5', $othersalt);
my $add_pass = $connect->prepare_cached("UPDATE $login SET pass = ?, salt = ? WHERE id = '0'");
$add_pass->execute($crypthash, $othersalt);
$session->param('pass', $crypthash);
} else {
$get_hash->execute();
$get_hash->bind_columns(undef, \$crypthash);
while($get_hash->fetch()){
$session->param('pass', $crypthash);
}
}
my @salt = ( '.', '/', 0 .. 9, 'A' .. 'Z', 'a' .. 'z' );
sub gensalt {
  my $count = shift;
  my $salt;
  for (1..$count) {
    $salt .= (@salt)[rand @salt];
  }
  return $salt;
}

my $n_name = $session->param("username");
my $n_pass = $session->param("pass");
$get_pass->execute();
$get_pass->bind_columns(undef, \$lg_id, \$lg_pass, \$lg_salt, \$lg_user);
while($get_pass->fetch()){
if (unix_md5_crypt($pass, $lg_salt) eq $n_pass && $n_name eq $lg_user) {
$session->param('log', '1');
} else {
$session->param('log', '0');
}
}
}

if ($log) {
$session->param('log', '0');
$session = $session->new() or die $session->errstr;
}

if ($session->is_expired){
print $session->header();
print <<"ABC";
<html>
<head>
</head>
<body>
Your session timed out! Refresh the screen to start new session!
</body>
</html>
ABC
exit(0);
}
if ($session->is_empty){
   $session = $session->new() or die $session->errstr;
}
print $session->header();

#if there is a new title thats been typed in, enter it into the database along with the alignment
if ($title && $align && $photo){
$sth->execute($title, $align, $photo, $color);
}

#get the title and alignment to use for the page
my $query_handle = $connect->prepare_cached("SELECT * FROM $info ORDER BY id desc");
$query_handle->execute();
$query_handle->bind_columns(undef, \$cm_id, \$cm_title, \$cm_align, \$cm_photo, \$cm_color);

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
<h1 class="fancy_head" color="$cm_color">$cm_title</h1>
<form action=index.pl method=post>
<table border=0 cellpadding=0 cellspacing=0>
<tr>
abc
if ($session->param('log')){
print<<"abc";
<td><input type=hidden value=true name=log>
<input type=submit value=\"Logout\">
</td></tr>
abc
} else {
print<<"abc";
<td>Username:</td><td> <input type=text size=20 name=username></td><td>Password:</td><td> <input type=text size=20 name=password></td><td><input type=submit border=0 value=\"Login\"></td></tr>
abc
}
print<<"abc";
</table>
</form>
</div>
abc
}

if ($session->param('log')){
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

#print all the options for photos by listing each photo in "images/headers/" as an option for the drop down box
my @files = <images/headers/*.jpg>;
foreach my $file (@files) {
print <<"ABC";
 <option value="$file">$file</option>
ABC
}

print<<"abc";
</td></tr>
<tr><td>Text Color:</td><td> <select name=color>
 <option value="white">White</option>
 <option value="grey">Grey</option>
 <option value="black">Black</option>
</select></td></tr>
<tr><td></td><td><input type=submit border=0 value=\"Submit\"></td></tr>
</table>
</form>
</div>
<input type=button id="hide-button" value=\"Edit\">

abc
}

print<<"abc";
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
