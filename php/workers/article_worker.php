<?php

// make the connection
$db_conn = mysql_connect('localhost', 'db41232_sn_usr', 'dope911t') or die("Could not connect to database.");

// select the proper db
mysql_select_db('assemblyDEV') or die("Could not select database.");

// get the current date / time from mysql
$ts_result = mysql_query("SELECT NOW();") or die("Couldn't get the date from MySQL");
$row = mysql_fetch_row($ts_result);
$sql_time = $row[0];

$topic_id = $argv[1];

$query = 'SELECT * FROM `tblKeywords`;';
$keyword_result = mysql_query($query);

$keyword_arr = array();
while ($keyword_row = mysql_fetch_array($keyword_result, MYSQL_BOTH)) {
	array_push($keyword_arr, $keyword_row['title']);
}

$line = 0;
$keywordCSV_arr = array();
$hashtagCSV_arr = array();

if (($handle = fopen("funny.csv", "r")) !== FALSE) {
	while (($data = fgetcsv($handle, 1000, ",")) !== FALSE) {
		
		for ($i=0; $i<count($data); $i++) {
			if ($line > 0 && $i == 0 && strlen($data[$i]) > 0)   			
				array_push($keywordCSV_arr, $data[0]);
				
			if ($line > 0 && $i == 1 && strlen($data[$i]) > 0) {
				array_push($keywordCSV_arr, $data[1]);
			}   							
		}
		
		$line++;
	}
}


$query = 'DELETE FROM `tblTopicsKeywords` WHERE `topic_id` = '. $topic_id .';';
$result = mysql_query($query);

foreach ($keywordCSV_arr as $val) {
	$query = 'SELECT `id` FROM `tblKeywords` WHERE `title` = "'. $val .'";';
	$result = mysql_query($query);
	
	if (mysql_num_rows($result) == 0) {
	    $query = 'INSERT INTO `tblKeywords` (`id`, `title`, `active`, `added`) VALUES (NULL, "'. $val .'", "Y", NOW());';
		$keyword_result = mysql_query($query);	
		$keyword_id = mysql_insert_id();
		
		$query = 'INSERT INTO `tblTopicsKeywords` (`topic_id`, `keyword_id`) VALUES ("'. $topic_id .'", "'. $keyword_id .'");';
		$keyword_result = mysql_query($query);	
		
	} else {
		$row = mysql_fetch_row($result);
		$keyword_id = $row[0];
		
		$query = 'INSERT INTO `tblTopicsKeywords` (`topic_id`, `keyword_id`) VALUES ("'. $topic_id .'", "'. $keyword_id .'");';
		$keyword_result = mysql_query($query);	
	}
}


$query = 'DELETE FROM `tblTopicsHashtags` WHERE `topic`'


echo ("\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n". $argv[1] ."\n");

/*
$query = 'SELECT * FROM `tblArticles` WHERE `type_id` < -1;';
$result = mysql_query($query);

while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
	$type_id = $row['type_id'] + 100;
	echo ("ID:[". $row['id'] ."] (". $type_id .") <". $row['tweet_msg'] .">\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n");
	
	//$query = 'INSERT INTO `tblArticleImages` (`id`, `type_id`, `article_id`, `url`, `ratio`, `added`) VALUES (NULL, 1, '. $row['id'] .', "'. $row['image_url'] .'", '. $row['image_ratio'] .', "'. $row['added'] .'");';
	//$img_result = mysql_query($query);
	
	//$query = 'DELETE FROM `tblUsersLikedArticles` WHERE `user_id` = '. $user_id .' AND `article_id` = '. $article_id .';';
	//$result = mysql_query($query);
	
	$query = 'UPDATE `tblArticles` SET `type_id` = '. $type_id .' WHERE `id` = '. $row['id'] .';';
	$upd_result = mysql_query($query);
}
*/

?>
