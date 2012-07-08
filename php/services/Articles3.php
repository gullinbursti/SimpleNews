<?php

	class Articles {
		private $db_conn;
	
	  	function __construct() {
		
			$this->db_conn = mysql_connect('localhost', 'db41232_sn_usr', 'dope911t') or die("Could not connect to database.");
			mysql_select_db('assemblyDEV') or die("Could not select database.");
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
			
			if ($topic_id == "10")
				$query = 'SELECT * FROM `tblArticles` INNER JOIN `tblContributors` ON `tblArticles`.`contributor_id` = `tblContributors`.`id` INNER JOIN `tblTopicsArticles` ON `tblArticles`.`id` = `tblTopicsArticles`.`article_id` WHERE `tblArticles`.`active` = "Y" AND `tblTopicsArticles`.`topic_id` = '. $topic_id .' AND `tblArticles`.`type_id` >= 4 ORDER BY `tblArticles`.`created` DESC LIMIT 30;';
			
			else
				$query = 'SELECT * FROM `tblArticles` INNER JOIN `tblContributors` ON `tblArticles`.`contributor_id` = `tblContributors`.`id` INNER JOIN `tblTopicsArticles` ON `tblArticles`.`id` = `tblTopicsArticles`.`article_id` WHERE `tblArticles`.`active` = "Y" AND `tblTopicsArticles`.`topic_id` = '. $topic_id .' AND `tblArticles`.`type_id` >= 2 ORDER BY `tblArticles`.`created` DESC LIMIT 30;';
				
			$article_result = mysql_query($query);
			
			while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) { 				
				$query = 'SELECT `title` FROM `tblTopics` WHERE `id` = '. $topic_id .";";
				$topic_row = mysql_fetch_row(mysql_query($query));
				
				$query = 'SELECT * FROM `tblArticleImages` WHERE `article_id` = '. $article_row[0] .';';
				$img_result = mysql_query($query);
				
				$img_arr = array();
				while ($img_row = mysql_fetch_array($img_result, MYSQL_BOTH)) {
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
					
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
					
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
				}
				
				$query = 'SELECT * FROM `tblComments` INNER JOIN `tblUsers` ON `tblComments`.`user_id` = `tblUsers`.`id` WHERE `tblComments`.`article_id` = '. $article_row[0] .' ORDER BY `tblComments`.`added` DESC;';
				$comment_result = mysql_query($query);
				
				$comment_arr = array();
				while ($comment_row = mysql_fetch_array($comment_result, MYSQL_BOTH)) {
					$query = 'SELECT * FROM `tblUsersLikedArticles` WHERE `user_id` = '. $comment_row['user_id'] .' AND `article_id` = '. $article_row[0] .';';
					$liked_result = mysql_query($query);
				
					array_push($comment_arr, array(
						"comment_id" => $comment_row[0], 
						"handle" => $comment_row['handle'], 
						"avatar" => "https://api.twitter.com/1/users/profile_image?screen_name=". $comment_row['handle'] ."&size=reasonably_small", 
						"content" => $comment_row['content'], 
						"liked" => (mysql_num_rows($liked_result) > 0), 
						"added" => $comment_row[5]
					));
				}
				
				$query = 'SELECT * FROM `tblUsers` INNER JOIN `tblUsersLikedArticles` ON `tblUsers`.`id` = `tblUsersLikedArticles`.`user_id` WHERE `tblUsersLikedArticles`.`article_id` = '. $article_row[0] .';';
				$user_result = mysql_query($query);
			
				$user_arr = array();
				while ($user_row = mysql_fetch_array($user_result, MYSQL_BOTH)) { 				
					array_push($user_arr, array(
						"id" => $user_row['id'], 
						"id_str" => $user_row['twitter_id'], 
						"screen_name" => $user_row['handle'], 
						"name" => $user_row['name'], 
						"profile_image_url" => "https://api.twitter.com/1/users/profile_image?screen_name=". $user_row['handle'] ."&size=reasonably_small"
					)); 
				}
								
				array_push($article_arr, array(
					"article_id" => $article_row['article_id'], 
					"list_id" => $topic_id, 
					"topic_name" => $topic_row[0], 
					"type_id" => $article_row[1], 
					"title" => $article_row['title'], 
					"article_url" => $article_row['content_url'], 
					"short_url" => $article_row['short_url'], 
					"tweet_id" => $article_row['tweet_id'], 
					"tweet_msg" => $article_row['tweet_msg'], 
					"twitter_name" => $article_row['name'], 
					"twitter_handle" => $article_row['handle'],
					"content" => $article_row['content_txt'], 
					"avatar_url" => $article_row['avatar_url'], 
					"video_url" => $article_row['youtube_id'], 
					"likes" => $user_arr, 
					"liked" => false, 
					"added" => $article_row['created'], 
					"comments" => $comment_arr, 
					"images" => $img_arr
				)); 
			}
			
			$this->sendResponse(200, json_encode($article_arr));
			return (true); 
		}
	    
		
		
		function getTopicArticlesAfterID($topic_id, $article_id) {
			$article_arr = array();
			
			if ($topic_id == "10")
				$query = 'SELECT * FROM `tblArticles` INNER JOIN `tblContributors` ON `tblArticles`.`contributor_id` = `tblContributors`.`id` INNER JOIN `tblTopicsArticles` ON `tblArticles`.`id` = `tblTopicsArticles`.`article_id` WHERE `tblArticles`.`active` = "Y" AND `tblTopicsArticles`.`topic_id` = '. $topic_id .' AND `tblArticles`.`type_id` >= 4 AND `tblArticles`.`id` > '. $article_id .' ORDER BY `tblArticles`.`created` DESC LIMIT 30;';
			else
				$query = 'SELECT * FROM `tblArticles` INNER JOIN `tblContributors` ON `tblArticles`.`contributor_id` = `tblContributors`.`id` INNER JOIN `tblTopicsArticles` ON `tblArticles`.`id` = `tblTopicsArticles`.`article_id` WHERE `tblArticles`.`active` = "Y" AND `tblTopicsArticles`.`topic_id` = '. $topic_id .' AND `tblArticles`.`type_id` >= 2 AND `tblArticles`.`id` > '. $article_id .' ORDER BY `tblArticles`.`created` DESC LIMIT 30;';
			$article_result = mysql_query($query);
			
			while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) {				
				$query = 'SELECT `title` FROM `tblTopics` WHERE `id` = '. $topic_id .";";
				$topic_row = mysql_fetch_row(mysql_query($query));
				
				$query = 'SELECT * FROM `tblArticleImages` WHERE `article_id` = '. $article_row[0] .';';
				$img_result = mysql_query($query);
				
				$img_arr = array();
				while ($img_row = mysql_fetch_array($img_result, MYSQL_BOTH)) {
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
					
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
					
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
				}
				
				$query = 'SELECT * FROM `tblComments` INNER JOIN `tblUsers` ON `tblComments`.`user_id` = `tblUsers`.`id` WHERE `tblComments`.`article_id` = '. $article_row[0] .' ORDER BY `tblComments`.`added` DESC;';
				$comment_result = mysql_query($query);
				
				$comment_arr = array();
				while ($comment_row = mysql_fetch_array($comment_result, MYSQL_BOTH)) {
					$query = 'SELECT * FROM `tblUsersLikedArticles` WHERE `user_id` = '. $comment_row['user_id'] .' AND `article_id` = '. $article_row[0] .';';
					$liked_result = mysql_query($query);
				
					array_push($comment_arr, array(
						"comment_id" => $comment_row[0], 
						"handle" => $comment_row['handle'], 
						"avatar" => "https://api.twitter.com/1/users/profile_image?screen_name=". $comment_row['handle'] ."&size=reasonably_small", 
						"content" => $comment_row['content'], 
						"liked" => (mysql_num_rows($liked_result) > 0), 
						"added" => $comment_row[5]
					));
				}
				
				$query = 'SELECT * FROM `tblUsers` INNER JOIN `tblUsersLikedArticles` ON `tblUsers`.`id` = `tblUsersLikedArticles`.`user_id` WHERE `tblUsersLikedArticles`.`article_id` = '. $article_row[0] .';';
				$user_result = mysql_query($query);
			
				$user_arr = array();
				while ($user_row = mysql_fetch_array($user_result, MYSQL_BOTH)) { 				
					array_push($user_arr, array(
						"id" => $user_row['id'], 
						"id_str" => $user_row['twitter_id'], 
						"screen_name" => $user_row['handle'], 
						"name" => $user_row['name'], 
						"profile_image_url" => "https://api.twitter.com/1/users/profile_image?screen_name=". $user_row['handle'] ."&size=reasonably_small"
					)); 
				}
				
				array_push($article_arr, array(
					"article_id" => $article_row['article_id'], 
					"list_id" => $topic_id, 
					"topic_name" => $topic_row[0], 
					"type_id" => $article_row[1], 
					"title" => $article_row['title'], 
					"article_url" => $article_row['content_url'], 
					"short_url" => $article_row['short_url'], 
					"tweet_id" => $article_row['tweet_id'], 
					"tweet_msg" => $article_row['tweet_msg'], 
					"twitter_name" => $article_row['name'], 
					"twitter_handle" => $article_row['handle'],
					"content" => $article_row['content_txt'], 
					"avatar_url" => $article_row['avatar_url'], 
					"video_url" => $article_row['youtube_id'], 
					"likes" => $user_arr, 
					"liked" => false, 
					"added" => $article_row['created'], 
					"comments" => $comment_arr, 
					"images" => $img_arr
				)); 
			}
			
			$this->sendResponse(200, json_encode($article_arr));
			return (true);
		}
		
		function getComments($article_id) {
			$comment_arr = array();
			
			$query = 'SELECT * FROM `tblComments` INNER JOIN `tblUsers` ON `tblComments`.`user_id` = `tblUsers`.`id` WHERE `tblComments`.`article_id` = '. $article_row[0] .' ORDER BY `tblComments`.`added` DESC;';
			$comment_result = mysql_query($query);
				
			$comment_arr = array();
			while ($comment_row = mysql_fetch_array($comments_result, MYSQL_BOTH)) {
				$query = 'SELECT `tblArticles`.`isLiked` INNER JOIN `tblUsersLikedArticles` ON `tblArticles`.`id` = `tblUsersLikedArticles`.`article_id` WHERE `tblUsersLikedArticles`.`user_id` = '. $comment_row['user_id']. ';';
				$article_result = mysql_query($query);
				
				array_push($comment_arr, array(
					"comment_id" => $comment_row[0], 
			      	"handle" => $comment_row['handle'], 
				   	"avatar" => "https://api.twitter.com/1/users/profile_image?screen_name=". $comment_row['handle'] ."&size=reasonably_small", 
				   	"content" => $comment_row['content'], 
					"liked" => (mysql_num_rows($article_result) > 0), 
				   	"added" => $comment_row[5]
			   	));
		    }
				
			$this->sendResponse(200, json_encode($comment_arr));
			return (true);
		}
		
		function submitComment($user_id, $article_id, $content, $isLiked) {			
			$query = 'INSERT INTO `tblComments` (';
			$query .= '`id`, `article_id`, `user_id`, `type_id`, `content`, `added`) ';
			$query .= 'VALUES (NULL, "'. $article_id .'", "'. $user_id .'", "1", "'. $content .'", NOW());';
			$result = mysql_query($query);
			$comment_id = mysql_insert_id();
			
			if ($isLiked == "Y") {
				$query = 'INSERT INTO `tblUsersLikedArticles` (';
				$query .= '`user_id`, `article_id`, `added`) ';
				$query .= 'VALUES ("'. $user_id .'", "'. $article_id .'", NOW());';
				$result = mysql_query($query);				
			}
			
			$query = 'SELECT * FROM `tblComments` INNER JOIN `tblUsers` ON `tblComments`.`user_id` = `tblUsers`.`id` WHERE `tblComments`.`id` = '. $comment_id .';';
			$comment_row = mysql_fetch_row(mysql_query($query));
			
			$this->sendResponse(200, json_encode(array(
				"comment_id" => $comment_id, 
		      	"handle" => $comment_row[8], 
			   	"avatar" => "https://api.twitter.com/1/users/profile_image?screen_name=". $comment_row[8] ."&size=reasonably_small", 
			   	"content" => $comment_row[4], 
				"liked" => (int)$isLiked, 
			   	"added" => $comment_row[5]
			)));
			
			return (true);
		}
				
		function removeLike($user_id, $article_id) {
			$query = 'DELETE FROM `tblUsersLikedArticles` WHERE `user_id` = '. $user_id .' AND `article_id` = '. $article_id .';';
			$result = mysql_query($query);
		   			
			$query = 'SELECT * FROM `tblUsersLikedArticles` WHERE `article_id` = '. $article_id .';';
			$tot_result = mysql_query($query);
			
			$this->sendResponse(200, json_encode(array(
				"article_id" => $article_id, 
				"likes" => mysql_num_rows($tot_result), 
				"success" => true
			)));
			return (true);
		}
		
		function addLike($user_id, $article_id) {
			$query = 'INSERT INTO `tblUsersLikedArticles` (`user_id`, `article_id`, `added`) VALUES ('. $user_id .', '. $article_id .', NOW());';
			$result = mysql_query($query);
			
			$query = 'SELECT * FROM `tblUsersLikedArticles` WHERE `article_id` = '. $article_id .';';
			$tot_result = mysql_query($query);
			
			$this->sendResponse(200, json_encode(array(
				"article_id" => $article_id, 
				"likes" => mysql_num_rows($tot_result), 
				"success" => true
			)));
			return (true);
		}
		
		function getArticlesCommentedByUser($user_id) {
			$article_arr = array();
			$id_arr = array();
			
			$query = 'SELECT `article_id` FROM `tblComments` WHERE `user_id` = '. $user_id .' ORDER BY `added` DESC;';
			$commented_result = mysql_query($query);
			
			while ($commented_row = mysql_fetch_array($commented_result, MYSQL_BOTH)) {
				
				$isFound = false;
				foreach ($id_arr as $article_id) {
					if ($article_id == $commented_row['article_id']) {
						$isFound = true;
						break;
					}
				}
				
				if (!$isFound)
				    array_push($id_arr, $commented_row['article_id']);
				else
					continue;
					
				
				$query = 'SELECT * FROM `tblArticles` INNER JOIN `tblContributors` ON `tblArticles`.`contributor_id` = `tblContributors`.`id` WHERE `tblArticles`.`active` = "Y" AND `tblArticles`.`id` = '. $commented_row['article_id'] .';';				
				$article_row = mysql_fetch_row(mysql_query($query));
				
				if (!$article_row)
					continue;
				
				$query = 'SELECT `tblTopics`.`id`, `tblTopics`.`title` FROM `tblTopics` INNER JOIN `tblTopicsArticles` ON `tblTopics`.`id` = `tblTopicsArticles`.`topic_id` WHERE `tblTopicsArticles`.`article_id` = '. $commented_row['article_id'] .';';
				$topic_row = mysql_fetch_row(mysql_query($query));
				
				$query = 'SELECT * FROM `tblArticleImages` WHERE `article_id` = '. $commented_row[0] .';';
				$img_result = mysql_query($query);
				
				$img_arr = array();
				while ($img_row = mysql_fetch_array($img_result, MYSQL_BOTH)) {
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
					
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
					
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
				}
				
				$query = 'SELECT * FROM `tblComments` INNER JOIN `tblUsers` ON `tblComments`.`user_id` = `tblUsers`.`id` WHERE `tblComments`.`article_id` = '. $commented_row['article_id'] .' ORDER BY `tblComments`.`added` DESC;';
				$comment_result = mysql_query($query);
				
				$comment_arr = array();
				while ($comment_row = mysql_fetch_array($comment_result, MYSQL_BOTH)) {
					$query = 'SELECT * FROM `tblUsersLikedArticles` WHERE `user_id` = '. $comment_row['user_id'] .' AND `article_id` = '. $commented_row['article_id'] .';';
					$liked_result = mysql_query($query);
					
					array_push($comment_arr, array(
						"comment_id" => $comment_row[0], 
						"handle" => $comment_row['handle'], 
						"avatar" => "https://api.twitter.com/1/users/profile_image?screen_name=". $comment_row['handle'] ."&size=reasonably_small", 
						"content" => $comment_row['content'], 
						"liked" => (mysql_num_rows($liked_result) > 0), 
						"added" => $comment_row[5]
					));
				}
				
				$query = 'SELECT * FROM `tblUsers` INNER JOIN `tblUsersLikedArticles` ON `tblUsers`.`id` = `tblUsersLikedArticles`.`user_id` WHERE `tblUsersLikedArticles`.`article_id` = '. $commented_row['article_id'] .';';
				$user_result = mysql_query($query);
			
				$user_arr = array();
				while ($user_row = mysql_fetch_array($user_result, MYSQL_BOTH)) { 				
					array_push($user_arr, array(
						"id" => $user_row['id'], 
						"id_str" => $user_row['twitter_id'], 
						"screen_name" => $user_row['handle'], 
						"name" => $user_row['name'], 
						"profile_image_url" => "https://api.twitter.com/1/users/profile_image?screen_name=". $user_row['handle'] ."&size=reasonably_small"
					)); 
				}
			    
				array_push($article_arr, array(
					"article_id" => $article_row[0], 
					"list_id" => $topic_row[0], 
					"topic_name" => $topic_row[1], 
					"type_id" => $article_row[1], 
					"title" => $article_row[6], 
					"article_url" => $article_row[8], 
					"short_url" => $article_row[5], 
					"tweet_id" => $article_row[2], 
					"tweet_msg" => $article_row[4], 
					"twitter_name" => $article_row[19], 
					"twitter_handle" => $article_row[18],
					"content" => $article_row[7], 
					"avatar_url" => $article_row[19], 
					"video_url" => $article_row[11], 
					"likes" => $user_arr, 
					"added" => $article_row[14], 
					"comments" => $comment_arr, 
					"images" => $img_arr
				)); 
			}
			
			$this->sendResponse(200, json_encode($article_arr));
			return (true);
		}
		
		function shareArticle($user_id, $article_id, $type_id) {
			$query = 'INSERT INTO `tblUsersSharedArticles` (`user_id`, `article_id`, `type_id`, `added`) VALUES ("'. $user_id .'", "'. $article_id .'", "'. $type_id .'", NOW());';
			$result = mysql_query($query);
			
		  	$this->sendResponse(200, json_encode(array("success" => true)));
			return (true);
		}
		
		function getArticlesSharedByUser($user_id) {
			$article_arr = array();
			$id_arr = array();
			
			$query = 'SELECT `article_id` FROM `tblUsersSharedArticles` WHERE `user_id` = '. $user_id .' ORDER BY `added` DESC;';
			$shared_result = mysql_query($query);
			
			while ($shared_row = mysql_fetch_array($shared_result, MYSQL_BOTH)) { 
				$isFound = false;
				foreach ($id_arr as $article_id) {
					if ($article_id == $commented_row['article_id']) {
						$isFound = true;
						break;
					}
				}
				
				if (!$isFound)
				    array_push($id_arr, $commented_row['article_id']);
				else
					continue;
					
				$query = 'SELECT * FROM `tblArticles` INNER JOIN `tblContributors` ON `tblArticles`.`contributor_id` = `tblContributors`.`id` WHERE `tblArticles`.`active` = "Y" AND `tblArticles`.`id` = '. $shared_row['article_id'] .';';				
				$article_row = mysql_fetch_row(mysql_query($query));
				
				if (!$article_row)
					continue;
				
				$query = 'SELECT `tblTopics`.`id`, `tblTopics`.`title` FROM `tblTopics` INNER JOIN `tblTopicsArticles` ON `tblTopics`.`id` = `tblTopicsArticles`.`topic_id` WHERE `tblTopicsArticles`.`article_id` = '. $shared_row['article_id'] .';';
				$topic_row = mysql_fetch_row(mysql_query($query));
				
				$query = 'SELECT * FROM `tblArticleImages` WHERE `article_id` = '. $shared_row[0] .';';
				$img_result = mysql_query($query);
				
				$img_arr = array();
				while ($img_row = mysql_fetch_array($img_result, MYSQL_BOTH)) {
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
					
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
					
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
				}
				
				
				$query = 'SELECT * FROM `tblComments` INNER JOIN `tblUsers` ON `tblComments`.`user_id` = `tblUsers`.`id` WHERE `tblComments`.`article_id` = '. $shared_row['article_id'] .' ORDER BY `tblComments`.`added` DESC;';
				$comment_result = mysql_query($query);
				
				$comment_arr = array();
				while ($comment_row = mysql_fetch_array($comment_result, MYSQL_BOTH)) {
					$query = 'SELECT * FROM `tblUsersLikedArticles` WHERE `user_id` = '. $comment_row['user_id'] .' AND `article_id` = '. $commented_row['article_id'] .';';
					$liked_result = mysql_query($query);
					
					array_push($comment_arr, array(
						"comment_id" => $comment_row[0], 
						"handle" => $comment_row['handle'], 
						"avatar" => "https://api.twitter.com/1/users/profile_image?screen_name=". $comment_row['handle'] ."&size=reasonably_small", 
						"content" => $comment_row['content'], 
						"liked" => (mysql_num_rows($liked_result) > 0), 
						"added" => $comment_row[5]
					));
				}
				
				$query = 'SELECT * FROM `tblUsers` INNER JOIN `tblUsersLikedArticles` ON `tblUsers`.`id` = `tblUsersLikedArticles`.`user_id` WHERE `tblUsersLikedArticles`.`article_id` = '. $shared_row[0] .';';
				$user_result = mysql_query($query);
			
				$user_arr = array();
				while ($user_row = mysql_fetch_array($user_result, MYSQL_BOTH)) { 				
					array_push($user_arr, array(
						"id" => $user_row['id'], 
						"id_str" => $user_row['twitter_id'], 
						"screen_name" => $user_row['handle'], 
						"name" => $user_row['name'], 
						"profile_image_url" => "https://api.twitter.com/1/users/profile_image?screen_name=". $user_row['handle'] ."&size=reasonably_small"
					)); 
				}
				
				array_push($article_arr, array(
					"article_id" => $article_row[0], 
					"list_id" => $topic_row[0], 
					"topic_name" => $topic_row[1], 
					"type_id" => $article_row[1], 
					"title" => $article_row[6], 
					"article_url" => $article_row[8], 
					"short_url" => $article_row[5], 
					"tweet_id" => $article_row[2], 
					"tweet_msg" => $article_row[4], 
					"twitter_name" => $article_row[19], 
					"twitter_handle" => $article_row[18],
					"content" => $article_row[7], 
					"avatar_url" => $article_row[19], 
					"video_url" => $article_row[11], 
					"likes" => $user_arr, 
					"added" => $article_row[14], 
					"comments" => $comment_arr, 
					"images" => $img_arr
				)); 
			}
			
			$this->sendResponse(200, json_encode($article_arr));
			return (true);
		}
		
		
		function getArticlesLikedByUser($user_id) {
			$article_arr = array();
			$id_arr = array();
			
			$query = 'SELECT `article_id` FROM `tblUsersLikedArticles` WHERE `user_id` = '. $user_id .' ORDER BY `added` DESC;';
			$liked_result = mysql_query($query);
			
			while ($liked_row = mysql_fetch_array($liked_result, MYSQL_BOTH)) { 	
				$query = 'SELECT * FROM `tblArticles` INNER JOIN `tblContributors` ON `tblArticles`.`contributor_id` = `tblContributors`.`id` WHERE `tblArticles`.`active` = "Y" AND `tblArticles`.`id` = '. $liked_row['article_id'] .';';				
				$article_row = mysql_fetch_row(mysql_query($query));
				
				if (!$article_row)
					continue;
				
				$query = 'SELECT `tblTopics`.`id`, `tblTopics`.`title` FROM `tblTopics` INNER JOIN `tblTopicsArticles` ON `tblTopics`.`id` = `tblTopicsArticles`.`topic_id` WHERE `tblTopicsArticles`.`article_id` = '. $liked_row['article_id'] .';';
				$topic_row = mysql_fetch_row(mysql_query($query));
				
				$query = 'SELECT * FROM `tblArticleImages` WHERE `article_id` = '. $liked_row[0] .';';
				$img_result = mysql_query($query);
				
				$img_arr = array();
				while ($img_row = mysql_fetch_array($img_result, MYSQL_BOTH)) {
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
					
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
					
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
				}
				
				
				$query = 'SELECT * FROM `tblComments` INNER JOIN `tblUsers` ON `tblComments`.`user_id` = `tblUsers`.`id` WHERE `tblComments`.`article_id` = '. $liked_row['article_id'] .' ORDER BY `tblComments`.`added` DESC;';
				$comment_result = mysql_query($query);
				
				$comment_arr = array();
				while ($comment_row = mysql_fetch_array($comment_result, MYSQL_BOTH)) {
					array_push($comment_arr, array(
						"comment_id" => $comment_row[0], 
						"handle" => $comment_row['handle'], 
						"avatar" => "https://api.twitter.com/1/users/profile_image?screen_name=". $comment_row['handle'] ."&size=reasonably_small", 
						"content" => $comment_row['content'], 
						"liked" => true, 
						"added" => $comment_row[5]
					));
				}
				
				$query = 'SELECT * FROM `tblUsers` INNER JOIN `tblUsersLikedArticles` ON `tblUsers`.`id` = `tblUsersLikedArticles`.`user_id` WHERE `tblUsersLikedArticles`.`article_id` = '. $liked_row[0] .';';
				$user_result = mysql_query($query);
			
				$user_arr = array();
				while ($user_row = mysql_fetch_array($user_result, MYSQL_BOTH)) { 				
					array_push($user_arr, array(
						"id" => $user_row['id'], 
						"id_str" => $user_row['twitter_id'], 
						"screen_name" => $user_row['handle'], 
						"name" => $user_row['name'], 
						"profile_image_url" => "https://api.twitter.com/1/users/profile_image?screen_name=". $user_row['handle'] ."&size=reasonably_small"
					)); 
				}
				
				array_push($article_arr, array(
					"article_id" => $article_row[0], 
					"list_id" => $topic_row[0], 
					"topic_name" => $topic_row[1], 
					"type_id" => $article_row[1], 
					"title" => $article_row[6], 
					"article_url" => $article_row[8], 
					"short_url" => $article_row[5], 
					"tweet_id" => $article_row[2], 
					"tweet_msg" => $article_row[4], 
					"twitter_name" => $article_row[19], 
					"twitter_handle" => $article_row[18],
					"content" => $article_row[7], 
					"avatar_url" => $article_row[19], 
					"video_url" => $article_row[11], 
					"likes" => $user_arr, 
					"added" => $article_row[14], 
					"comments" => $comment_arr, 
					"images" => $img_arr
				)); 
			}
			
			$this->sendResponse(200, json_encode($article_arr));
			return (true);
		}
		
		
		function getPopularArticles() {
			$article_arr = array();
			
			$query = 'SELECT * FROM `tblArticles` INNER JOIN `tblContributors` ON `tblArticles`.`contributor_id` = `tblContributors`.`id` WHERE `tblArticles`.`active` = "Y" AND `tblArticles`.`type_id` >= 2 ORDER BY `tblArticles`.`created` DESC LIMIT 30;';
			$article_result = mysql_query($query);
			
			while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) {
				$query = 'SELECT `tblTopics`.`id`, `tblTopics`.`title` FROM `tblTopics` INNER JOIN `tblTopicsArticles` ON `tblTopics`.`id` = `tblTopicsArticles`.`topic_id` WHERE  `tblTopicsArticles`.`article_id` = '. $article_row[0] .";";
				$topic_row = mysql_fetch_row(mysql_query($query));
							
				$query = 'SELECT * FROM `tblComments` INNER JOIN `tblUsers` ON `tblComments`.`user_id` = `tblUsers`.`id` WHERE `tblComments`.`article_id` = '. $article_row[0] .' ORDER BY `tblComments`.`added` DESC;';
				$comment_result = mysql_query($query);
				
				$query = 'SELECT * FROM `tblArticleImages` WHERE `article_id` = '. $article_row[0] .';';
				$img_result = mysql_query($query);
				
				$img_arr = array();
				while ($img_row = mysql_fetch_array($img_result, MYSQL_BOTH)) {
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
					
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
					
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
				}
				
				$comment_arr = array();
				while ($comment_row = mysql_fetch_array($comment_result, MYSQL_BOTH)) {
					$query = 'SELECT * FROM `tblUsersLikedArticles` WHERE `user_id` = '. $comment_row['user_id'] .' AND `article_id` = '. $article_row[0] .';';
					$liked_result = mysql_query($query);
				
					array_push($comment_arr, array(
						"comment_id" => $comment_row[0], 
						"handle" => $comment_row['handle'], 
						"avatar" => "https://api.twitter.com/1/users/profile_image?screen_name=". $comment_row['handle'] ."&size=reasonably_small", 
						"content" => $comment_row['content'], 
						"liked" => (mysql_num_rows($liked_result) > 0), 
						"added" => $comment_row[5]
					));
				}
				
				$query = 'SELECT * FROM `tblUsers` INNER JOIN `tblUsersLikedArticles` ON `tblUsers`.`id` = `tblUsersLikedArticles`.`user_id` WHERE `tblUsersLikedArticles`.`article_id` = '. $article_row[0] .';';
				$user_result = mysql_query($query);
			
				$user_arr = array();
				while ($user_row = mysql_fetch_array($user_result, MYSQL_BOTH)) { 				
					array_push($user_arr, array(
						"id" => $user_row['id'], 
						"id_str" => $user_row['twitter_id'], 
						"screen_name" => $user_row['handle'], 
						"name" => $user_row['name'], 
						"profile_image_url" => "https://api.twitter.com/1/users/profile_image?screen_name=". $user_row['handle'] ."&size=reasonably_small"
					)); 
				}
				
				array_push($article_arr, array(
					"article_id" => $article_row[0], 
					"list_id" => $topic_row[0],
					"topic_name" => $topic_row[1],  
					"type_id" => $article_row[1], 
					"title" => $article_row['title'], 
					"article_url" => $article_row['content_url'], 
					"short_url" => $article_row['short_url'], 
					"tweet_id" => $article_row['tweet_id'], 
					"tweet_msg" => $article_row['tweet_msg'], 
					"twitter_name" => $article_row['name'], 
					"twitter_handle" => $article_row['handle'],
					"content" => $article_row['content_txt'], 
					"avatar_url" => $article_row['avatar_url'], 
					"video_url" => $article_row['youtube_id'], 
					"likes" => $user_arr, 
					"liked" => false, 
					"added" => $article_row['created'], 
					"comments" => $comment_arr, 
					"images" => $img_arr
				)); 
			}
			
			$this->sendResponse(200, json_encode($article_arr));
			return (true);	
		} 
		
		
		function getPopularArticlesAfterID($article_id) {
			$article_arr = array();
			
			$query = 'SELECT * FROM `tblArticles` INNER JOIN `tblContributors` ON `tblArticles`.`contributor_id` = `tblContributors`.`id` WHERE `tblArticles`.`active` = "Y" AND `tblArticles`.`type_id` >= 2 AND `tblArticles`.`id` > '. $article_id .' ORDER BY `tblArticles`.`created` DESC LIMIT 30;';
			$article_result = mysql_query($query);
			
			while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) {
				$query = 'SELECT `tblTopics`.`id`, `tblTopics`.`title` FROM `tblTopics` INNER JOIN `tblTopicsArticles` ON `tblTopics`.`id` = `tblTopicsArticles`.`topic_id` WHERE  `tblTopicsArticles`.`article_id` = '. $article_row[0] .";";
				$topic_row = mysql_fetch_row(mysql_query($query));
				
				$query = 'SELECT * FROM `tblArticleImages` WHERE `article_id` = '. $article_row[0] .';';
				$img_result = mysql_query($query);
				
				$img_arr = array();
				while ($img_row = mysql_fetch_array($img_result, MYSQL_BOTH)) {
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
					
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
					
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
				}
				
				$query = 'SELECT * FROM `tblComments` INNER JOIN `tblUsers` ON `tblComments`.`user_id` = `tblUsers`.`id` WHERE `tblComments`.`article_id` = '. $article_row[0] .' ORDER BY `tblComments`.`added` DESC;';
				$comment_result = mysql_query($query);
				
				$comment_arr = array();
				while ($comment_row = mysql_fetch_array($comment_result, MYSQL_BOTH)) {
					$query = 'SELECT * FROM `tblUsersLikedArticles` WHERE `user_id` = '. $comment_row['user_id'] .' AND `article_id` = '. $article_row[0] .';';
					$liked_result = mysql_query($query);
				
					array_push($comment_arr, array(
						"comment_id" => $comment_row[0], 
						"handle" => $comment_row['handle'], 
						"avatar" => "https://api.twitter.com/1/users/profile_image?screen_name=". $comment_row['handle'] ."&size=reasonably_small", 
						"content" => $comment_row['content'], 
						"liked" => (mysql_num_rows($liked_result) > 0), 
						"added" => $comment_row[5]
					));
				}
				
				$query = 'SELECT * FROM `tblUsers` INNER JOIN `tblUsersLikedArticles` ON `tblUsers`.`id` = `tblUsersLikedArticles`.`user_id` WHERE `tblUsersLikedArticles`.`article_id` = '. $article_row[0] .';';
				$user_result = mysql_query($query);
			
				$user_arr = array();
				while ($user_row = mysql_fetch_array($user_result, MYSQL_BOTH)) { 				
					array_push($user_arr, array(
						"id" => $user_row['id'], 
						"id_str" => $user_row['twitter_id'], 
						"screen_name" => $user_row['handle'], 
						"name" => $user_row['name'], 
						"profile_image_url" => "https://api.twitter.com/1/users/profile_image?screen_name=". $user_row['handle'] ."&size=reasonably_small"
					)); 
				}
								
				array_push($article_arr, array(
					"article_id" => $article_row[0], 
					"list_id" => $topic_row[0], 
					"topic_name" => $topic_row[1],  
					"type_id" => $article_row[1], 
					"title" => $article_row['title'], 
					"article_url" => $article_row['content_url'], 
					"short_url" => $article_row['short_url'], 
					"tweet_id" => $article_row['tweet_id'], 
					"tweet_msg" => $article_row['tweet_msg'], 
					"twitter_name" => $article_row['name'], 
					"twitter_handle" => $article_row['handle'],
					"content" => $article_row['content_txt'], 
					"avatar_url" => $article_row['avatar_url'], 
					"video_url" => $article_row['youtube_id'], 
					"likes" => $user_arr, 
					"liked" => false, 
					"added" => $article_row['created'], 
					"comments" => $comment_arr, 
					"images" => $img_arr
				)); 
			}
			
			$this->sendResponse(200, json_encode($article_arr));
			return (true);	
		}
		
		function getPopularArticlesBeforeDate($date) {
			$article_arr = array();
			
			$query = 'SELECT * FROM `tblArticles` INNER JOIN `tblContributors` ON `tblArticles`.`contributor_id` = `tblContributors`.`id` WHERE `tblArticles`.`active` = "Y" AND `tblArticles`.`type_id` >= 2 AND `tblArticles`.`created` < "'. $date .'" ORDER BY `tblArticles`.`created` DESC LIMIT 30;';
			$article_result = mysql_query($query);
			
			while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) {
				$query = 'SELECT `tblTopics`.`id`, `tblTopics`.`title` FROM `tblTopics` INNER JOIN `tblTopicsArticles` ON `tblTopics`.`id` = `tblTopicsArticles`.`topic_id` WHERE  `tblTopicsArticles`.`article_id` = '. $article_row[0] .";";
				$topic_row = mysql_fetch_row(mysql_query($query));
				
				$query = 'SELECT * FROM `tblArticleImages` WHERE `article_id` = '. $article_row[0] .';';
				$img_result = mysql_query($query);
				
				$img_arr = array();
				while ($img_row = mysql_fetch_array($img_result, MYSQL_BOTH)) {
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
					
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
					
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
				}
				
				$query = 'SELECT * FROM `tblComments` INNER JOIN `tblUsers` ON `tblComments`.`user_id` = `tblUsers`.`id` WHERE `tblComments`.`article_id` = '. $article_row[0] .' ORDER BY `tblComments`.`added` DESC;';
				$comment_result = mysql_query($query);
				
				$comment_arr = array();
				while ($comment_row = mysql_fetch_array($comment_result, MYSQL_BOTH)) {
					$query = 'SELECT * FROM `tblUsersLikedArticles` WHERE `user_id` = '. $comment_row['user_id'] .' AND `article_id` = '. $article_row[0] .';';
					$liked_result = mysql_query($query);
				
					array_push($comment_arr, array(
						"comment_id" => $comment_row[0], 
						"handle" => $comment_row['handle'], 
						"avatar" => "https://api.twitter.com/1/users/profile_image?screen_name=". $comment_row['handle'] ."&size=reasonably_small", 
						"content" => $comment_row['content'], 
						"liked" => (mysql_num_rows($liked_result) > 0), 
						"added" => $comment_row[5]
					));
				}
				
				$query = 'SELECT * FROM `tblUsers` INNER JOIN `tblUsersLikedArticles` ON `tblUsers`.`id` = `tblUsersLikedArticles`.`user_id` WHERE `tblUsersLikedArticles`.`article_id` = '. $article_row[0] .';';
				$user_result = mysql_query($query);
			
				$user_arr = array();
				while ($user_row = mysql_fetch_array($user_result, MYSQL_BOTH)) { 				
					array_push($user_arr, array(
						"id" => $user_row['id'], 
						"id_str" => $user_row['twitter_id'], 
						"screen_name" => $user_row['handle'], 
						"name" => $user_row['name'], 
						"profile_image_url" => "https://api.twitter.com/1/users/profile_image?screen_name=". $user_row['handle'] ."&size=reasonably_small"
					)); 
				}
								
				array_push($article_arr, array(
					"article_id" => $article_row[0], 
					"list_id" => $topic_row[0], 
					"topic_name" => $topic_row[1],  
					"type_id" => $article_row[1], 
					"title" => $article_row['title'], 
					"article_url" => $article_row['content_url'], 
					"short_url" => $article_row['short_url'], 
					"tweet_id" => $article_row['tweet_id'], 
					"tweet_msg" => $article_row['tweet_msg'], 
					"twitter_name" => $article_row['name'], 
					"twitter_handle" => $article_row['handle'],
					"content" => $article_row['content_txt'], 
					"avatar_url" => $article_row['avatar_url'], 
					"video_url" => $article_row['youtube_id'], 
					"likes" => $user_arr, 
					"liked" => false, 
					"added" => $article_row['created'], 
					"comments" => $comment_arr, 
					"images" => $img_arr
				)); 
			}
			
			
			$this->sendResponse(200, json_encode($article_arr));
			return (true);
		}
		
		function getTopicArticlesBeforeDate($topic_id, $date) {
			$article_arr = array();
			
			if ($topic_id == "10")
				$query = 'SELECT * FROM `tblArticles` INNER JOIN `tblContributors` ON `tblArticles`.`contributor_id` = `tblContributors`.`id` INNER JOIN `tblTopicsArticles` ON `tblArticles`.`id` = `tblTopicsArticles`.`article_id` WHERE `tblArticles`.`active` = "Y" AND `tblTopicsArticles`.`topic_id` = '. $topic_id .' AND `tblArticles`.`type_id` >= 4 AND `tblArticles`.`created` < "'. $date .'" ORDER BY `tblArticles`.`created` DESC LIMIT 30;';
			else
				$query = 'SELECT * FROM `tblArticles` INNER JOIN `tblContributors` ON `tblArticles`.`contributor_id` = `tblContributors`.`id` INNER JOIN `tblTopicsArticles` ON `tblArticles`.`id` = `tblTopicsArticles`.`article_id` WHERE `tblArticles`.`active` = "Y" AND `tblTopicsArticles`.`topic_id` = '. $topic_id .' AND `tblArticles`.`type_id` >= 2 AND `tblArticles`.`created` < "'. $date .'" ORDER BY `tblArticles`.`created` DESC LIMIT 30;';
			$article_result = mysql_query($query);
			
			while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) {				
				$query = 'SELECT `title` FROM `tblTopics` WHERE `id` = '. $topic_id .";";
				$topic_row = mysql_fetch_row(mysql_query($query));
				
				$query = 'SELECT * FROM `tblArticleImages` WHERE `article_id` = '. $article_row[0] .';';
				$img_result = mysql_query($query);
				
				$img_arr = array();
				while ($img_row = mysql_fetch_array($img_result, MYSQL_BOTH)) {
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
					
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
					
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
				}
				
				$query = 'SELECT * FROM `tblComments` INNER JOIN `tblUsers` ON `tblComments`.`user_id` = `tblUsers`.`id` WHERE `tblComments`.`article_id` = '. $article_row[0] .' ORDER BY `tblComments`.`added` DESC;';
				$comment_result = mysql_query($query);
				
				$comment_arr = array();
				while ($comment_row = mysql_fetch_array($comment_result, MYSQL_BOTH)) {
					$query = 'SELECT * FROM `tblUsersLikedArticles` WHERE `user_id` = '. $comment_row['user_id'] .' AND `article_id` = '. $article_row[0] .';';
					$liked_result = mysql_query($query);
				
					array_push($comment_arr, array(
						"comment_id" => $comment_row[0], 
						"handle" => $comment_row['handle'], 
						"avatar" => "https://api.twitter.com/1/users/profile_image?screen_name=". $comment_row['handle'] ."&size=reasonably_small", 
						"content" => $comment_row['content'], 
						"liked" => (mysql_num_rows($liked_result) > 0), 
						"added" => $comment_row[5]
					));
				}
				
				$query = 'SELECT * FROM `tblUsers` INNER JOIN `tblUsersLikedArticles` ON `tblUsers`.`id` = `tblUsersLikedArticles`.`user_id` WHERE `tblUsersLikedArticles`.`article_id` = '. $article_row[0] .';';
				$user_result = mysql_query($query);
			
				$user_arr = array();
				while ($user_row = mysql_fetch_array($user_result, MYSQL_BOTH)) { 				
					array_push($user_arr, array(
						"id" => $user_row['id'], 
						"id_str" => $user_row['twitter_id'], 
						"screen_name" => $user_row['handle'], 
						"name" => $user_row['name'], 
						"profile_image_url" => "https://api.twitter.com/1/users/profile_image?screen_name=". $user_row['handle'] ."&size=reasonably_small"
					)); 
				}
				
				array_push($article_arr, array(
					"article_id" => $article_row['article_id'], 
					"list_id" => $topic_id, 
					"topic_name" => $topic_row[0], 
					"type_id" => $article_row[1], 
					"title" => $article_row['title'], 
					"article_url" => $article_row['content_url'], 
					"short_url" => $article_row['short_url'], 
					"tweet_id" => $article_row['tweet_id'], 
					"tweet_msg" => $article_row['tweet_msg'], 
					"twitter_name" => $article_row['name'], 
					"twitter_handle" => $article_row['handle'],
					"content" => $article_row['content_txt'], 
					"avatar_url" => $article_row['avatar_url'], 
					"video_url" => $article_row['youtube_id'], 
					"likes" => $user_arr, 
					"liked" => false, 
					"added" => $article_row['created'], 
					"comments" => $comment_arr, 
					"images" => $img_arr
				)); 
			}
			
			$this->sendResponse(200, json_encode($article_arr));
			return (true);
		} 
		
		function getDiscoveryArticles() {
			$article_arr = array();
			
			$query = 'SELECT * FROM `tblArticles` INNER JOIN `tblContributors` ON `tblArticles`.`contributor_id` = `tblContributors`.`id` WHERE `tblArticles`.`active` = "Y" AND `tblArticles`.`type_id` >= 2 ORDER BY `tblArticles`.`created` DESC LIMIT 10;';
			$article_result = mysql_query($query);
			
			while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) {
				$query = 'SELECT `tblTopics`.`id`, `tblTopics`.`title` FROM `tblTopics` INNER JOIN `tblTopicsArticles` ON `tblTopics`.`id` = `tblTopicsArticles`.`topic_id` WHERE  `tblTopicsArticles`.`article_id` = '. $article_row[0] .";";
				$topic_row = mysql_fetch_row(mysql_query($query));
				
				$query = 'SELECT * FROM `tblArticleImages` WHERE `article_id` = '. $article_row[0] .';';
				$img_result = mysql_query($query);
				
				$img_arr = array();
				while ($img_row = mysql_fetch_array($img_result, MYSQL_BOTH)) {
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
					
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
					
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
				}
							
				$query = 'SELECT * FROM `tblComments` INNER JOIN `tblUsers` ON `tblComments`.`user_id` = `tblUsers`.`id` WHERE `tblComments`.`article_id` = '. $article_row[0] .' ORDER BY `tblComments`.`added` DESC;';
				$comment_result = mysql_query($query);
				
				$comment_arr = array();
				while ($comment_row = mysql_fetch_array($comment_result, MYSQL_BOTH)) {
					$query = 'SELECT * FROM `tblUsersLikedArticles` WHERE `user_id` = '. $comment_row['user_id'] .' AND `article_id` = '. $article_row[0] .';';
					$liked_result = mysql_query($query);
				
					array_push($comment_arr, array(
						"comment_id" => $comment_row[0], 
						"handle" => $comment_row['handle'], 
						"avatar" => "https://api.twitter.com/1/users/profile_image?screen_name=". $comment_row['handle'] ."&size=reasonably_small", 
						"content" => $comment_row['content'], 
						"liked" => (mysql_num_rows($liked_result) > 0), 
						"added" => $comment_row[5]
					));
				}
				
				$query = 'SELECT * FROM `tblUsers` INNER JOIN `tblUsersLikedArticles` ON `tblUsers`.`id` = `tblUsersLikedArticles`.`user_id` WHERE `tblUsersLikedArticles`.`article_id` = '. $article_row[0] .';';
				$user_result = mysql_query($query);
			
				$user_arr = array();
				while ($user_row = mysql_fetch_array($user_result, MYSQL_BOTH)) { 				
					array_push($user_arr, array(
						"id" => $user_row['id'], 
						"id_str" => $user_row['twitter_id'], 
						"screen_name" => $user_row['handle'], 
						"name" => $user_row['name'], 
						"profile_image_url" => "https://api.twitter.com/1/users/profile_image?screen_name=". $user_row['handle'] ."&size=reasonably_small"
					)); 
				}
				
				array_push($article_arr, array(
					"article_id" => $article_row[0], 
					"list_id" => $topic_row[0],
					"topic_name" => $topic_row[1],  
					"type_id" => $article_row[1], 
					"title" => $article_row['title'], 
					"article_url" => $article_row['content_url'], 
					"short_url" => $article_row['short_url'], 
					"tweet_id" => $article_row['tweet_id'], 
					"tweet_msg" => $article_row['tweet_msg'], 
					"twitter_name" => $article_row['name'], 
					"twitter_handle" => $article_row['handle'],
					"content" => $article_row['content_txt'], 
					"avatar_url" => $article_row['avatar_url'], 
					"video_url" => $article_row['youtube_id'], 
					"likes" => $user_arr, 
					"liked" => false, 
					"added" => $article_row['created'], 
					"comments" => $comment_arr, 
					"images" => $img_arr
				)); 
			}
			
			$this->sendResponse(200, json_encode($article_arr));
			return (true);
		}
		
		
		function getDiscoveryArticlesBeforeDate($date) {
			$article_arr = array();
			
			$query = 'SELECT * FROM `tblArticles` INNER JOIN `tblContributors` ON `tblArticles`.`contributor_id` = `tblContributors`.`id` WHERE `tblArticles`.`active` = "Y" AND `tblArticles`.`type_id` >= 2 AND `tblArticles`.`created` < "'. $date .'" ORDER BY `tblArticles`.`created` DESC LIMIT 10;';
			$article_result = mysql_query($query);
			
			while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) {
				$query = 'SELECT `tblTopics`.`id`, `tblTopics`.`title` FROM `tblTopics` INNER JOIN `tblTopicsArticles` ON `tblTopics`.`id` = `tblTopicsArticles`.`topic_id` WHERE  `tblTopicsArticles`.`article_id` = '. $article_row[0] .";";
				$topic_row = mysql_fetch_row(mysql_query($query));
				
				$query = 'SELECT * FROM `tblArticleImages` WHERE `article_id` = '. $article_row[0] .';';
				$img_result = mysql_query($query);
				
				$img_arr = array();
				while ($img_row = mysql_fetch_array($img_result, MYSQL_BOTH)) {
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
					
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
					
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));
				}
							
				$query = 'SELECT * FROM `tblComments` INNER JOIN `tblUsers` ON `tblComments`.`user_id` = `tblUsers`.`id` WHERE `tblComments`.`article_id` = '. $article_row[0] .' ORDER BY `tblComments`.`added` DESC;';
				$comment_result = mysql_query($query);
				
				$comment_arr = array();
				while ($comment_row = mysql_fetch_array($comment_result, MYSQL_BOTH)) {
					$query = 'SELECT * FROM `tblUsersLikedArticles` WHERE `user_id` = '. $comment_row['user_id'] .' AND `article_id` = '. $article_row[0] .';';
					$liked_result = mysql_query($query);
				
					array_push($comment_arr, array(
						"comment_id" => $comment_row[0], 
						"handle" => $comment_row['handle'], 
						"avatar" => "https://api.twitter.com/1/users/profile_image?screen_name=". $comment_row['handle'] ."&size=reasonably_small", 
						"content" => $comment_row['content'], 
						"liked" => (mysql_num_rows($liked_result) > 0), 
						"added" => $comment_row[5]
					));
				}
				
				$query = 'SELECT * FROM `tblUsers` INNER JOIN `tblUsersLikedArticles` ON `tblUsers`.`id` = `tblUsersLikedArticles`.`user_id` WHERE `tblUsersLikedArticles`.`article_id` = '. $article_row[0] .';';
				$user_result = mysql_query($query);
			
				$user_arr = array();
				while ($user_row = mysql_fetch_array($user_result, MYSQL_BOTH)) { 				
					array_push($user_arr, array(
						"id" => $user_row['id'], 
						"id_str" => $user_row['twitter_id'], 
						"screen_name" => $user_row['handle'], 
						"name" => $user_row['name'], 
						"profile_image_url" => "https://api.twitter.com/1/users/profile_image?screen_name=". $user_row['handle'] ."&size=reasonably_small"
					)); 
				}
				
				array_push($article_arr, array(
					"article_id" => $article_row[0], 
					"list_id" => $topic_row[0],
					"topic_name" => $topic_row[1],  
					"type_id" => $article_row[1], 
					"title" => $article_row['title'], 
					"article_url" => $article_row['content_url'], 
					"short_url" => $article_row['short_url'], 
					"tweet_id" => $article_row['tweet_id'], 
					"tweet_msg" => $article_row['tweet_msg'], 
					"twitter_name" => $article_row['name'], 
					"twitter_handle" => $article_row['handle'],
					"content" => $article_row['content_txt'], 
					"avatar_url" => $article_row['avatar_url'], 
					"video_url" => $article_row['youtube_id'], 
					"likes" => $user_arr, 
					"liked" => false, 
					"added" => $article_row['created'], 
					"comments" => $comment_arr, 
					"images" => $img_arr
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
				if (isset($_POST['userID']) && isset($_POST['articleID']))
					$articles->addLike($_POST['userID'], $_POST['articleID']);
				break;
				
			case "2":
				if (isset($_POST['userID']))
					$articles->getArticlesCommentedByUser($_POST['userID']);
				break;
				
			case "3":
				if (isset($_POST['userID']) && isset($_POST['articleID']) && isset($_POST['typeID']))
					$articles->shareArticle($_POST['userID'], $_POST['articleID'], $_POST['typeID']);
				break;
				
			case "4":
				if (isset($_POST['topicID']) && isset($_POST['articleID']))
					$articles->getTopicArticlesAfterID($_POST['topicID'], $_POST['articleID']);
				break;
				
			case "5":
				if (isset($_POST['userID']))
					$articles->getArticlesSharedByUser($_POST['userID']);
				break;
				
			case "6":
				if (isset($_POST['userID']))
					$articles->getArticlesLikedByUser($_POST['userID']);
				break;
				
			case "7":
				if (isset($_POST['userID']) && isset($_POST['articleID']))
					$articles->removeLike($_POST['userID'], $_POST['articleID']);
				break;
				
			case "8":
			 	if (isset($_POST['topicID']))
					$articles->getArticlesForTopic($_POST['topicID']);
				break;
				
			case "9":
				if (isset($_POST['userID']) && isset($_POST['articleID']) && isset($_POST['content']) && isset($_POST['liked']))
					$articles->submitComment($_POST['userID'], $_POST['articleID'], $_POST['content'], $_POST['liked']);
				break;
				
			case "10":
				$articles->getPopularArticles();
				break;
				
			case "11":
				if (isset($_POST['articleID']))
					$articles->getPopularArticlesAfterID($_POST['articleID']);
				break;
				 
			case "12":
				if (isset($_POST['datetime']))
					$articles->getPopularArticlesBeforeDate($_POST['datetime']);
				break;
				
			case "13":
				if (isset($_POST['topicID']) && isset($_POST['datetime']))
					$articles->getTopicArticlesBeforeDate($_POST['topicID'], $_POST['datetime']);
				break;
				
			case "14":
				$articles->getDiscoveryArticles();
				break;
				
			 case "15":
				if (isset($_POST['datetime']))
					$articles->getDiscoveryArticlesBeforeDate($_POST['datetime']);
				break;
				
		     case "16":
				$articles->getDiscoveryArticlesBeforeDate($_POST['datetime']);
				break;
    	}
	}
?>