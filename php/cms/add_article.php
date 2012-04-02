<?php

// start the session engine
session_start();

if (!isset($_SESSION['login']))  
	header('Location: login.php');  
	
require './_db_open.php';

$influencer_id = $_GET['fID'];
$handle = $_GET['handle'];
$tweet_id = $_GET['tID'];


require_once('_twitter_conn.php');
$tweet_obj = $connection->get('statuses/show', array('id' => $tweet_id));	

$tweet_msg = $tweet_obj->text;

$tweet_html = eregi_replace('(((f|ht){1}tp://)[-a-zA-Z0-9@:%_\+.~#?&//=]+)', '<a href="\\1" target="_blank">\\1</a>', $tweet_msg); 
$tweet_html = eregi_replace('([[:space:]()[{}])(www.[-a-zA-Z0-9@:%_\+.~#?&//=]+)', '\\1<a href="http://\\2">\\2</a>', $tweet_html); 
$tweet_html = eregi_replace('([_\.0-9a-z-]+@([0-9a-z][0-9a-z-]+\.)+[a-z]{2,3})', '<a href="mailto:\\1">\\1</a>', $tweet_html);

$tweet_html = eregi_replace('@([_\.0-9a-z-]+)', '<a href="https://twitter.com/#!/\\1" target="_blank">@\\1</a>', $tweet_html);

$query = 'SELECT * FROM `tblTags`;';
$tag_result = mysql_query($query);
$tot = mysql_num_rows($tag_result);

$query = 'SELECT * FROM `tblSourceTypes`;';
$src_result = mysql_query($query); 



if (isset($_POST['txtArticleSource'])) {
	$type_id = 7;
	$source_url = $_POST['txtArticleSource'];
	$network_id = $_POST['selNetworks'];
	$title = $_POST['txtArticleTitle'];
	$content = $_POST['txtArticleText'];
	$image_url = $_POST['txtImageURL_1'];
	$video_url = $_POST['txtVideoURL'];
	
	
	if ($_POST['radTint'] == "0")
		$isDark = 'N';
	
	else
		$isDark = 'Y';
	
	if (strlen($video_url) == 0)
		$type_id -= 4;
		
	if (strlen($image_url) == 0)
		$type_id -= 2;
	
	
		
	$query = 'INSERT INTO `tblArticles` (';
	$query .= '`id`, `influencer_id`, `tweet_id`, `tweet_msg`, `source_id`, `type_id`, `article_url`, `title`, `content`, `image_url`, `video_url`, `isDark`, `added`) ';
	$query .= 'VALUES (NULL, "'. $influencer_id .'", "'. $tweet_id .'", "'. $tweet_msg .'", "'. $network_id .'", "'. $type_id .'", "'. $source_url .'", "'. $title .'", "'. $content .'",  "'. $image_url .'", "'. $video_url .'", "'. $isDark .'", NOW());';
	$result = mysql_query($query);
	$article_id = mysql_insert_id();
	
	//echo ($query);
	
	$tagID_arr = explode("|", $_POST['hidIDs']);

	for ($i=0; $i<count($tagID_arr); $i++) {
		$tag_id = $tagID_arr[$i];
		
		$query = 'INSERT INTO `tblArticlesTags` (';
		$query .= '`article_id`, `tag_id`) ';
		$query .= 'VALUES ("'. $article_id .'", "'. $tag_id .'");';
		$result = mysql_query($query);
	}
	
	//echo ($query);
	header('Location: tweets.php?id='. $follower_id .'&handle='. $handle);
}
	
?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<meta http-equiv="Content-language" value="en" />
		<script type="text/javascript">
			function submitArticle() {
				var tot = <?php echo ($tot); ?>;
				var tagIDs = "";
				var cnt = 0;
			
				for (var i=0; i<tot; i++) {
					var chkbox = document.getElementById('chkTag_' + i);
				
					if (chkbox.checked) {
						var tag_id = chkbox.name.substring(7);
						
						if (cnt > 0)
							tagIDs += "|";
						
						tagIDs += tag_id;
						cnt++;
					}
				}
			
			    document.frmAddArticle.hidIDs.value = tagIDs;
				document.frmAddArticle.submit();
			}
		</script>
	</head>
	
	<body><form name="frmAddArticle" id="frmAddArticle" method="post" action="./add_article.php?fID=<?php echo ($follower_id); ?>&handle=<?php echo ($handle); ?>&tID=<?php echo ($tweet_id); ?>">
		<table cellpadding="0" cellspacing="0" border="0">
			<tr>
				<td width="320" valign="top"><?php include './nav.php'; ?></td>
				<td><table cellspacing="0" cellpadding="0" border="0">
					<tr><td colspan="2"></td></tr>
					<tr><td colspan="2"><?php 
						echo ("Message: ". $tweet_html ."<br />");
						echo ("Created: ". $tweet_obj->created_at ."<br />");
						echo ("Retweet Count: ". $tweet_obj->retweet_count ."<br />");
					?></td></tr>
					<tr><td colspan="2"><hr /></td></tr>
					<tr><td>Article Source:</td><td><input type="text" id="txtArticleSource" name="txtArticleSource" size="80" /></td></tr>
					<tr><td>Social Network:</td><td><select id="selNetworks" name="selNetworks"><?php while ($row = mysql_fetch_array($src_result, MYSQL_BOTH)) {
						echo ("<option id=\"". $row['id'] ."\">". $row['title'] ."</option>");
					} ?><select></td></tr>
					<tr><td>Article Title:</td><td><input type="text" id="txtArticleTitle" name="txtArticleTitle" size="80" /></td></tr>
					<tr><td>Article Text:</td><td><textarea id="txtArticleText" name="txtArticleText" rows="18" cols="80"></textarea></td></tr>
					<tr><td>Image URL:</td><td><input type="text" id="txtImageURL_1" name="txtImageURL_1" size="80" /></td></tr>
					<tr><td>App Controls:</td><td><input type="radio" id="radTint" name="radTint" value="0" checked />Light<input type="radio" id="radTint" name="radTint" value="1" />Dark</td></tr>
					<tr><td>Video URL:</td><td><input type="text" id="txtVideoURL" name="txtVideoURL" size="80" /></td></tr>
					<tr><td>Tags:</td><td><?php 
						$tot = 0;
						while ($row = mysql_fetch_array($tag_result, MYSQL_BOTH)) {
							echo ("<input type=\"checkbox\" id=\"chkTag_". $tot ."\" name=\"chkTag_". $row['id'] ."\" value=\"N\" />#". $row['title'] ."<br />");
							$tot++;
						}
					?><input type="hidden" id="hidIDs" name="hidIDs" value="" /></td></tr>
					<tr><td colspan="2"><hr /></td></tr>
					<tr><td colspan="2"><input type="button" id="idSubmit" name="btnSubmit" value="Add Article" onclick="submitArticle()" /></td></tr>
				</table></td>
			</tr>
		</table>
	</form></body>
</html> 

<?php require './_db_close.php'; ?>