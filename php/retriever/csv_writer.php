<?php 

session_start();

require './_db_open.php'; 
require_once('twitteroauth.php');
require_once('_oauth_cfg.php');
require_once('TwitterSearch.php');

$start_date = "0000-00-00 00:00:00";
if (isset($argv[1]))
	$start_date = $argv[1];
	

// write articles	
echo ("--> WRITING NEW ARTICLES <--\n");
$query = 'SELECT * FROM `tblArticles` WHERE `type_id` > 0 AND `active` = "Y" AND `added` >= "'. $start_date .'";';
$result = mysql_query($query);

$articleID_arr = array();
$contribID_arr = array();
$file = fopen("articles.csv", 'w');
while ($row = mysql_fetch_assoc($result)) {
	array_push($articleID_arr, $row['id']);
	array_push($contribID_arr, $row['contributor_id']);
	
	fputcsv($file, $row);
}
fclose($file);


// write contributors
echo ("--> WRITING NEW CONTRIBUTORS <--\n");
$file = fopen("contributors.csv", 'w');
foreach ($contribID_arr as $key) {
	$query = 'SELECT * FROM `tblContributors` WHERE `id` = "'. $key .'";';
	$result = mysql_query($query);
	$row = mysql_fetch_assoc($result);
	
	if ($row) {	
		fputcsv($file, $row);
	}
}
fclose($file);


// write article images
echo ("--> WRITING ARTICLE IMAGES <--\n");
$file = fopen("article_images.csv", 'w');
foreach ($articleID_arr as $key) {
	$query = 'SELECT * FROM `tblArticleImages` WHERE `article_id` = '. $key .';';
	$result = mysql_query($query);
	$row = mysql_fetch_assoc($result);
	
	if ($row) {		
		fputcsv($file, $row);
	}
}
fclose($file);


// write topics / articles
echo ("--> WRITING ARTICLES TO TOPICS <--\n");
$file = fopen("topics_articles.csv", 'w');
foreach ($articleID_arr as $key) {
	$query = 'SELECT * FROM `tblTopicsArticles` WHERE `article_id` = '. $key .';';
	$result = mysql_query($query);
	$row = mysql_fetch_assoc($result);
	
	if ($row) {	
		fputcsv($file, $row);
	}
}
fclose($file);

	
// write user likes
echo ("--> WRITING USER LIKES <--\n");
$file = fopen("user_likes.csv", 'w');
foreach ($articleID_arr as $key) {
	$query = 'SELECT * FROM `tblUsersLikedArticles` WHERE `article_id` = '. $key .';';
	$result = mysql_query($query);
	$row = mysql_fetch_assoc($result);
	
	if ($row) {	
		fputcsv($file, $row);
	}
}
fclose($file);

	
	                         

 

require './_db_close.php';

?>