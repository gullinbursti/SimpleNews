<?php

// start the session engine
session_start();

if (!isset($_SESSION['login']))  
	header('Location: login.php');

require './_db_open.php';

if (isset($_GET['a'])) {
	$twitter_info = $_POST['txtBlurb'];
	
	$twitter_active = "N";
	if ($_POST['chkActive'] == "Y")
		$twitter_active = "Y";
		
	$query = 'UPDATE `tblInfluencers` SET ';
	$query .= '`description` = "'. $twitter_info .'", ';
	$query .= '`active` = "'. $twitter_active .'" ';
	$query .= 'WHERE `id` = "'. $_GET['id'] .'"';
	$result = mysql_query($query);
	
	header('Location: influencers.php');
}

$query = 'SELECT * FROM `tblInfluencers` WHERE `id` = "'. $_GET['id'] .'";';
$row = mysql_fetch_row(mysql_query($query));
	
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
				<td><form id="frmEdit" name="frmEdit" method="post" action="./edit_influencer.php?a=0&id=<?php echo ($row[0]); ?>"><table cellspacing="0" cellpadding="0" border="0">
					<tr><td colspan="2"><img src="<?php echo ($row[3]); ?>" /></td></tr>
					<tr><td>Handle:</td><td>@<input type="text" id="txtHandle" name="txtHandle" value="<?php echo ($row[1]); ?>" disabled="disabled" /></td></tr>
					<tr><td>Name:</td><td><input type="text" id="txtName" name="txtName" value="<?php echo ($row[2]); ?>" disabled="disabled" /></td></tr>
					<tr><td>Info:</td><td><textarea id="txtBlurb" name="txtBlurb" rows="4" cols="40"><?php echo ($row[4]); ?></textarea></td></tr>
					<?php if ($row[5] == "Y")
						echo ("<tr><td>Active:</td><td><input type=\"checkbox\" id=\"chkActive\" name=\"chkActive\" value=\"Y\" checked /></td></tr>");
						
					else
						echo ("<tr><td>Active:</td><td><input type=\"checkbox\" id=\"chkActive\" name=\"chkActive\" value=\"N\" /></td></tr>");
					?><tr><td colspan="2"><hr /></td></tr>
					<tr><td><input type="button" id="btnCancel" name="btnCancel" value="Cancel" onclick="history.back();" /></td><td><input type="button" id="btnEdit" name="btnEdit" value="Edit Influencer" onclick="edit();" /></td></tr>
				</form></table></td>
			</tr>
		</table>
	</body>
</html>

<?php require './_db_close.php'; ?>