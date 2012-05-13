<?php

// make the connection
$db_conn = mysql_connect('localhost', 'db41232_sn_usr', 'dope911t') or die("Could not connect to database.");

// select the proper db
mysql_select_db('assembly') or die("Could not select database.");

// get the current date / time from mysql
$ts_result = mysql_query("SELECT NOW();") or die("Couldn't get the date from MySQL");
$row = mysql_fetch_row($ts_result);
$sql_time = $row[0];


$query = 'SELECT `id`, `content` FROM `tblArticles`;';
$result = mysql_query($query);

while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
	$content = str_replace('</p><p>', '\n\n', $row['content']);
	
	$content = str_replace('</p>', '', $content);
	$content = str_replace('<p>', '', $content);
	
	//echo ("ID:[".$row['id']."]<br />\n".str_replace('</p>', '\n\n', $content)."<hr /><hr />\n\n");
	
	$query = 'UPDATE `tblArticles` SET `content` = "'. $content .'" WHERE `id` = '. $row['id'] .';';
	$res = mysql_query($query);
}

?>
