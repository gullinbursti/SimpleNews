<?php

	class Articles {
		private $db_conn;
	
	  	function __construct() {
		
			$this->db_conn = mysql_connect('localhost', 'db41232_sn_usr', 'dope911t') or die("Could not connect to database.");
			mysql_select_db('assembly2') or die("Could not select database.");
		}
	
		function __destruct() {	
			if ($this->db_conn) {
				mysql_close($this->db_conn);
				$this->db_conn = null;
			}
		}
		
		
		/**
		 * Helper method to get a string description for an HTTP status code
		 * http://www.gen-x-design.com/archives/create-a-rest-api-with-php/ 
		 * @returns status
		 */
		function getStatusCodeMessage($status) {
			
			$codes = Array(
				100 => 'Continue',
				101 => 'Switching Protocols',
				200 => 'OK',
				201 => 'Created',
				202 => 'Accepted',
				203 => 'Non-Authoritative Information',
				204 => 'No Content',
				205 => 'Reset Content',
				206 => 'Partial Content',
				300 => 'Multiple Choices',
				301 => 'Moved Permanently',
				302 => 'Found',
				303 => 'See Other',
				304 => 'Not Modified',
				305 => 'Use Proxy',
				306 => '(Unused)',
				307 => 'Temporary Redirect',
				400 => 'Bad Request',
				401 => 'Unauthorized',
				402 => 'Payment Required',
				403 => 'Forbidden',
				404 => 'Not Found',
				405 => 'Method Not Allowed',
				406 => 'Not Acceptable',
				407 => 'Proxy Authentication Required',
				408 => 'Request Timeout',
				409 => 'Conflict',
				410 => 'Gone',
				411 => 'Length Required',
				412 => 'Precondition Failed',
				413 => 'Request Entity Too Large',
				414 => 'Request-URI Too Long',
				415 => 'Unsupported Media Type',
				416 => 'Requested Range Not Satisfiable',
				417 => 'Expectation Failed',
				500 => 'Internal Server Error',
				501 => 'Not Implemented',
				502 => 'Bad Gateway',
				503 => 'Service Unavailable',
				504 => 'Gateway Timeout',
				505 => 'HTTP Version Not Supported');

			return (isset($codes[$status])) ? $codes[$status] : '';
		}
		
		
		/**
		 * Helper method to send a HTTP response code/message
		 * @returns body
		 */
		function sendResponse($status=200, $body='', $content_type='text/html') {
			
			$status_header = "HTTP/1.1 ". $status ." ". $this->getStatusCodeMessage($status);
			header($status_header);
			header("Content-type: ". $content_type);
			echo $body;
		}
		
		function getArticlesForTopic($topic_id) {
			$article_arr = array();
			
			$query = 'SELECT * FROM `tblArticles` INNER JOIN `tblContributors` ON `tblArticles`.`contributor_id` = `tblContributors`.`id` INNER JOIN `tblTopicsArticles` ON `tblArticles`.`id` = `tblTopicsArticles`.`article_id` WHERE `tblArticles`.`active` = "Y" AND `tblTopicsArticles`.`topic_id` = '. $topic_id .' ORDER BY `tblArticles`.`created` DESC;';
			$article_result = mysql_query($query);
			
			while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) { 				
				/*
				$query = 'SELECT `tblUsers`.`handle`, `tblUsers`.`name` FROM `tblUsers` INNER JOIN `tblUsersReadArticles` ON `tblUsers`.`id` = `tblUsersReadArticles`.`user_id` WHERE `tblUsersReadArticles`.`article_id` = '. $article_row['id'] .' ORDER BY `tblUsersReadArticles`.`added` DESC LIMIT 16;';
				$users_result = mysql_query($query);
				$user_arr = array();
				while ($user_row = mysql_fetch_array($users_result, MYSQL_BOTH)) {
					array_push($user_arr, array(
						"handle" => $user_row['handle'], 
						"name" => $user_row['name']
					));
				}
				
				$query = 'SELECT * FROM `tblUsersLikedArticles` WHERE `article_id` = '. $article_row['id'] .';';
				$isLiked = (mysql_num_rows(mysql_query($query)) > 0);				
				
				$query = 'SELECT * FROM `tblInfluencers` WHERE `id` = '. $article_row['influencer_id'] .';';
				$influencer_row = mysql_fetch_row(mysql_query($query));

				
				$query = 'SELECT `tblComments`.`id`, `tblComments`.`content`, `tblComments`.`liked`, `tblComments`.`added`, `tblUsers`.`name`, `tblUsers`.`handle` FROM `tblComments` INNER JOIN `tblUsers` ON `tblComments`.`user_id` = `tblUsers`.`id` WHERE `tblComments`.`article_id` = '. $article_row['id'] .' ORDER BY `tblComments`.`added` DESC;';
				$comments_result = mysql_query($query);
				
				$comment_arr = array();
				while ($comment_row = mysql_fetch_array($comments_result, MYSQL_BOTH)) {
					array_push($comment_arr, array(
						"reaction_id" => $comment_row['id'], 
						"thumb_url" => "https://api.twitter.com/1/users/profile_image?screen_name=". $comment_row['handle'] ."&size=reasonably_small", 
						"name" => $comment_row['name'], 
						"handle" => $comment_row['handle'], 
						"comment_url" => "", 
						"content" => htmlentities($comment_row['content'], ENT_QUOTES), 
						"liked" => $comment_row['liked'], 
						"added" => $comment_row['added']
					 ));
				}
				
				$query = 'SELECT * FROM `tblRetweets` WHERE `tweet_id` = "'. $article_row['tweet_id'] .'" ORDER BY `created` DESC;';
				$retweet_result = mysql_query($query);
				
				while ($retweet_row = mysql_fetch_array($retweet_result, MYSQL_BOTH)) {
					array_push($comment_arr, array(
						"reaction_id" => $retweet_row['id'], 
						"thumb_url" => $retweet_row['avatar_url'], 
						"name" => $retweet_row['name'], 
						"handle" => $retweet_row['handle'], 
						"comment_url" => "", 
						"content" => htmlentities("RT", ENT_QUOTES), 
						"liked" => "N", 
						"added" => $retweet_row['created']
					 ));
				}
				*/
				
				array_push($article_arr, array(
					"article_id" => $article_row['article_id'], 
					"list_id" => 0, 
					"type_id" => $article_row['type_id'], 
					"source_id" => 0, 
					"title" => $article_row['title'], 
					"article_url" => $article_row['short_url'], 
					"short_url" => $article_row['short_url'], 
					"affiliate_url" => "", 
					"tweet_id" => $article_row['tweet_id'], 
					"tweet_msg" => $article_row['tweet_msg'], 
					"twitter_name" => $article_row['name'], 
					"twitter_handle" => $article_row['handle'],
					"twitter_info" => "", 
					"bg_url" => $article_row['image_url'], 
					"source" => "", 
					"content" => $article_row['content_txt'], 
					"avatar_url" => $article_row['avatar_url'], 
					"video_url" => $article_row['youtube_id'], 
					"likes" => $article_row['likes'], 
					"liked" => false, 
					"img_ratio" => $article_row['image_ratio'], 
					"added" => $article_row['created'], 
					"tags" => array(), 
					"reads" => array(), 
					"reactions" => array()
				)); 
			}
			
			$this->sendResponse(200, json_encode($article_arr));
			return (true);
			
			/*
			$article_arr = array();
			
			$query = 'SELECT * FROM `tblArticles` WHERE `list_id` = '. $topic_id .' AND `active` = "Y" ORDER BY `added` DESC;';
			$article_result = mysql_query($query);
			
			while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) { 				
				$query = 'SELECT `tblUsers`.`handle`, `tblUsers`.`name` FROM `tblUsers` INNER JOIN `tblUsersReadArticles` ON `tblUsers`.`id` = `tblUsersReadArticles`.`user_id` WHERE `tblUsersReadArticles`.`list_id` = '. $topic_id .' AND `tblUsersReadArticles`.`article_id` = '. $article_row['id'] .' ORDER BY `tblUsersReadArticles`.`added` DESC LIMIT 16;';
				$users_result = mysql_query($query);
				$user_arr = array();
				while ($user_row = mysql_fetch_array($users_result, MYSQL_BOTH)) {
					array_push($user_arr, array(
						"handle" => $user_row['handle'], 
						"name" => $user_row['name']
					));
				}
				
				$query = 'SELECT * FROM `tblUsersLikedArticles` WHERE `list_id` = '. $topic_id .' AND `article_id` = '. $article_row['id'] .';';
				$isLiked = (mysql_num_rows(mysql_query($query)) > 0);				
				
				$query = 'SELECT * FROM `tblInfluencers` WHERE `id` = '. $article_row['influencer_id'] .';';
				$influencer_row = mysql_fetch_row(mysql_query($query));

				
				$query = 'SELECT `tblComments`.`id`, `tblComments`.`content`, `tblComments`.`liked`, `tblComments`.`added`, `tblUsers`.`name`, `tblUsers`.`handle` FROM `tblComments` INNER JOIN `tblUsers` ON `tblComments`.`user_id` = `tblUsers`.`id` WHERE `tblComments`.`article_id` = '. $article_row['id'] .' AND `tblComments`.`list_id` = '. $topic_id .' ORDER BY `tblComments`.`added` DESC;';
				$comments_result = mysql_query($query);
				
				$comment_arr = array();
				while ($comment_row = mysql_fetch_array($comments_result, MYSQL_BOTH)) {
					array_push($comment_arr, array(
						"reaction_id" => $comment_row['id'], 
						"thumb_url" => "https://api.twitter.com/1/users/profile_image?screen_name=". $comment_row['handle'] ."&size=reasonably_small", 
						"name" => $comment_row['name'], 
						"handle" => $comment_row['handle'], 
						"comment_url" => "", 
						"content" => htmlentities($comment_row['content'], ENT_QUOTES), 
						"liked" => $comment_row['liked'], 
						"added" => $comment_row['added']
					 ));
				}
				
				$query = 'SELECT * FROM `tblRetweets` WHERE `tweet_id` = "'. $article_row['tweet_id'] .'" ORDER BY `created` DESC;';
				$retweet_result = mysql_query($query);
				
				while ($retweet_row = mysql_fetch_array($retweet_result, MYSQL_BOTH)) {
					array_push($comment_arr, array(
						"reaction_id" => $retweet_row['id'], 
						"thumb_url" => $retweet_row['avatar_url'], 
						"name" => $retweet_row['name'], 
						"handle" => $retweet_row['handle'], 
						"comment_url" => "", 
						"content" => htmlentities("RT", ENT_QUOTES), 
						"liked" => "N", 
						"added" => $retweet_row['created']
					 ));
				}
				
				
				array_push($article_arr, array(
					"article_id" => $article_row['id'], 
					"list_id" => $topic_id, 
					"type_id" => $article_row['type_id'], 
					"source_id" => $article_row['source_id'], 
					"title" => $article_row['title'], 
					"article_url" => $article_row['article_url'], 
					"short_url" => "", 
					"affiliate_url" => $article_row['affiliate_url'], 
					"tweet_id" => $article_row['tweet_id'], 
					"tweet_msg" => $article_row['tweet_msg'], 
					"twitter_name" => $influencer_row[2], 
					"twitter_handle" => $influencer_row[1],
					"twitter_info" => $influencer_row[4], 
					"bg_url" => $article_row['image_url'], 
					"source" => $article_row['source'], 
					"content" => $article_row['content'], 
					"avatar_url" => $influencer_row[3], 
					"video_url" => $article_row['video_url'], 
					"likes" => $article_row['likes'], 
					"liked" => $isLiked, 
					"img_ratio" => $article_row['img_ratio'], 
					"added" => $article_row['added'], 
					"tags" => array(), 
					"reads" => $user_arr, 
					"reactions" => $comment_arr
				)); 
			}
			
			$this->sendResponse(200, json_encode($article_arr));
			return (true);
			*/	
		}
	    
		
		
		function getListArticlesAfterDate($list_id, $datetime) {
			$article_arr = array();
			
			$query = 'SELECT * FROM `tblArticles` WHERE `list_id` = '. $list_id .' AND `active` = "Y" AND `added` > "'. $datetime .'" ORDER BY `added` DESC;';
			$article_result = mysql_query($query);
			
			while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) { 				
				$query = 'SELECT `tblComments`.`id`, `tblComments`.`content`, `tblComments`.`liked`, `tblComments`.`added`, `tblUsers`.`name`, `tblUsers`.`handle` FROM `tblComments` INNER JOIN `tblUsers` ON `tblComments`.`user_id` = `tblUsers`.`id` WHERE `tblComments`.`article_id` = '. $article_row['id'] .' AND `tblComments`.`list_id` = '. $list_id .' ORDER BY `tblComments`.`added` DESC;';
				$comments_result = mysql_query($query);
				
				$comment_arr = array();
				while ($comment_row = mysql_fetch_array($comments_result, MYSQL_BOTH)) {
					array_push($comment_arr, array(
						"reaction_id" => $comment_row['id'], 
						"thumb_url" => "https://api.twitter.com/1/users/profile_image?screen_name=". $comment_row['handle'] ."&size=reasonably_small", 
						"name" => $comment_row['name'], 
						"handle" => $comment_row['handle'], 
						"comment_url" => "http://shelby.tv", 
						"content" => htmlentities($comment_row['content'], ENT_QUOTES), 
						"liked" => $comment_row['liked'], 
						"added" => $comment_row['added']
					 ));
				}
				
				$query = 'SELECT * FROM `tblRetweets` WHERE `tweet_id` = "'. $article_row['tweet_id'] .'" ORDER BY `created` DESC;';
				$retweet_result = mysql_query($query);
				
				while ($retweet_row = mysql_fetch_array($retweet_result, MYSQL_BOTH)) {
					array_push($comment_arr, array(
						"reaction_id" => $retweet_row['id'], 
						"thumb_url" => $retweet_row['avatar_url'], 
						"name" => $retweet_row['name'], 
						"handle" => $retweet_row['handle'], 
						"comment_url" => "", 
						"content" => htmlentities("RT", ENT_QUOTES), 
						"liked" => "N", 
						"added" => $retweet_row['created']
					 ));
				}
				
				$query = 'SELECT `tblUsers`.`handle`, `tblUsers`.`name` FROM `tblUsers` INNER JOIN `tblUsersReadArticles` ON `tblUsers`.`id` = `tblUsersReadArticles`.`user_id` WHERE `tblUsersReadArticles`.`list_id` = '. $list_id .' AND `tblUsersReadArticles`.`article_id` = '. $article_row['id'] .' ORDER BY `tblUsersReadArticles`.`added` DESC LIMIT 16;';
				$users_result = mysql_query($query);
				$user_arr = array();
				while ($user_row = mysql_fetch_array($users_result, MYSQL_BOTH)) {
					array_push($user_arr, array(
						"handle" => $user_row['handle'], 
						"name" => $user_row['name']
					));
				}
				
				$query = 'SELECT * FROM `tblUsersLikedArticles` WHERE `user_id` = 1 AND `list_id` = '. $list_id .' AND `article_id` = '. $article_row['id'] .';';
				$isLiked = (mysql_num_rows(mysql_query($query)) > 0);
				
				$query = 'SELECT * FROM `tblInfluencers` WHERE `id` = '. $article_row['influencer_id'] .';';
				$influencer_row = mysql_fetch_row(mysql_query($query));
				
				array_push($article_arr, array(
					"article_id" => $article_row['id'], 
					"list_id" => $list_id, 
					"type_id" => $article_row['type_id'], 
					"source_id" => $article_row['source_id'], 
					"title" => $article_row['title'], 
					"article_url" => $article_row['article_url'], 
					"short_url" => "",
					"affiliate" => $article_row['affiliate_url'], 
					"tweet_id" => $article_row['tweet_id'], 
					"tweet_msg" => $article_row['tweet_msg'], 
					"twitter_name" => $influencer_row[2], 
					"twitter_handle" => $influencer_row[1],
					"twitter_info" => $influencer_row[4], 
					"bg_url" => $article_row['image_url'], 
					"source" => $article_row['source'], 
					"content" => $article_row['content'], 
					"avatar_url" => $influencer_row[3], 
					"video_url" => $article_row['video_url'], 
					"likes" => $article_row['likes'], 
					"liked" => $isLiked, 
					"img_ratio" => $article_row['img_ratio'], 
					"added" => $article_row['added'], 
					"tags" => array(), 
					"reads" => $user_arr, 
					"reactions" => $comment_arr
				)); 
			}
			
			
			$this->sendResponse(200, json_encode($article_arr));
			return (true);
		}
		
		function submitComment($handle, $list_id, $article_id, $content, $isLiked) {
			$query = 'SELECT `id` FROM `tblUsers` WHERE `handle` = "'. $handle .'";';
			$result = mysql_query($query);
			
			$user_id = "0";
			if (mysql_num_rows($result) > 0) {
				$row = mysql_fetch_row($result);
				$user_id = $row[0];
			}
			
			$query = 'INSERT INTO `tblComments` (';
			$query .= '`id`, `article_id`, `list_id`, `user_id`, `content`, `liked`, `added`) ';
			$query .= 'VALUES (NULL, '. $article_id .', '. $list_id .', '. $user_id .', "'. $content .'", "'. $isLiked .'", NOW());';
			$result = mysql_query($query);
			$comment_id = mysql_insert_id();
			
			if ($isLiked == "Y") {
				$query = 'SELECT `likes` FROM `tblArticles` WHERE `id` ='. $article_id .';';
				$row = mysql_fetch_row(mysql_query($query));
				$likes_tot = $row[0];
				$likes_tot++;
				
				$query = 'UPDATE `tblArticles` SET `likes` = '. $likes_tot .' WHERE `id` = '. $article_id .';';
				$result = mysql_query($query);
			}
			
			$this->sendResponse(200, json_encode(array("comment_id" => $comment_id)));
			return (true);
		}
				
		function removeLike($user_id, $list_id, $article_id) {
			$query = 'SELECT `likes` FROM `tblArticles` WHERE `id` = '. $article_id .';';
			$row = mysql_fetch_row(mysql_query($query));
			$likes_tot = $row[0];
			$likes_tot--;
				
			$query = 'UPDATE `tblArticles` SET `likes` = '. $likes_tot .' WHERE `id` ='. $article_id .';';
			$result = mysql_query($query);
			
			$query = 'DELETE FROM `tblUsersLikedArticles` WHERE `user_id` = '. $user_id .' AND `list_id` = '. $list_id .' AND `article_id` = '. $article_id .';';
			$result = mysql_query($query);
			
			$this->sendResponse(200, json_encode(array("success" => true)));
			return (true);
		}
		
		function addLike($user_id, $list_id, $article_id) {
			$query = 'SELECT `likes` FROM `tblArticles` WHERE `id` = '. $article_id .';';
			$row = mysql_fetch_row(mysql_query($query));
			$likes_tot = $row[0];
			$likes_tot++;
				
			$query = 'UPDATE `tblArticles` SET `likes` = '. $likes_tot .' WHERE `id` ='. $article_id .';';
			$result = mysql_query($query);
			
			$query = 'INSERT INTO `tblUsersLikedArticles` (`user_id`, `list_id`, `article_id`, `added`) VALUES ('. $user_id .', '. $list_id .', '. $article_id .', NOW());';
			$result = mysql_query($query);
			
			$this->sendResponse(200, json_encode(array("success" => true)));
			return (true);
		}
		
		function readLater($user_id, $list_id, $article_id) {
			$query = 'INSERT INTO `tblUsersReadLater` (`user_id`, `list_id`, `article_id`, `added`) VALUES ('. $user_id .', '. $list_id .', '. $article_id .', NOW());';
			$result = mysql_query($query);
			
			$this->sendResponse(200, json_encode(array("success" => true)));
			return (true);
		}
		
		function readArticle($user_id, $list_id, $article_id) {
			$query = 'INSERT INTO `tblUsersReadArticles` (`user_id`, `list_id`, `article_id`, `added`) VALUES ('. $user_id .', '. $list_id .', '. $article_id .', NOW());';
			$result = mysql_query($query);
			
		  	$this->sendResponse(200, json_encode(array("success" => true)));
			return (true);
		}
		
		function getArticlesReadByUser($user_id) {
			$article_arr = array();
			
			$query = 'SELECT * FROM `tblArticles` INNER JOIN `tblUsersReadArticles` ON `tblArticles`.`id` = `tblUsersReadArticles`.`article_id` WHERE `tblUsersReadArticles`.`user_id` = '. $user_id .';';
			$article_result = mysql_query($query);
			
			while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) { 				
				$query = 'SELECT `tblComments`.`id`, `tblComments`.`content`, `tblComments`.`liked`, `tblComments`.`added`, `tblUsers`.`name`, `tblUsers`.`handle` FROM `tblComments` INNER JOIN `tblUsers` ON `tblComments`.`user_id` = `tblUsers`.`id` WHERE `tblComments`.`article_id` = '. $article_row['id'] .' AND `tblComments`.`list_id` = '. $list_id .' ORDER BY `tblComments`.`added` DESC;';
				$comments_result = mysql_query($query);
				
				$comment_arr = array();
				while ($comment_row = mysql_fetch_array($comments_result, MYSQL_BOTH)) {
					array_push($comment_arr, array(
						"reaction_id" => $comment_row['id'], 
						"thumb_url" => "https://api.twitter.com/1/users/profile_image?screen_name=". $comment_row['handle'] ."&size=reasonably_small", 
						"name" => $comment_row['name'], 
						"handle" => $comment_row['handle'], 
						"comment_url" => "http://shelby.tv", 
						"content" => htmlentities($comment_row['content'], ENT_QUOTES), 
						"liked" => $comment_row['liked'], 
						"added" => $comment_row['added']
					 ));
				}
				
				$query = 'SELECT * FROM `tblRetweets` WHERE `tweet_id` = "'. $article_row['tweet_id'] .'" ORDER BY `created` DESC;';
				$retweet_result = mysql_query($query);
				
				while ($retweet_row = mysql_fetch_array($retweet_result, MYSQL_BOTH)) {
					array_push($comment_arr, array(
						"reaction_id" => $retweet_row['id'], 
						"thumb_url" => $retweet_row['avatar_url'], 
						"name" => $retweet_row['name'], 
						"handle" => $retweet_row['handle'], 
						"comment_url" => "", 
						"content" => htmlentities("RT", ENT_QUOTES), 
						"liked" => "N", 
						"added" => $retweet_row['created']
					 ));
				}
				
				$query = 'SELECT `tblUsers`.`handle`, `tblUsers`.`name` FROM `tblUsers` INNER JOIN `tblUsersReadArticles` ON `tblUsers`.`id` = `tblUsersReadArticles`.`user_id` WHERE `tblUsersReadArticles`.`list_id` = '. $list_id .' AND `tblUsersReadArticles`.`article_id` = '. $article_row['id'] .' ORDER BY `tblUsersReadArticles`.`added` DESC LIMIT 16;';
				$users_result = mysql_query($query);
				$user_arr = array();
				while ($user_row = mysql_fetch_array($users_result, MYSQL_BOTH)) {
					array_push($user_arr, array(
						"handle" => $user_row['handle'], 
						"name" => $user_row['name']
					));
				}
				
				$query = 'SELECT * FROM `tblUsersLikedArticles` WHERE `user_id` = 1 AND `list_id` = '. $list_id .' AND `article_id` = '. $article_row['id'] .';';
				$isLiked = (mysql_num_rows(mysql_query($query)) > 0);
				
				$query = 'SELECT * FROM `tblInfluencers` WHERE `id` = '. $article_row['influencer_id'] .';';
				$influencer_row = mysql_fetch_row(mysql_query($query));
				
				array_push($article_arr, array(
					"article_id" => $article_row['id'], 
					"list_id" => $article_row['list_id'], 
					"type_id" => $article_row['type_id'], 
					"source_id" => $article_row['source_id'], 
					"title" => $article_row['title'], 
					"article_url" => $article_row['article_url'], 
					"short_url" => "",
					"affiliate" => $article_row['affiliate_url'], 
					"tweet_id" => $article_row['tweet_id'], 
					"tweet_msg" => $article_row['tweet_msg'], 
					"twitter_name" => $influencer_row[2], 
					"twitter_handle" => $influencer_row[1],
					"twitter_info" => $influencer_row[4], 
					"bg_url" => $article_row['image_url'], 
					"source" => $article_row['source'], 
					"content" => $article_row['content'], 
					"avatar_url" => $influencer_row[3], 
					"video_url" => $article_row['video_url'], 
					"likes" => $article_row['likes'], 
					"liked" => $isLiked, 
					"img_ratio" => $article_row['img_ratio'], 
					"added" => $article_row['added'], 
					"tags" => array(), 
					"reads" => $user_arr, 
					"reactions" => $comment_arr
				)); 
			}
			
			
			$this->sendResponse(200, json_encode($article_arr));
			return (true); 				
		}
		
		
		function getArticlesLikedByUser($user_id) {
			$article_arr = array();
			
			$query = 'SELECT * FROM `tblArticles` INNER JOIN `tblUsersLikedArticles` ON `tblArticles`.`id` = `tblUsersLikedArticles`.`article_id` WHERE `tblUsersLikedArticles`.`user_id` = '. $user_id .';';
			$article_result = mysql_query($query);
			
			while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) { 				
				$query = 'SELECT `tblComments`.`id`, `tblComments`.`content`, `tblComments`.`liked`, `tblComments`.`added`, `tblUsers`.`name`, `tblUsers`.`handle` FROM `tblComments` INNER JOIN `tblUsers` ON `tblComments`.`user_id` = `tblUsers`.`id` WHERE `tblComments`.`article_id` = '. $article_row['id'] .' AND `tblComments`.`list_id` = '. $list_id .' ORDER BY `tblComments`.`added` DESC;';
				$comments_result = mysql_query($query);
				
				$comment_arr = array();
				while ($comment_row = mysql_fetch_array($comments_result, MYSQL_BOTH)) {
					array_push($comment_arr, array(
						"reaction_id" => $comment_row['id'], 
						"thumb_url" => "https://api.twitter.com/1/users/profile_image?screen_name=". $comment_row['handle'] ."&size=reasonably_small", 
						"name" => $comment_row['name'], 
						"handle" => $comment_row['handle'], 
						"comment_url" => "http://shelby.tv", 
						"content" => htmlentities($comment_row['content'], ENT_QUOTES), 
						"liked" => $comment_row['liked'], 
						"added" => $comment_row['added']
					 ));
				}
				
				$query = 'SELECT * FROM `tblRetweets` WHERE `tweet_id` = "'. $article_row['tweet_id'] .'" ORDER BY `created` DESC;';
				$retweet_result = mysql_query($query);
				
				while ($retweet_row = mysql_fetch_array($retweet_result, MYSQL_BOTH)) {
					array_push($comment_arr, array(
						"reaction_id" => $retweet_row['id'], 
						"thumb_url" => $retweet_row['avatar_url'], 
						"name" => $retweet_row['name'], 
						"handle" => $retweet_row['handle'], 
						"comment_url" => "", 
						"content" => htmlentities("RT", ENT_QUOTES), 
						"liked" => "N", 
						"added" => $retweet_row['created']
					 ));
				}
				
				$query = 'SELECT `tblUsers`.`handle`, `tblUsers`.`name` FROM `tblUsers` INNER JOIN `tblUsersReadArticles` ON `tblUsers`.`id` = `tblUsersReadArticles`.`user_id` WHERE `tblUsersReadArticles`.`list_id` = '. $list_id .' AND `tblUsersReadArticles`.`article_id` = '. $article_row['id'] .' ORDER BY `tblUsersReadArticles`.`added` DESC LIMIT 16;';
				$users_result = mysql_query($query);
				$user_arr = array();
				while ($user_row = mysql_fetch_array($users_result, MYSQL_BOTH)) {
					array_push($user_arr, array(
						"handle" => $user_row['handle'], 
						"name" => $user_row['name']
					));
				}
				
				$query = 'SELECT * FROM `tblUsersLikedArticles` WHERE `user_id` = 1 AND `list_id` = '. $list_id .' AND `article_id` = '. $article_row['id'] .';';
				$isLiked = (mysql_num_rows(mysql_query($query)) > 0);
				
				$query = 'SELECT * FROM `tblInfluencers` WHERE `id` = '. $article_row['influencer_id'] .';';
				$influencer_row = mysql_fetch_row(mysql_query($query));
				
				array_push($article_arr, array(
					"article_id" => $article_row['id'], 
					"list_id" => $article_row['list_id'], 
					"type_id" => $article_row['type_id'], 
					"source_id" => $article_row['source_id'], 
					"title" => $article_row['title'], 
					"article_url" => $article_row['article_url'], 
					"short_url" => "",
					"affiliate" => $article_row['affiliate_url'], 
					"tweet_id" => $article_row['tweet_id'], 
					"tweet_msg" => $article_row['tweet_msg'], 
					"twitter_name" => $influencer_row[2], 
					"twitter_handle" => $influencer_row[1],
					"twitter_info" => $influencer_row[4], 
					"bg_url" => $article_row['image_url'], 
					"source" => $article_row['source'], 
					"content" => $article_row['content'], 
					"avatar_url" => $influencer_row[3], 
					"video_url" => $article_row['video_url'], 
					"likes" => $article_row['likes'], 
					"liked" => $isLiked, 
					"img_ratio" => $article_row['img_ratio'], 
					"added" => $article_row['added'], 
					"tags" => array(), 
					"reads" => $user_arr, 
					"reactions" => $comment_arr
				)); 
			}
			
			
			$this->sendResponse(200, json_encode($article_arr));
			return (true); 				
		}
		
		
		function getPopularArticles() {
			$article_arr = array();
			
			$query = 'SELECT * FROM `tblArticles` INNER JOIN `tblContributors` ON `tblArticles`.`contributor_id` = `tblContributors`.`id` WHERE `tblArticles`.`active` = "Y" ORDER BY `tblArticles`.`created` DESC;';
			$article_result = mysql_query($query);
			
			while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) { 				
				/*
				$query = 'SELECT `tblUsers`.`handle`, `tblUsers`.`name` FROM `tblUsers` INNER JOIN `tblUsersReadArticles` ON `tblUsers`.`id` = `tblUsersReadArticles`.`user_id` WHERE `tblUsersReadArticles`.`article_id` = '. $article_row['id'] .' ORDER BY `tblUsersReadArticles`.`added` DESC LIMIT 16;';
				$users_result = mysql_query($query);
				$user_arr = array();
				while ($user_row = mysql_fetch_array($users_result, MYSQL_BOTH)) {
					array_push($user_arr, array(
						"handle" => $user_row['handle'], 
						"name" => $user_row['name']
					));
				}
				
				$query = 'SELECT * FROM `tblUsersLikedArticles` WHERE `article_id` = '. $article_row['id'] .';';
				$isLiked = (mysql_num_rows(mysql_query($query)) > 0);				
				
				$query = 'SELECT * FROM `tblInfluencers` WHERE `id` = '. $article_row['influencer_id'] .';';
				$influencer_row = mysql_fetch_row(mysql_query($query));

				
				$query = 'SELECT `tblComments`.`id`, `tblComments`.`content`, `tblComments`.`liked`, `tblComments`.`added`, `tblUsers`.`name`, `tblUsers`.`handle` FROM `tblComments` INNER JOIN `tblUsers` ON `tblComments`.`user_id` = `tblUsers`.`id` WHERE `tblComments`.`article_id` = '. $article_row['id'] .' ORDER BY `tblComments`.`added` DESC;';
				$comments_result = mysql_query($query);
				
				$comment_arr = array();
				while ($comment_row = mysql_fetch_array($comments_result, MYSQL_BOTH)) {
					array_push($comment_arr, array(
						"reaction_id" => $comment_row['id'], 
						"thumb_url" => "https://api.twitter.com/1/users/profile_image?screen_name=". $comment_row['handle'] ."&size=reasonably_small", 
						"name" => $comment_row['name'], 
						"handle" => $comment_row['handle'], 
						"comment_url" => "", 
						"content" => htmlentities($comment_row['content'], ENT_QUOTES), 
						"liked" => $comment_row['liked'], 
						"added" => $comment_row['added']
					 ));
				}
				
				$query = 'SELECT * FROM `tblRetweets` WHERE `tweet_id` = "'. $article_row['tweet_id'] .'" ORDER BY `created` DESC;';
				$retweet_result = mysql_query($query);
				
				while ($retweet_row = mysql_fetch_array($retweet_result, MYSQL_BOTH)) {
					array_push($comment_arr, array(
						"reaction_id" => $retweet_row['id'], 
						"thumb_url" => $retweet_row['avatar_url'], 
						"name" => $retweet_row['name'], 
						"handle" => $retweet_row['handle'], 
						"comment_url" => "", 
						"content" => htmlentities("RT", ENT_QUOTES), 
						"liked" => "N", 
						"added" => $retweet_row['created']
					 ));
				}
				*/
				
				array_push($article_arr, array(
					"article_id" => $article_row[0], 
					"list_id" => 0, 
					"type_id" => $article_row['type_id'], 
					"source_id" => 0, 
					"title" => $article_row['title'], 
					"article_url" => $article_row['short_url'], 
					"short_url" => $article_row['short_url'], 
					"affiliate_url" => "", 
					"tweet_id" => $article_row['tweet_id'], 
					"tweet_msg" => $article_row['tweet_msg'], 
					"twitter_name" => $article_row['name'], 
					"twitter_handle" => $article_row['handle'],
					"twitter_info" => "", 
					"bg_url" => $article_row['image_url'], 
					"source" => "", 
					"content" => $article_row['content_txt'], 
					"avatar_url" => $article_row['avatar_url'], 
					"video_url" => $article_row['youtube_id'], 
					"likes" => $article_row['likes'], 
					"liked" => false, 
					"img_ratio" => $article_row['image_ratio'], 
					"added" => $article_row['created'], 
					"tags" => array(), 
					"reads" => array(), 
					"reactions" => array()
				)); 
			}
			
			$this->sendResponse(200, json_encode($article_arr));
			return (true);	
		}
		
		
		
		function test() {
			$this->sendResponse(200, json_encode(array(
				"result" => true
			)));
			return (true);	
		}
	}
	
	$articles = new Articles;
	////$articles->test();
	
	
	if (isset($_POST['action'])) {
		switch ($_POST['action']) {
			
			case "0":
				break;
				
			case "1":
				if (isset($_POST['userID']) && isset($_POST['listID']) && isset($_POST['articleID']))
					$articles->addLike($_POST['userID'], $_POST['listID'], $_POST['articleID']);
				break;
				
			case "2":
				if (isset($_POST['userID']) && isset($_POST['listID']) && isset($_POST['articleID']))
					$articles->readLater($_POST['userID'], $_POST['listID'], $_POST['articleID']);
				break;
				
			case "3":
				if (isset($_POST['userID']) && isset($_POST['listID']) && isset($_POST['articleID']))
					$articles->readArticle($_POST['userID'], $_POST['listID'], $_POST['articleID']);
				break;
				
			case "4":
				if (isset($_POST['listID']) && isset($_POST['datetime']))
					$articles->getListArticlesAfterDate($_POST['listID'], $_POST['datetime']);
				break;
				
			case "5":
				if (isset($_POST['userID']))
					$articles->getArticlesReadByUser($_POST['userID']);
				break;
				
			case "6":
				if (isset($_POST['userID']))
					$articles->getArticlesLikedByUser($_POST['userID']);
				break;
				
			case "7":
				if (isset($_POST['userID']) && isset($_POST['listID']) && isset($_POST['articleID']))
					$articles->removeLike($_POST['userID'], $_POST['listID'], $_POST['articleID']);
				break;
				
			case "8":
			 	if (isset($_POST['topicID']))
					$articles->getArticlesForTopic($_POST['topicID']);
				break;
				
			case "9":
				if (isset($_POST['handle']) && isset($_POST['listID']) && isset($_POST['articleID']) && isset($_POST['content']) && isset($_POST['liked']))
					$articles->submitComment($_POST['handle'], $_POST['listID'], $_POST['articleID'], $_POST['content'], $_POST['liked']);
				break;
				
			case "10":
				$articles->getPopularArticles();
				break;
    	}
	}
?>