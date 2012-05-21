<?php 

session_start();

require './_db_open.php'; 
require_once('twitteroauth.php');
require_once('_oauth_cfg.php');
require_once('TwitterSearch.php');

$access_token = $_SESSION['access_token'];
$connection = new TwitterOAuth(CONSUMER_KEY, CONSUMER_SECRET, $access_token['oauth_token'], $access_token['oauth_token_secret']);
$tweetProfile_obj = $connection->get('account/verify_credentials');

/*
$curator_arr = array();   
$tweetLookup_obj = $connection->get('users/lookup', array('screen_name' => 'andvari'));
foreach ($tweetLookup_obj as $key => $val) {
	array_push($curator_arr, array(
		"id" => $tweetLookup_obj[$key]->id_str, 
		"name" => $tweetLookup_obj[$key]->name, 
		"handle" => $tweetLookup_obj[$key]->screen_name,  
		"avatar" => str_replace("_normal.", "_reasonably_small.", $tweetLookup_obj[$key]->profile_image_url), 
		"info" => $tweetLookup_obj[$key]->description
	));	
} 
*/

$search = new TwitterSearch();
$search->user_agent = 'assembly:staff@getassembly.com';

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

$query = 'SELECT * FROM `tblTopics` WHERE `active` = "Y";';
$topic_result = mysql_query($query);

