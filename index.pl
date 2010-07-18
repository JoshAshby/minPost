#!/usr/bin/perl

#Newest incarnation of minPost that is slowly taking shape
#main goal of this one is to add the ability to change the basic look easily and fast
#also place the password and user in a database so it's easily changed (if you know how [don't worry the script does];) )
#JoshAshby 2010
#joshuaashby@joshashby.com
#http://joshashby.com

use warnings;
use strict;

use CGI;
use DBI;
use DBD::mysql;
use Time::localtime;
use CGI::Session;
use Crypt::PasswdMD5 qw(unix_md5_crypt);

#setup stuff for the forms
my $form=new CGI;
my $title=CGI::escapeHTML($form->param("title"));
my $head_align=CGI::escapeHTML($form->param("head_align"));
my $head_photo=CGI::escapeHTML($form->param("head_photo"));
my $head_color=CGI::escapeHTML($form->param("head_color"));
my $head_round=CGI::escapeHTML($form->param("head_round"));
my $head_form=CGI::escapeHTML($form->param("head_form"));
my $head_box=CGI::escapeHTML($form->param("head_box"));
my $name=CGI::escapeHTML($form->param("username"));
my $pass=CGI::escapeHTML($form->param("password"));
my $log=CGI::escapeHTML($form->param("log"));
my $link=CGI::escapeHTML($form->param("link"));
my $add_link_name=CGI::escapeHTML($form->param("add_link_name"));
my $add_link_link=CGI::escapeHTML($form->param("add_link_link"));
my $area_color=CGI::escapeHTML($form->param("area_color"));
my $area_text=CGI::escapeHTML($form->param("area_text"));
my $area_round=CGI::escapeHTML($form->param("area_round"));
my $area_align=CGI::escapeHTML($form->param("area_align"));
my $area_form=CGI::escapeHTML($form->param("area_form"));
my $area_show=CGI::escapeHTML($form->param("area_show"));
my $area_name=CGI::escapeHTML($form->param("area_name"));
my $post_name=CGI::escapeHTML($form->param("post_name"));
my $post_update=CGI::escapeHTML($form->param("post_update"));
my $post_delete=CGI::escapeHTML($form->param("post_delete"));
my $post_id=CGI::escapeHTML($form->param("post_id"));
my $post_com_id=CGI::escapeHTML($form->param("post_com_id"));
my $add_post_name=CGI::escapeHTML($form->param("add_post_name"));
my $add_post_post=CGI::escapeHTML($form->param("add_post_post"));
my $add_com_name=CGI::escapeHTML($form->param("add_com_name"));
my $add_com_email=CGI::escapeHTML($form->param("add_com_email"));
my $add_com_com=CGI::escapeHTML($form->param("add_com_com"));
my $new_com_id=CGI::escapeHTML($form->param("new_com_id"));
my $del_com_id=CGI::escapeHTML($form->param("del_com_id"));
my $del_com_postid=CGI::escapeHTML($form->param("del_com_postid"));

my $id;
my $name_top;
my $maxpost_id;
my $data;

our $years;
our $year;
our $day;
our $months;
our $month;
our @c_date;
our $date;

our $info_db;
our $login_db;
our $content_db;
our $link_db;
our $comment_db;
our $col_db;
our $user;
our $pw;
our $dsn;
our $connect;
our $sth;
our $get_pass;
our $get_hash;
our $content;
our $links;
our $get_com_num;
our $get_col;
our $info;
our $link_del;
our $get_max_link;
our $add_new_link;
our $update_area_look;
our $get_comments;
our $update_content;
our $del_post;
our $del_comments;
our $del_comment;
our $add_new_post;
our $get_post_num;
our $add_new_comment;
our $cm_id;
our $cm_title;
our $cm_align;
our $cm_photo;
our $cm_color;
our $cm_round;
our $cm_form;
our $cm_box;
our $lg_id;
our $lg_pass;
our $lg_salt;
our $lg_user;
our $data;
our $first;
our $othersalt;
our $crypthash;
our $c_id;
our $c_date;
our $c_title;
our $c_author;
our $c_post;
our $l_link;
our $l_name;
our $l_id;
our $com_id;
our $com_date;
our $com_name;
our $com_email;
our $com_post;
our $com_postid;
our $col_col;
our $col_round;
our $col_form;
our $col_text;
our $col_align;
our $col_show;

