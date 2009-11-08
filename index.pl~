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
$cmf_name=CGI::escapeHTML($form->param("cmf_name"));
$cmf_title=CGI::escapeHTML($form->param("cmf_title"));
$cmf_post=CGI::escapeHTML($form->param("cmf_post"));
$l_name=CGI::escapeHTML($form->param("l_name"));
$l_pass=CGI::escapeHTML($form->param("l_pass"));
$f_name=CGI::escapeHTML($form->param("f_name"));
$f_email=CGI::escapeHTML($form->param("f_email"));
$f_post=CGI::escapeHTML($form->param("f_post"));

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

do 'cms.pl';

do 'footer.pl';
