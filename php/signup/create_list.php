<?php

// start the session engine
session_start();  

require './_db_open.php';
require_once('twitteroauth/twitteroauth.php');
require_once('_oauth_cfg.php');


$access_token = $_SESSION['access_token'];
$connection = new TwitterOAuth(CONSUMER_KEY, CONSUMER_SECRET, $access_token['oauth_token'], $access_token['oauth_token_secret']);


if ($_POST['hidPostback'] == "true") {
	$follower_arr = explode('|', $_POST['hidIDs']);
	
	$tweet_obj = $connection->get('account/verify_credentials');
	$query = 'SELECT `id` FROM `tblCurators` WHERE `handle` = "'. $tweet_obj->screen_name .'";';
	$result = mysql_query($query);
		
	if (mysql_num_rows($result) == 0) {
		$query = 'INSERT INTO `tblCurators` (';
		$query .= '`id`, `handle`, `name`, `info`, `active`, `added`, `modified`) ';
		$query .= 'VALUES (NULL, "'. $tweet_obj->screen_name .'", "'. $tweet_obj->name .'", "'. $tweet_obj->description .'", "Y", NOW(), CURRENT_TIMESTAMP);';
		$result = mysql_query($query);
		$curator_id = mysql_insert_id();
			
	} else {
		$row = mysql_fetch_row($result);
		$curator_id = $row[0];
	} 
	
	$query = 'INSERT INTO `tblLists` (';
	$query .= '`id`, `title`, `info`, `type_id`, `curator_id`, `thumb_url`, `image_url`, `active`, `added`, `modified`) ';
	$query .= 'VALUES (NULL, "'. $_POST['txtListName'] .'", "'. $_POST['txtTopic'] .'", 1, "'. $curator_id .'", "", "", "Y", NOW(), CURRENT_TIMESTAMP);';
	$result = mysql_query($query);
	$list_id = mysql_insert_id();
	
	foreach ($follower_arr as $follower_id) {
		$tweet_obj = $connection->get('users/lookup', array('user_id' => $follower_id));
		
		foreach($tweet_obj as $key => $val) {
			//$twitter_handle = $tweet_obj[$key]->screen_name;
			//$twitter_name = $tweet_obj[$key]->name;
			//$twitter_info = $tweet_obj[$key]->description;
		
			$query = 'SELECT `id` FROM `tblInfluencers` WHERE `handle` = "'. $tweet_obj[$key]->screen_name .'";';
			$result = mysql_query($query);
			
			if (mysql_num_rows($result) == 0) {
				echo ($twitter_handle ." ". $twitter_name ." ". $avatar_url ." ". $twitter_info);
				
				$query = 'INSERT INTO `tblInfluencers` (';
				$query .= '`id`, `handle`, `name`, `avatar_url`, `description`, `active`, `added`, `modified`) ';
				$query .= 'VALUES (NULL, "'. $tweet_obj[$key]->screen_name .'", "'. $tweet_obj[$key]->name .'", "'. str_replace("_normal.", "_reasonably_small.", $tweet_obj[$key]->profile_image_url) .'", "'. $tweet_obj[$key]->description .'", "Y", NOW(), CURRENT_TIMESTAMP);';
				$result = mysql_query($query);
				$influencer_id = mysql_insert_id();
			
			} else {
				$row = mysql_fetch_row($result);
				$influencer_id = $row[0];
				
			}
			
			$query = 'INSERT INTO `tblListsInfluencers` (';
			$query .= '`list_id`, `influencer_id`) ';
			$query .= 'VALUES ("'. $list_id .'", "'. $influencer_id .'");';
			$result = mysql_query($query);
			
			
			$query = 'SELECT `id` FROM `tblArticles` WHERE `influencer_id` = "'. $influencer_id .'";';
			$article_result = mysql_query($query);
			
			while ($row = mysql_fetch_array($article_result, MYSQL_BOTH)) {
				$query = 'INSERT INTO `tblArticlesLists` (';
				$query .= '`article_id`, `list_id`) ';
				$query .= 'VALUES ("'. $row['id'] .'", "'. $list_id .'");';
				$result = mysql_query($query);	
			}
		}
	}
}