do 'database.pl';

my @salt = ( '.', '/', 0 .. 9, 'A' .. 'Z', 'a' .. 'z' );
sub gensalt {
  my $count = shift;
  my $salt;
  for (1..$count) {
    $salt .= (@salt)[rand @salt];
  }
  return $salt;
}

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
      $crypthash = unix_md5_crypt($pass, $othersalt);
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
$session->expire('1h');
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
if ($session->is_empty){
   $session = $session->new() or die $session->errstr;
   $session->expire('1h');
}

#if they pressed the logout button clear the session and set log to false
if ($log) {
   $session->param('log', '0');
   $session->clear(['username', 'pass']);
   $session->delete();
}
print $session->header();

$name_top = $session->param('username');

if ($session->param('log')){
#post processing
if ($post_name) {
$update_content->execute($date, $post_name, $name_top, $post_update, $post_id);
}
if ($post_com_id) {
$del_post->execute($post_id);
$del_comments->execute($post_com_id);
}
if ($add_post_name) {
$add_new_post->execute($post_id, $date, $add_post_name, $name_top, $add_post_post);
}

#comment stuff
if ($add_com_name && $add_com_email) {
$add_new_comment->execute($new_com_id, $date, $add_com_name, $add_com_email, $add_com_com, $post_id);
}
if ($del_com_id) {
$del_comment->execute($del_com_id, $del_com_postid);
}

#link processing
#delete link
if ($link != "") {
   $link_del->execute($link);
}
#add link
if ($add_link_name) {
$get_max_link->execute();
$get_max_link->bind_columns(undef, \$l_id);
while($get_max_link->fetch()){
my $new_id = $l_id + 1;
$add_new_link->execute($new_id, $add_link_link, $add_link_name);
}
}

#if there is a new title thats been typed in, enter it into the database along with the alignment
if ($title){
   $sth->execute($title, $head_align, $head_photo, $head_color, $head_round, $head_form, $head_box);
}

#chaging area stuff
if ($area_color){
$update_area_look->execute($area_color, $area_round, $area_text, $area_align, $area_form, $area_show, $area_name);
}
}

#get the title and alignment to use for the page
$info->execute();
$info->bind_columns(undef, \$cm_id, \$cm_title, \$cm_align, \$cm_photo, \$cm_color, \$cm_round, \$cm_form, \$cm_box);
while($info->fetch()) {
print<<"abc";
<html>
   <head>
   <link rel="stylesheet" href="css/screen.css" type="text/css" media="screen, projection" />
   <script src="js/jquery.js" type="text/javascript"></script>
   <title>$cm_title</title>
</head>
<body>
   <div class="container">
      <br>
abc
}

#top bar processing
$get_col->execute("top");
$get_col->bind_columns(undef, \$col_col, \$col_round, \$col_form, \$col_text, \$col_align, \$col_show);
while($get_col->fetch()){
if ($col_show) {
if ($session->param('log')) {
print<<"abc";
<div class="top_area" align=$col_align style="background:$col_col;" round=$col_round color=$col_text>
Hello, $name_top! $data
</div>
abc
} else {
print<<"abc";
<div class="top_area" align=$col_align style="background:$col_col;" round=$col_round color=$col_text>
Hello, Guest!
</div>
abc
}
}
}


#header processing
print<<"abc";
   <div class="header" align=$cm_align style="background:url('$cm_photo');" round=$cm_round>
   <h1 class="fancy_head" color=$cm_color>$cm_title</h1>
   <form action=index.pl method=post>
   <table class="form" round=$cm_box>
      <tr>
abc

#if their logged in let them edit the page header, if not show the login boxes
if ($session->param('log')){
print<<"abc";
   <td>
      <input type=hidden value=true name=log>
      <button class="log" round=$cm_form type=submit>Logout</button>
   </td>
</tr>
</table>
</form>
</div>
abc
} else {
print<<"abc";
   <td>Username:</td>
   <td><input type=text size=20 round=$cm_form name=username></td>
   <td>Password:</td>
   <td><input type=password size=20 round=$cm_form name=password></td>
   <td><button class="log" round=$cm_form type=submit>Login</button></td>
</tr>
</table>
</form>
</div>
abc
}

