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
	
	$query = 'INSERT INTO `tblCategories` (';
	$query .= '`id`, `title`, `info`, `active`, `added`, `modified`) ';
	$query .= 'VALUES (NULL, "'. $cat_name .'", "'. $cat_info .'", "'. $cat_active .'", NOW(), CURRENT_TIMESTAMP);';
	$result = mysql_query($query);
	$cat_id = mysql_insert_id();
	
	header('Location: categories.php');
}
	
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
				<td><form id="frmAdd" name="frmAdd" method="post" action="./add_category.php"><table cellspacing="0" cellpadding="0" border="0">
					<tr><td>Name:</td><td><input type="text" id="txtName" name="txtName" /></td></tr>
					<tr><td>Info:</td><td><input type="text" id="txtInfo" name="txtInfo" /></td></tr>
					<tr><td>Active:</td><td><input type="checkbox" id="chkActive" name="chkActive" value="Y" checked /></td></tr>
					<tr><td colspan="2"><hr /></td></tr>
					<tr><td colspan="2"><input type="submit" id="btnAdd" name="btnAdd" value="Add Category" /></td></tr>
				</form></table></td>
			</tr>
		</table>
	</body>
</html>

<?php require './_db_close.php'; ?>