$topic_arr = array();
while ($topic_row = mysql_fetch_array($topic_result, MYSQL_BOTH)) {
	$search_arr = array();
	
	$query = 'SELECT `tblHashtags`.`title` FROM `tblHashtags` INNER JOIN `tblTopicsHashtags` ON `tblHashtags`.`id` = `tblTopicsHashtags`.`hashtag_id` WHERE `tblTopicsHashtags`.`topic_id` = '. $topic_row['id'] .' AND `tblHashtags`.`active` = "Y";';
	$hashtag_result = mysql_query($query);
	
	$hashtag_arr = array();
	while ($hashtag_row = mysql_fetch_array($hashtag_result, MYSQL_BOTH)) {
		array_push($hashtag_arr, $hashtag_row['title']);
		
		$results = $search->with($hashtag_row['title'])->results();
		foreach ($results as $key => $val) {
			array_push($search_arr, $results[$key]);
		}
	}
	
	$query = 'SELECT `tblKeywords`.`title` FROM `tblKeywords` INNER JOIN `tblTopicsKeywords` ON `tblKeywords`.`id` = `tblTopicsKeywords`.`keyword_id` WHERE `tblTopicsKeywords`.`topic_id` = '. $topic_row['id'] .' AND `tblKeywords`.`active` = "Y";';
	$keyword_result = mysql_query($query);
	
	$keyword_arr = array();
	while ($keyword_row = mysql_fetch_array($keyword_result, MYSQL_BOTH)) {
		array_push($hashtag_arr, $keyword_row['title']);
		
		$results = $search->with($keyword_row['title'])->results();
		foreach ($results as $key => $val) {
			array_push($search_arr, $results[$key]);
		}
	}
	
	$query = 'SELECT `tblContributors`.`handle` FROM `tblContributors` INNER JOIN `tblTopicsContributors` ON `tblContributors`.`id` = `tblTopicsContributors`.`contributor_id` WHERE `tblTopicsContributors`.`topic_id` = '. $topic_row['id'] .' AND `tblContributors`.`active` = "Y" AND `tblContributors`.`type_id` = 1;';
	$contributor_result = mysql_query($query);
	
	$contributor_arr = array();
	while ($contributor_row = mysql_fetch_array($contributor_result, MYSQL_BOTH)) {
		array_push($hashtag_arr, $contributor_row['handle']);
		
		$results = $search->from($contributor_row['handle'])->results();
		foreach ($results as $key => $val) {
			array_push($search_arr, $results[$key]);
		}
	}
	
	$tweet_arr = array();
	foreach($search_arr as $key => $val) {
		//echo($search_arr[$key]->id_str."<br />");

/*		
		$retweet_arr = array();
		$retweet_obj = $connection->get('statuses/retweets/'. $search_arr[$key]->id_str, array('count' => "10"));
		print_r($retweet_obj); 
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
		
			//$query = 'INSERT INTO `tblRetweets` (';
			//$query .= '`id`, `tweet_id`, `retweet_id`, `handle`, `avatar_url`, `created`, `added`) ';
			//$query .= 'VALUES (NULL, "'. $tweet_id .'", "'. $retweet_obj[$key]->id_str .'", "'. $retweet_obj[$key]->user->screen_name .'", "'. $retweet_obj[$key]->user->profile_image_url .'", "'. $created .'" NOW());';
			//$result = mysql_query($query);
			//$retweet_id = mysql_insert_id();
		}
*/
		
		array_push($tweet_arr, array(
			"tweet_id" => $search_arr[$key]->id_str, 
			"twitter_handle" => $search_arr[$key]->from_user,
			"twitter_name" => $search_arr[$key]->from_user_name, 
			"twitter_avatar" => $search_arr[$key]->profile_image_url, 
			"message" => $search_arr[$key]->text, 
			"created" => $search_arr[$key]->created_at	
		));
	}
	
	foreach($tweet_arr as $key => $val) {
		
		$query = 'SELECT `id` FROM `tblContributors` WHERE `handle` = "'. $tweet_arr[$key]['twitter_handle'] .'";';		
		if (mysql_num_rows(mysql_query($query)) == 0) {
			$query = 'INSERT INTO `tblContributors` (';
			$query .= '`id`, `handle`, `name`, `avatar_url`, `type_id`, `active`, `added`) ';
			$query .= 'VALUES (NULL, "'. $tweet_arr[$key]['twitter_handle'] .'", "'. $tweet_arr[$key]['twitter_name'] .'", "'. $tweet_arr[$key]['twitter_avatar'] .'", "2", "N", NOW());';	 
			$result = mysql_query($query);
			$contributor_id = mysql_insert_id();			
		
		} else {
			$contributor_row = mysql_fetch_row(mysql_query($query));
			$contributor_id = $contributor_row[0];
		}
		
		
		$query = 'SELECT `id` FROM `tblArticles` WHERE `tweet_id` = "'. $tweet_arr[$key]['tweet_id'] .'";';		
		if (mysql_num_rows(mysql_query($query)) == 0) {
			echo($tweet_arr[$key]['created'] ."<br />");
			
			
			$timestamp_arr = explode(' ', $tweet_arr[$key]['created']);
			$month = strtolower($timestamp_arr[2]);
			$day = $timestamp_arr[1];
			$time = $timestamp_arr[4];
			$year = $timestamp_arr[3];
		
			$created = $year ."-". $month_arr[$month] ."-". $day ." ". $time;
			
			$query = 'INSERT INTO `tblArticles` (';
			$query .= '`id`, `type_id`, `tweet_id`, `contributor_id`, `tweet_msg`, `title`, `content_txt`, `content_url`, `image_url`, `image_ratio`, `youtube_id`, `active`, `created`, `added`) ';
			$query .= 'VALUES (NULL, "0", "'. $tweet_arr[$key]['tweet_id'] .'", "'. $contributor_id .'", "'. $tweet_arr[$key]['message'] .'", "", "", "", "", "1.0", "", "N", "'. $created .'", NOW());';	 
			echo ($query ."<br />");
		    $result = mysql_query($query);
			$article_id = mysql_insert_id();			
			
			$query = 'INSERT INTO `tblTopicsArticles` ('; 
			$query .= '`topic_id`, `article_id`) ';
			$query .= 'VALUES ("'. $topic_row['id'] .'", "'. $article_id .'");';
			$result = mysql_query($query);
		
		} else {
			$article_row = mysql_fetch_row(mysql_query($query));
			$article_id = $article_row[0];
		}	  
		
		echo ("[". $contributor_id ."][". $article_id ."] <br />");
		
		



		//$query = 'INSERT INTO `tblArticles` (';
	    //$query .= '`id`, `type_id`, `tweet_id`, `contributor_id`, `title`, `content_txt`, `content_url`, `image_url`, `image_ratio`, `youtube_id`, `active`, `added`) ';
		//$query .= 'VALUES (NULL, "1", "'. $retweet_obj[$key]->id_str .'", "'. $retweet_obj[$key]->user->screen_name .'", "'. $retweet_obj[$key]->user->profile_image_url .'", "'. $created .'" NOW());';
		//$result = mysql_query($query);
		//$retweet_id = mysql_insert_id();
	}
	
	
	//print_r($tweet_arr);
}



