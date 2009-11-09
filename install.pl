#!/usr/bin/perl
use DBI;
use DBD::mysql;
use CGI::Session;

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

print <<"ABC";

<html>
<head>
</head>
<body>

ABC

$query = "CREATE DATABASE perl";
$query_handle = $connect->prepare($query);
$query_handle->execute();
$query_handle->finish();

print "Database created";

$queryc = "USE perl;
CREATE TABLE IF NOT EXISTS `pl_content` (
  `id` int(11) NOT NULL,
  `date` date NOT NULL,
  `title` text NOT NULL,
  `name` text NOT NULL,
  `post` text NOT NULL,
  KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;"
$query_handlec = $connect->prepare($queryc);
$query_handlec->execute();
$query_handlec->finish();

print "Post table created";

$querycm = "USE perl;
CREATE TABLE IF NOT EXISTS `pl_db` (
  `id` int(11) NOT NULL,
  `date` date NOT NULL,
  `name` text NOT NULL,
  `email` text NOT NULL,
  `post` text NOT NULL,
  `postid` int(11) NOT NULL,
  KEY `date` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;"
$query_handlecm = $connect->prepare($querycm);
$query_handlecm->execute();
$query_handlecm->finish();

print "Comment table created";

$querys = "USE perl;
CREATE TABLE IF NOT EXISTS `pl_site` (
  `title` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;"
$query_handles = $connect->prepare($querys);
$query_handles->execute();
$query_handles->finish();

print "Site data table created";

$queryl = "USE perl;
CREATE TABLE IF NOT EXISTS `pl_links` (
  `links` text NOT NULL,
  `linkname` text NOT NULL,
  `class` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;"
$query_handlel = $connect->prepare($queryl);
$query_handlel->execute();
$query_handlel->finish();

print "Links table created";

print <<"ABC";

</body>
</html>

ABC

$connect->diconnect();
