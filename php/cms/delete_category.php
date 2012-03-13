<?php

// start the session engine
session_start();

if (!isset($_SESSION['login']))  
	header('Location: login.php');

require './_db_open.php';

if (isset($_GET['id'])) {
	
	$query = 'DELETE FROM `tblFollowersCategories` WHERE `category_id` = "'. $_GET['id'] .'";';
	$result = mysql_query($query);
	
	$query = 'DELETE FROM `tblCategories` WHERE `id` = "'. $_GET['id'] .'";';
	$result = mysql_query($query);

	
	header('Location: categories.php');
}
	
?>


<?php require './_db_close.php'; ?>