//$search = new TwitterSearch('awkward penguin');
//$search = new TwitterSearch('joseph ducreux');
//$search->user_agent = 'assembly:staff@getassembly.com';
//$results = $search->results();
//print_r($results[0]);

/*
$tweet_arr = array();
foreach ($results as $key => $val) {
	
	$tweet_msg = eregi_replace('(((f|ht){1}tp://)[-a-zA-Z0-9@:%_\+.~#?&//=]+)', '<a href="\\1" target="_blank">\\1</a>', $results[$key]->text); 
	$tweet_msg = eregi_replace('([[:space:]()[{}])(www.[-a-zA-Z0-9@:%_\+.~#?&//=]+)', '\\1<a href="http://\\2">\\2</a>', $tweet_msg); 
	$tweet_msg = eregi_replace('([_\.0-9a-z-]+@([0-9a-z][0-9a-z-]+\.)+[a-z]{2,3})', '<a href="mailto:\\1">\\1</a>', $tweet_msg);
	$tweet_msg = eregi_replace('@([_\.0-9a-z-]+)', '<a href="https://twitter.com/#!/\\1" target="_blank">@\\1</a>', $tweet_msg);
	
	
	array_push($tweet_arr, array(
		"tweet_id" => $results[$key]->id_str, 
		"user_handle" => $results[$key]->from_user, 
		"user_avatar" => $results[$key]->profile_image_url, 
		"message" => $tweet_msg, 
		"created" => $results[$key]->created_at
	));
	//print_r($results[$key]->created_at . "\n");
}

//print_r($tweet_arr);

foreach($tweet_arr as $key => $val) {
	echo(eregi_replace('([_\.0-9a-z-]+)', '<a href="https://twitter.com/#!/\\1" target="_blank">@\\1</a>', $results[$key]->from_user) ."<br />". $val['message'] ."<hr />");
}
*/

/*
$friend_arr = array();
$tweetLookup_obj = $connection->get('friends/ids', array('screen_name' => 'andvari'));	
foreach ($tweetLookup_obj->ids as $key => $val) {
	print_r ("IDS:[". $val ."]");
}
*/

?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<meta http-equiv="Content-language" value="en" />
	</head>
	
	<body>
		<?php if (empty($_SESSION['access_token'])) {
			echo ("<a href=\"./redirect.php\">Sign in</a>");
		
		} else {
			echo ("Signed into Twitter as @". $tweetProfile_obj->screen_name ." <a href=\"./signout.php\">Signout</a>");
		} ?><hr />   
	</body>
</html>

<?php require './_db_close.php'; ?>



<?php
	//print_r($tweet_obj);

	//$content = $connection->get('account/rate_limit_status');
	//echo "Current API hits remaining: {$content->remaining_hits}.";

/*
	$tweet_obj = $connection->get('friends/ids', array('screen_name' => $handle));
	$follower_tot = count($tweet_obj->ids);

	$id_arr = array();
	foreach ($tweet_obj->ids as $key => $val)
		array_push($id_arr, $val);
	

	$paged_arr = array_chunk($id_arr, 100);
	$follower_arr = array();

	for ($i=0; $i<count($paged_arr); $i++) {
		$id_str = "";
	
		foreach ($paged_arr[$i] as $val)
			$id_str .= $val .",";	
	
		$id_str = substr_replace($id_str, "", -1);
		$tweet_obj = $connection->get('users/lookup', array('user_id' => $id_str));
	
		foreach ($tweet_obj as $key => $val) {
			array_push($follower_arr, array(
				"id" => $tweet_obj[$key]->id_str, 
				"name" => $tweet_obj[$key]->name, 
				"handle" => $tweet_obj[$key]->screen_name,  
				"avatar" => str_replace("_normal.", "_reasonably_small.", $tweet_obj[$key]->profile_image_url), 
				"info" => $tweet_obj[$key]->description
			));
		}
	}
*/	
?>