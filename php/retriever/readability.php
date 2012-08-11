<?php 

require './_db_open.php';

function parseYoutubeIDFromURL($src) {
	$pattern = '#^(?:https?://)?(?:www\.)?(?:youtu\.be/|youtube\.com(?:/embed/|/v/|/watch\?v=|/watch\?.+&v=))([\w-]{11})(?:.+)?$#x';
	preg_match($pattern, $src, $matches);
	
    return ((isset($matches[1])) ? $matches[1] : false);
}

function parseYoutubeIDFromContent($src) {
	$pattern = '/\<iframe.*?src\=\"http\:\/\/www\.youtube\.com\/embed\/(.*?)\?.*?\<\/iframe\>/';
	preg_match($pattern, $src, $matches);
	
    return ((isset($matches[1])) ? $matches[1] : false);
}

function parseITunesSuffix($src) {
	$pattern = '/http:\/\/itunes\.apple\.com\/(.+)[&"]/';
	preg_match($pattern, $src, $matches);
	
    return ((isset($matches[1])) ? $matches[1] : false);
}

function disableArticle($id) {
	$query = 'UPDATE `tblArticlesWorking` SET `type_id` = -1, `active` = "N" WHERE `id` = '. $id .';';
	$result = mysql_query($query);			
}

$query = 'SELECT `id`, `short_url`, `added` FROM `tblArticlesWorking` WHERE `active` = "N" AND `type_id` != -1;';
$article_result = mysql_query($query);

while ($row = mysql_fetch_array($article_result, MYSQL_BOTH)) {
	echo ("\nProcessing: [". $row['id'] ."] <". $row['short_url'] .">... ");	
	
	$query = 'SELECT `id` FROM `tblArticles` WHERE `short_url` = "'. $row['short_url'] .'";';
	$result = mysql_query($query);
	if (mysql_num_rows(mysql_query($query)) > 0) {
		echo ("Article already exists for <". $row['short_url'] .">\n");
		
		disableArticle($row['id']);		
		continue;
	}
	
	$type_id = 0;
	
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, "https://www.readability.com/api/content/v1/parser?token=787f09449bb2fe8b4e675289f619113f9f96bc2d&url=". $row['short_url']);
	curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type:application/json'));
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	$response = curl_exec($ch);
    curl_close ($ch);
    
	$json_arr = json_decode($response, true);
	
	if (count($json_arr) == 2) {
		echo ("Article couldn't be processed for <". $row['short_url'] .">\n");
		
		disableArticle($row['id']);
		continue;
	}
	
	$query = 'SELECT `id` FROM `tblArticles` WHERE `content_url` = "'. $json_arr['url'] .'";';
	$result = mysql_query($query);
	if (mysql_num_rows(mysql_query($query)) > 0) {
		echo ("Article already exists for <". $row['short_url'] .">\n");
		
		disableArticle($row['id']);
		continue;
	}
	
	echo("\"". $json_arr['title'] ."\" <". $json_arr['url'] .">" ."\n");
	
	$youtube_id = false;
	$youtube_id = parseYoutubeIDFromURL($json_arr['url']);
	
	if (!$youtube_id)
	    $youtube_id = parseYoutubeIDFromContent($json_arr['content']);
	
	if ($youtube_id) {
		echo ("Found youtube id [". $youtube_id ."]\n");
		$type_id += 4;
	}
	
		
	$itunes = false;
	$itunes = parseITunesSuffix($json_arr['url']);
	
	if (!$itunes)
	    $itunes = parseITunesSuffix($json_arr['content']);
	
	if ($itunes == "us/app/my-clinic-for-iphone/id503156674?mt=8&uo=4") {
		disableArticle($row['id']);
		continue;
	}		
	
	if ($itunes) {
		$itunes = "http://itunes.apple.com/" . $itunes;
		echo ("Found iTunes link <". $itunes .">\n");
		$type_id += 2;
	}

	
	echo ("Trying images for <". $row['short_url'] .">");
	preg_match_all('/<img .*?src="(.*?)".*?>/', $json_arr['content'], $matches);	
	foreach ($matches[1] as $key => $val) {		
		echo (".");
		
		if ($val == "http://www.memestache.com/sites/memestache.com//images/builder/loader_top.jpg") {
			disableArticle($row['id']);
			continue;
		}
		$img_url = "";
		$img_ratio = 0.0;
		
		$headers = get_headers($val, 1);
		if ($headers[0] != 'HTTP/1.1 200 OK')
			continue;
				
		$size_arr = getimagesize($val);
		if ($size_arr[0] > 400) {
			$img_url = $val;
			$type_id += 2;
			$img_ratio = $size_arr[1] / $size_arr[0];
			
			echo (" Using image <". $img_url ."> (". $img_ratio .")");
			break;			
		}
	}
	
	if ($type_id < 2) {
		echo ("\nWriting article as inactive...\n");
		disableArticle($row['id']);
	
	} else {
		echo ("\nWriting article as ACTIVE...\n");
		
		$query = 'INSERT INTO tblArticleImagesWorking (`id`, `type_id`, `article_id`, `url`, `ratio`, `added`) VALUES (NULL, 1, "'. $row['id'] .'", "'. $img_url .'", "'. $img_ratio .'", NOW());';
		$result = mysql_query($query);
		
		$query = 'UPDATE tblArticlesWorking SET `type_id` = '. $type_id .', `title` = "'. $json_arr['title'] .'", `content_txt` = "'. $json_arr['excerpt'] .'", `content_url` = "'. $json_arr['url'] .'", `image_url` = "", `image_ratio` = "", `youtube_id` = "'. $youtube_id .'", `itunes_url` = "'. $itunes .'", `active` = "Y" WHERE `id` = '. $row['id'] .';';
		$result = mysql_query($query);
	}   
}



        
require './_db_close.php'; 

?>