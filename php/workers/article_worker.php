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
$topic_name = $argv[2];

$line = 0;

$keywordCSV_arr = array();
$hashtagCSV_arr = array();
$handleCSV_arr = array();

if (($handle = fopen($topic_name .".csv", "r")) !== FALSE) {
	while (($data = fgetcsv($handle, 1000, ",")) !== FALSE) {
		
		for ($i=0; $i<count($data); $i++) {
			if ($line > 0 && $i == 0 && strlen($data[$i]) > 0)   			
				array_push($keywordCSV_arr, $data[0]);
				
			if ($line > 0 && $i == 1 && strlen($data[$i]) > 0) {
				array_push($hashtagCSV_arr, $data[1]);
			}
			
			if ($line > 0 && $i == 2 && strlen($data[$i]) > 0)
			   	array_push($handleCSV_arr, $data[2]);
		}
		
		$line++;
	}
}


echo ("\nKeywords:\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n");

$query = 'DELETE FROM `tblTopicsKeywords` WHERE `topic_id` = '. $topic_id .';';
$result = mysql_query($query);

foreach ($keywordCSV_arr as $val) {
	echo ($val ."\n");
	
	$query = 'SELECT `id` FROM `tblKeywords` WHERE `title` = "'. str_replace("\"", "%22", $val) .'";';
	$result = mysql_query($query);
	
	if (mysql_num_rows($result) == 0) {
	    $query = 'INSERT INTO `tblKeywords` (`id`, `title`, `active`, `added`) VALUES (NULL, "'. str_replace("\"", "%22", $val) .'", "Y", NOW());';
		$keyword_result = mysql_query($query);	
		$keyword_id = mysql_insert_id();
		
	} else {
		$row = mysql_fetch_row($result);
		$keyword_id = $row[0];
	}
	
	$query = 'INSERT INTO `tblTopicsKeywords` (`topic_id`, `keyword_id`) VALUES ("'. $topic_id .'", "'. $keyword_id .'");';
	$keyword_result = mysql_query($query);	
}

echo ("\nHashtags:\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n");


$query = 'DELETE FROM `tblTopicsHashtags` WHERE `topic_id` = '. $topic_id .';';
$result = mysql_query($query);

foreach ($hashtagCSV_arr as $val) {
	echo ($val ."\n");
	
	$query = 'SELECT `id` FROM `tblHashtags` WHERE `title` = "'. substr($val, 1) .'";';
	$result = mysql_query($query);
	
	if (mysql_num_rows($result) == 0) {
	    $query = 'INSERT INTO `tblHashtags` (`id`, `title`, `active`, `added`) VALUES (NULL, "'. substr($val, 1) .'", "Y", NOW());';
		$hastag_result = mysql_query($query);	
		$hashtag_id = mysql_insert_id();
		
	} else {
		$row = mysql_fetch_row($result);
		$hashtag_id = $row[0];
	}
	
	$query = 'INSERT INTO `tblTopicsHashtags` (`topic_id`, `hashtag_id`) VALUES ("'. $topic_id .'", "'. $hashtag_id .'");';
	$hashtag_result = mysql_query($query);	
}
echo ("\nHandles:\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n");


$query = 'DELETE FROM `tblTopicsContributors` WHERE `topic_id` = '. $topic_id .';';
$result = mysql_query($query);

foreach ($handleCSV_arr as $val) {
	echo ($val ."\n");
	
	$query = 'SELECT `id` FROM `tblContributors` WHERE `handle` = "'. substr($val, 1) .'";';
	$result = mysql_query($query);
	
	if (mysql_num_rows($result) == 0) {
	    $query = 'INSERT INTO `tblContributors` (`id`, `handle`, `name`, `avatar_url`, `type_id`, `active`, `added`) VALUES (NULL, "'. substr($val, 1) .'", "'. substr($val, 1) .'", "https://api.twitter.com/1/users/profile_image?screen_name='. substr($val, 1) .'&size=reasonably_small", "1", "Y", NOW());';
		$handle_result = mysql_query($query);
		$handle_id = mysql_insert_id();
	
	} else {
		$row = mysql_fetch_row($result);
		$handle_id = $row[0];
	}
	
	$query = 'INSERT INTO `tblTopicsContributors` (`topic_id`, `contributor_id`) VALUES ("'. $topic_id .'", "'. $handle_id .'");';
	$handle_result = mysql_query($query);	
}


echo ("\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n[". $argv[1] ."] \"". $topic_name ."\"\n");

?>
