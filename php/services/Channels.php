<?php

	class Channels {
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
	
		
		function getSubscriptions() {
            $channel_arr = array();
			$subscriptions_xml = new SimpleXMLElement('http://gdata.youtube.com/feeds/api/users/getassemblytv/subscriptions', NULL, true);
            
			$tot = 0;
			foreach ($subscriptions_xml -> entry as $subscription_entry) {
				$attr_arr = $subscription_entry->link[1]->attributes();
				$href_arr = explode('/', $attr_arr['href']);
				$youtube_id = $href_arr[4];
	
				$title_arr = explode(': ', $subscription_entry->title);
				$youtube_name = $title_arr[1];
				$image_url = "http://i4.ytimg.com/i/". $youtube_id ."/1.jpg";
				
				//$user_xml = new SimpleXMLElement('http://gdata.youtube.com/feeds/api/users/'. strtolower($youtube_name), NULL, true);
				$created_date = "2005-10-02T16:06:36.000Z"; //$user_xml->published;
				$updated_date = "2005-10-02T16:06:36.000Z"; //$user_xml->updated;
				
				array_push($channel_arr, array(
					"channel_id" => $tot + 1, 
					"youtube_id" => $youtube_id, 
					"title" => $youtube_name, 
					"thumb" => $image_url, 
					"image" => $image_url, 
					"added" => $created_date, 
					"updated" => $updated_date
				));
				
				$tot++;
	    	}

			$this->sendResponse(200, json_encode($channel_arr));
			return (true);
		}
		
		
		function getVideosByChannel($channel_id, $channel_name) {
			$video_arr = array();
			$videos_xml = new SimpleXMLElement('http://gdata.youtube.com/feeds/api/users/'. strtolower($channel_name) .'/uploads', NULL, true);
			
			// width=\"480\" height=\"360\"
			
			$tot = 0;
			foreach ($videos_xml -> entry as $video_entry) {
				$id_arr = explode('/', $video_entry->id);
				
				$video_id = $id_arr[count($id_arr) - 1];
				$image_url = "http://i.ytimg.com/vi/". $video_id ."/0.jpg";
				$title = (string)$video_entry->title;
				$info = (string)$video_entry->content;
				$added = (string)$video_entry->published;
				
				$added = substr($added, 0, strlen($added) - 5);
				$added = str_replace("T", " ", $added);
				$added = "2012-03-06 01:19:26";
				
				array_push($video_arr, array(
					"video_id" => $tot + 1, 
					"youtube_id" => $video_id, 
					"title" => $title, 
					"info" => $info, 
					"channel" => "http://i4.ytimg.com/i/". $channel_id ."/1.jpg", 
					"image" => $image_url, 
					"thumb" => $image_url, 
					"video" => "", 
					"date" => $added//"2012-03-08 12:21:00"//$added
				));
				
				$tot++;
			}
			
			$this->sendResponse(200, json_encode($video_arr));			
			return (true);
		}
		
		
		function test() {
			$this->sendResponse(200, json_encode(array(
				"result" => true
			)));
			return (true);	
		}
	}
	
	$channels = new Channels;
	////$channels->test();
	
	
	if (isset($_POST['action'])) {
		switch ($_POST['action']) {
			
			case "0":
				$channels->getSubscriptions();
				break;
				
			case "1":
				if (isset($_POST['id']) && isset($_POST['name']))
					$channels->getVideosByChannel($_POST['id'], $_POST['name']);
				break;
    	}
	}
?>