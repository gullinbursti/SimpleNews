<?php

// start the session engine
session_start();


require_once('twitteroauth/twitteroauth.php');
require_once('_oauth_cfg.php');

$access_token = $_SESSION['access_token'];

// make the connection
$db_conn = mysql_connect('internal-db.s41232.gridserver.com', 'db41232_sn_usr', 'dope911t') or die("Could not connect to database.");

// select the proper db
mysql_select_db('db41232_simplenews') or die("Could not select database.");

// get the current date / time from mysql
$ts_result = mysql_query("SELECT NOW();") or die("Couldn't get the date from MySQL");
$row = mysql_fetch_row($ts_result);
$sql_time = $row[0];


$connection = new TwitterOAuth(CONSUMER_KEY, CONSUMER_SECRET, $access_token['oauth_token'], $access_token['oauth_token_secret']);
/*$tweet_obj = $connection->get('statuses/retweets', array(
	'id' => $_GET['tID'], 
	'count' => "10"
));

print_r($tweet_obj);

foreach($tweet_obj as $key => $val) {
	
}
*/

$month_arr = array(
	"jan" => "01", 
	"feb" => "02", 
	"mar" => "03", 
	"apr" => "04", 
	"may" => "05", 
	"jun" => "06", 
	"jul" => "07", 
	"aug" => "08", 
	"sep" => "09", 
	"oct" => "10", 
	"nov" => "11", 
	"dec" => "12" 
);

$query = 'SELECT * FROM `tblArticles` WHERE `tweet_id` != "0" AND `source_id` = 1;';
$result = mysql_query($query);

while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
	$retweet_obj = $connection->get('statuses/retweets/'. $row['tweet_id'], array('count' => "10"));

	foreach ($retweet_obj as $key => $val) {
		$retweet_id = $retweet_obj[$key]->id_str;
		$avatar_url = $retweet_obj[$key]->user->profile_image_url;
		$twitter_name = $retweet_obj[$key]->user->name;
		$handle = $retweet_obj[$key]->user->screen_name;
	
		$timestamp_arr = explode(' ', $retweet_obj[$key]->created_at);
		$month = strtolower($timestamp_arr[1]);
		$day = $timestamp_arr[2];
		$time = $timestamp_arr[3];
		$year = $timestamp_arr[5];
	
		$created = $year ."-". $month_arr[$month] ."-". $day ." ". $time;
	    
		$query = 'SELECT `retweet_id` FROM `tblRetweets` WHERE `tweet_id` = "'. $row['tweet_id'] .'";';
		$dup_result = mysql_query($query);
	
		if (mysql_num_rows(mysql_query($query)) == 0) {
			$query = 'INSERT INTO `tblRetweets` (';
			$query .= '`id`, `tweet_id`, `retweet_id`, `handle`, `name`, `avatar_url`, `created`, `added`) ';
			$query .= 'VALUES (NULL, "'. $row['tweet_id'] .'", "'. $retweet_obj[$key]->id_str .'", "'. $retweet_obj[$key]->user->screen_name .'", "'. $retweet_obj[$key]->user->name .'", "'. $retweet_obj[$key]->user->profile_image_url .'", "'. $created .'", NOW());';
			$res = mysql_query($query);		
			$retweet_id = mysql_insert_id();
		}
		
		//echo ($query);
	}	
} 

?>