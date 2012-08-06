<?php

// start the session engine
session_start();

if (isset($_POST['txtLogin']) && isset($_POST['txtPassword'])) {	
	if ($_POST['txtLogin'] == "assembly-admin" && $_POST['txtPassword'] == "broA8hiE") {
		$_SESSION['login']['verified'] = "YES";
		header('Location: main.php');
		
		echo ("txtLogin:[". $_POST['txtLogin'] ."] txtPassword:[" . $_POST['txtPassword'] . "]");
	}		
}
	
?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<meta http-equiv="Content-language" value="en" />
	</head>
	
	<body>
		<form id="frmLogin" name="frmLogin" method="post" action="./login.php">
			<table cellpadding="0" cellspacing="0" border="0">
				<tr><td>Username:</td><td><input type="text" id="txtLogin" name="txtLogin" /></td></tr>
				<tr><td>Password:</td><td><input type="password" id="txtPassword" name="txtPassword" /></td></tr>
				<tr><td colspan="2"><input type="submit" id="btnSubmit" name="btnSubmit" /></td></tr>
			</table> 
		</form>
	</body>
</html>