#links area stuff
$get_col->execute("link");
$get_col->bind_columns(undef, \$col_col, \$col_round, \$col_form, \$col_text, \$col_align, \$col_show);
while($get_col->fetch()){
print<<"abc";
<div class="links" align=$col_align style="background:$col_col;" round=$col_round>
abc
$links->execute();
$links->bind_columns(undef, \$l_id, \$l_link, \$l_name);
if ($session->param('log')){
print "<form action=index.pl method=post><table><tr>";
while($links->fetch()) {
print<<"abc";
   <td><input type="radio" name="link" value=$l_id><a color=$col_text href=$l_link>$l_name</a> |</td>
abc
}

#continue with the link stuff, in this case, now making the forms to edit the link area
print<<"abc";
         <td>
            powered by minPost - JoshAshby 2010
         </td>
      </tr>
</table>
</div>
<div id="hide-link">
<table class="edit" round=$col_form>
   <tr><td colspan=3><b>Editing Link Area</b></td></tr>
      <tr>
         <td colspan=2>
            <button type=submit class="negative" round=$col_form><img src="images/icons/cross.png" alt=""/>Delete Selected</button>
            </form>
         </td>
         <td>Link name:</td>
         <td><form action=index.pl method=post><input type=text name="add_link_name" round=$col_form></td>
         <td>Link url:</td><td><input type=text name="add_link_link" round=$col_form></td>
         <td colspan=2><button type=submit class="positive" round=$col_form><img src="images/icons/tick.png" alt=""/>Add Link</button></form></td>
   </tr>
   <tr>
      <td>Area color:</td>
      <td><form action=index.pl method=post>
         <select name=area_color>
            <option value="">--</option>
            <option value="white">White</option>
            <option value="grey">Grey</option>
            <option value="black">Black</option>
         </select>
      </td>
      <td>Link color:</td>
      <td><select name=area_text>
            <option value="">--</option>
            <option value="white">White</option>
            <option value="grey">Grey</option>
            <option value="black">Black</option>
         </select>
      </td>
      <td>Round area:</td>
      <td><select name=area_round>
         <option value="">--</option>
         <option value="yes">All</option>
         <option value="top">Top</option>
         <option value="bottom">Bottom</option>
         <option value="left">Left</option>
         <option value="right">Right</option>
      </select></td>
      <td>Round form:</td>
      <td><select name=area_form>
         <option value="">--</option>
         <option value="yes">All</option>
         <option value="top">Top</option>
         <option value="bottom">Bottom</option>
         <option value="left">Left</option>
         <option value="right">Right</option>
      </select></td>
      <td>Text align:</td>
      <td><select name=area_align>
         <option value="">--</option>
         <option value="left">Left</option>
         <option value="center">Center</option>
         <option value="right">Right</option>
      </select></td>
      <td><input type=hidden name=area_name value="link"><button type=submit class="positive" round=$col_form><img src="images/icons/tick.png" alt=""/>Update</button></td>
   </tr>
</table>
</form>
</div>
abc
} else {
while($links->fetch()){
print<<"abc";
<a href=$l_link>$l_name</a> | 
abc
}
print "powered by minPost - JoshAshby 2010</div> <br>";
}
}

