#!/usr/bin/perl
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

$query = "DELETE FROM $contentname WHERE id=\"$id\"";
$query_handle = $connect->prepare($query);
$query_handle->execute();

print <<"ABC";

Welcome, $n_name!<br><br>
Post #$id has been deleted.
<a href="index.pl">Return to Home</a>

ABC

$query_handle->finish();
$connect->disconnect();
}
} else {
print <<"ABC";

You are not logged in. Please login on the <a href="index.pl">home page.</a>

ABC

}

do 'footer1.pl'
