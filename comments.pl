if($f_name && $f_email) {#if you enter both a name and email
	$queryn = "SELECT MAX(id) FROM $tablename";#connect to the db and get the max id number
	$query_handlen = $connect->prepare($queryn);
	$query_handlen->execute();
	$query_handlen->bind_columns(\$n_id);

	while($query_handlen->fetch()) {#get the max id number and add 1 to it, this will be for the next data entry
		$f_id = $n_id + 1;
	}

	$query_handlen->finish();#finish that query

	$years = localtime->year();#this builds the time stamp for the db, in YYMMDD format
	$year = 1900 + $years;
	$day = localtime->mday();
	$months = localtime->mon();
	$month = 1 + $months;
	@f_date = ($year, $month, $day);
	$n_date = join("-", @f_date);

	$queryw = "INSERT INTO $tablename VALUES ('$f_id', '$n_date', '$f_name', '$f_email', '$f_post')";#connect to the
	$query_handlew = $connect->prepare($queryw);#db and add the new data from the form (below)
	$query_handlew->execute();
	$query_handlew->finish();

	$queryr = "SELECT * FROM $tablename ORDER BY id desc";#re-read the data including the new data and print it out
	$query_handler = $connect->prepare($queryr);
	$query_handler->execute();
	$query_handler->bind_columns(undef, \$id, \$date, \$name, \$email, \$post);
	while($query_handler->fetch()) {
		print "On $date, $name Said:<br> $post <br><br>";#will print out something like "On 2009-10-22, Joshua Ashby said:"
	}
	$query_handler->finish(); $connect->disconnect();#finish the query and close the connection to the database
} else {#if there is no data in the form
	while($query_handle->fetch()) {#get the data in the database and print it out
		print "On $date, $name Said:<br> $post <br>";#prints out like above
	}
}

$query_handle->finish(); $connect->disconnect();#finish the first query and close the database connection
