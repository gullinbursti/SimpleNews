<?php 

session_start();

require './_db_open.php'; 


if (($handle = fopen("images.csv", "r")) !== FALSE) {
	while (($data = fgetcsv($handle, 1000, ",")) !== FALSE) {
		
		//for ($i=0; $i<count($data); $i++) {
		//	echo ($data[$i] .", ");
		//}
		
		$query = 'SELECT * FROM `tblArticleImages` WHERE `id` = '. $data[0] .';';
		$result = mysql_query($query);
		
		if (mysql_num_rows($result) == 0) {		
			$query = 'INSERT INTO `tblArticleImages` (';
			$query .= '`id`, `type_id`, `article_id`, `url`, `ratio`, `added`) ';
			$query .= 'VALUES (NULL, "1", "'. $data[2] .'", "'. $data[3] .'", "'. $data[4] .'", "'. $data[5] .'");';
			$img_result = mysql_query($query);
			$img_id = mysql_insert_id();		
		}
	}
}


/*
$article_arr = array();
$query = 'SELECT `tblArticles`.`id`, `tblArticles`.`type_id`, `tblArticles`.`tweet_id`, `tblArticles`.`contributor_id`, `tblArticles`.`tweet_msg`, `tblArticles`.`short_url`, `tblArticles`.`title`, `tblArticles`.`content_txt`, `tblArticles`.`content_url`, `tblArticles`.`image_url`, `tblArticles`.`retweets`, `tblArticles`.`image_ratio`, `tblArticles`.`youtube_id`, `tblArticles`.`itunes_url`, `tblArticles`.`active`, `tblArticles`.`created`, `tblArticles`.`added` FROM `tblArticles` INNER JOIN `tblTopicsArticles` ON `tblArticles`.`id` = `tblTopicsArticles`.`article_id` WHERE `tblTopicsArticles`.`topic_id` = 2 AND `tblArticles`.`id` < 25944 AND `tblArticles`.`active` =  "Y" AND `tblArticles`.`type_id` >= 2 AND `tblArticles`.`itunes_url` LIKE "http://itunes.apple.com/%";';
$article_result = mysql_query($query);

while ($article_row = mysql_fetch_array($article_result, MYSQL_ASSOC)) {
	echo ("[". $article_row['id'] ."]\n");
	
	/*
	$line = "\n";
	foreach($article_row as $key => $val) {
		echo ("===[". $key ."]===");
		if ($key == 'title' || $key == 'content_url' || $key == 'tweet_msg' || $key == 'short_url' || $key == 'itunes_url' || $key == 'image_url')
			$line = $line . "\"". $val ."\",";
		
		else
			$line = $line . $val .",";
	}
	
	$line = substr_replace($line, "", -1);	
	echo ($line);
	*/
	
	/*
	$query = 'SELECT * FROM `tblArticleImages` WHERE `article_id` = '. $article_row['id'] .';';
	$img_result = mysql_query($query);
	
	$img_arr = array();
	while ($img_row = mysql_fetch_array($img_result, MYSQL_ASSOC)) {
		$line = "image_row";
		foreach($img_row as $key => $val) {
			$line = $line . "[". $key ."] = ". $val ." ";
		}	
		echo ($line ."\n");
	}
	
	echo ("===================================================================\n\n\n");
	*/
//}



/* MAKE TOP10 TABLE
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
*/


/* CHANGE AVATAR SIZES
$query = 'SELECT * FROM `tblContributors` WHERE `avatar_url` LIKE "%size=reasonably_small";';
$result = mysql_query($query);

while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
	$url = str_replace("size=reasonably_small", "size=normal", $row['avatar_url']);
	$query = 'UPDATE `tblContributors` SET `avatar_url` = "'. $url .'" WHERE `id` = '. $row['id'] .';';
	$upd_result = mysql_query($query);
	
	echo ("UPDATING -> [". $row['id'] ."] @". $row['handle'] ." <". $url .">\n");				
}
*/

/* REMOVE DUPLICATES ACROSS TOPICS
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