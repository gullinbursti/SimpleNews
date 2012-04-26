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

$query = 'SELECT * FROM `tblLists` INNER JOIN `tblListsInfluencers` ON `tblLists`.`id` = `tblListsInfluencers`.`list_id` WHERE `tblListsInfluencers`.`influencer_id` = '. $influencer_id .';';
$list_result = mysql_query($query);
$tot = mysql_num_rows($list_result);

$query = 'SELECT * FROM `tblSourceTypes`;';
$src_result = mysql_query($query);

$retweet_obj = $connection->get('statuses/retweets/'. $tweet_id, array('count' => "10")); 

$month_arr = array(
	"jan" => "01", 
	"feb" => "02", 
	"mar" => "03", 
	"apr" => "04", 
	"may" => "05", 
	"jun" => "06", 
	"jul" => "07", 
	"aug" => "08", 
	"sep" => "09", 
	"oct" => "10", 
	"nov" => "11", 
	"dec" => "12" 
);
	
	
if (isset($_POST['txtArticleSource'])) {
	$type_id = 7;
	$source_url = $_POST['txtArticleSource'];
	$affiliate_url = $_POST['txtAffiliate'];
	$network_id = $_POST['selNetworks'];
	$title = $_POST['txtArticleTitle'];
	$content = $_POST['txtArticleText'];
	$image_url = $_POST['txtImageURL_1'];
	$video_url = $_POST['txtVideoURL'];
	
	if ($_POST['txtImageHeight'] != "" && $_POST['txtImageWidth'] !="")
		$img_ratio = $_POST['txtImageHeight'] / $_POST['txtImageWidth'];
	
	else	
		$img_ratio = 0;
	
	if (strlen($video_url) == 0)
		$type_id -= 4;
		
	if (strlen($image_url) == 0)
		$type_id -= 2;
	
	$list_arr = explode('|', $_POST['hidIDs']);
	
	foreach ($list_arr as $val) { 
		$query = 'INSERT INTO `tblArticles` (';
		$query .= '`id`, `influencer_id`, `list_id`, `tweet_id`, `tweet_msg`, `source_id`, `type_id`, `article_url`, `affiliate_url`, `title`, `content`, `image_url`, `video_url`, `img_ratio`, `likes`, `added`) ';
		$query .= 'VALUES (NULL, "'. $influencer_id .'", "'. $val .'", "'. $tweet_id .'", "'. $tweet_msg .'", "'. $network_id .'", "'. $type_id .'", "'. $source_url .'", "'. $affiliate_url .'", "'. $title .'", "'. $content .'",  "'. $image_url .'", "'. $video_url .'", '. $img_ratio .', 0, NOW());';
		$result = mysql_query($query);
		$article_id = mysql_insert_id();
		
		//echo ($query);
	}
	
	foreach ($retweet_obj as $key => $val) {
		$retweet_id = $retweet_obj[$key]->id_str;
		$avatar_url = $retweet_obj[$key]->user->profile_image_url;
		$twitter_name = $retweet_obj[$key]->user->name;
		$handle = $retweet_obj[$key]->user->screen_name;
		
		$timestamp_arr = explode(' ', $retweet_obj[$key]->created_at);
		$month = strtolower($timestamp_arr[1]);
		$day = $timestamp_arr[2];
		$time = $timestamp_arr[3];
		$year = $timestamp_arr[5];
		
		$created = $year ."-". $month_arr[$month] ."-". $day ." ". $time;
		
		$query = 'INSERT INTO `tblRetweets` (';
		$query .= '`id`, `tweet_id`, `retweet_id`, `handle`, `avatar_url`, `created`, `added`) ';
		$query .= 'VALUES (NULL, "'. $tweet_id .'", "'. $retweet_obj[$key]->id_str .'", "'. $retweet_obj[$key]->user->screen_name .'", "'. $retweet_obj[$key]->user->profile_image_url .'", "'. $created .'" NOW());';
		$result = mysql_query($query);
		$retweet_id = mysql_insert_id();
	}
	
	
	
	//echo ($query);
	header('Location: tweets.php?id='. $influencer_id .'&handle='. $handle);
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
				var listIDs = "";
				var cnt = 0;
			
				for (var i=0; i<tot; i++) {
					var chkbox = document.getElementById('chkList_' + i);
				
					if (chkbox.checked) {
						var list_id = chkbox.name.substring(8);
						
						if (cnt > 0)
							listIDs += "|";
						
						listIDs += list_id;
						cnt++;
					}
				}
				
			    document.frmAddArticle.hidIDs.value = listIDs;
				document.frmAddArticle.submit();
			}
		</script>
	</head>
	
	<body><form name="frmAddArticle" id="frmAddArticle" method="post" action="./add_article.php?fID=<?php echo ($influencer_id); ?>&handle=<?php echo ($handle); ?>&tID=<?php echo ($tweet_id); ?>">
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
						if ($row['id'] == 1)
						    echo ("<option id=\"". $row['id'] ."\" selected=\"selected\">". $row['title'] ."</option>");
						else
							echo ("<option id=\"". $row['id'] ."\">". $row['title'] ."</option>");
					} ?><select></td></tr>
					<tr><td>Article Title:</td><td><input type="text" id="txtArticleTitle" name="txtArticleTitle" size="80" /></td></tr>
					<tr><td>Article Text:</td><td><textarea id="txtArticleText" name="txtArticleText" rows="18" cols="80"></textarea></td></tr>
					<tr><td>Image URL:</td><td><input type="text" id="txtImageURL_1" name="txtImageURL_1" size="80" /></td></tr>
					<tr><td>Image Size:</td><td><input type="text" id="txtImageWidth" name="txtImageWidth" />x<input type="text" id="txtImageHeight" name="txtImageHeight" /></td></tr>
					<tr><td>Video URL:</td><td><input type="text" id="txtVideoURL" name="txtVideoURL" size="80" /></td></tr>
					<tr><td>Affiliate URL:</td><td><input type="text" id="txtAffiliate" name="txtAffiliate" size="80" /></td></tr>
					<tr><td>Lists:</td><td><?php 
						$tot = 0;
						while ($row = mysql_fetch_array($list_result, MYSQL_BOTH)) {
							echo ("<input type=\"checkbox\" id=\"chkList_". $tot ."\" name=\"chkList_". $row['id'] ."\" value=\"N\" />". $row['title'] ."<br />");
							$tot++;
						}
					?><input type="hidden" id="hidIDs" name="hidIDs" value="" /></td></tr>
					<tr><td colspan="2"><hr /></td></tr>
					<tr><td colspan="2"><input type="button" id="btnCancel" name="btnCancel" value="Cancel" onclick="history.back();" /><input type="button" id="idSubmit" name="btnSubmit" value="Add Article" onclick="submitArticle()" /></td></tr>
					<tr><td colspan="2"><hr /><hr /></td></tr>
					<tr><td colspan="2">Retweets:<br />
						<table cellspacing="4" cellpadding="0" border="1"><tr><?php $cnt = 0; 
						foreach ($retweet_obj as $key => $val) {
							echo ("<td><img src=\"". $retweet_obj[$key]->user->profile_image_url ."\" /><br />");
							echo (implode(' ', explode(' ', $retweet_obj[$key]->created_at, -2)) ."<br />");
							echo ("<a href=\"https://twitter.com/#!/". $retweet_obj[$key]->user->screen_name ."\" target=\"_blank\">@". $retweet_obj[$key]->user->screen_name ."</a></td>");
							$cnt++;
							
							if ($cnt % 5 == 0)
								echo ("</tr><tr>");
						} 
					?></tr></table></td></tr>
				</table></td>
			</tr>
		</table>
	</form></body>
</html> 

<?php require './_db_close.php'; ?>