<?php 

session_start();

require './_db_open.php'; 
require_once('twitteroauth.php');
require_once('_oauth_cfg.php');
require_once('TwitterSearch.php');


function tweetsForTopicID($topic_id) {
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
	$search->user_agent = 'assembly:retriever@getassembly.com';

	$search_arr = array();
	
	$query = 'SELECT `tblHashtags`.`title` FROM `tblHashtags` INNER JOIN `tblTopicsHashtags` ON `tblHashtags`.`id` = `tblTopicsHashtags`.`hashtag_id` WHERE `tblTopicsHashtags`.`topic_id` = '. $topic_id .' AND `tblHashtags`.`active` = "Y";';
	$hashtag_result = mysql_query($query);
	while ($hashtag_row = mysql_fetch_array($hashtag_result, MYSQL_BOTH)) {
		echo ("TOPIC[". $topic_id ."] HASHTAG --> #". $hashtag_row['title'] ."\n");
		
		$results = $search->with($hashtag_row['title'])->results();
		foreach ($results as $key => $val) {
			array_push($search_arr, $results[$key]);
		}
	}
	
	echo ("\n");	
	$query = 'SELECT `tblKeywords`.`title` FROM `tblKeywords` INNER JOIN `tblTopicsKeywords` ON `tblKeywords`.`id` = `tblTopicsKeywords`.`keyword_id` WHERE `tblTopicsKeywords`.`topic_id` = '. $topic_id .' AND `tblKeywords`.`active` = "Y";';
	$keyword_result = mysql_query($query);	
	while ($keyword_row = mysql_fetch_array($keyword_result, MYSQL_BOTH)) {
		echo ("TOPIC[". $topic_id ."] KEYWORD --> ". str_replace("%22", "\"", $keyword_row['title']) ."\n");
		
		$results = $search->contains(str_replace("%22", "\"", $keyword_row['title']))->results();
		foreach ($results as $key => $val) {
			array_push($search_arr, $results[$key]);
		}
	}
	
	echo ("\n");	
	$query = 'SELECT `tblContributors`.`handle` FROM `tblContributors` INNER JOIN `tblTopicsContributors` ON `tblContributors`.`id` = `tblTopicsContributors`.`contributor_id` WHERE `tblTopicsContributors`.`topic_id` = '. $topic_id .' AND `tblContributors`.`active` = "Y" AND `tblContributors`.`type_id` = 1;';
	$contributor_result = mysql_query($query);	
	while ($contributor_row = mysql_fetch_array($contributor_result, MYSQL_BOTH)) {
		echo ("TOPIC[". $topic_id ."] HANDLE --> @". $contributor_row['handle'] ."\n");
		
		$results = $search->from($contributor_row['handle'])->results();
		foreach ($results as $key => $val) {
			array_push($search_arr, $results[$key]);
		}
	}
	
	echo ("\n");	
	$allTweet_arr = array();
	foreach($search_arr as $key => $val) {
		$query = 'SELECT `id` FROM `tblArticles` WHERE `tweet_id` = "'. $search_arr[$key]->id_str .'";';		
		if (mysql_num_rows(mysql_query($query)) > 0)
			continue;
			
		$query = 'SELECT `id` FROM `tblArticlesWorking` WHERE `tweet_id` = "'. $search_arr[$key]->id_str .'";';		
		if (mysql_num_rows(mysql_query($query)) > 0)
			continue;
			
		if ($search_arr[$key]->from_user == "OneWord_kenny")
			continue;
			
			
		preg_match_all('!https?://[\S]+!', $search_arr[$key]->text, $matches);
		if (count($matches[0]) == 0)
			continue;
			
		array_push($allTweet_arr, array(
			"tweet_id" => $search_arr[$key]->id_str, 
			"twitter_handle" => $search_arr[$key]->from_user,
			"twitter_name" => $search_arr[$key]->from_user_name, 
			"twitter_avatar" => "https://api.twitter.com/1/users/profile_image?screen_name=". $search_arr[$key]->from_user ."&size=normal", //$search_arr[$key]->profile_image_url, 
			"message" => $search_arr[$key]->text, 
			"retweets" => 0, 
			"created" => $search_arr[$key]->created_at,
			"created_at" => $search_arr[$key]->created_at			
		));
	}
	
	shuffle($allTweet_arr);
	$tweet_arr = array();
	
	$tot = 0;	
	foreach($allTweet_arr as $key => $val) {
		echo ("TWEET LOOKUP --> [". $allTweet_arr[$key]['tweet_id'] ."]\n");
		
		$allTweet_arr[$key]['retweets'] = 0;
		
		$timestamp_arr = explode(' ', $allTweet_arr[$key]['created_at']);
		$month = strtolower($timestamp_arr[2]);
		$day = $timestamp_arr[1];
		$time = $timestamp_arr[4];
		$year = $timestamp_arr[3];
		$allTweet_arr[$key]['created'] = $year ."-". $month_arr[$month] ."-". $day ." ". $time;
				
		$lookup = $search->lookup($allTweet_arr[$key]['tweet_id']);
	    $allTweet_arr[$key]['retweets'] = $lookup->retweet_count;
	
		array_push($tweet_arr, $allTweet_arr[$key]);
	
		$tot++;		
		if ($tot >= 20)
			break;
	}
	
	echo ("\n");
	$search_arr = array();	
	$query = 'SELECT `tblContributors`.`handle` FROM `tblContributors` INNER JOIN `tblTopicsContributors` ON `tblContributors`.`id` = `tblTopicsContributors`.`contributor_id` WHERE `tblTopicsContributors`.`topic_id` = '. $topic_id .' AND `tblContributors`.`active` = "Y" AND `tblContributors`.`type_id` = 3;';
	$contributor_result = mysql_query($query);	
	while ($contributor_row = mysql_fetch_array($contributor_result, MYSQL_BOTH)) {
		echo ("TOPIC[". $topic_id ."] HANDLE --> @". $contributor_row['handle'] ."\n");
		
		$results = $search->from($contributor_row['handle'])->results();
		foreach ($results as $key => $val) {
			array_push($search_arr, $results[$key]);
		}
	}
	
	foreach($search_arr as $key => $val) {
		$query = 'SELECT `id` FROM `tblArticles` WHERE `tweet_id` = "'. $search_arr[$key]->id_str .'";';		
		if (mysql_num_rows(mysql_query($query)) > 0)
			continue;
			
		$query = 'SELECT `id` FROM `tblArticlesWorking` WHERE `tweet_id` = "'. $search_arr[$key]->id_str .'";';		
		if (mysql_num_rows(mysql_query($query)) > 0)
			continue;
			
		echo ("TWEET LOOKUP --> [". $search_arr[$key]->id_str ."]\n");		
		$lookup = $search->lookup($search_arr[$key]->id_str);
	
		$timestamp_arr = explode(' ', $search_arr[$key]->created_at);
		$month = strtolower($timestamp_arr[2]);
		$day = $timestamp_arr[1];
		$time = $timestamp_arr[4];
		$year = $timestamp_arr[3];		
		
		array_push($tweet_arr, array(
			"tweet_id" => $search_arr[$key]->id_str, 
			"twitter_handle" => $search_arr[$key]->from_user,
			"twitter_name" => $search_arr[$key]->from_user_name, 
			"twitter_avatar" => "https://api.twitter.com/1/users/profile_image?screen_name=". $search_arr[$key]->from_user ."&size=normal", //$search_arr[$key]->profile_image_url, 
			"message" => $search_arr[$key]->text, 
			"retweets" => $lookup->retweet_count, 	
			"created_at" => $search_arr[$key]->created_at, 
			"created" => $year ."-". $month_arr[$month] ."-". $day ." ". $time			
		));
	}
	
	$tot = 0;
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
			   		
		preg_match_all('!https?://[\S]+!', $tweet_arr[$key]['message'], $matches);
		$url_arr = $matches[0];
		
		if (count($url_arr) == 1)
			$short_url = $url_arr[0];
		
		else
			$short_url = $url_arr[1];
		
		
		$query = 'INSERT INTO `tblArticlesWorking` (';
		$query .= '`id`, `type_id`, `tweet_id`, `contributor_id`, `tweet_msg`, `short_url`, `title`, `content_txt`, `content_url`, `image_url`, `retweets`, `image_ratio`, `youtube_id`, `active`, `created`, `added`) ';
		$query .= 'VALUES (NULL, "0", "'. $tweet_arr[$key]['tweet_id'] .'", "'. $contributor_id .'", "'. $tweet_arr[$key]['message'] .'", "'. $short_url .'", "", "", "", "", "'. $tweet_arr[$key]['retweets'] .'", "1.0", "", "N", "'. $tweet_arr[$key]['created'] .'", NOW());';	 
	    $ins1_result = mysql_query($query);
		$article_id = mysql_insert_id();
		
		$query = 'INSERT INTO `tblTopicsArticlesWorking` ('; 
		$query .= '`topic_id`, `article_id`) ';
		$query .= 'VALUES ("'. $topic_id .'", "'. $article_id .'");';
		$ins2_result = mysql_query($query);
		
		echo ("INSERT(". ($tot + 1) ."/". count($tweet_arr) .") -> [". $article_id ."][". $tweet_arr[$key]['tweet_id'] ."] (". $tweet_arr[$key]['created'] .") FOR [". $topic_id ."]>> {". $tweet_arr[$key]['retweets'] ."} \"". $tweet_arr[$key]['message'] ."\"\n");
		$tot++;		
	}	
}


