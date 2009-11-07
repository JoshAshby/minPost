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
#these use set up the moduals that perl will use
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

#when called this will connect to the MySQL database
$connect = DBI->connect($dsn, $user, $pw) or die "Couldn't connect to database!" . DBI->errstr;

#sets up the data, and column names that will be used later
$query = "SELECT * FROM $tablename ORDER BY id desc";
$query_handle = $connect->prepare($query);
$query_handle->execute();
$query_handle->bind_columns(undef, \$id, \$date, \$name, \$email, \$post);

do 'header.pl';

do 'cms.pl';

do 'comments.pl';

do 'footer.pl';
