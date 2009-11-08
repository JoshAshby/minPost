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
$postid=CGI::escapeHTML($form->param("postid"));
$f_name=CGI::escapeHTML($form->param("f_name"));
$f_email=CGI::escapeHTML($form->param("f_email"));
$f_post=CGI::escapeHTML($form->param("f_post"));

$session = CGI::Session->load() or die CGI::Session->errstr();

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
print "Welcome, $n_name!<br><br>";
}

print<<"ABC";

<a id="v_toggle" href="#"></a>
<div id="vertical_slide"></div>

ABC

if ($postid) {

$query = "SELECT * FROM $contentname WHERE id=$postid";
$query_handle = $connect->prepare($query);
$query_handle->execute();
$query_handle->bind_columns(undef, \$did, \$ddate, \$dtitle, \$dname, \$dpost);

while($query_handle->fetch()) {

print <<"ABC";

<a href="index.pl">Return to Home</a>
<h4>$dtitle</h4>
$dpost<br>
<br><br>

ABC

}

$query_handle->finish();
}

do 'comments.pl';

do 'footer.pl';
