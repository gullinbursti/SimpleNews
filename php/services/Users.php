<?php

	class Users {
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
	    
		
		function submitUser($device_token, $twitter_handle, $twitter_id) {
			$user_arr = array();
			
			$query = 'SELECT * FROM `tblUsers` WHERE `twitter_id` = "'. $twitter_id .'";';
			$result = mysql_query($query);
			
			if (mysql_num_rows($result) > 0) {
				$row = mysql_fetch_row($result);
				
				$user_arr = array(
					"id" => $row[0], 
					"twitter_id" => $row[2], 
					"handle" => $row[3], 
					"name" => $row[4], 
					"token" => $row[5]					
				);
				
				$query = 'UPDATE `tblUsers` SET `modified` = CURRENT_TIMESTAMP WHERE `id` ='. $row[0] .';';
				$result = mysql_query($query);
				
			} else {
				$query = 'INSERT INTO `tblUsers` (';
				$query .= '`id`, `type_id`, `twitter_id`, `handle`, `name`, `device_token`, `added`, `modified`) ';
				$query .= 'VALUES (NULL, "4", "'. $twitter_id .'", "'. $twitter_handle .'", "", "'. $device_token .'", NOW(), CURRENT_TIMESTAMP);';
				$result = mysql_query($query);
				$user_id = mysql_insert_id();
				
				//for ($i=4; $i<=7; $i++) {
				//	$query = 'INSERT INTO `tblUsersLists` (`user_id`, `list_id`) VALUES ('. $user_id .', '. $i .');';
				//	$result = mysql_query($query);
				//}
				
				$query = 'SELECT * FROM `tblUsers` WHERE `id` ='. $user_id .';';
				$row = mysql_fetch_row(mysql_query($query));
				
				$user_arr = array(
					"id" => $row[0], 
					"twitter_id" => $row[1], 
					"handle" => $row[2], 
					"name" => $row[3], 
					"token" => $row[4]					
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
				"twitter_id" => $row[1], 
				"handle" => $row[2], 
				"name" => $row[3], 
				"token" => $row[4]					
			);
			
			$this->sendResponse(200, json_encode($user_arr));
			return (true);
		}
	    
		function findFriends($user_id, $twitter_id) {
			$isFound = "false";
			
			$query = 'SELECT `id` FROM `tblUsers` WHERE `twitter_id` = "'. $twitter_id .'";';
			$result = mysql_query($query);
			if (mysql_num_rows($result) > 0) {
				$isFound = "true";
				
				$row = mysql_fetch_row($result);				
				$query = 'INSERT INTO `tblUserFriends` (`user_id`, `friend_id`, `isComment`, `isLike`, `isShare`, `added`) VALUES ('. $user_id .', '. $row[0] .', "Y", "Y", "Y", NOW());';
				$result = mysql_query($query);				
			}
			
			$this->sendResponse(200, json_encode(array(
				"result" => $isFound
			)));			
			return (true);
		}
		
		function getFriends($user_id) {
			$friend_arr = array();
			
			$query = 'SELECT * FROM `tblUsers` INNER JOIN `tblUserFriends` ON `tblUsers`.`id` = `tblUserFriends`.`friend_id` WHERE `tblUserFriends`.`user_id` = '. $user_id .';';
			$result = mysql_query($query);
			
			while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
				array_push($friend_arr, array(
					"id" => $row['id'], 
					"id_str" => $row['twitter_id'], 
					"screen_name" => $row['handle'], 
					"name" => $row['name'], 
					"profile_image_url" => "https://api.twitter.com/1/users/profile_image?screen_name=". $row['handle'] ."&size=reasonably_small"
				));
			}
			
			$this->sendResponse(200, json_encode($friend_arr));
			
			return (true);
		}
		
		function getProfileStats($user_id) {
			$query = 'SELECT * FROM `tblUsersLikedArticles` WHERE `user_id` = '. $user_id .';';
			$liked_tot = mysql_num_rows(mysql_query($query));
			
			$query = 'SELECT * FROM `tblComments` WHERE `user_id` = '. $user_id .';';
			$comment_tot = mysql_num_rows(mysql_query($query));
			
			$query = 'SELECT * FROM `tblUsersSharedArticles` WHERE `user_id` = '. $user_id .';';
			$share_tot = mysql_num_rows(mysql_query($query));
			
			
			$this->sendResponse(200, json_encode(array(
				"likes" => $liked_tot, 
				"comments" => $comment_tot, 
				"shares" => $share_tot
			)));			
			
			return (true);	
		}
		
		function getFriendNotifications($user_id, $friend_id) {
			$query = 'SELECT `isComment`, `isLike`, `isShare` FROM `tblUserFriends` WHERE `user_id` = '. $user_id .' AND `friend_id` = '. $friend_id .';';
			$row = mysql_fetch_row(mysql_query($query));
			
			$this->sendResponse(200, json_encode(array(
				"comment" => $row[0] == "Y", 
				"like" => $row[1] == "Y", 
				"share" => $row[2] == "Y"
			)));			
			
			return (true);	
		}
		
		function setFriendNotifications($user_id, $friend_id, $isComment, $isLike, $isShare) {
			
			if ($isComment == "1")
				$isComment = "Y";
			else
				$isComment = "N";
				
			if ($isLike == "1")
				$isLike = "Y";			
			else
				$isLike = "N";
				
			if ($isShare == "1")
				$isShare = "Y";
			else
				$isShare = "N";
			
			
			$query = 'UPDATE `tblUserFriends` SET `isComment` = "'. $isComment .'", `isLike` = "'. $isLike .'", `isShare` = "'. $isShare .'" WHERE `user_id` = '. $user_id .' AND `friend_id` = '. $friend_id .';';
			$result = mysql_query($query);
			
			$query = 'SELECT `isComment`, `isLike`, `isShare` FROM `tblUserFriends` WHERE `user_id` = '. $user_id .' AND `friend_id` = '. $friend_id .';';
			$row = mysql_fetch_row(mysql_query($query));
			
			$this->sendResponse(200, json_encode(array(
				"comment" => $row[0] == "Y", 
				"like" => $row[1] == "Y", 
				"share" => $row[2] == "Y"
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
	
	$users = new Users;
	////$users->test();
	
	
	if (isset($_POST['action'])) {
		switch ($_POST['action']) {
			
			case "0":
				break;
				
			case "1":
				if (isset($_POST['token']) && isset($_POST['handle']) && isset($_POST['twitterID']))
					$users->submitUser($_POST['token'], $_POST['handle'], $_POST['twitterID']);
				break;
				
			case "2":
				if (isset($_POST['userID']) && isset($_POST['userName']))
					$users->updateName($_POST['userID'], $_POST['userName']);
				break;
				
			case "3":
				if (isset($_POST['userID']) && isset($_POST['twitterID']))
					$users->findFriends($_POST['userID'], $_POST['twitterID']);
				break;
				
			 case "4":
				if (isset($_POST['userID']))
					$users->getFriends($_POST['userID']);
				break;
				
			 case "5":
				if (isset($_POST['userID']))
					$users->getProfileStats($_POST['userID']);
				break;
			 
			 case "6":
				if (isset($_POST['userID']) && isset($_POST['friendID']))
					$users->getFriendNotifications($_POST['userID'], $_POST['friendID']);
				break;
			
			 case "7":
				if (isset($_POST['userID']) && isset($_POST['friendID']) && isset($_POST['isComment']) && isset($_POST['isLike']) && isset($_POST['isShare']))
					$users->setFriendNotifications($_POST['userID'], $_POST['friendID'], $_POST['isComment'], $_POST['isLike'], $_POST['isShare']);
				break;
    	}
	}
?>