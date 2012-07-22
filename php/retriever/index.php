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
	$tweet_arr = array();
	foreach($search_arr as $key => $val) {
		array_push($tweet_arr, array(
			"tweet_id" => $search_arr[$key]->id_str, 
			"twitter_handle" => $search_arr[$key]->from_user,
			"twitter_name" => $search_arr[$key]->from_user_name, 
			"twitter_avatar" => "https://api.twitter.com/1/users/profile_image?screen_name=". $search_arr[$key]->from_user ."&size=normal", //$search_arr[$key]->profile_image_url, 
			"message" => $search_arr[$key]->text, 
			"retweets" => 0, 	
			"created" => $search_arr[$key]->created_at
			
		));
	}
	
	shuffle($tweet_arr);
	
	$tot = 0;	
	foreach($tweet_arr as $key => $val) {
		echo ("TWEET LOOKUP --> [". $tweet_arr[$key]['tweet_id'] ."]\n");
		
		$lookup = $search->lookup($tweet_arr[$key]['tweet_id']);
	    $tweet_arr[$key]['retweets'] = $lookup->retweet_count;
	
		$timestamp_arr = explode(' ', $tweet_arr[$key]['created']);
		$month = strtolower($timestamp_arr[2]);
		$day = $timestamp_arr[1];
		$time = $timestamp_arr[4];
		$year = $timestamp_arr[3];
		$tweet_arr[$key]['created'] = $year ."-". $month_arr[$month] ."-". $day ." ". $time;
		
		$tot++;		
		if ($tot >= 20)
			break;
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
		
		
		$query = 'SELECT `id` FROM `tblArticles` WHERE `tweet_id` = "'. $tweet_arr[$key]['tweet_id'] .'";';		
		if (mysql_num_rows(mysql_query($query)) == 0) {
			preg_match_all('!https?://[\S]+!', $tweet_arr[$key]['message'], $matches);			
			$short_url = $matches[0];
			
			if (count($short_url) > 0) {
				if (strlen($short_url[0]) > 0) {
					//$lookup = $search->lookup($tweet_arr[$key]['tweet_id']);                    
					//$retweet_count = $lookup->retweet_count;
					
					$query = 'INSERT INTO `tblArticles` (';
					$query .= '`id`, `type_id`, `tweet_id`, `contributor_id`, `tweet_msg`, `short_url`, `title`, `content_txt`, `content_url`, `image_url`, `retweets`, `image_ratio`, `youtube_id`, `active`, `created`, `added`) ';
					$query .= 'VALUES (NULL, "0", "'. $tweet_arr[$key]['tweet_id'] .'", "'. $contributor_id .'", "'. $tweet_arr[$key]['message'] .'", "'. $short_url[0] .'", "", "", "", "", "'. $tweet_arr[$key]['retweets'] .'", "1.0", "", "N", "'. $tweet_arr[$key]['created'] .'", NOW());';	 
				    $ins1_result = mysql_query($query);
					$article_id = mysql_insert_id();
					
					$query = 'INSERT INTO `tblTopicsArticles` ('; 
					$query .= '`topic_id`, `article_id`) ';
					$query .= 'VALUES ("'. $topic_id .'", "'. $article_id .'");';
					$ins2_result = mysql_query($query);
					
					echo ("INSERT(". ($tot + 1) ."/20) -> [". $article_id ."][". $tweet_arr[$key]['tweet_id'] ."] (". $tweet_arr[$key]['created'] .") FOR [". $topic_id ."]>> ". $tweet_arr[$key]['retweets'] ."\n\"". $tweet_arr[$key]['message'] ."\"\n\n");
					$tot++;
				}
			}   	
		}
		
		if ($tot >= 20)
			break;
	}
	
	/*
	$query = 'SELECT * FROM `tblArticles` WHERE `added` >= "'. $start_ts .'";';
	$article_result = mysql_query($query);
	while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) {
		$query = 'SELECT * FROM `tblTopicsArticles` WHERE `article_id` = '. $article_row['id'] .';';
		$topic_result = mysql_query($query);
	
		if (mysql_num_rows($topic_result) > 1) {
		
			$cnt = 0;
			while ($topic_row = mysql_fetch_array($topic_result, MYSQL_BOTH)) {
				$cnt++;			
				if ($cnt == 1)
					continue;
			
				$query = 'DELETE FROM `tblTopicsArticles` WHERE `topic_id` = '. $topic_row['topic_id'] .' AND `article_id` = '. $topic_row['article_id'] .';';
				//$del_result = mysql_query($query);			
				echo ("REMOVING -> [". $article_row['id'] ."][". $article_row['tweet_id'] ."] (". $topic_row['topic_id'] .")\n\"". $article_row['tweet_msg'] ."\"\n\n");
			}
		}
	}
	*/
}

