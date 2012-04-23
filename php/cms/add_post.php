<?php

// start the session engine
session_start();

if (!isset($_SESSION['login']))  
	header('Location: login.php');  
	
require './_db_open.php';

$influencer_id = 3;
$handle = "getassembly";
$tweet_id = 0;

$query = 'SELECT * FROM `tblLists` INNER JOIN `tblListsInfluencers` ON `tblLists`.`id` = `tblListsInfluencers`.`list_id` WHERE `tblListsInfluencers`.`influencer_id` = '. $influencer_id .';';
$list_result = mysql_query($query);
$tot = mysql_num_rows($list_result);

$query = 'SELECT * FROM `tblSourceTypes`;';
$src_result = mysql_query($query); 



if (isset($_POST['txtArticleSource'])) {
	$type_id = 7;
	$source_url = $_POST['txtArticleSource'];
	$title = $_POST['txtArticleTitle'];
	$content = "<p>". str_replace('\r\n', '<br />', str_replace('\r\n\r\n', '</p><p>', $_POST['txtArticleText'])) ."</p>";
	$image_url = $_POST['txtImageURL_1'];
	$video_url = $_POST['txtVideoURL'];
	
	if (strlen($video_url) == 0)
		$type_id -= 4;
		
	if (strlen($image_url) == 0)
		$type_id -= 2;
	
	$list_arr = explode('|', $_POST['hidIDs']);
	
	foreach ($list_arr as $val) { 
		$query = 'INSERT INTO `tblArticles` (';
		$query .= '`id`, `influencer_id`, `list_id`, `tweet_id`, `tweet_msg`, `source_id`, `type_id`, `article_url`, `title`, `content`, `image_url`, `video_url`, `img_ratio`, `likes`, `added`) ';
		$query .= 'VALUES (NULL, "'. $influencer_id .'", "'. $val .'", "0000", "", 0, "'. $type_id .'", "'. $source_url .'", "'. $title .'", "'. $content .'",  "'. $image_url .'", "'. $video_url .'", 1.0, 0, NOW());';
		$result = mysql_query($query);
		$article_id = mysql_insert_id();
		
		//echo ($query);
	}
	
	//echo ($query);
	header('Location: main.php');
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
	
	<body><form name="frmAddArticle" id="frmAddArticle" method="post" action="./add_post.php?fID=<?php echo ($influencer_id); ?>&handle=<?php echo ($handle); ?>&tID=<?php echo ($tweet_id); ?>">
		<table cellpadding="0" cellspacing="0" border="0">
			<tr>
				<td width="320" valign="top"><?php include './nav.php'; ?></td>
				<td><table cellspacing="0" cellpadding="0" border="0">
					<tr><td colspan="2"></td></tr>
					<tr><td colspan="2"><hr /></td></tr>
					<tr><td>Article Source:</td><td><input type="text" id="txtArticleSource" name="txtArticleSource" size="80" /></td></tr>
					<tr><td>Article Title:</td><td><input type="text" id="txtArticleTitle" name="txtArticleTitle" size="80" /></td></tr>
					<tr><td>Article Text:</td><td><textarea id="txtArticleText" name="txtArticleText" rows="18" cols="80"></textarea></td></tr>
					<tr><td>Image URL:</td><td><input type="text" id="txtImageURL_1" name="txtImageURL_1" size="80" /></td></tr>
					<tr><td>Video URL:</td><td><input type="text" id="txtVideoURL" name="txtVideoURL" size="80" /></td></tr>
					<tr><td>Lists:</td><td><?php 
						$tot = 0;
						while ($row = mysql_fetch_array($list_result, MYSQL_BOTH)) {
							echo ("<input type=\"checkbox\" id=\"chkList_". $tot ."\" name=\"chkList_". $row['id'] ."\" value=\"N\" />". $row['title'] ."<br />");
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