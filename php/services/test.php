<?php

//$subscriptions_xml = new SimpleXMLElement('http://gdata.youtube.com/feeds/api/users/getassemblytv/subscriptions', NULL, true);

//echo ("SUBSCRIPTION_ID:". $subscriptions_xml->id ."<br /><hr />");

/*
$subscribers_arr = array();
foreach ($subscriptions_xml -> entry as $subscription_entry) {
	$attr_arr = $subscription_entry->link[1]->attributes();
	$href_arr = explode('/', $attr_arr['href']);
	$youtube_id = $href_arr[4];
	
	$title_arr = explode(': ', $subscription_entry->title);
	$youtube_name = strtolower($title_arr[1]);
	$upload_url = "http://gdata.youtube.com/feeds/api/users/". $youtube_name ."/uploads";
    echo ("<p><img src=\"http://i4.ytimg.com/i/". $youtube_id ."/1.jpg\" width=\"88\" height=\"88\" /><br />");
	echo ("<strong>". $youtube_name ."</strong><br />");
	
	$user_xml = new SimpleXMLElement('http://gdata.youtube.com/feeds/api/users/'. strtolower($youtube_name), NULL, true);
	$created_date = $user_xml->published;
	$updated_date = $user_xml->updated;
	
	
	$videos_xml = new SimpleXMLElement('http://gdata.youtube.com/feeds/api/users/'. $youtube_name .'/uploads', NULL, true);
	
	foreach ($videos_xml -> entry as $video_entry) {
		$id_arr = explode('/', $video_entry->id);
		$video_id = $id_arr[count($id_arr) - 1];
		
		echo ("<img src=\"http://i.ytimg.com/vi/". $video_id ."/0.jpg\" height=\"360\" width=\"480\" />");
	}
    
	echo ("</p><p /><hr />");
}
*/

//$channel_name = "CNN";
//$videos_xml = new SimpleXMLElement('http://gdata.youtube.com/feeds/api/users/'. strtolower($channel_name) .'/uploads', NULL, true);

//$tot = 0;
/*
foreach ($videos_xml -> entry as $video_entry) {
	$id_arr = explode('/', $video_entry->id);
	
	$video_id = $id_arr[count($id_arr) - 1];
	$title = $video_entry->title;
	$info = $video_entry->content;
	$added = $video_entry->published;
	
	echo ("ID:[". $video_id ."]<br />");
	echo ("TITLE:[". $title ."]<br />");
	echo ("INFO:[". $info ."]<br />");
	echo ("ADDED:[". $added ."]<br />");
}*/

/*
$followers = "1|3|4|5";


$followers_sql = '';
if ($followers) {
	$followers_sql = ' AND (';
	$follower_arr = explode('|', $followers);
	
	foreach ($follower_arr as $follower_id)
		$followers_sql .= '`follower_id` = "'. $follower_id .'" OR ';
	
	$followers_sql = substr($followers_sql, 0, -4);
	$followers_sql .= ')';
	
}

$query = 'SELECT * FROM `tblArticles` WHERE `added` < "'. $date .'"'. $followers_sql .';';

echo ($query);
*/

// make the connection
$db_conn = mysql_connect('internal-db.s41232.gridserver.com', 'db41232_sn_usr', 'dope911t') or die("Could not connect to database.");

// select the proper db
mysql_select_db('db41232_simplenews') or die("Could not select database.");

// get the current date / time from mysql
$ts_result = mysql_query("SELECT NOW();") or die("Couldn't get the date from MySQL");
$row = mysql_fetch_row($ts_result);
$sql_time = $row[0];


$query = 'SELECT * FROM `tblLists`;';
$result = mysql_query($query);

while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {	
	$query = 'UPDATE `tblLists` SET `enc_name` = "'. base64_encode($row['title']) .'" WHERE `id` ='. $row['id'] .';';
	$res = mysql_query($query);
}



?>