<?php

// start the session engine
session_start();

if (!isset($_SESSION['login']))  
	header('Location: login.php');

require './_db_open.php';

require_once('twitteroauth/twitteroauth.php');
require_once('_oauth_cfg.php');
require_once('_twitter_conn.php');

if (isset($_GET['a'])) {
	$twitter_info = $_POST['txtBlurb'];
	
	$twitter_active = "N";
	if ($_POST['chkActive'] == "Y")
		$twitter_active = "Y";
		
	$query = 'UPDATE `tblFollowers` SET ';
	$query .= '`description` = "'. $twitter_info .'", ';
	$query .= '`active` = "'. $twitter_active .'" ';
	$query .= 'WHERE `id` = "'. $_GET['id'] .'"';
	$result = mysql_query($query);
	
	header('Location: followers.php');
}

$query = 'SELECT * FROM `tblLists` WHERE `id` = "'. $_GET['id'] .'";';
$row = mysql_fetch_row(mysql_query($query));

$query = 'SELECT `tblCurators`.`handle` FROM `tblCurators` INNER JOIN `tblListsCurators` ON `tblCurators`.`id` = `tblListsCurators`.`curator_id` WHERE `tblListsCurators`.`list_id` ='. $_GET['id'] .';';
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
		"avatar" => $tweetLookup_obj[$key]->profile_image_url, 
		"info" => $tweetLookup_obj[$key]->description
	));	
}



$query = 'SELECT `tblInfluencers`.`handle` FROM `tblInfluencers` INNER JOIN `tblListsInfluencers` ON `tblInfluencers`.`id` = `tblListsInfluencers`.`influencer_id` WHERE `tblListsInfluencers`.`list_id` ='. $_GET['id'] .';';
$follower_result = mysql_query($query);

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
		"avatar" => $tweetLookup_obj[$key]->profile_image_url, 
		"info" => $tweetLookup_obj[$key]->description
	));	
}
	
?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<meta http-equiv="Content-language" value="en" />
		
		<script type="text/javascript">
			function edit() {
				var chkbox = document.getElementById('chkActive');				
				if (chkbox.checked)
					chkbox.value = "Y";
				
				else
					chkbox.value = "N";
				
				document.frmEdit.submit();
			}
		</script>
	</head>
	
	<body>
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
			<tr>
				<td width="320" valign="top"><?php include './nav.php'; ?></td>
				<td><form id="frmEdit" name="frmEdit" method="post" action="./edit_list.php?a=0&id=<?php echo ($row[0]); ?>">
					<table cellspacing="0" cellpadding="0" border="0" width="100%">
						<tr><td rowspan="5" width="137"><img src="<?php echo ($row[5]); ?>" width="137" height="194" /></td><td width="100">Name:</td><td><input type="text" id="txtTitle" name="txtTitle" value="<?php echo ($row[1]); ?>" /></td>
					    <tr><td width="100">Info:</td><td><input type="text" id="txtInfo" name="txtInfo" value="<?php echo ($row[2]); ?>" /></td></tr>
						<tr><td width="100">Status:</td><td><?php echo ($row[3]); ?></td></tr>
						<tr><td width="100">Curators:</td><td>
							<table cellspacing="0" cellpadding="4" border="0"><?php
								$col = 0;
								$row = 0;
								$tot = 0;
								foreach ($curator_arr as $key => $val) {
									$pre_html = "<td>";									
									$avatar_html = "<img src=\"". $curator_arr[$key]['avatar'] ."\" alt=\"". $curator_arr[$key]['handle'] ."\" />";
									$handle_html = "<a href=\"https://twitter.com/#!/". $curator_arr[$key]['handle'] ."\" target=\"_blank\">@". $curator_arr[$key]['handle'] ."</a>";
									$post_html = "</td>";
						
									echo ($pre_html . $avatar_html ."<br />". $handle_html . $post_html);
						
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
						<tr><td width="100">Influencers:</td><td>
							<table cellspacing="0" cellpadding="4" border="0"><?php
								$col = 0;
								$row = 0;
								$tot = 0;
								foreach ($follower_arr as $key => $val) {
									$pre_html = "<td>";
									$avatar_html = "<img src=\"". $follower_arr[$key]['avatar'] ."\" alt=\"". $follower_arr[$key]['handle'] ."\" />";
									$handle_html = "<a href=\"https://twitter.com/#!/". $follower_arr[$key]['handle'] ."\" target=\"_blank\">@". $follower_arr[$key]['handle'] ."</a>";
									$post_html = "</td>";
						
									echo ($pre_html . $avatar_html ."<br />". $handle_html . $post_html);
						
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
						<tr><td colspan="3"><input type="button" id="btnCancel" name="btnCancel" value="Cancel" onclick="history.back();" /><input type="button" id="btnEdit" name="btnEdit" value="Edit List" onclick="edit();" /></td></tr>
					</table>
				</form></td>
			</tr>
		</table>
	</body>
</html>

<?php require './_db_close.php'; ?>