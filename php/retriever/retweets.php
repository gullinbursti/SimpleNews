<?php 

session_start();

require './_db_open.php'; 
require_once('twitteroauth.php');
require_once('_oauth_cfg.php');
require_once('TwitterSearch.php');

$start_date = "0000-00-00 00:00:00";
if (isset($argv[1]))
	$start_date = $argv[1];
	
$query = 'SELECT * FROM `tblArticles` WHERE `retweets` > 0 AND `active` = "Y" AND `added` >= "'. $start_date .'";';
$result = mysql_query($query);                         

while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
	$query = 'SELECT `user_id` FROM `tblUsersLikedArticles` WHERE `article_id` = "'. $row['id'] .'";';
	$like_result = mysql_query($query);
	
	if (mysql_num_rows($like_result) == 0) {
		echo ("\nID:[". $row['id'] ."] <". $row['title'] .">\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n");
		$tot = min($row['retweets'], rand(10, 15));
		
		for ($i=0; $i<$tot; $i++) {
			$range_result = mysql_query(" SELECT MAX(`id`) AS max_id , MIN(`id`) AS min_id FROM `tblContributors`");
			$range_row = mysql_fetch_object($range_result); 
			$id_rnd = mt_rand($range_row->min_id , $range_row->max_id);
			$query = "SELECT * FROM `tblContributors` WHERE `id` >= $id_rnd LIMIT 0,1";
			$contrib_row = mysql_fetch_row(mysql_query($query));
			
			$query = 'SELECT `id` FROM `tblUsers` WHERE `handle` = "'. $contrib_row[1] .'";';
			$user_result = mysql_query($query);
						
			if (mysql_num_rows($user_result) == 0) {
				$query = 'INSERT INTO `tblUsers` (';
				$query .= '`id`, `type_id`, `twitter_id`, `handle`, `name`, `device_token`, `added`, `modified`) ';
				$query .= 'VALUES (NULL, "5", "0", "'. $contrib_row[1] .'", "", "", NOW(), CURRENT_TIMESTAMP);';
				$ins_result = mysql_query($query);
				$user_id = mysql_insert_id();
			
		   	} else {
				$user_row = mysql_fetch_row($user_result);
				$user_id = $user_row[0];
			}
		
			$query = 'INSERT INTO `tblUsersLikedArticles` (`user_id`, `article_id`, `added`) VALUES ('. $user_id .', '. $row['id'] .', NOW());';
		    $like_result = mysql_query($query);
		
			echo ("ADD LIKE FROM: @". $contrib_row[1] ."\n"); 
		}
	}
}  

require './_db_close.php';

?>