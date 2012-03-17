<?php

	class Followers {
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
	
		
		function getActiveFollowers() {
            $follower_arr = array();

			$query = 'SELECT * FROM `tblTwitterFollowers` WHERE `active` = "Y";';
			$follower_result = mysql_query($query); 
            
			$tot = 0;
			while ($follower_row = mysql_fetch_array($follower_result, MYSQL_BOTH)) {
				$query = 'SELECT `id` FROM `tblArticles` WHERE `follower_id` = "'. $follower_row['id'] .'"';
				$article_arr = mysql_query($query);
				
				
				array_push($follower_arr, array(
					"follower_id" => $follower_row['id'], 
					"handle" => $follower_row['handle'],
					"name" => $follower_row['name'], 
					"avatar_url" => $follower_row['avatar_url'], 
					"blurb" => $follower_row['description'], 
					"article_total" => mysql_num_rows($article_arr)
				));
				
				$tot++;
	    	}
			
			$this->sendResponse(200, json_encode($follower_arr));
			return (true);
		}
		
		function getFollowersByChannel($chan_id) {
			$follower_arr = array();
			
			$query = 'SELECT * FROM `tblTwitterFollowers` INNER JOIN `tblFollowersChannels` ON `tblTwitterFollowers`.`id` = `tblFollowersChannels`.`follower_id` WHERE `tblFollowersChannels`.`channel_id` = "'. $chan_id .'";';
			$follower_result = mysql_query($query);
		    
			$tot = 0;
			while ($follower_row = mysql_fetch_array($follower_result, MYSQL_BOTH)) {
				$query = 'SELECT `id` FROM `tblArticles` WHERE `follower_id` = "'. $follower_row['id'] .'"';
				$article_arr = mysql_fetch_array(mysql_query($query));
				
				array_push($follower_arr, array(
					"follower_id" => $follower_row['id'], 
					"handle" => $follower_row['handle'],
					"name" => $follower_row['name'], 
					"avatar_url" => $follower_row['avatar_url'], 
					"article_total" => count($article_arr) - 1
				));
				
				$tot++;
	    	}

			$this->sendResponse(200, json_encode($channel_arr));
			return (true);
		}
		
	   
		function test() {
			$this->sendResponse(200, json_encode(array(
				"result" => true
			)));
			return (true);	
		}
	}
	
	$followers = new Followers;
	////$channels->test();
	
	
	if (isset($_POST['action'])) {
		switch ($_POST['action']) {
			
			case "0":
				$followers->getActiveFollowers();
				break;
				
			case "1":
				if (isset($_POST['channelID']))
					$followers->getFollowersByChannel($_POST['channelID']);
				break;
			
    	}
	}
?>