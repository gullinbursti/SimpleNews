<?php

	class Lists {
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
	
		
		function getPublicLists() {
			$list_arr = array();
            
			$query = 'SELECT `id`, `title`, `info`, `image_url`, `thumb_url` FROM `tblLists` WHERE `active` = "Y" ORDER BY `title` DESC;';
			$list_result = mysql_query($query);
			
            while ($list_row = mysql_fetch_array($list_result, MYSQL_BOTH)) {
	            $query = 'SELECT * FROM `tblListsCurators` WHERE `list_id` = "'. $list_row['id'] .'";';
				$result = mysql_query($query);
				
				$curator_arr = array();
				while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
					$query = 'SELECT * FROM `tblCurators` WHERE `id` = "'. $row['curator_id'] .'";';
					$curator_row = mysql_fetch_row(mysql_query($query));
					
				    array_push($curator_arr, array(
						"curator_id" => $curator_row[0], 
						"handle" => $curator_row[1], 
						"name" => $curator_row[2], 
						"info" => $curator_row[3] 
					));
				}
	
				$query = 'SELECT * FROM `tblListsInfluencers` WHERE `list_id` = "'. $list_row['id'] .'";';
				$influencer_result = mysql_query($query);
				
				$likes_tot = 0;
				while ($influencer_row = mysql_fetch_array($influencer_result, MYSQL_BOTH)) {
					$query = 'SELECT `likes` FROM `tblArticles` WHERE `influencer_id` = "'. $influencer_row['influencer_id'] .'";';
					$article_result = mysql_query($query);
					
					while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH))
						$likes_tot += $article_row['likes'];
				}
				
				$query = 'SELECT * FROM `tblUsersLists` WHERE `list_id` = "'. $list_row['id'] .'";';
				$user_result = mysql_query($query);
				
				array_push($list_arr, array(
					"list_id" => $list_row['id'], 
					"name" => $list_row['title'],
					"info" => $list_row['info'], 
					"curators" => $curator_arr, 
					"image_url" => $list_row['image_url'], 
					"thumb_url" => $list_row['thumb_url'], 
					"influencers" => mysql_num_rows($influencer_result),
					"subscribers" => mysql_num_rows($user_result), 
					"likes" => $likes_tot
				));				
			}
            
			$this->sendResponse(200, json_encode($list_arr));
			return (true);
		}
		
		function getSubscribedLists($user_id) {
			$list_arr = array();
            
			$query = 'SELECT `tblLists`.`id`, `tblLists`.`title`, `tblLists`.`info`, `tblLists`.`image_url`, `tblLists`.`thumb_url` FROM `tblLists` INNER JOIN `tblUsersLists` ON `tblLists`.`id` = `tblUsersLists`.`list_id` WHERE `tblUsersLists`.`user_id` = "'. $user_id .'" AND `tblLists`.`active` = "Y" ORDER BY `tblLists`.`modified` DESC;';
			$list_result = mysql_query($query);
			
            while ($list_row = mysql_fetch_array($list_result, MYSQL_BOTH)) {
	            $query = 'SELECT * FROM `tblListsCurators` WHERE `list_id` = "'. $list_row['id'] .'";';
				$result = mysql_query($query);
				
				$curator_arr = array();
				while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
					$query = 'SELECT * FROM `tblCurators` WHERE `id` = "'. $row['curator_id'] .'";';
					$curator_row = mysql_fetch_row(mysql_query($query));
					
				    array_push($curator_arr, array(
						"curator_id" => $curator_row[0], 
						"handle" => $curator_row[1], 
						"name" => $curator_row[2], 
						"info" => $curator_row[3] 
					));
				}
	
				$query = 'SELECT * FROM `tblListsInfluencers` WHERE `list_id` = "'. $list_row['id'] .'";';
				$influencer_result = mysql_query($query);
				
				$likes_tot = 0;
				while ($influencer_row = mysql_fetch_array($influencer_result, MYSQL_BOTH)) {
					$query = 'SELECT `likes` FROM `tblArticles` WHERE `influencer_id` = "'. $influencer_row['influencer_id'] .'";';
					$article_result = mysql_query($query);
					
					while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH))
						$likes_tot += $article_row['likes'];
				}
				
				$query = 'SELECT * FROM `tblUsersLists` WHERE `list_id` = "'. $list_row['id'] .'";';
				$user_result = mysql_query($query);
				
				array_push($list_arr, array(
					"list_id" => $list_row['id'], 
					"name" => $list_row['title'],
					"info" => $list_row['info'], 
					"curators" => $curator_arr, 
					"image_url" => $list_row['image_url'], 
					"thumb_url" => $list_row['thumb_url'], 
					"influencers" => mysql_num_rows($influencer_result),
					"subscribers" => mysql_num_rows($user_result), 
					"likes" => $likes_tot
				));				
			}
            
			$this->sendResponse(200, json_encode($list_arr));
			return (true);
		}
		
		function getInfluencersInfoByList($list_id) {
			$influencers_arr = array();
            
			$query = 'SELECT * FROM `tblInfluencers` INNER JOIN `tblListsInfluencers` ON `tblInfluencers`.`id` = `tblListsInfluencers`.`influencer_id` WHERE `tblListsInfluencers`.`list_id` = "'. $list_id .'";';
			$influencer_result = mysql_query($query);
			
			while ($influencer_row = mysql_fetch_array($influencer_result, MYSQL_BOTH)) {
				array_push($influencers_arr, array(
					"influencer_id" => $influencer_row['id'], 
					"handle" => $influencer_row['handle'],
					"name" => $influencer_row['name'], 
					"avatar_url" => $influencer_row['avatar_url'], 
					"blurb" => $influencer_row['description'], 
					"article_total" => 0, 
					"source_types" => array()
				));
			}
			
			$this->sendResponse(200, json_encode($influencers_arr));
			return (true);
		}
		
		
		
	   
		function test() {
			$this->sendResponse(200, json_encode(array(
				"result" => true
			)));
			return (true);	
		}
	}
	
	$lists = new Lists;
	////$lists->test();
	
	
	if (isset($_POST['action'])) {
		switch ($_POST['action']) {
			
			case "0":
				$lists->getPublicLists();
				break;
				
			case "1":
				if ($_POST['userID'])
					$lists->getSubscribedLists($_POST['userID']);
				break;
				
			case "2":
				if ($_POST['listID'])
					$lists->getInfluencersInfoByList($_POST['listID']);
				break;
    	}
	}
?>