#!/usr/bin/perl
################################################
#Project Bouncing Off Bumpers "BOB" Website code
#Joshua Ashby 2009-10-22 (YYMMDD)
#this page, and the css and images will produce
#a dynamic website that will give users the 
#ability to comment on the page, and possibly for
#me, the admin, to post, and change the paragraphs
#that the users can read on bob.
################################################
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
$postid=CGI::escapeHTML($form->param("postid"));

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

do 'footer1.pl';
