<?php

// start the session engine
session_start();

if (!isset($_SESSION['login']))  
	header('Location: login.php');  
	

require './_db_open.php';  

require_once('twitteroauth/twitteroauth.php');
require_once('_oauth_cfg.php');
require_once('_twitter_conn.php'); 

	
$query = 'SELECT * FROM `tblLists` ORDER BY `added` DESC;';
$result = mysql_query($query);
	
?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<meta http-equiv="Content-language" value="en" />
		<script type="text/javascript">
			function edit(list_id) {
				location.href = "./edit_list.php?id=" + list_id;
			}
			
			function remove(list_id) {
				var prompt = confirm("Delete this list ["+ list_id +"]?");
				
				if (prompt)
					location.href = "./delete_list.php?id=" + list_id;
			}
		</script>
	</head>
	
	<body>
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
			<tr>
				<td width="320" valign="top"><?php include './nav.php'; ?></td>
				<td><table cellspacing="0" cellpadding="0" border="0">
					<tr><td><input type="button" id="btnAdd" name="btnAdd" value="Add List" onclick="location.href='./add_list.php'"></td></tr>
					<tr><td colspan="2"><hr /></td></tr>
					
					<?php while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
						$query = 'SELECT `tblCurators`.`handle` FROM `tblCurators` INNER JOIN `tblListsCurators` ON `tblCurators`.`id` = `tblListsCurators`.`curator_id` WHERE `tblListsCurators`.`list_id` ='. $row['id'] .';';
						$curator_result = mysql_query($query);

						$handles_str = "";
						while ($curator_row = mysql_fetch_array($curator_result, MYSQL_BOTH)) {
							$handles_str .= $curator_row['handle'] .",";
						}

						$tweetLookup_obj = $connection->get('users/lookup', array('screen_name' => substr_replace($handles_str, "", -1)));
						$curator_html = "<table cellspacing=\"10\" cellpadding=\"0\" border=\"0\"><tr>";
						
						foreach ($tweetLookup_obj as $key => $val) {
							$curator_html .= "<td><img src=\"". $tweetLookup_obj[$key]->profile_image_url ."\" alt=\"". $tweetLookup_obj[$key]->name ."\" /><br />";
							$curator_html .= "<a href=\"https://twitter.com/#!/". $tweetLookup_obj[$key]->screen_name ."\" target=\"_blank\">@". $tweetLookup_obj[$key]->screen_name ."</a></td>";						
						}
						$curator_html .= "</tr></table>";
						
						
						$query = 'SELECT `tblInfluencers`.`handle` FROM `tblInfluencers` INNER JOIN `tblListsInfluencers` ON `tblInfluencers`.`id` = `tblListsInfluencers`.`influencer_id` WHERE `tblListsInfluencers`.`list_id` ='. $row['id'] .';';
						$follower_result = mysql_query($query);
	
						$handles_str = "";
						while ($follower_row = mysql_fetch_array($follower_result, MYSQL_BOTH)) {
							$handles_str .= $follower_row['handle'] .",";
						}
	                    
						$tweetLookup_obj = $connection->get('users/lookup', array('screen_name' => substr_replace($handles_str, "", -1)));
						$follower_html = "<table cellspacing=\"10\" cellpadding=\"0\" border=\"0\"><tr>";
						
						foreach ($tweetLookup_obj as $key => $val) {
							$follower_html .= "<td><img src=\"". $tweetLookup_obj[$key]->profile_image_url ."\" alt=\"". $tweetLookup_obj[$key]->name ."\" /><br />";
							$follower_html .= "<a href=\"https://twitter.com/#!/". $tweetLookup_obj[$key]->screen_name ."\" target=\"_blank\">@". $tweetLookup_obj[$key]->screen_name ."</a></td>";
						}
						$follower_html .= "</tr></table>";
						
						$query = 'SELECT `title` FROM `tblListTypes` WHERE `id` ='. $row['type_id'] .';';
						$type_row = mysql_fetch_row(mysql_query($query));
						
						
						$pre_html = "<tr><td><table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" width=\"100%\">";
						$post_html = "</table></td></tr>";
						
						echo ($pre_html);
						echo ("<tr><td rowspan=\"6\" width=\"137\"><img src=\"". $row['image_url'] ."\" width=\"137\" height=\"194\" /></td>");
						echo ("<td width=\"100\">Name:</td><td>". $row['title'] ."</td>");
						echo ("<tr><td width=\"100\">Info:</td><td>". $row['info'] ."</td></tr>");
						echo ("<tr><td width=\"100\">Status:</td><td>". $type_row[0] ."</td></tr>");
						//echo ("<tr><td width=\"100\">Share:</td><td><a href=\"http://dev.gullinbursti.cc/projs/simplenews/signup/index.php?l=". str_replace('=', '%3D', $row['enc_name']) ."\" target=\"_blank\">http://dev.gullinbursti.cc/projs/simplenews/signup/index.php?l=". str_replace('=', '%3D', $row['enc_name']) ."</a></td></tr>");
						echo ("<tr><td width=\"100\">Share:</td><td><a href=\"http://dev.gullinbursti.cc/projs/simplenews/signup/index.php?lID=". $row['id'] ."\" target=\"_blank\">http://dev.gullinbursti.cc/projs/simplenews/signup/index.php?lID=". $row['id'] ."</a></td></tr>");
						echo ("<tr><td width=\"100\">Curators:</td><td>". $curator_html ."</td></tr>");
						echo ("<tr><td width=\"100\">Influencers:</td><td>". $follower_html ."</td></tr>");
						echo ("<tr><td colspan=\"3\" align=\"left\"><input type=\"button\" value=\"Delete\" onclick=\"remove('". $row['id'] ."');\" /><input type=\"button\" value=\"Edit\" onclick=\"edit('". $row['id'] ."');\" /></td></tr>");
						echo ("<tr><td colspan=\"3\"><hr /></td></tr>");
						echo ($post_html);
					} ?>
				</table></td>
			</tr>
		</table>
	</body>
</html>

<?php require './_db_close.php'; ?>