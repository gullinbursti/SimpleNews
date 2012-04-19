<?php

	class Users {
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
	    
		
		function submitUser($device_token, $twitter_handle) {
			$user_arr = array();
			
			$query = 'SELECT * FROM `tblUsers` WHERE `handle` = "'. $twitter_handle .'";';
			$result = mysql_query($query);
			
			if (mysql_num_rows($result) > 0) {
				$row = mysql_fetch_row($result);
				
				$user_arr = array(
					"id" => $row[0], 
					"handle" => $row[1], 
					"name" => $row[2], 
					"token" => $row[3]					
				);
				
				$query = 'UPDATE `tblUsers` SET `modified` = CURRENT_TIMESTAMP WHERE `id` ='. $row[0] .';';
				$result = mysql_query($query);
				
			} else {
				$query = 'INSERT INTO `tblUsers` (';
				$query .= '`id`, `handle`, `name`, `device_token`, `added`, `modified`) ';
				$query .= 'VALUES (NULL, "'. $twitter_handle .'", "", "'. $device_token .'", NOW(), CURRENT_TIMESTAMP);';
				$result = mysql_query($query);
				$user_id = mysql_insert_id();
				
				$query = 'SELECT * FROM `tblUsers` WHERE `id` ='. $user_id .';';
				$row = mysql_fetch_row(mysql_query($query));
				
				$user_arr = array(
					"id" => $row[0], 
					"handle" => $row[1], 
					"name" => $row[2], 
					"token" => $row[3]					
				);
			}
			
			$this->sendResponse(200, json_encode($user_arr));
			return (true);	
		}
		
		
		function updateName($user_id, $user_name) {
			$query = 'UPDATE `tblUsers` SET `name` = "'. $user_name .'" WHERE `id` ='. $user_id .';';
			$result = mysql_query($query);
			
			$query = 'SELECT * FROM `tblUsers` WHERE `id` = "'. $user_id .'";';
			$row = mysql_fetch_row(mysql_query($query));
			$user_arr = array(
				"id" => $row[0], 
				"handle" => $row[1], 
				"name" => $row[2], 
				"token" => $row[3]					
			);
			
			$this->sendResponse(200, json_encode($user_arr));
			return (true);
		}
	
	
		function test() {
			$this->sendResponse(200, json_encode(array(
				"result" => true
			)));
			return (true);	
		}
	}
	
	$users = new Users;
	////$users->test();
	
	
	if (isset($_POST['action'])) {
		switch ($_POST['action']) {
			
			case "0":
				break;
				
			case "1":
				if (isset($_POST['token']) && isset($_POST['handle']))
					$users->submitUser($_POST['token'], $_POST['handle']);
				break;
				
			case "2":
				if (isset($_POST['userID']) && isset($_POST['userName']))
					$users->updateName($_POST['userID'], $_POST['userName']);
				break;
			
    	}
	}
?>