//print_r($tweet_obj);

//$content = $connection->get('account/rate_limit_status');
//echo "Current API hits remaining: {$content->remaining_hits}.";

$tweet_obj = $connection->get('friends/ids', array('screen_name' => $handle));


$follower_tot = count($tweet_obj->ids);

$id_arr = array();
foreach ($tweet_obj->ids as $key => $val)
	array_push($id_arr, $val);
	

$paged_arr = array_chunk($id_arr, 100);
$follower_arr = array();

for ($i=0; $i<count($paged_arr); $i++) {
	$id_str = "";
	
	foreach ($paged_arr[$i] as $val)
		$id_str .= $val .",";	
	
	$id_str = substr_replace($id_str, "", -1);
	$tweet_obj = $connection->get('users/lookup', array('user_id' => $id_str));
	
	foreach ($tweet_obj as $key => $val) {
		array_push($follower_arr, array(
			"id" => $tweet_obj[$key]->id_str, 
			"name" => $tweet_obj[$key]->name, 
			"handle" => $tweet_obj[$key]->screen_name,  
			"avatar" => str_replace("_normal.", "_reasonably_small.", $tweet_obj[$key]->profile_image_url), 
			"info" => $tweet_obj[$key]->description
		));
	}
}
  
?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<meta http-equiv="Content-language" value="en" />
		<script type="text/javascript">
			function submitList() {
				var tot = <?php echo($follower_tot); ?>;
				var followerIDs = "";
				var cnt = 0;

				for (var i=0; i<tot; i++) {
					var chkbox = document.getElementById('chkFollower_' + i);
					
					if (chkbox.checked) {
						var follower_id = chkbox.value;
					    
						if (cnt > 0)
							followerIDs += "|";
						
						followerIDs += follower_id;
						cnt++;
					}
				}
				
				document.frmAddList.hidIDs.value = followerIDs;
				document.frmAddList.hidPostback.value = "true";
				document.frmAddList.submit();
			}
		</script>
	</head>
	
	<body>
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
			<tr>
				<td width="320" valign="top"></td>
				<td><form id="frmAddList" name="frmAddList" method="post" action="./create_list.php"><table cellspacing="0" cellpadding="0" border="0">
					<tr><td colspan="2"><hr /></td></tr>
					<tr><td>List Name</td><td><input type="text" id="txtListName" name="txtListName" /></td></tr>
					<tr><td>Topic</td><td><input type="text" id="txtTopic" name="txtTopic" /></td></tr>
					<tr><td colspan="2"><table cellspacing="0" cellpadding="0" border="1"><?php
						$col = 0;
						$row = 0;
						$tot = 0;
						foreach ($follower_arr as $key => $val) {
							$pre_html = "<td>";
							$chkbox_html = "<input type=\"checkbox\" id=\"chkFollower_". $tot ."\" name=\"chkFollower_". $tot ."\" value=\"". $follower_arr[$key]['id'] ."\" />";
							$handle_html = "<a href=\"https://twitter.com/#!/". $follower_arr[$key]['handle'] ."\" target=\"_blank\">@". $follower_arr[$key]['handle'] ."</a>";
							$avatar_html = "<img src=\"". $follower_arr[$key]['avatar'] ."\" alt=\"". $follower_arr[$key]['handle'] ."\" />";
							$post_html = "</td>";
							
							echo ($pre_html . $chkbox_html . $handle_html ."<br />". $avatar_html . $post_html);
							
							$col++;
							if ($col == 5) {
								$row++;
								$col = 0;
								
								echo ("</tr><tr>");
							}
							
							$tot++;
						}
						echo ("</tr>");
						
					?></table></td></tr>
					<tr><td><input type="hidden" id="hidIDs" name="hidIDs" value="" /><input type="hidden" id="hidPostback" name="hidPostback" value="false" /></td></tr>
					<tr><td><input type="button" id="btnAdd" name="btnAdd" value="Add My List" onclick="submitList();" /></td></tr>
				</table></form></td>
			</tr>
		</table>
	</body>
</html>

<?php require './_db_close.php'; ?>