#if they are loged in let them edit the different areas, if not then don't show them anything
if ($session->param('log')){
$get_col->execute("top");
$get_col->bind_columns(undef, \$col_col, \$col_round, \$col_form, \$col_text, \$col_align, \$col_show);
while($get_col->fetch()){
print<<"abc";
<div id="hide-top">
   <form action=index.pl method=post>
      <table class="edit" round=$col_form>
         <tr><td colspan=3><b>Editing Top Area</b></td></tr>
         <tr>
            <td>Top color:</td>
            <td>
               <select name=area_color>
                  <option value="">--</option>
                  <option value="white">White</option>
                  <option value="grey">Grey</option>
                  <option value="black">Black</option>
               </select>
            </td>
            <td>Text color:</td>
            <td>
               <select name=area_text>
                  <option value="">--</option>
                  <option value="white">White</option>
                  <option value="grey">Grey</option>
                  <option value="black">Black</option>
               </select>
            </td>
            <td>Round area:</td>
            <td>
               <select name=area_round>
                  <option value="">--</option>
                  <option value="yes">All</option>
                  <option value="top">Top</option>
                  <option value="bottom">Bottom</option>
                  <option value="left">Left</option>
                  <option value="right">Right</option>
               </select>
            </td>
            <td>Round forms:</td>
            <td>
               <select name=area_form>
                  <option value="">--</option>
                  <option value="yes">All</option>
                  <option value="top">Top</option>
                  <option value="bottom">Bottom</option>
                  <option value="left">Left</option>
                  <option value="right">Right</option>
               </select>
            </td>
            <td>Text align:</td>
            <td>
               <select name=area_align>
                  <option value="">--</option>
                  <option value="left">Left</option>
                  <option value="center">Center</option>
                  <option value="right">Right</option>
               </select>
            </td>
            <td>Show:</td>
            <td>
               <select name=area_show>
                  <option value="">--</option>
                  <option value="1">Yes</option>
                  <option value="0">No</option>
               </select>
            </td>
            <td>
               <input type=hidden name=area_name value="top"><button type=submit class="positive" round=$col_form><img src="images/icons/tick.png" alt=""/>Update</button></td>
         </tr>
      </table>
   </form>     
</div>
<div id="hide-head">
   <form action=index.pl method=post>
   <table class="edit" round=$cm_form>
      <tr><td colspan=3><b>Editing Header Area</b></td></tr>
      <tr>
         <td>Title:</td>
         <td><input type=text size=20 round=$cm_form name=title></td>
         <td>Align:</td>
         <td><select name=head_align>
            <option value="">--</option>
            <option value="left">Left</option>
            <option value="center">Center</option>
            <option value="right">Right</option>
         </select>
         </td>
         <td>Photo:</td>
         <td><select name=head_photo>
            <option value="">--</option>
abc
}

#print all the options for photos by listing each photo in "images/headers/" as an option for the drop down box
my @files = <images/headers/*.jpg>;
foreach my $file (@files) {
print <<"ABC";
   <option value=$file>$file</option>
ABC
}

print<<"abc";
         </select>
      </td>
      <td>Text Color:</td>
      <td><select name=head_color>
            <option value="">--</option>
            <option value="white">White</option>
            <option value="grey">Grey</option>
            <option value="black">Black</option>
         </select>
      </td>
   </tr>
   <tr>
      <td>Round Header:</td>
      <td><select name=head_round>
            <option value="">--</option>
            <option value="yes">All</option>
            <option value="top">Top</option>
            <option value="bottom">Bottom</option>
            <option value="left">Left</option>
            <option value="right">Right</option>
         </select>
      </td>
      <td>Round Forms:</td>
      <td><select name=head_form>
            <option value="">--</option>
            <option value="yes">All</option>
            <option value="top">Top</option>
            <option value="bottom">Bottom</option>
            <option value="left">Left</option>
            <option value="right">Right</option>
         </select>
      </td>
      <td>Round Login Box:</td>
      <td><select name=head_box>
            <option value="">--</option>
            <option value="yes">All</option>
            <option value="top">Top</option>
            <option value="bottom">Bottom</option>
            <option value="left">Left</option>
            <option value="right">Right</option>
         </select>
      </td>
      <td><button type=submit round=$cm_form class="positive"><img src="images/icons/tick.png" alt=""/>Update</button></td>
   </tr>
</table>
</form>
</div>
abc

$get_col->execute("content");
$get_col->bind_columns(undef, \$col_col, \$col_round, \$col_form, \$col_text, \$col_align, \$col_show);
while($get_col->fetch()){
print<<"abc";
<div id="hide-content">
   <form action=index.pl method=post>
      <table class="edit" round=$col_form>
         <tr><td colspan=3><b>Editing Content Area</b></td></tr>
         <tr>
            <td>Content color:</td>
            <td>
               <select name=area_color>
                  <option value="">--</option>
                  <option value="white">White</option>
                  <option value="grey">Grey</option>
                  <option value="black">Black</option>
               </select>
            </td>
            <td>Text color:</td>
            <td>
               <select name=area_text>
                  <option value="">--</option>
                  <option value="white">White</option>
                  <option value="grey">Grey</option>
                  <option value="black">Black</option>
               </select>
            </td>
            <td>Round area:</td>
            <td>
               <select name=area_round>
                  <option value="">--</option>
                  <option value="yes">All</option>
                  <option value="top">Top</option>
                  <option value="bottom">Bottom</option>
                  <option value="left">Left</option>
                  <option value="right">Right</option>
               </select>
            </td>
            <td>Round forms:</td>
            <td>
               <select name=area_form>
                  <option value="">--</option>
                  <option value="yes">All</option>
                  <option value="top">Top</option>
                  <option value="bottom">Bottom</option>
                  <option value="left">Left</option>
                  <option value="right">Right</option>
               </select>
            </td>
            <td>Text align:</td>
            <td>
               <select name=area_align>
                  <option value="">--</option>
                  <option value="left">Left</option>
                  <option value="center">Center</option>
                  <option value="right">Right</option>
               </select>
            </td>
            <td>
               <input type=hidden name=area_name value="content"><button type=submit class="positive" round=$col_form><img src="images/icons/tick.png" alt=""/>Update</button></td>
         </tr>
      </table>
   </form>     
</div>
abc
}
$get_post_num->execute();
$get_post_num->bind_columns(undef, \$maxpost_id);
while ($get_post_num->fetch()) {
$id = $maxpost_id + 1;
print<<"abc";
<div id="hide-add">
   <form action=index.pl method=post>
      <table class="edit" round=$col_form style="vertical-align:top;">
         <tr>
            <td>
               <b>Add a new post</b>
            </td>
         </tr>
         <tr>
            <td>
               New post name:
            </td>
            <td>
               <input type=text size=20 name=add_post_name round=$col_form>
            </td>
            <td>
               New post:
            </td>
            <td>
               <textarea rows="5" cols="30" name=add_post_post></textarea>
            </td>
            <td>
               <input type=hidden name=post_id value=$id><button type=submit class="positive" round=$col_form><img src="images/icons/tick.png" alt=""/>Add Post</button>
               </form>
         </tr>
      </table>
   </form>
</div>
abc
}
print<<"abc";
<table class="edit" round="yes">
   <tr>
      <td>
         <b>Edit looks:</b>
      </td>
      <td>
         <button class="log" id="hide-top-button" round=$col_form>Edit Top</button>
      </td>
      <td>
         <button class="log" id="hide-head-button" round=$col_form>Edit Header</button>
      </td>
      <td>
         <button class="log" id="hide-link-button" round=$col_form>Edit Link</button>
      </td>
      <td>
         <button class="log" id="hide-content-button" round=$col_form>Edit Content</button>
      </td>
      <td>
         <b>Add post:</b>
      </td>
      <td>
         <button class="log" id="hide-add-button" round=$col_form>Add Post</button>
      </td>
   </tr>
</table>
<br>
abc
}

#content area
$get_col->execute("content");
$get_col->bind_columns(undef, \$col_col, \$col_round, \$col_form, \$col_text, \$col_align);
while($get_col->fetch()){
print<<"abc";
<div class=content align=$col_align color=$col_text style="background:$col_col;" round=$col_round>
abc
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
if ($session->param('log')){
if ($com_id == '0'){
   print "<button class=\"log\" id=\"hide_$c_id-button\" round=$col_form>No Comments</button> <button  class=\"log\" id=\"hide_$c_id-post-button\" round=$col_form>Edit Post</button><br><br>";
} elsif ($com_id == '1'){
   print "<button class=\"log\" id=\"hide_$c_id-button\" round=$col_form>1 Comment</button> <button  class=\"log\" id=\"hide_$c_id-post-button\" round=$col_form>Edit Post</button><br><br>";
} else {
   print "<button class=\"log\" id=\"hide_$c_id-button\" round=$col_form>$com_id Comments</button> <button  class=\"log\" id=\"hide_$c_id-post-button\" round=$col_form>Edit Post</button><br><br>";
}
} else {
if ($com_id == '0'){
   print "<button class=\"log\" id=\"hide_$c_id-button\" round=$col_form>No Comments</button><br><br>";
} elsif ($com_id == '1'){
   print "<button class=\"log\" id=\"hide_$c_id-button\" round=$col_form>1 Comment</button><br><br>";
} else {
   print "<button class=\"log\" id=\"hide_$c_id-button\" round=$col_form>$com_id Comments</button><br><br>";
}
}
print<<"abc";
   $c_post<br>
abc
$com_id = $com_id + 1;
if ($session->param('log')) {
print<<"abc";
<div id="hide_$c_id-post">
<form action=index.pl method=post>
   <table class="edit" round=$col_form style="vertical-align:top;">
      <tr>
         <td colspan=2>
            Editing post "<b>$c_title</b>"
         </td>
      </tr>
      <tr>
         <td>
            Edit name:
         </td>
         <td>
            <input type=text size=20 name=post_name round=$col_form>
         </td>
         <td>
            Edit Post:
         </td>
         <td>
            <textarea rows="5" cols="30" name=post_update>$c_post</textarea>
         </td>
         <td>
            <input type=hidden name=post_id value=$c_id><button type=submit class="positive" round=$col_form><img src="images/icons/tick.png" alt=""/>Edit post</button>
            </form>
            <form action=index.pl method=post>
               <input type=hidden name=post_id value=$c_id>
               <input type=hidden name=post_com_id value=$c_id>
               <button type=submit class="negative" round=$col_form><img src="images/icons/cross.png" alt=""/>Delete post</button>
         </td>
      </tr>
   </table>
</form>
</div>
<div id="hide_$c_id">
abc
$get_comments->execute($c_id);
$get_comments->bind_columns(undef, \$com_date, \$com_name, \$com_email, \$com_post, \$com_id, \$com_postid);
while($get_comments->fetch()) {
print<<"abc";
<b>$com_name</b> said on $com_date<br>
$com_post<br>
<form action=index.pl method=post>
   <input type=hidden name=del_com_id value=$com_id>
   <input type=hidden name=del_com_postid value=$com_postid>
   <button type=submit class="negative" round=$col_form><img src="images/icons/cross.png" alt=""/>Delete comment</button>
</form>
<br>
<hr>
<br>
abc
}
print<<"abc";
<form action=index.pl method=post>
   <table class="edit" round=$col_form>
      <tr>
         <td>
            Add a comment:
         </td>
      </tr>
      <tr>
         <td>
            Name:
         </td>
         <td>
            <input type=text name=add_com_name round=$col_form>
         </td>
         <td>
            Email*:
         </td>
         <td>
            <input type=text name=add_com_email round=$col_form>
         </td>
      </tr>
      <tr>
         <td colspan=3>
            <textarea rows="10" cols="50" name=add_com_com></textarea>
         </td>
         <td>
            <input type=hidden name=post_id value=$c_id><input type=hidden name=new_com_id value=$com_id><button type=submit class="positive" round=$col_form><img src="images/icons/tick.png" alt=""/>Add comment</button> 
         </td>
      </tr>
   </table>
</form>
</div><br><hr>
<script type="text/javascript">
\$("#hide_$c_id-post").hide();
\$("#hide_$c_id").hide();

\$("#hide_$c_id-post-button").click(function () {
      if (\$("#hide_$c_id").is(":visible")) {
         \$("#hide_$c_id").slideToggle("slow");
      }
      \$("#hide_$c_id-post").slideToggle("slow");
    });

\$("#hide_$c_id-button").click(function () {
      if (\$("#hide_$c_id-post").is(":visible")) {
         \$("#hide_$c_id-post").slideToggle("slow");
      }
      \$("#hide_$c_id").slideToggle("slow");
    });
</script>
abc
} else {
print<<"abc";
<br>
<div id="hide_$c_id">
abc
$get_comments->execute($c_id);
$get_comments->bind_columns(undef, \$com_date, \$com_name, \$com_email, \$com_post);
while($get_comments->fetch()) {
print<<"abc";
<b>$com_name</b> said on $com_date<br>
$com_post<br>
abc
}
print<<"abc";
<form action=index.pl method=post>
   <table class="edit">
      <tr>
         <td>
            Add a comment:
         </td>
      </tr>
      <tr>
         <td>
            Name:
         </td>
         <td>
            <input type=text name=add_com_name>
         </td>
         <td>
            Email*:
         </td>
         <td>
            <input type=text name=add_com_email>
         </td>
      </tr>
   </table>
</form>
</div>
<br>
<hr>
<script type="text/javascript">
\$("#hide_$c_id").hide();
\$("#hide_$c_id-button").click(function () {
      \$("#hide_$c_id").slideToggle("slow");
    });
</script>
abc
}
}
}
print "</div>";
}

#footer area
$get_col->execute("link");
$get_col->bind_columns(undef, \$col_col, \$col_round, \$col_form, \$col_text, \$col_align);
while($get_col->fetch()){
print<<"abc";
<div class="links" align=$col_align style="background:$col_col" round=$col_round>
abc
}
$links->execute();
$links->bind_columns(undef, \$l_id, \$l_link, \$l_name);
while($links->fetch()){
print<<"abc";
<a href=$l_link>$l_name</a> | 
abc
}

print<<"abc";
 Design and minPost by <a href="http://joshashby.com">JoshAshby</a> <a href="mailto:joshuaashby\@joshashby.com">joshuaashby\@joshashby.com</a>
</div>
</div>
<script type="text/javascript">
\$("#hide-head").hide();
\$("#hide-link").hide();
\$("#hide-top").hide();
\$("#hide-content").hide();
\$("#hide-add").hide();

\$("#hide-head-button").click(function () {
      if (\$("#hide-link").is(":visible")) {
         \$("#hide-link").slideToggle("slow");
      }
      if (\$("#hide-top").is(":visible")) {
         \$("#hide-top").slideToggle("slow");
      }
      if (\$("#hide-content").is(":visible")) {
         \$("#hide-content").slideToggle("slow");
      }
      if (\$("#hide-add").is(":visible")) {
         \$("#hide-add").slideToggle("slow");
      }
      \$("#hide-head").slideToggle("slow");
    });

\$("#hide-link-button").click(function () {
      if (\$("#hide-head").is(":visible")) {
         \$("#hide-head").slideToggle("slow");
      }
      if (\$("#hide-top").is(":visible")) {
         \$("#hide-top").slideToggle("slow");
      }
      if (\$("#hide-content").is(":visible")) {
         \$("#hide-content").slideToggle("slow");
      }
      if (\$("#hide-add").is(":visible")) {
         \$("#hide-add").slideToggle("slow");
      }
      \$("#hide-link").slideToggle("slow");
    });

\$("#hide-top-button").click(function () {
      if (\$("#hide-link").is(":visible")) {
         \$("#hide-link").slideToggle("slow");
      }
      if (\$("#hide-head").is(":visible")) {
         \$("#hide-head").slideToggle("slow");
      }
      if (\$("#hide-content").is(":visible")) {
         \$("#hide-content").slideToggle("slow");
      }
      if (\$("#hide-add").is(":visible")) {
         \$("#hide-add").slideToggle("slow");
      }
      \$("#hide-top").slideToggle("slow");
    });

\$("#hide-content-button").click(function () {
      if (\$("#hide-link").is(":visible")) {
         \$("#hide-link").slideToggle("slow");
      }
      if (\$("#hide-top").is(":visible")) {
         \$("#hide-top").slideToggle("slow");
      }
      if (\$("#hide-head").is(":visible")) {
         \$("#hide-head").slideToggle("slow");
      }
      if (\$("#hide-add").is(":visible")) {
         \$("#hide-add").slideToggle("slow");
      }
      \$("#hide-content").slideToggle("slow");
    });

\$("#hide-add-button").click(function () {
      if (\$("#hide-link").is(":visible")) {
         \$("#hide-link").slideToggle("slow");
      }
      if (\$("#hide-top").is(":visible")) {
         \$("#hide-top").slideToggle("slow");
      }
      if (\$("#hide-head").is(":visible")) {
         \$("#hide-head").slideToggle("slow");
      }
      if (\$("#hide-content").is(":visible")) {
         \$("#hide-content").slideToggle("slow");
      }
      \$("#hide-add").slideToggle("slow");
    });
</script>
<br>
</body>
</html>
abc
