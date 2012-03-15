<?php

	class Articles {
		private $db_conn;
	
	  	function __construct() {
		
			$this->db_conn = mysql_connect('internal-db.s41232.gridserver.com', 'db41232_sn_usr', 'dope911t') or die("Could not connect to database.");
			mysql_select_db('db41232_simplenews') or die("Could not select database.");
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
	
		
		function articlesByChannel($chan_id) {
			$article_arr = array();
			$query = 'SELECT * FROM `tblArticles` INNER JOIN `tblFollowersChannels` ON `tblArticles`.`follower_id` = `tblFollowersChannels`.`follower_id` WHERE `tblFollowersChannels`.`channel_id` = "'. $chan_id .'"';
			$article_result = mysql_query($query);
			
			$tot = 0;
			while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) {
				array_push($article_arr, array(
					"article_id" => $article_row['id'], 
					"handle" => $article_row['handle'],
					"name" => $article_row['name'], 
					"avatar_url" => $article_row['avatar_url']
				));
				
				$tot++;
	    	}
			
			$this->sendResponse(200, json_encode($article_arr));
			return (true);	
		}
		
		function articlesByFollower($follower_id) {
			$article_arr = array();
			$query = 'SELECT * FROM `tblArticles` WHERE `follower_id` = "'. $follower_id .'";';
			$article_result = mysql_query($query);
			
			$query = 'SELECT `avatar_url`, `name` FROM `tblTwitterFollowers` WHERE `id` = "'. $follower_id .'";';
			$follower_arr = mysql_fetch_row(mysql_query($query));
			
				
			$tot = 0;
			while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) { 
				$query = 'SELECT * FROM `tblTags` INNER JOIN `tblArticlesTags` ON `tblTags`.`id` = `tblArticlesTags`.`tag_id` WHERE `tblArticlesTags`.`article_id` = "'. $article_row['id'] .'";';
				$tag_result = mysql_query($query);
				
				$tag_arr = array();
				while ($tag_row = mysql_fetch_array($tag_result, MYSQL_BOTH)) { 
					array_push($tag_arr, array(
						"tag_id" => $tag_row['id'], 
						"title" => $tag_row['title']
					));
				}
				
				array_push($article_arr, array(
					"article_id" => $article_row['id'], 
					"type_id" => $article_row['type_id'], 
					"title" => $article_row['title'], 
					"tweet_msg" => $article_row['tweet_msg'], 
					"twitter_name" => $follower_arr[1], 
					"bg_url" => $article_row['image_url'], 
					"content" => $article_row['content'], 
					"avatar_url" => $follower_arr[0], 
					"video_url" => $article_row['video_url'], 
					"is_dark" => $article_row['isDark'], 
					"added" => $article_row['added'], 
					"tags" => $tag_arr
				));
				
				$tot++;
	    	}
			
			$this->sendResponse(200, json_encode($article_arr));
			return (true);	
		}
		
		
		function articlesByFollowers($follower_list) {
			
			$article_arr = array();
			$follower_arr = explode('|', $follower_list);
			
			foreach ($follower_arr as $follower_id) {	
				$query = 'SELECT * FROM `tblArticles` WHERE `follower_id` = "'. $follower_id .'";';
				$article_result = mysql_query($query);
			
				$query = 'SELECT `avatar_url`, `name` FROM `tblTwitterFollowers` WHERE `id` = "'. $follower_id .'";';
				$follower_arr = mysql_fetch_row(mysql_query($query));
			
				
				$tot = 0;
				while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) { 
					$query = 'SELECT * FROM `tblTags` INNER JOIN `tblArticlesTags` ON `tblTags`.`id` = `tblArticlesTags`.`tag_id` WHERE `tblArticlesTags`.`article_id` = "'. $article_row['id'] .'";';
					$tag_result = mysql_query($query);
				
					$tag_arr = array();
					while ($tag_row = mysql_fetch_array($tag_result, MYSQL_BOTH)) { 
						array_push($tag_arr, array(
							"tag_id" => $tag_row['id'], 
							"title" => $tag_row['title']
						));
					}
				
					array_push($article_arr, array(
						"article_id" => $article_row['id'], 
						"type_id" => $article_row['type_id'], 
						"title" => $article_row['title'], 
						"tweet_msg" => $article_row['tweet_msg'], 
						"twitter_name" => $follower_arr[1], 
						"bg_url" => $article_row['image_url'], 
						"content" => $article_row['content'], 
						"avatar_url" => $follower_arr[0], 
						"video_url" => $article_row['video_url'], 
						"is_dark" => $article_row['isDark'], 
						"added" => $article_row['added'], 
						"tags" => $tag_arr
					));
				
					$tot++;
		    	}  
		    }
			
			$this->sendResponse(200, json_encode($article_arr));
			return (true);	
		}
		
		
		
		function getMostRecentArticles() {
			$article_arr = array();
			
			$query = 'SELECT * FROM `tblArticles` WHERE `added` >= "2012-03-14 00:00:00";';
			$article_result = mysql_query($query); 
			
			$tot = 0;
			while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) { 
				$query = 'SELECT `avatar_url`, `name` FROM `tblTwitterFollowers` WHERE `id` = "'. $article_row['follower_id'] .'";';
				$follower_arr = mysql_fetch_row(mysql_query($query));
				
				$query = 'SELECT * FROM `tblTags` INNER JOIN `tblArticlesTags` ON `tblTags`.`id` = `tblArticlesTags`.`tag_id` WHERE `tblArticlesTags`.`article_id` = "'. $article_row['id'] .'";';
				$tag_result = mysql_query($query);
				
				$tag_arr = array();
				while ($tag_row = mysql_fetch_array($tag_result, MYSQL_BOTH)) { 
					array_push($tag_arr, array(
						"tag_id" => $tag_row['id'], 
						"title" => $tag_row['title']
					));
				}
				
				array_push($article_arr, array(
					"article_id" => $article_row['id'], 
					"type_id" => $article_row['type_id'], 
					"title" => $article_row['title'], 
					"tweet_msg" => $article_row['tweet_msg'], 
					"twitter_name" => $follower_arr[1], 
					"bg_url" => $article_row['image_url'], 
					"content" => $article_row['content'], 
					"avatar_url" => $follower_arr[0], 
					"video_url" => $article_row['video_url'], 
					"is_dark" => $article_row['isDark'], 
					"added" => $article_row['added'], 
					"tags" => $tag_arr
				));
				
				$tot++;
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
	////$channels->test();
	
	
	if (isset($_POST['action'])) {
		switch ($_POST['action']) {
			
			case "0":
				if (isset($_POST['channelID']))
					$articles->articlesByChannel($_POST['channelID']);
				break;
				
			case "1":
				if (isset($_POST['followerID']))
					$articles->articlesByFollower($_POST['followerID']);
				break;
				
			case "2":
				$articles->getMostRecentArticles();
				break;
				
			case "3":
				if (isset($_POST['followers']))
					$articles->articlesByFollowers($_POST['followers']);
				break;
    	}
	}
?>