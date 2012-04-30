<?php

	class Categories {
		private $db_conn;
	
	  	function __construct() {
		
			$this->db_conn = mysql_connect('localhost', 'db41232_sn_usr', 'dope911t') or die("Could not connect to database.");
			mysql_select_db('assembly') or die("Could not select database.");
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
	
		
		function getActiveCategories() {
			$category_arr = array();
            
			$query = 'SELECT * FROM `tblCategories`;';
			$category_result = mysql_query($query);
			
            while ($category_row = mysql_fetch_array($category_result, MYSQL_BOTH)) {
				$query = 'SELECT * FROM `tblFollowers` INNER JOIN `tblFollowersCategories` ON `tblFollowers`.`id` = `tblFollowersCategories`.`follower_id` WHERE `tblFollowersCategories`.`category_id` = "'. $category_row[`id`] .'" AND `tblFollowers`.`active` = "Y";';
				$tot = mysql_num_rows(mysql_query($query));
				
				array_push($category_arr, array(
					"category_id" => $category_row['id'], 
					"title" => $category_row['title'], 
					"total" => $tot
				));
			}
            
			$this->sendResponse(200, json_encode($category_arr));
			return (true);
		}
		
	   
		function test() {
			$this->sendResponse(200, json_encode(array(
				"result" => true
			)));
			return (true);	
		}
	}
	
	$categories = new Categories;
	////$categories->test();
	
	
	if (isset($_POST['action'])) {
		switch ($_POST['action']) {
			
			case "0":
				$categories->getActiveCategories();
				break;				
    	}
	}
?>