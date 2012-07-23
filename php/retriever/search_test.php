<?php 

session_start();

require './_db_open.php'; 


$keyVal_arr = array();
			
$query = 'SELECT * FROM `tblArticles` WHERE `active` = "Y" AND `type_id` >= 2 AND `retweets` > 0;';
$article_result = mysql_query($query);

while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) {
	$query = 'SELECT * FROM `tblArticleImages` WHERE `article_id` = '. $article_row[0] .';';
	$img_result = mysql_query($query);
	$img_row = mysql_fetch_array($img_result, MYSQL_BOTH);
	
	if ($img_row['ratio'] < 1.0)
		continue;
	
	$query = 'SELECT * FROM `tblUsersLikedArticles` WHERE `article_id` = '. $article_row[0] .';';
	$likes_result = mysql_query($query);
	$likes_tot = mysql_num_rows($likes_result);
	
	$keyVal_arr[$article_row['id']] = $likes_tot;
}

arsort($keyVal_arr);
$article_arr = array();
$tot = 0;

$query = 'DELETE FROM `tblTopArticles` WHERE `type_id` = 1;';
$result = mysql_query($query);

foreach ($keyVal_arr as $key => $val) {
	$query = 'INSERT INTO `tblTopArticles` (`article_id`, `type_id`, `total`) VALUES ('. $key .', 1, '. $val .');';
	$ins_result = mysql_query($query);
	
	$tot++;
	if ($tot >= 10)
		break;
}

/*
$query = 'SELECT * FROM `tblContributors` WHERE `avatar_url` LIKE "%size=reasonably_small";';
$result = mysql_query($query);

while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
	$url = str_replace("size=reasonably_small", "size=normal", $row['avatar_url']);
	$query = 'UPDATE `tblContributors` SET `avatar_url` = "'. $url .'" WHERE `id` = '. $row['id'] .';';
	$upd_result = mysql_query($query);
	
	echo ("UPDATING -> [". $row['id'] ."] @". $row['handle'] ." <". $url .">\n");				
}
*/

/*
$start_date = "2012-07-21 00:00:00";

$query = 'SELECT * FROM `tblArticles` WHERE `added` >= "'. $start_date .'";';
$article_result = mysql_query($query);
while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) {
	$query = 'SELECT * FROM `tblTopicsArticles` WHERE `article_id` = '. $article_row['id'] .' ORDER BY `topic_id`;';
	$topic_result = mysql_query($query);
	
	echo ("CHECKING -> [". $article_row['id'] ."] (". mysql_num_rows($topic_result) .")\n");	
	if (mysql_num_rows($topic_result) > 1) {
		
		$cnt = 0;
		while ($topic_row = mysql_fetch_array($topic_result, MYSQL_BOTH)) {
			$cnt++;			
			if ($cnt == 1)
				continue;
			
			echo ("REMOVING -> [". $article_row['id'] ."][". $article_row['tweet_id'] ."] (". $topic_row['topic_id'] .")\n\"". $article_row['tweet_msg'] ."\"\n\n");				
			$query = 'DELETE FROM `tblTopicsArticles` WHERE `topic_id` = '. $topic_row['topic_id'] .' AND `article_id` = '. $topic_row['article_id'] .';';
			$del_result = mysql_query($query);							
		}
	}
}
*/

require './_db_close.php'; 

?>