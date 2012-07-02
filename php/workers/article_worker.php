<?php

// make the connection
$db_conn = mysql_connect('localhost', 'db41232_sn_usr', 'dope911t') or die("Could not connect to database.");

// select the proper db
mysql_select_db('assembly2') or die("Could not select database.");

// get the current date / time from mysql
$ts_result = mysql_query("SELECT NOW();") or die("Couldn't get the date from MySQL");
$row = mysql_fetch_row($ts_result);
$sql_time = $row[0];


$query = 'SELECT * FROM `tblArticles` WHERE `id` < 3123 AND `active` = "Y";';
$result = mysql_query($query);

while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
	echo ("ID:[". $row['id'] ."] <". $row['tweet_msg'] .">\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n");
	
	//$query = 'INSERT INTO `tblArticleImages` (`id`, `type_id`, `article_id`, `url`, `ratio`, `added`) VALUES (NULL, 1, '. $row['id'] .', "'. $row['image_url'] .'", '. $row['image_ratio'] .', "'. $row['added'] .'");';
	//$img_result = mysql_query($query);
	
	//$query = 'UPDATE `tblArticles` SET `type_id` = -10 WHERE `id` = '. $row['id'] .';';
	//$result = mysql_query($query);
}

?>
