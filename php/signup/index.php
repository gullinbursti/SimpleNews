<?php 

session_start();

require './_db_open.php'; 
require_once('twitteroauth/twitteroauth.php');
require_once('_oauth_cfg.php');

if (empty($_SESSION['access_token'])) {
	
	
} else {
	$access_token = $_SESSION['access_token'];
	$connection = new TwitterOAuth(CONSUMER_KEY, CONSUMER_SECRET, $access_token['oauth_token'], $access_token['oauth_token_secret']);
	$tweetProfile_obj = $connection->get('account/verify_credentials');
	
	if (isset($_GET['lID'])) {
		$list_id = $_GET['lID'];
	
		$query = 'SELECT * FROM `tblLists` WHERE `id` = "'. $list_id .'";';
		$list_row = mysql_fetch_row(mysql_query($query));
		
		$query = 'SELECT `tblCurators`.`handle` FROM `tblCurators` INNER JOIN `tblListsCurators` ON `tblCurators`.`id` = `tblListsCurators`.`curator_id` WHERE `tblListsCurators`.`list_id` ='. $list_row[0] .';';
		$curator_result = mysql_query($query);
		
		$handles_str = "";
		while ($curator_row = mysql_fetch_array($curator_result, MYSQL_BOTH)) {
			$handles_str .= $curator_row['handle'] .",";
		}
	
		$tweetLookup_obj = $connection->get('users/lookup', array('screen_name' => substr_replace($handles_str, "", -1)));
		$curator_arr = array();
		foreach ($tweetLookup_obj as $key => $val) {
			array_push($curator_arr, array(
				"id" => $tweetLookup_obj[$key]->id_str, 
				"name" => $tweetLookup_obj[$key]->name, 
				"handle" => $tweetLookup_obj[$key]->screen_name,  
				"avatar" => str_replace("_normal.", "_reasonably_small.", $tweetLookup_obj[$key]->profile_image_url), 
				"info" => $tweetLookup_obj[$key]->description
			));	
		}
		
		
	
		$query = 'SELECT `tblInfluencers`.`handle` FROM `tblInfluencers` INNER JOIN `tblListsInfluencers` ON `tblInfluencers`.`id` = `tblListsInfluencers`.`influencer_id` WHERE `tblListsInfluencers`.`list_id` ='. $list_row[0] .';';
		$follower_result = mysql_query($query);
		$follower_tot = count($follower_result);
	
		$handles_str = "";
		while ($follower_row = mysql_fetch_array($follower_result, MYSQL_BOTH)) {
			$handles_str .= $follower_row['handle'] .",";
		}
	
		$tweetLookup_obj = $connection->get('users/lookup', array('screen_name' => substr_replace($handles_str, "", -1)));
		$follower_arr = array();
		foreach ($tweetLookup_obj as $key => $val) {
			array_push($follower_arr, array(
				"id" => $tweetLookup_obj[$key]->id_str, 
				"name" => $tweetLookup_obj[$key]->name, 
				"handle" => $tweetLookup_obj[$key]->screen_name,  
				"avatar" => str_replace("_normal.", "_reasonably_small.", $tweetLookup_obj[$key]->profile_image_url), 
				"info" => $tweetLookup_obj[$key]->description
			));	
		}
	}
    
	if ($_POST['hidPostback'] == "true") {
		if ($_POST['txtAddlHandles'] != "") {
			$follower_arr = explode(',', $_POST['txtAddlHandles']); 
		
			foreach ($follower_arr as $twitter_handle) {
				$tweetLookup_obj = $connection->get('users/lookup', array('screen_name' => str_replace("@", "", $twitter_handle)));
				array_push($follower_arr, $tweetLookup_obj[0]->id_str);
			}       
		}
		
		foreach ($follower_arr as $follower_id) {
			$tweet_obj = $connection->get('users/lookup', array('user_id' => $follower_id));
			
			//$sendTweet_obj = $connection->post('statuses/update', array('status' => "@". $tweet_obj[0]->screen_name .", mentioned Test Tweet from PHP"));

			$query = 'SELECT `id` FROM `tblInfluencers` WHERE `handle` = "'. $tweet_obj[0]->screen_name .'";';
			$result = mysql_query($query);
	
			if (mysql_num_rows($result) == 0) {
				echo ($twitter_handle ." ". $twitter_name ." ". $avatar_url ." ". $twitter_info);
		
				$query = 'INSERT INTO `tblInfluencers` (';
				$query .= '`id`, `handle`, `name`, `avatar_url`, `description`, `active`, `added`, `modified`) ';
				$query .= 'VALUES (NULL, "'. $tweet_obj[0]->screen_name .'", "'. $tweet_obj[0]->name .'", "'. str_replace("_normal.", "_reasonably_small.", $tweet_obj[0]->profile_image_url) .'", "'. $tweet_obj[0]->description .'", "Y", NOW(), CURRENT_TIMESTAMP);';
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
		
		$query = 'UPDATE `tblLists` SET `type_id` =4 WHERE `id` ='. $list_id .';';
		$result = mysql_query($query);		
	}
}

?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<meta http-equiv="Content-language" value="en" />
		<script type="text/javascript">
			function approveList() {
				document.frmApproveList.hidPostback.value = "true";
				document.frmApproveList.submit();
			}
		</script>
	</head>
	
	<body>
		<?php if (empty($_SESSION['access_token'])) {
			echo ("<a href=\"./redirect.php\"><img src=\"./images/lighter.png\" alt=\"Sign in with Twitter\"/></a>");
		
		} else {
			echo ("Signed into Twitter as <a href=\"https://twitter.com/#!/". $tweetProfile_obj->screen_name ."\" target=\"_blank\">@". $tweetProfile_obj->screen_name ."</a>");
		} ?><hr />
		
		<form id="frmApproveList" name="frmApproveList" method="post" action="./index.php?lID=<?php echo ($list_id); ?>"><table cellspacing="0" cellpadding="0" border="0" width="100%">
			<tr><td>List Name:</td><td><input type="text" id="txtListName" name="txtListName" value="<?php echo ($list_row[1]); ?>" disabled="disabled" /></td></tr>
			<tr><td>Topic:</td><td><input type="text" id="txtTopic" name="txtTopic" size="80" value="<?php echo ($list_row[2]); ?>" disabled="disabled" /></td></tr>
			<tr><td>Cover Photo:</td><td><a href="<?php echo ($list_row[6]); ?>" target="_blank"><img src="<?php echo ($list_row[5]); ?>" width="137" height="194" /></a></td></tr>
			<tr><td colspan="2"><hr /></td></tr>
			<tr><td colspan="2"><h3>Curators</h3>
				<table cellspacing="0" cellpadding="0" border="1"><?php
					$col = 0;
					$row = 0;
					$tot = 0;
					foreach ($curator_arr as $key => $val) {
						$pre_html = "<td>";
						$handle_html = "<a href=\"https://twitter.com/#!/". $curator_arr[$key]['handle'] ."\" target=\"_blank\">@". $curator_arr[$key]['handle'] ."</a>";
						$avatar_html = "<img src=\"". $curator_arr[$key]['avatar'] ."\" alt=\"". $curator_arr[$key]['handle'] ."\" />";
						$post_html = "</td>";
						
						echo ($pre_html . $handle_html ."<br />". $avatar_html . $post_html);
						
						$col++;
						if ($col == 5) {
							$row++;
							$col = 0;
							
							echo ("</tr><tr>");
						}
						
						$tot++;
					}
					echo ("</tr>");
					
				?></table>
			</td></tr>
			<tr><td colspan="2"><hr /></td></tr>
			<tr><td colspan="2"><h3>Influencers</h3>
				<table cellspacing="0" cellpadding="0" border="1"><?php
					$col = 0;
					$row = 0;
					$tot = 0;
					foreach ($follower_arr as $key => $val) {
						$pre_html = "<td>";
						$chkbox_html = "";//<input type=\"checkbox\" id=\"chkFollower_". $tot ."\" name=\"chkFollower_". $tot ."\" value=\"". $follower_arr[$key]['id'] ."\" />";
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
					
				?></table>
			</td></tr>
			<tr><td colspan="2"><h3>Add'l Influencers:</h3><textarea id="txtAddlHandles" name="txtAddlHandles" cols="30" rows="5"></textarea></td></tr>
			<tr><td colspan="2"><hr /></td></tr>
			<tr><td colspan="2"><input type="hidden" id="hidPostback" name="hidPostback" value="false" /></td></tr>
			<tr><td colspan="2" align="center"><input type="button" id="btnAdd" name="btnAdd" value="Approve This List" onclick="approveList();" /></td></tr>
		</table></form>   
	</body>
</html>

<?php require './_db_close.php'; ?>



<?php
	//print_r($tweet_obj);

	//$content = $connection->get('account/rate_limit_status');
	//echo "Current API hits remaining: {$content->remaining_hits}.";

/*
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
*/	
?>