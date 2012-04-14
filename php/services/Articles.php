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
	    
		function getArticlesForList($list_id) {
			$article_arr = array();
			
			$query = 'SELECT * FROM `tblInfluencers` INNER JOIN `tblListsInfluencers` ON `tblInfluencers`.`id` = `tblListsInfluencers`.`influencer_id` WHERE `tblListsInfluencers`.`list_id` = "'. $list_id .'";';
			$influencer_result = mysql_query($query);
			
			while ($influencer_row = mysql_fetch_array($influencer_result, MYSQL_BOTH)) { 
				$query = 'SELECT * FROM `tblArticles` WHERE `influencer_id` = "'. $influencer_row['id'] .'";';
				$article_result = mysql_query($query);
				
				while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) {
					$query = 'SELECT * FROM `tblComments` WHERE `article_id` = "'. $article_row['id'] .'" AND `list_id` = "'. $list_id .'";';
					$comments_result = mysql_query($query);
				
					$reaction_arr = array();
					while ($comment_row = mysql_fetch_array($comments_result, MYSQL_BOTH)) {
						array_push($reaction_arr, array(
							"reaction_id" => $comment_row['id'], 
							"thumb_url" => "https://si0.twimg.com/profile_images/180710325/andvari.jpg", 
							"user_url" => "https://twitter.com/#!/andvari", 
							"reaction_url" => "http://shelby.tv", 
							"content" => $comment_row['content']
						 ));
					}
					
					array_push($article_arr, array(
						"article_id" => $article_row['id'], 
						"type_id" => $article_row['type_id'], 
						"source_id" => $article_row['source_id'], 
						"title" => $article_row['title'], 
						"article_url" => $article_row['article_url'], 
						"short_url" => $article_row['short_url'], 
						"tweet_id" => $article_row['tweet_id'], 
						"tweet_msg" => $article_row['tweet_msg'], 
						"twitter_name" => $influencer_row['name'], 
						"twitter_handle" => $influencer_row['handle'],
						"twitter_info" => $influencer_row['info'], 
						"bg_url" => $article_row['image_url'], 
						"thumb_url" => $article_row['thumb_url'], 
						"content" => $article_row['content'], 
						"avatar_url" => $influencer_row['avatar_url'], 
						"video_url" => $article_row['video_url'], 
						"is_dark" => $article_row['isDark'], 
						"added" => $article_row['added'], 
						"tags" => array(), 
						"reactions" => $reaction_arr
					));
				}
			}
			
			
			$this->sendResponse(200, json_encode($article_arr));
			return (true);
		}
		
		function submitComment($handle, $list_id, $article_id, $content) {
			$query = 'SELECT `id` FROM `tblUsers` WHERE `handle` = "'. $handle .'";';
			$result = mysql_query($query);
			
			$user_id = "0";
			if (mysql_num_rows($result) > 0) {
				$row = mysql_fetch_row($result);
				$user_id = $row[0];
			}
			
			
			$query = 'INSERT INTO `tblComments` (';
			$query .= '`id`, `article_id`, `list_id`, `user_id`, `content`, `added`) ';
			$query .= 'VALUES (NULL, "'. $article_id .'", "'. $list_id .'", "'. $user_id .'", "'. $content .'", NOW());';
			$result = mysql_query($query);
			$comment_id = mysql_insert_id();
			
			$this->sendResponse(200, json_encode(array(
				"comment_id" => $comment_id
			)));
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
				
			case "8":
			 	if (isset($_POST['listID']))
					$articles->getArticlesForList($_POST['listID']);
				break;
				
			case "9":
				if (isset($_POST['handle']) && isset($_POST['listID']) && isset($_POST['articleID']) && isset($_POST['content']))
					$articles->submitComment($_POST['handle'], $_POST['listID'], $_POST['articleID'], $_POST['content']);
				break;
    	}
	}
?>