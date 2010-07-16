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

#setup all the data for the database, this bit will eventually be replaced by minPost's setting package when merged
my $platform = "mysql";
my $database = "perl";
my $host = "localhost";
my $port = "3306";
my $info_db = "pl_site";
my $login_db = "pl_login";
my $content_db = "pl_content";
my $link_db = "pl_links";
my $comment_db = "pl_db";
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

my $data;
my $first = 0;
my $othersalt;
my $crypthash;

my $c_id;
my $c_date;
my $c_title;
my $c_author;
my $c_post;

my $l_link;
my $l_name;

my $com_id;
my $com_date;
my $com_name;
my $com_email;
my $com_post;
my $com_postid;

#update the title and alignment SQL query
my $sth = $connect->prepare_cached(<<"SQL");
UPDATE $info_db
SET title = ?, align = ?, photo = ?, color = ?
WHERE id = '0'
SQL

#get the login info query
my $get_pass = $connect->prepare_cached("SELECT * FROM $login_db ORDER BY id desc");

#get the hash query
my $get_hash = $connect->prepare_cached("SELECT pass FROM $login_db WHERE 1");

#get the content for the main area
my $content = $connect->prepare_cached("SELECT * FROM $content_db ORDER BY id desc");

#links query
my $links = $connect->prepare_cached("SELECT * FROM $link_db");



#session stuff
my $sid = $form->cookie("CGISESSID") || undef;
my $session = new CGI::Session(undef, $sid, {Directory=>'/tmp'});
my $cookie = $form->cookie(CGISESSID => $session->id);
print $form->header( -cookie=>$cookie );

#if someone typed something into the login boxes then go about checking if it matches info in the database
if ($name && $pass){
   $session->param('username', $name);
   if ($first){
      $othersalt = gensalt(8);
      #this will eventually be for when someone wants to change their password through the admin, it will make the new hash, salt and everything else needed and pass then along to the database.
      $crypthash = unix_md5_crypt('speeddyy5', $othersalt);
      my $add_pass = $connect->prepare_cached("UPDATE $login_db SET pass = ?, salt = ? WHERE id = '0'");
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
$session->expire('+1h');
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
   $session->expire('+1h');
}
#if they pressed the logout button clear the session and set log to false
if ($log) {
   $session->param('log', '0');
   $session->clear(['username', 'pass']);
   $session->delete();
}
print $session->header();

#if there is a new title thats been typed in, enter it into the database along with the alignment
if ($title){
   $sth->execute($title, $align, $photo, $color);
}

#get the title and alignment to use for the page
my $query_handle = $connect->prepare_cached("SELECT * FROM $info_db ORDER BY id desc");
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
   <div class="header" align="$cm_align" style="background:url('$cm_photo');">
   <h1 class="fancy_head" color="$cm_color">$cm_title</h1>
   <form action=index.pl method=post>
   <table class="form" border=0 cellpadding=0 cellspacing=0>
      <tr>
abc
}
#if their logged in let them edit the page header, if not show the login boxes
if ($session->param('log')){
print<<"abc";
   <td>
      <input type=hidden value=true name=log>
      <button class="log" type=submit>Logout</button>
   </td>
</tr>
abc
} else {
print<<"abc";
   <td>Username:</td>
   <td><input type=text size=20 name=username></td>
   <td>Password:</td>
   <td><input type=password size=20 name=password></td>
   <td><button class="log" type=submit>Login</button></td>
</tr>
abc
}

print<<"abc";
      </table>
   </form>
</div>
abc

$links->execute();
$links->bind_columns(undef, \$l_link, \$l_name);
while($links->fetch()) {
print<<"abc";
   <a href="$l_link">$l_name</a>
abc
}

#if they are loged in let them edit the header, if not then don't show the edit button
if ($session->param('log')){
print<<"abc";
<div id="hide">
   <form action=index.pl method=post>
   <table border=0 cellpadding=0 cellspacing=0>
      <tr>
      <td>Title:</td>
      <td><input type=text size=20 name=title></td>
   </tr>
   <tr>
      <td>Align:</td>
      <td><select name=align>
         <option value="left">Left</option>
         <option value="center">Center</option>
         <option value="right">Right</option>
      </select>
      </td>
   </tr>
   <tr>
      <td>Photo:</td>
      <td><select name=photo>
abc

#print all the options for photos by listing each photo in "images/headers/" as an option for the drop down box
my @files = <images/headers/*.jpg>;
foreach my $file (@files) {
print <<"ABC";
   <option value="$file">$file</option>
ABC
}

print<<"abc";
      </td>
   </tr>
   <tr>
      <td>Text Color:</td>
      <td><select name=color>
            <option value="white">White</option>
            <option value="grey">Grey</option>
            <option value="black">Black</option>
         </select>
      </td>
   </tr>
   <tr>
      <td></td>
      <td><input type=submit border=0 value=\"Submit\"></td>
   </tr>
</table>
</form>
</div>
<input type=button id="hide-button" value=\"Edit\">
abc
}

my $get_com_num = $connect->prepare_cached("SELECT MAX(id) FROM $comment_db WHERE postid=?");
$content->execute();
$content->bind_columns(undef, \$c_id, \$c_date, \$c_title, \$c_author, \$c_post);
while($content->fetch()) {
$get_com_num->execute($c_id);
$get_com_num->bind_columns(undef, \$com_id);
while($get_com_num->fetch()){
print <<"abc"; 
   <h4>$c_title</h4>
   From: $c_date By: $c_author<br>
abc
if ($com_id == '0'){
   print "No Comments<br>";
} elsif ($com_id == '1'){
   print "1 Comment<br>";
} else {
   print "$com_id Comments<br>";
}
print<<"abc";
   $c_post<br>
   <br>
abc
}
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
