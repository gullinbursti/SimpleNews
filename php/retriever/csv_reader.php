<?php 

session_start();

require './_db_open.php'; 
require_once('twitteroauth.php');
require_once('_oauth_cfg.php');
require_once('TwitterSearch.php');

$start_date = "0000-00-00 00:00:00";
if (isset($argv[1]))
	$start_date = $argv[1];
	
// read contributors
$contribID_arr = array();
echo ("--> READING CONTRIBUTORS <--\n");
if (($handle = fopen("http://107.20.161.159/retriever/contributors.csv", 'r')) !== FALSE) {
	while (($row = fgetcsv($handle, 1000, ',')) !== FALSE) {
		$query = 'SELECT `id` FROM `tblContributors` WHERE `handle` = "'. $row[1] .'";';
		$result = mysql_query($query);
		
		if (mysql_num_rows($result) == 0) {
			$query = 'INSERT INTO `tblContributors` (`id`, `handle`, `name`, `avatar_url`, `type_id`, `active`, `added`) ';
			$query .= 'VALUES (NULL, "'. $row[1] .'", "'. $row[2] .'", "'. $row[3] .'", "'. $row[4] .'", "'. $row[5] .'", "'. $row[6] .'");';
			$ins_result = mysql_result($query);
			$contrib_id = mysql_insert_id();
		
		} else {
			$contrib_id = mysql_fetch_row($result);
		}
		
		$contribID_arr[$row[0]] = $contrib_id;
	}
}
fclose($handle);


// read articles
$articleID_arr = array();
echo ("--> READING ARTICLES <--\n");
if (($handle = fopen("http://107.20.161.159/retriever/articles.csv", 'r')) !== FALSE) {
	while (($row = fgetcsv($handle, 1000, ',')) !== FALSE) {
		$query = 'INSERT INTO `tblArticles` (`id`, `type_id`, `tweet_id`, `contributor_id`, `tweet_msg`, `short_url`, `title`, `content_txt`, `content_url`, `image_url`, `retweets`, `image_ratio`, `youtube_id`, `itunes_url`, `active`, `created`, `added`) ';
		$query .= 'VALUES (NULL, "'. $row[1] .'", "'. $row[2] .'", "'. $contribID_arr[$row[3]] .'", "'. $row[4] .'", "'. $row[5] .'", "'. $row[6] .'", "'. $row[7] .'", "'. $row[8] .'", "'. $row[9] .'", "'. $row[10] .'", "'. $row[11] .'", "'. $row[12] .'", "'. $row[13] .'", "'. $row[14] .'", "'. $row[15] .'", "'. $row[16] .'");';
		$ins_result = mysql_result($query);
		$article_id = mysql_insert_id();
		$articleID_arr[$row[0]] = $article_id;
	}
}
fclose($handle);

// read images
echo ("--> READING IMAGES <--\n");
if (($handle = fopen("http://107.20.161.159/retriever/article_images.csv", 'r')) !== FALSE) {
	while (($row = fgetcsv($handle, 1000, ',')) !== FALSE) {
		$query = 'INSERT INTO `tblArticleImages` (`id`, `type_id`, `article_id`, `url`, `ratio`, `added`) ';
		$query .= 'VALUES (NULL, "'. $row[1] .'", "'. $articleID_arr[$row[2]] .'", "'. $row[3] .'", "'. $row[4] .'", "'. $row[5] .'");';
		$ins_result = mysql_result($query);
		$img_id = mysql_insert_id();
	}
}
fclose($handle);


// read articles / topics
echo ("--> READING TOPICS / ARTICLES <--\n");
if (($handle = fopen("http://107.20.161.159/retriever/topic_articles.csv", 'r')) !== FALSE) {
	while (($row = fgetcsv($handle, 1000, ',')) !== FALSE) {
		$query = 'INSERT INTO `tblTopicsArticles` (`topic_id`, `article_id`) ';
		$query .= 'VALUES ("'. $row[0] .'", "'. $articleID_arr[$row[1]] .'");';
		$ins_result = mysql_result($query);
	}
}
fclose($handle);


// read user likes
echo ("--> READING USER LIKES <--\n");
if (($handle = fopen("http://107.20.161.159/retriever/user_likes.csv", 'r')) !== FALSE) {
	while (($row = fgetcsv($handle, 1000, ',')) !== FALSE) {
		$query = 'INSERT INTO `tblTopicsArticles` (`topic_id`, `article_id`) ';
		$query .= 'VALUES ("'. $row[0] .'", "'. $articleID_arr[$row[1]] .'");';
		$ins_result = mysql_result($query);
	}
}
fclose($handle);
	
                         

 

require './_db_close.php';

?>