$start_date = "0000-00-00 00:00:00";
if (isset($argv[1]))
	$start_date = $argv[1];


$result = mysql_query('DELETE FROM `tblArticlesWorking` WHERE 1 = 1;');
$result = mysql_query('ALTER TABLE `tblArticlesWorking` AUTO_INCREMENT = 1;');  
$result = mysql_query('DELETE FROM `tblTopicsArticlesWorking` WHERE 1 = 1;');  
$result = mysql_query('DELETE FROM `tblArticleImagesWorking` WHERE 1 = 1;');
$result = mysql_query('ALTER TABLE `tblArticleImagesWorking` AUTO_INCREMENT = 1;');
	

$query = 'SELECT * FROM `tblTopics` WHERE `active` = "Y" ORDER BY `id`;';
$topic_result = mysql_query($query);

while ($topic_row = mysql_fetch_array($topic_result, MYSQL_BOTH)) {
	tweetsForTopicID($topic_row['id']);
	echo ("[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n");	
}


   


/*
16:34:00
16:36:05
16:39:00
128x128
https://api.twitter.com/1/users/profile_image?screen_name=Contreras_J&size=reasonably_small

48x48
https://api.twitter.com/1/users/profile_image?screen_name=Contreras_J&size=normal
*/

require './_db_close.php'; 

?>