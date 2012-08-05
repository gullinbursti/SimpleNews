<?php 

session_start();

require './_db_open.php'; 
require_once('twitteroauth.php');
require_once('_oauth_cfg.php');
require_once('TwitterSearch.php');


$start_date = "0000-00-00 00:00:00";
if (isset($argv[1]))
	$start_date = $argv[1];
	

$query = 'SELECT * FROM `tblArticles` WHERE `itunes_url` LIKE "http://itunes.apple.com/%" AND `added` >= "'. $start_date .'";';
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
	
	$query = 'UPDATE `tblArticles` SET `type_id` = 2, `title` = "'. $json_title .'", `content_txt` = "'. $json_descript .'", `content_url` = "'. $json_url .'", `itunes_url` = "'. $json_url .'", `active` = "Y" WHERE `id` = '. $row['id'] .';';
	$upd_result = mysql_query($query);
	
	
	$query = 'DELETE FROM `tblArticleImages` WHERE `article_id` = '. $row['id'] .';';
	$img_result = mysql_query($query);
		
	$query = 'INSERT INTO `tblArticleImages` (`id`, `type_id`, `article_id`, `url`, `ratio`, `added`) VALUES (NULL, 1, '. $row['id'] .', "'. $json_imgs[0] .'", '. $img_ratio .', "'. $row['added'] .'");';			
	$img_result = mysql_query($query);
	
	$query = 'INSERT INTO `tblArticleImages` (`id`, `type_id`, `article_id`, `url`, `ratio`, `added`) VALUES (NULL, 1, '. $row['id'] .', "'. $json_imgs[1] .'", '. $img_ratio .', "'. $row['added'] .'");';			
	$img_result = mysql_query($query);
}

require './_db_close.php';
		
?>