<?php

	class Composer {
		private $db_conn;
	
	  	function __construct() {
		
			$this->db_conn = mysql_connect('localhost', 'db41232_sn_usr', 'dope911t') or die("Could not connect to database.");
			mysql_select_db('assembly-dev') or die("Could not select database.");
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
	
		
		function submitQuoteArticle($user_id, $img_url) {
			$query = 'SELECT * FROM `tblUsers` WHERE `id` = '. $user_id .';';
			$user_row = mysql_fetch_row(mysql_query($query));
		   
		 	$article_arr = array();
			if ($user_row) {
				$query = 'INSERT INTO `tblArticles` (';
				$query .= '`id`, `type_id`, `tweet_id`, `contributor_id`, `tweet_msg`, `short_url`, `title`, `content_txt`, `content_url`, `image_url`, `retweets`, `image_ratio`, `youtube_id`, `active`, `created`, `added`) ';
				$query .= 'VALUES (NULL, "2", "0", "'. $user_id .'", "", "", "", "", "", "", "0", "1.0", "", "Y", NOW(), NOW());';	 
			    $ins1_result = mysql_query($query);
				$article_id = mysql_insert_id();
		
				$query = 'INSERT INTO `tblTopicsArticles` ('; 
				$query .= '`topic_id`, `article_id`) ';
				$query .= 'VALUES ("3", "'. $article_id .'");';
				$ins2_result = mysql_query($query);
				
				$size_arr = getimagesize($img_url);
				$img_ratio = $size_arr[1] / $size_arr[0];
				
				$query = 'INSERT INTO tblArticleImages (';
				$query .= '`id`, `type_id`, `article_id`, `url`, `ratio`, `added`) ';
				$query .= 'VALUES (NULL, 1, "'. $article_id .'", "'. $img_url .'", "'. $img_ratio .'", NOW());';
				$ins3_result = mysql_query($query);

								
				$query = 'SELECT * FROM `tblArticles` INNER JOIN `tblContributors` ON `tblArticles`.`contributor_id` = `tblContributors`.`id` WHERE `tblArticles`.`active` = "Y" AND `tblArticles`.`id` = '. $article_id .';';				
				$article_row = mysql_fetch_row(mysql_query($query));
				
				if (!$article_row)
					continue;
				
				$query = 'SELECT `tblTopics`.`id`, `tblTopics`.`title` FROM `tblTopics` INNER JOIN `tblTopicsArticles` ON `tblTopics`.`id` = `tblTopicsArticles`.`topic_id` WHERE `tblTopicsArticles`.`article_id` = '. $article_id .';';
				$topic_row = mysql_fetch_row(mysql_query($query));
				
				$query = 'SELECT * FROM `tblArticleImages` WHERE `article_id` = '. $article_id .';';
				$img_result = mysql_query($query);
				
				$img_arr = array();
				while ($img_row = mysql_fetch_array($img_result, MYSQL_BOTH)) {
					array_push($img_arr, array(
						"id" => $img_row['id'], 
						"type_id" => $img_row['type_id'], 
						"url" => $img_row['url'], 
						"ratio" => $img_row['ratio']
					));					
				}
				
				switch (mysql_num_rows($img_result)) {
					case 1:
						array_push($img_arr, $img_arr[0]);						
				   		array_push($img_arr, $img_arr[0]);
						break;
						
					case 2:					
						array_push($img_arr, $img_arr[0]);
						break;
				}
				
				$query = 'SELECT * FROM `tblComments` INNER JOIN `tblUsers` ON `tblComments`.`user_id` = `tblUsers`.`id` WHERE `tblComments`.`article_id` = '. $article_id .' ORDER BY `tblComments`.`added` DESC;';
				$comment_result = mysql_query($query);
				
				$comment_arr = array();
				while ($comment_row = mysql_fetch_array($comment_result, MYSQL_BOTH)) {
					$query = 'SELECT * FROM `tblUsersLikedArticles` WHERE `user_id` = '. $comment_row['user_id'] .' AND `article_id` = '. $article_id .';';
					$liked_result = mysql_query($query);
					
					array_push($comment_arr, array(
						"comment_id" => $comment_row[0], 
						"handle" => $comment_row['handle'], 
						"avatar" => "https://api.twitter.com/1/users/profile_image?screen_name=". $comment_row['handle'] ."&size=normal", 
						"content" => $comment_row['content'], 
						"liked" => (mysql_num_rows($liked_result) > 0), 
						"added" => $comment_row[5]
					));
				}
				
				$query = 'SELECT * FROM `tblUsers` INNER JOIN `tblUsersLikedArticles` ON `tblUsers`.`id` = `tblUsersLikedArticles`.`user_id` WHERE `tblUsersLikedArticles`.`article_id` = '. $article_id .';';
				$user_result = mysql_query($query);
			
				$user_arr = array();
				while ($user_row = mysql_fetch_array($user_result, MYSQL_BOTH)) { 				
					array_push($user_arr, array(
						"id" => $user_row['id'], 
						"id_str" => $user_row['twitter_id'], 
						"screen_name" => $user_row['handle'], 
						"name" => $user_row['name'], 
						"profile_image_url" => "https://api.twitter.com/1/users/profile_image?screen_name=". $user_row['handle'] ."&size=normal"
					)); 
				}
			    
				$article_arr = array(
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
					"avatar_url" => $article_row[20], 
					"video_url" => $article_row[12], 
					"likes" => $user_arr, 
					"added" => $article_row[15], 
					"comments" => $comment_arr, 
					"images" => $img_arr
				);
			}
			
			$this->sendResponse(200, json_encode($article_arr));
			
			return (true);
		}
		
		function getStickerList() {
			$sticker_arr = array();
			
			$query = 'SELECT * FROM `tblComposeStickers` WHERE `active` = "Y";';
			$result = mysql_query($query);
			
			while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
				$query = 'SELECT `topic_id` FROM `tblStickersTopics` WHERE `sticker_id` = '. $row['id'] .';';
				$topic_row = mysql_fetch_row(mysql_query($query));
				
				array_push($sticker_arr, array(
					"id" => $row['id'], 
					"title" => $row['title'], 
					"url" => $row['url'], 
					"topic_id" => $topic_row[0]
				));				
			}			
			
			$this->sendResponse(200, json_encode($sticker_arr));
			return (true);
		}
		
		function submitStickerArticle($user_id, $img_url, $sticker_id) {
			$query = 'SELECT * FROM `tblUsers` WHERE `id` = '. $user_id .';';
			$user_row = mysql_fetch_row(mysql_query($query));
			
			$article_arr = array();
			if ($user_row) {
				$query = 'SELECT `topic_id` FROM `tblComposeStickers` WHERE `sticker_id` = '. $sticker_id .';';
				$sticker_result = mysql_query($query);
				$sticker_row = mysql_fetch_row($sticker_result);
				$topic_id = $sticker_row[0];
				
				$query = 'INSERT INTO `tblArticles` (';
				$query .= '`id`, `type_id`, `tweet_id`, `contributor_id`, `tweet_msg`, `short_url`, `title`, `content_txt`, `content_url`, `image_url`, `retweets`, `image_ratio`, `youtube_id`, `active`, `created`, `added`) ';
				$query .= 'VALUES (NULL, "2", "0", "'. $user_id .'", "", "", "", "", "", "", "0", "1.0", "", "Y", NOW(), NOW());';	 
			    $ins1_result = mysql_query($query);
				$article_id = mysql_insert_id();
		
				$query = 'INSERT INTO `tblTopicsArticles` ('; 
				$query .= '`topic_id`, `article_id`) ';
				$query .= 'VALUES ("'. $topic_id .'", "'. $article_id .'");';
				$ins2_result = mysql_query($query);
				
				$size_arr = getimagesize($img_url);
				$img_ratio = $size_arr[1] / $size_arr[0];
				
				$query = 'INSERT INTO tblArticleImages (';
				$query .= '`id`, `type_id`, `article_id`, `url`, `ratio`, `added`) ';
				$query .= 'VALUES (NULL, 1, "'. $article_id .'", "'. $img_url .'", "'. $img_ratio .'", NOW());';
				$ins3_result = mysql_query($query);
				
								
				$query = 'SELECT * FROM `tblArticles` INNER JOIN `tblContributors` ON `tblArticles`.`contributor_id` = `tblContributors`.`id` INNER JOIN `tblTopicsArticles` ON `tblArticles`.`id` = `tblTopicsArticles`.`article_id` WHERE `tblArticles`.`article_id` = '. $article_id .';';
				$result = mysql_query($query);
				$article_row = mysql_fetch_row($result);
				
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
				}
					
				switch (mysql_num_rows($img_result)) {
					case 1:
						array_push($img_arr, $img_arr[0]);						
				   		array_push($img_arr, $img_arr[0]);
						break;
						
					case 2:					
						array_push($img_arr, $img_arr[0]);
						break;
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
						"avatar" => "https://api.twitter.com/1/users/profile_image?screen_name=". $comment_row['handle'] ."&size=normal", 
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
						"profile_image_url" => "https://api.twitter.com/1/users/profile_image?screen_name=". $user_row['handle'] ."&size=normal"
					)); 
				}
				
				$article_arr = array(
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
				);												
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
	
	$composer = new Composer;
	////$lists->test();
	
	
	if (isset($_POST['action'])) {
		switch ($_POST['action']) {
			
			case "0":
				if (isset($_POST['userID']) && isset($_POST['imgURL']))
					$composer->submitQuoteArticle($_POST['userID'], $_POST['imgURL']);
				break;
				
			case "1":
				$composer->getStickerList();
				break;
				
			case "2":
				if (isset($_POST['userID']) && isset($_POST['imgURL']) && isset($_POST['stickerID']))
					$composer->submitStickerArticle($_POST['userID'], $_POST['imgURL'], $_POST['stickerID']);
				break;
    	}
	}
?>