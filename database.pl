#setup all the data for the database, this bit will eventually be replaced by minPost's setting package when merged
our $platform = "mysql";
our $database = "perl";
our $host = "localhost";
our $port = "3306";
our $info_db = "pl_site";
our $login_db = "pl_login";
our $content_db = "pl_content";
our $link_db = "pl_links";
our $comment_db = "pl_db";
our $col_db = "pl_color";
our $user = "root";
our $pw = "speeddyy5";
our $dsn = "dbi:$platform:$database:$host:$port";
our $connect = DBI->connect($dsn, $user, $pw) or die "Couldn't connect to database!" . DBI->errstr;

our $first = 0;

our $years = localtime->year();
our $year = 1900 + $years;
our $day = localtime->mday();
our $months = localtime->mon();
our $month = 1 + $months;
our @c_date = ($year, $month, $day);
our $date = join("-", @c_date);

#update the title and alignment SQL query
our $sth = $connect->prepare_cached(<<"SQL");
UPDATE $info_db
SET title = ?, align = ?, photo = ?, color = ?, round = ?, form = ?, box_round = ?
WHERE id = '0'
SQL

#get the login info query
our $get_pass = $connect->prepare_cached("SELECT * FROM $login_db ORDER BY id desc");

#get the hash query
our $get_hash = $connect->prepare_cached("SELECT pass FROM $login_db WHERE 1");

#get the content for the main area
our $content = $connect->prepare_cached("SELECT * FROM $content_db ORDER BY id desc");

#update a post query
our $update_content = $connect->prepare_cached("UPDATE $content_db SET date = ?, title = ?, name = ?, post = ? WHERE id = ?");

#delete a post query
our $del_post = $connect->prepare_cached("DELETE FROM $content_db WHERE id = ?");
our $del_comments = $connect->prepare_cached("DELETE FROM $comment_db WHERE postid = ?");

#comment delete query
our $del_comment = $connect->prepare_cached("DELETE FROM $comment_db WHERE id = ? AND postid = ?");

#add post
our $add_new_post = $connect->prepare_cached("INSERT INTO $content_db (id, date, title, name, post) VALUES (?, ?, ?, ?, ?)");

#add comment
our $add_new_comment = $connect->prepare_cached("INSERT INTO $comment_db (id, date, name, email, post, postid) VALUES (?, ?, ?, ?, ?, ?)");

#links query
our $links = $connect->prepare_cached("SELECT * FROM $link_db");

#get the amount of comments per post query
our $get_com_num = $connect->prepare_cached("SELECT MAX(id) FROM $comment_db WHERE postid = ?");

#get max post id
our $get_post_num = $connect->prepare_cached("SELECT MAX(id) FROM $content_db");

#get comments query
our $get_comments = $connect->prepare_cached("SELECT date, name, email, post, id, postid FROM $comment_db WHERE postid = ?");

#color query
our $get_col = $connect->prepare_cached("SELECT color, round, form, text_color, align, no_show FROM $col_db WHERE name = ?");

#title query
our $info = $connect->prepare_cached("SELECT * FROM $info_db ORDER BY id desc");

#link delete query
our $link_del = $connect->prepare_cached("DELETE FROM $link_db WHERE id = ?");

#link max id query
our $get_max_link = $connect->prepare_cached("SELECT MAX(id) FROM $link_db");

#add link query
our $add_new_link = $connect->prepare_cached("INSERT INTO $link_db (`id`, `link`, `linkname`) VALUES (?, ?, ?)");

#change area look
our $update_area_look = $connect->prepare_cached("UPDATE $col_db SET color = ?, round = ?, text_color = ?, align = ?, form = ?, no_show = ? WHERE name = ?");