$query = 'SELECT * FROM `tblTopics` WHERE `active` = "Y" ORDER BY `id`;';
$topic_result = mysql_query($query);

while ($topic_row = mysql_fetch_array($topic_result, MYSQL_BOTH)) {
	tweetsForTopicID($topic_row['id']);
	echo ("[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n");	
}

/*
while ($topic_row = mysql_fetch_array($topic_result, MYSQL_BOTH)) {
	$search_arr = array();
	
	$query = 'SELECT `tblHashtags`.`title` FROM `tblHashtags` INNER JOIN `tblTopicsHashtags` ON `tblHashtags`.`id` = `tblTopicsHashtags`.`hashtag_id` WHERE `tblTopicsHashtags`.`topic_id` = '. $topic_row['id'] .' AND `tblHashtags`.`active` = "Y";';
	$hashtag_result = mysql_query($query);
	
	while ($hashtag_row = mysql_fetch_array($hashtag_result, MYSQL_BOTH)) {
		$results = $search->with($hashtag_row['title'])->results();
		foreach ($results as $key => $val) {
			array_push($search_arr, $results[$key]);
		}
	}
	
	$query = 'SELECT `tblKeywords`.`title` FROM `tblKeywords` INNER JOIN `tblTopicsKeywords` ON `tblKeywords`.`id` = `tblTopicsKeywords`.`keyword_id` WHERE `tblTopicsKeywords`.`topic_id` = '. $topic_row['id'] .' AND `tblKeywords`.`active` = "Y";';
	$keyword_result = mysql_query($query);
	
	while ($keyword_row = mysql_fetch_array($keyword_result, MYSQL_BOTH)) {
		$results = $search->contains(str_replace("%22", "\"", $keyword_row['title']))->results();
		foreach ($results as $key => $val) {
			array_push($search_arr, $results[$key]);
		}
	}
	
	$query = 'SELECT `tblContributors`.`handle` FROM `tblContributors` INNER JOIN `tblTopicsContributors` ON `tblContributors`.`id` = `tblTopicsContributors`.`contributor_id` WHERE `tblTopicsContributors`.`topic_id` = '. $topic_row['id'] .' AND `tblContributors`.`active` = "Y" AND `tblContributors`.`type_id` = 1;';
	$contributor_result = mysql_query($query);
	
	while ($contributor_row = mysql_fetch_array($contributor_result, MYSQL_BOTH)) {
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
	
	shuffle($tweet_arr);
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
					$ch = curl_init();
					curl_setopt($ch, CURLOPT_URL, "https://api.twitter.com/1/statuses/show.json?id=". $tweet_arr[$key]['tweet_id']);
					curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type:application/json'));
					curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
					$response = curl_exec($ch);
    				curl_close ($ch);
    
					$json_arr = json_decode($response, true);
					$retweet_count = $json_arr['retweet_count'];
					
					
					$query = 'INSERT INTO `tblArticles` (';
					$query .= '`id`, `type_id`, `tweet_id`, `contributor_id`, `tweet_msg`, `short_url`, `title`, `content_txt`, `content_url`, `image_url`, `retweets`, `image_ratio`, `youtube_id`, `active`, `created`, `added`) ';
					$query .= 'VALUES (NULL, "0", "'. $tweet_arr[$key]['tweet_id'] .'", "'. $contributor_id .'", "'. $tweet_arr[$key]['message'] .'", "'. $short_url[0] .'", "", "", "", "", "'. $retweet_count .'", "1.0", "", "N", "'. $created .'", NOW());';	 
				    $result = mysql_query($query);
					$article_id = mysql_insert_id();
					
					$query = 'SELECT * FROM `tblTopicsArticles` INNER JOIN `tblArticles` ON `tblTopicsArticles`.`article_id` = `tblArticles`.`id` WHERE `tblArticles`.`tweet_id` = "'. $tweet_arr[$key]['tweet_id'] .'"';
					$ta_result = mysql_query($query);
					
					if (mysql_num_rows($ta_result) == 0) {
						$query = 'INSERT INTO `tblTopicsArticles` ('; 
						$query .= '`topic_id`, `article_id`) ';
						$query .= 'VALUES ("'. $topic_row['id'] .'", "'. $article_id .'");';
						$result = mysql_query($query);
					}
					
					echo ("INSERT -> [". $article_id ."][". $tweet_arr[$key]['tweet_id'] ."] (". $created .") FOR [". $topic_row['id'] ."]>> ". $retweet_count ."\n\"". $tweet_arr[$key]['message'] ."\"\n\n");
					$tot++;
				}
			}
		
		}
		
		if ($tot >= 20)
			break;
	}
}


128x128
https://api.twitter.com/1/users/profile_image?screen_name=Contreras_J&size=reasonably_small

48x48
https://api.twitter.com/1/users/profile_image?screen_name=Contreras_J&size=normal



*/

require './_db_close.php'; 

?>