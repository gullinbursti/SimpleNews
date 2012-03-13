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
		
	$curl_handle = curl_init();
	curl_setopt($curl_handle, CURLOPT_URL, "https://api.twitter.com/1/users/lookup.json?screen_name=". $twitter_handle ."&include_entities=true");
	curl_setopt($curl_handle, CURLOPT_CONNECTTIMEOUT, 2);
	curl_setopt($curl_handle, CURLOPT_RETURNTRANSFER, 1);
	$tweet_json = curl_exec($curl_handle);
	curl_close($curl_handle);

	$tweet_obj = json_decode($tweet_json);
	foreach($tweet_obj as $key => $val)
		$twitter_name = $tweet_obj[$key]->name;
		
	
	$query = 'INSERT INTO `tblTwitterFollowers` (';
	$query .= '`id`, `handle`, `name`, `active`, `added`, `modified`) ';
	$query .= 'VALUES (NULL, "'. $twitter_handle .'", "'. $twitter_name .'", "'. $twitter_active .'", NOW(), CURRENT_TIMESTAMP);';
	$result = mysql_query($query);
	$twitter_id = mysql_insert_id();
	
	header('Location: followers.php');
}

$query = 'SELECT * FROM `tblTwitterFollowers` WHERE `id` = "'. $_GET['id'] .'";';
$row = mysql_fetch_row(mysql_query($query));

$query = 'SELECT * FROM `tblCategories`;';
$cat_result = mysql_query($query); 
	
?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<meta http-equiv="Content-language" value="en" />
	</head>
	
	<body>
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
			<tr>
				<td width="320"><?php include './nav.php'; ?></td>
				<td><form id="frmAdd" name="frmAdd" method="post" action="./edit_follower.php"><table cellspacing="0" cellpadding="0" border="0">
					<tr><td>Handle:</td><td>@<input type="text" id="txtHandle" name="txtHandle" value="<?php echo ($row[1]); ?>" disabled="disabled" /></td></tr>
					<tr><td>Name:</td><td><input type="text" id="txtName" name="txtName" value="<?php echo ($row[2]); ?>" disabled="disabled" /></td></tr>
					<tr><td>Categories:</td><td><?php while ($cat_row = mysql_fetch_array($cat_result, MYSQL_BOTH)) {
						echo ("<input type=\"checkbox\" id=\"chkCat_". $cat_row['id'] ."\" name=\"chkCat_". $cat_row['id'] ."\" />". $cat_row['title'] ."<br />");
					} ?></td></tr>
					<?php if ($row[3] == "Y")
						echo ("<tr><td>Active:</td><td><input type=\"checkbox\" id=\"chkActive\" name=\"chkActive\" value=\"Y\" checked /></td></tr>");
						
					else
						echo ("<tr><td>Active:</td><td><input type=\"checkbox\" id=\"chkActive\" name=\"chkActive\" value=\"N\" /></td></tr>");
					?>
					<tr><td colspan="2"><hr /></td></tr>
					<tr><td colspan="2"><input type="submit" id="btnEdit" name="btnEdit" value="Edit Follower" /></td></tr>
				</form></table></td>
			</tr>
		</table>
	</body>
</html>

<?php require './_db_close.php'; ?>