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
	
	foreach($tweet_obj as $key => $val)
		$twitter_name = $tweet_obj[$key]->name;
		$twitter_avatar = $tweet_obj[$key]->profile_image_url;
		$twitter_descript = $tweet_obj[$key]->description;
	
	$query = 'INSERT INTO `tblTwitterFollowers` (';
	$query .= '`id`, `handle`, `name`, `avatar_url`, `description`, `active`, `added`, `modified`) ';
	$query .= 'VALUES (NULL, "'. $twitter_handle .'", "'. $twitter_name .'", "'. $twitter_avatar .'", "'. $twitter_descript .'", "'. $twitter_active .'", NOW(), CURRENT_TIMESTAMP);';
	
	$result = mysql_query($query);
	$twitter_id = mysql_insert_id();
	
	$catID_arr = explode("|", $_POST['hidIDs']);

	for ($i=0; $i<count($catID_arr); $i++) {
		$cat_id = $catID_arr[$i];
		
		$query = 'INSERT INTO `tblFollowersCategories` (';
		$query .= '`follower_id`, `category_id`) ';
		$query .= 'VALUES ("'. $twitter_id .'", "'. $cat_id .'");';
		$result = mysql_query($query);
	}
	
	header('Location: followers.php');
}

$query = 'SELECT * FROM `tblCategories`;';
$result = mysql_query($query);

$cat_tot = 0;
while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
	$cat_tot++;
}

?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<meta http-equiv="Content-language" value="en" />
		
		<script type="text/javascript">
			function addFollower () {
				var tot = <?php echo ($cat_tot); ?>;
				var catIDs = "";
				var cnt = 0;    
				
				for (var i=0; i<tot; i++) {
					var chkbox = document.getElementById('chkCat_'+i);
					
					if (chkbox.checked) {
						var cat_id = chkbox.name.substring(7);
						
						if (cnt > 0)
							catIDs += "|";
						
						catIDs += cat_id;
						cnt++;
					}
				}
				
				document.frmAdd.hidIDs.value = catIDs;
				document.frmAdd.submit();
			}
		</script>
	</head>
	
	<body>
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
			<tr>
				<td width="320" valign="top"><?php include './nav.php'; ?></td>
				<td><form id="frmAdd" name="frmAdd" method="post" action="./add_follower.php"><table cellspacing="0" cellpadding="0" border="0">
					<tr><td>Handle:</td><td>@<input type="text" id="txtHandle" name="txtHandle" /></td></tr>
					<tr><td>Categories:</td><td><?php
					 	$query = 'SELECT * FROM `tblCategories`;';
						$result = mysql_query($query); 

						$cnt = 0;
						while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
							echo ("<input type=\"checkbox\" id=\"chkCat_". $cnt ."\" name=\"chkCat_". $row['id'] ."\" />". $row['title'] ."<br />");
							$cnt++;
						}
					?><input type="hidden" id="hidIDs" name="hidIDs" value="" /></td></tr>
					<tr><td>Active:</td><td><input type="checkbox" id="chkActive" name="chkActive" value="Y" checked /></td></tr>
					<tr><td colspan="2"><hr /></td></tr>
					<tr><td colspan="2"><input type="button" id="btnAdd" name="btnAdd" value="Add Follower" onclick="addFollower();" /></td></tr>
				</form></table></td>
			</tr>
		</table>
	</body>
</html>

<?php require './_db_close.php'; ?>