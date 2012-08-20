<?php

// make the connection
$db_conn = mysql_connect('localhost', 'db41232_sn_usr', 'dope911t') or die("Could not connect to database.");

// select the proper db
mysql_select_db('assembly-dev') or die("Could not select database.");

// get the current date / time from mysql
$ts_result = mysql_query("SELECT NOW();") or die("Couldn't get the date from MySQL");
$row = mysql_fetch_row($ts_result);
$sql_time = $row[0];




$topic_id = $argv[1];
$article_id = $argv[2];


$article_arr = array();
$query = 'SELECT * FROM `tblArticles` INNER JOIN `tblContributors` ON `tblArticles`.`contributor_id` = `tblContributors`.`id` WHERE `tblArticles`.`active` = "Y" AND `tblArticles`.`id` = '. $article_id .';';				
$article_row = mysql_fetch_row(mysql_query($query));

if (!$article_row)
	continue;

$query = 'SELECT `tblTopics`.`id`, `tblTopics`.`title` FROM `tblTopics` INNER JOIN `tblTopicsArticles` ON `tblTopics`.`id` = `tblTopicsArticles`.`topic_id` WHERE `tblTopicsArticles`.`article_id` = '. $article_id .';';
$topic_row = mysql_fetch_row(mysql_query($query));

$query = 'SELECT * FROM `tblArticleImages` WHERE `article_id` = '. $article_id .';';
$img_result = mysql_query($query);

$img_arr = array();
while ($img_row = mysql_fetch_array($img_result, MYSQL_BOTH)) {
	array_push($img_arr, array(
		"id" => $img_row['id'], 
		"type_id" => $img_row['type_id'], 
		"url" => $img_row['url'], 
		"ratio" => $img_row['ratio']
	));					
}

switch (mysql_num_rows($img_result)) {
	case 1:
		array_push($img_arr, $img_arr[0]);						
   		array_push($img_arr, $img_arr[0]);
		break;
		
	case 2:					
		array_push($img_arr, $img_arr[0]);
		break;
}

$query = 'SELECT * FROM `tblComments` INNER JOIN `tblUsers` ON `tblComments`.`user_id` = `tblUsers`.`id` WHERE `tblComments`.`article_id` = '. $article_id .' ORDER BY `tblComments`.`added` DESC;';
$comment_result = mysql_query($query);

$comment_arr = array();
while ($comment_row = mysql_fetch_array($comment_result, MYSQL_BOTH)) {
	$query = 'SELECT * FROM `tblUsersLikedArticles` WHERE `user_id` = '. $comment_row['user_id'] .' AND `article_id` = '. $article_id .';';
	$liked_result = mysql_query($query);
	
	array_push($comment_arr, array(
		"comment_id" => $comment_row[0], 
		"handle" => $comment_row['handle'], 
		"avatar" => "https://api.twitter.com/1/users/profile_image?screen_name=". $comment_row['handle'] ."&size=normal", 
		"content" => $comment_row['content'], 
		"liked" => (mysql_num_rows($liked_result) > 0), 
		"added" => $comment_row[5]
	));
}

$query = 'SELECT * FROM `tblUsers` INNER JOIN `tblUsersLikedArticles` ON `tblUsers`.`id` = `tblUsersLikedArticles`.`user_id` WHERE `tblUsersLikedArticles`.`article_id` = '. $article_id .';';
$user_result = mysql_query($query);

$user_arr = array();
while ($user_row = mysql_fetch_array($user_result, MYSQL_BOTH)) { 				
	array_push($user_arr, array(
		"id" => $user_row['id'], 
		"id_str" => $user_row['twitter_id'], 
		"screen_name" => $user_row['handle'], 
		"name" => $user_row['name'], 
		"profile_image_url" => "https://api.twitter.com/1/users/profile_image?screen_name=". $user_row['handle'] ."&size=normal"
	)); 
}
   
$article_arr = array(
	"article_id" => $article_row[0], 
	"list_id" => $topic_row[0], 
	"topic_name" => $topic_row[1], 
	"type_id" => $article_row[1], 
	"title" => $article_row[6], 
	"article_url" => $article_row[8], 
	"short_url" => $article_row[5], 
	"tweet_id" => $article_row[2], 
	"tweet_msg" => $article_row[4], 
	"twitter_name" => $article_row[19], 
	"twitter_handle" => $article_row[18],
	"content" => $article_row[7], 
	"avatar_url" => $article_row[20], 
	"video_url" => $article_row[12], 
	"likes" => $user_arr, 
	"added" => $article_row[15], 
	"comments" => $comment_arr, 
	"images" => $img_arr
);

print_r($article_arr);

?>
