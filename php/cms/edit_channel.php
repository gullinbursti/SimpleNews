<?php

// start the session engine
session_start();

if (!isset($_SESSION['login']))  
	header('Location: login.php');

require './_db_open.php';

if (isset($_POST['txtName'])) {
	
	$cat_name = $_POST['txtName'];
	$cat_info = $_POST['txtInfo'];
	$cat_active = "N";
	
	if ($_POST['chkActive'] == "Y")
		$cat_active = "Y"; 
	
	$query = 'UPDATE `tblChannels` SET ';
	$query .= '`title` = "'. $cat_name .'", ';
	$query .= '`info` = "'. $cat_info .'", ';
	$query .= '`active` = "'. $cat_active .'" ';
	$query .= 'WHERE `id` = "'. $_GET['id'] .'";';
	$result = mysql_query($query);
	
	header('Location: channels.php');
}

$query = 'SELECT * FROM `tblChannels` WHERE `id` = "'. $_GET['id'] .'"';
$result = mysql_query($query);
$row = mysql_fetch_row(mysql_query($query));
	
?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<meta http-equiv="Content-language" value="en" />
	</head>
	
	<script>
		function edit() {
			var chkbox = document.getElementById('chkActive');				
			if (chkbox.checked)
				chkbox.value = "Y";
				
			else
				chkbox.value = "N";
				
			document.frmEdit.submit();
		}
	</script>
	
	<body>
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
			<tr>
				<td width="320" valign="top"><?php include './nav.php'; ?></td>
				<td><form id="frmEdit" name="frmEdit" method="post" action="./edit_channel.php?id=<?php echo ($_GET['id']); ?>"><table cellspacing="0" cellpadding="0" border="0">
					<tr><td>Name:</td><td><input type="text" id="txtName" name="txtName" value="<?php echo($row[1]); ?>" /></td></tr>
					<tr><td>Info:</td><td><input type="text" id="txtInfo" name="txtInfo" value="<?php echo($row[2]); ?>" /></td></tr>
					<?php if ($row[3] == "Y") 
						echo ("<tr><td>Active:</td><td><input type=\"checkbox\" id=\"chkActive\" name=\"chkActive\" value=\"Y\" checked /></td></tr>");
					
					else
						echo ("<tr><td>Active:</td><td><input type=\"checkbox\" id=\"chkActive\" name=\"chkActive\" value=\"N\" /></td></tr>");
					?>
					<tr><td colspan="2"><hr /></td></tr>
					<tr><td colspan="2"><input type="button" id="btnAdd" name="btnAdd" value="Edit Channel" onclick="edit();" /></td></tr>
				</form></table></td>
			</tr>
		</table>
	</body>
</html>

<?php require './_db_close.php'; ?>