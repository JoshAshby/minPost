if($f_name && $f_email && $postid) {
	$queryn = "SELECT postid,MAX(id) FROM $tablename WHERE postid=$postid";
	$query_handlen = $connect->prepare($queryn);
	$query_handlen->execute();
	$query_handlen->bind_columns(undef, \$npostid, \$n_id);

	while($query_handlen->fetch()) {
		$f_id = $n_id + 1;
	}

	$query_handlen->finish();

	$years = localtime->year();
	$year = 1900 + $years;
	$day = localtime->mday();
	$months = localtime->mon();
	$month = 1 + $months;
	@f_date = ($year, $month, $day);
	$n_date = join("-", @f_date);

	$queryw = "INSERT INTO $tablename VALUES ('$f_id', '$n_date', '$f_name', '$f_email', '$f_post', '$postid')";
	$query_handlew = $connect->prepare($queryw);
	$query_handlew->execute();
	$query_handlew->finish();

	$queryr = "SELECT * FROM $tablename WHERE postid=$postid ORDER BY id desc";
	$query_handler = $connect->prepare($queryr);
	$query_handler->execute();
	$query_handler->bind_columns(undef, \$id, \$date, \$name, \$email, \$post, \$n_postid);

	while($query_handler->fetch()) {
		print "<br>On $date, $name Said:<br> $post <br>";
	}

	$query_handler->finish();

} else {
	$queryr = "SELECT * FROM $tablename WHERE postid=$postid ORDER BY id desc";
	$query_handler = $connect->prepare($queryr);
	$query_handler->execute();
	$query_handler->bind_columns(undef, \$id, \$date, \$name, \$email, \$post, \$n_postid);

	while($query_handler->fetch()) {
		print "<br>On $date, $name Said:<br> $post <br>";
	}

	$query_handler->finish();
}
