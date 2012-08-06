<?php 

session_start();

require './_db_open.php'; 

$start_date = "0000-00-00 00:00:00";
if (isset($argv[1]))
	$start_date = $argv[1];
	
$query = 'SELECT * FROM `tblArticlesWorking` WHERE `type_id` > 0 AND `active` = "Y" AND `added` >= "'. $start_date .'";';
$result = mysql_query($query);                         

$cnt = 0;
while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
	$query = 'SELECT `topic_id` FROM `tblTopicsArticlesWorking` WHERE `article_id` = '. $row['id'] .';';
	$topic_result = mysql_query($query);
	$topic_row = mysql_fetch_row($topic_result);
	$topic_id = $topic_row[0];
	
	$query = 'SELECT `url`, `ratio` FROM `tblArticleImagesWorking` WHERE `article_id` = '. $row['id'] .';';
	$img_result = mysql_query($query);
	$img_row = mysql_fetch_row($img_result);
	
	$query = 'INSERT INTO `tblArticles` (';
	$query .= '`id`, `type_id`, `tweet_id`, `contributor_id`, `tweet_msg`, `short_url`, `title`, `content_txt`, `content_url`, `image_url`, `retweets`, `image_ratio`, `youtube_id`, `itunes_url`, `active`, `created`, `added`) ';
	$query .= 'VALUES (NULL, "'. $row['type_id'] .'", "'. $row['tweet_id'] .'", "'. $row['contributor_id'] .'", "'. $row['tweet_msg'] .'", "'. $row['short_url'] .'", "'. $row['title'] .'", "'. $row['content_txt'] .'", "'. $row['content_url'] .'", "'. $row['image_url'] .'", "'. $row['retweets'] .'", "'. $row['image_ratio'] .'", "'. $row['youtube_id'] .'", "'. $row['itunes_url'] .'", "'. $row['active'] .'", "'. $row['created'] .'", "'. $row['added'] .'");';	 
	$ins_result = mysql_query($query);
	$article_id = mysql_insert_id();
	
	$query = 'INSERT INTO `tblTopicsArticles` ('; 
	$query .= '`topic_id`, `article_id`) ';
	$query .= 'VALUES ("'. $topic_id .'", "'. $article_id .'");';
	$ins_result = mysql_query($query);
	
	$query = 'INSERT INTO `tblArticleImages` (';
	$query .= '`id`, `type_id`, `article_id`, `url`, `ratio`, `added`) ';
	$query .= 'VALUES (NULL, "1", "'. $article_id .'", "'. $img_row[0] .'", "'. $img_row[1] .'", NOW());';
	$ins_result = mysql_query($query);
	
	echo ("TRANSFER #". ($cnt + 1) ." --> [". $article_id ."] ->[". $row['tweet_id'] ."] (". $row['created'] .") FOR [". $topic_id ."]>>\n\"". $row['tweet_msg'] ."\"\n\n");
	$cnt++;
}  

require './_db_close.php';

?>