<?php 

session_start();

require './_db_open.php'; 
require_once('twitteroauth.php');
require_once('_oauth_cfg.php');
require_once('TwitterSearch.php');

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

$search = new TwitterSearch();
$search->user_agent = 'assembly:staff@getassembly.com';

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
		array_push($keyword_arr, str_replace("%22", "\"", $keyword_row['title']));
		
		$results = $search->contains(str_replace("%22", "\"", $keyword_row['title']))->results();
		foreach ($results as $key => $val) {
			array_push($search_arr, $results[$key]);
		}
	}
	
	$query = 'SELECT `tblContributors`.`handle` FROM `tblContributors` INNER JOIN `tblTopicsContributors` ON `tblContributors`.`id` = `tblTopicsContributors`.`contributor_id` WHERE `tblTopicsContributors`.`topic_id` = '. $topic_row['id'] .' AND `tblContributors`.`active` = "Y" AND `tblContributors`.`type_id` = 1;';
	$contributor_result = mysql_query($query);
	
	$contributor_arr = array();
	while ($contributor_row = mysql_fetch_array($contributor_result, MYSQL_BOTH)) {
		array_push($contributor_arr, $contributor_row['handle']);
		
		$results = $search->from($contributor_row['handle'])->results();
		foreach ($results as $key => $val) {
			array_push($search_arr, $results[$key]);
		}
	}
	
	$tweet_arr = array();
	foreach($search_arr as $key => $val) {
		array_push($tweet_arr, array(
			"tweet_id" => $search_arr[$key]->id_str, 
			"twitter_handle" => $search_arr[$key]->from_user,
			"twitter_name" => $search_arr[$key]->from_user_name, 
			"twitter_avatar" => "https://api.twitter.com/1/users/profile_image?screen_name=". $search_arr[$key]->from_user ."&size=reasonably_small", //$search_arr[$key]->profile_image_url, 
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
			preg_match_all('!https?://[\S]+!', $tweet_arr[$key]['message'], $matches);			
			$short_url = $matches[0];
			
			if (count($short_url) > 0) {
				$timestamp_arr = explode(' ', $tweet_arr[$key]['created']);
				$month = strtolower($timestamp_arr[2]);
				$day = $timestamp_arr[1];
				$time = $timestamp_arr[4];
				$year = $timestamp_arr[3];
		
				$created = $year ."-". $month_arr[$month] ."-". $day ." ". $time;
			
			
				if (strlen($short_url[0]) > 0) {
					$query = 'INSERT INTO `tblArticles` (';
					$query .= '`id`, `type_id`, `tweet_id`, `contributor_id`, `tweet_msg`, `short_url`, `title`, `content_txt`, `content_url`, `image_url`, `image_ratio`, `youtube_id`, `active`, `created`, `added`) ';
					$query .= 'VALUES (NULL, "0", "'. $tweet_arr[$key]['tweet_id'] .'", "'. $contributor_id .'", "'. $tweet_arr[$key]['message'] .'", "'. $short_url[0] .'", "", "", "", "", "1.0", "", "N", "'. $created .'", NOW());';	 
				    $result = mysql_query($query);
					$article_id = mysql_insert_id();
					
					$query = 'INSERT INTO `tblTopicsArticles` ('; 
					$query .= '`topic_id`, `article_id`) ';
					$query .= 'VALUES ("'. $topic_row['id'] .'", "'. $article_id .'");';
					$result = mysql_query($query);
					
					echo ("INSERT -> [". $article_id ."][". $tweet_arr[$key]['tweet_id'] ."] (". $created .")\n\"". $tweet_arr[$key]['message'] ."\"\n\n");
				}
			}
		
		} else {
			$article_row = mysql_fetch_row(mysql_query($query));
			$article_id = $article_row[0];
		}	  
	}
}

require './_db_close.php'; 

?>