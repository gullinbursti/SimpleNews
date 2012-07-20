<?php 

session_start();

require './_db_open.php'; 
require_once('twitteroauth.php');
require_once('_oauth_cfg.php');
require_once('TwitterSearch.php');

$query = 'SELECT * FROM `tblArticles` INNER JOIN `tblTopicsArticles` ON `tblArticles`.`id` = `tblTopicsArticles`.`article_id` WHERE (`tblTopicsArticles`.`topic_id` = 3 OR `tblTopicsArticles`.`topic_id` = 4 OR `tblTopicsArticles`.`topic_id` = 10 OR `tblTopicsArticles`.`topic_id` = 11) AND (`tblArticles`.`title` != "");';
$result = mysql_query($query);                         

while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
	echo ("\nID:[". $row['id'] ."] <". $row['title'] .">\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n");
	$query = 'UPDATE `tblArticles` SET `title` = "" WHERE `id` = '. $row['id'] .';';
	$upd_result = mysql_query($query);
	echo ("CLEARED TITLE \n");
} 


$query = 'SELECT * FROM `tblArticles` WHERE `itunes_url` LIKE "http://itunes.apple.com/%";';
$result = mysql_query($query);

while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
	if (mysql_num_rows(mysql_query('SELECT * FROM `tblArticleImages` WHERE `article_id` = '. $row['id'] .';')) == 2)
		continue;	
	
	$url_arr = explode('/', $row['itunes_url']);
	$id_str = substr(array_pop($url_arr), 2);
	$itunes_id = substr($id_str, 0, strpos($id_str, '?'));
	
	echo ("\nID:[". $row['id'] ."]\n<". $row['itunes_url'] ."> (". $itunes_id .")\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n");
	
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, "http://itunes.apple.com/lookup?id=". $itunes_id);
	curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type:application/json'));
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	$response = curl_exec($ch);
    curl_close ($ch);
    
	$json_arr = json_decode($response, true);
	
	if (count($json_arr['results']) == 0) {
		$query = 'UPDATE `tblArticles` SET `active` = "N" WHERE `id` = '. $row['id'] .';';
		$upd_result = mysql_query($query);
		echo ("SKIPPING...\n");		
		continue;
	}
		
	$json_results = $json_arr['results'][0];	
	$json_title = $json_results['trackName'];
	$json_imgs = $json_results['screenshotUrls'];
	
	if (count($json_imgs) == 0) {
		$query = 'UPDATE `tblArticles` SET `active` = "N" WHERE `id` = '. $row['id'] .';';
		$upd_result = mysql_query($query);		
		echo ("SKIPPING...\n");
		continue;
	}
	
	$json_url = $json_results['trackViewUrl'];
	$json_descript = substr($json_results['description'], 0, 511) . "…";
	$img_size = getimagesize($json_imgs[0]);
	$img_ratio = $img_size[1] / $img_size[0];
	echo ($json_title ." <". $json_url ."> (". $img_ratio .")\n");
	echo ($json_imgs[0] ."\n". $json_imgs[1] ."\n");
	
	$query = 'UPDATE `tblArticles` SET `type_id` = 2, `title` = "'. $json_title .'", `content_txt` = "'. $json_descript .'", `content_url` = "'. $json_url .'", `active` = "Y" WHERE `id` = '. $row['id'] .';';
	$upd_result = mysql_query($query);
	
	
	$query = 'DELETE FROM `tblArticleImages` WHERE `article_id` = '. $row['id'] .';';
	$img_result = mysql_query($query);
		
	$query = 'INSERT INTO `tblArticleImages` (`id`, `type_id`, `article_id`, `url`, `ratio`, `added`) VALUES (NULL, 1, '. $row['id'] .', "'. $json_imgs[0] .'", '. $img_ratio .', "'. $row['added'] .'");';			
	$img_result = mysql_query($query);
	
	$query = 'INSERT INTO `tblArticleImages` (`id`, `type_id`, `article_id`, `url`, `ratio`, `added`) VALUES (NULL, 1, '. $row['id'] .', "'. $json_imgs[1] .'", '. $img_ratio .', "'. $row['added'] .'");';			
	$img_result = mysql_query($query);
}


$query = 'SELECT * FROM `tblArticles` WHERE `retweets` > 0 AND `active` = "Y";';
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
		
?>