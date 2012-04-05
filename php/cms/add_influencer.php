<?php

// start the session engine
session_start();

if (!isset($_SESSION['login']))  
	header('Location: login.php');

require './_db_open.php';

if (isset($_POST['txtHandle'])) {
	
	$twitter_handle = $_POST['txtHandle'];
	$twitter_active = "N";
	
	if ($_POST['chkActive'] == "Y")
		$twitter_active = "Y";
		
	require_once('_twitter_conn.php');
	
	$tweet_obj = $connection->get('users/lookup', array('screen_name' => $twitter_handle));
	//print_r ($tweet_obj);
	
	foreach($tweet_obj as $key => $val)
		$twitter_name = $tweet_obj[$key]->name;
		$twitter_avatar = str_replace("_normal.", "_reasonably_small.", $tweet_obj[$key]->profile_image_url);
		$twitter_descript = $tweet_obj[$key]->description;
	
	$query = 'SELECT * FROM `tblInfluencers` WHERE `handle` = "'. $twitter_handle .'";';
	if (mysql_num_rows(mysql_query($query)) == 0) {		
		$query = 'INSERT INTO `tblInfluencers` (';
		$query .= '`id`, `handle`, `name`, `avatar_url`, `description`, `active`, `added`, `modified`) ';
		$query .= 'VALUES (NULL, "'. $twitter_handle .'", "'. $twitter_name .'", "'. $twitter_avatar .'", "'. $twitter_descript .'", "'. $twitter_active .'", NOW(), CURRENT_TIMESTAMP);';
	
		$result = mysql_query($query);
		$twitter_id = mysql_insert_id();
	}
	
	header('Location: influencers.php');
}

?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<meta http-equiv="Content-language" value="en" />
		
		<script type="text/javascript">
			function addInfluencer () {
				var chkbox = document.getElementById('chkActive');				
				if (chkbox.checked)
					chkbox.value = "Y";
				
				else
					chkbox.value = "N";
					
				document.frmAdd.submit();
			}
		</script>
	</head>
	
	<body>
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
			<tr>
				<td width="320" valign="top"><?php include './nav.php'; ?></td>
				<td><form id="frmAdd" name="frmAdd" method="post" action="./add_influencer.php"><table cellspacing="0" cellpadding="0" border="0">
					<tr><td>Handle:</td><td>@<input type="text" id="txtHandle" name="txtHandle" /></td></tr>
					<tr><td>Active:</td><td><input type="checkbox" id="chkActive" name="chkActive" value="Y" checked /></td></tr>
					<tr><td colspan="2"><hr /></td></tr>
					<tr><td colspan="2"><input type="button" id="btnAdd" name="btnAdd" value="Add Influencer" onclick="addInfluencer();" /></td></tr>
				</form></table></td>
			</tr>
		</table>
	</body>
</html>

<?php require './_db_close.php'; ?>