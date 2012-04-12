<?php

// start the session engine
session_start();

if (!isset($_SESSION['login']))  
	header('Location: login.php');

require './_db_open.php';

if (isset($_GET['id'])) {
	
	$query = 'DELETE FROM `tblArticles` WHERE `follower_id` = "'. $_GET['id'] .'";';
	$result = mysql_query($query);
	
	$query = 'DELETE FROM `tblFollowers` WHERE `id` = "'. $_GET['id'] .'";';
	$result = mysql_query($query);
	
	header('Location: followers.php');
}
	
?>


<?php require './_db_close.php'; ?>