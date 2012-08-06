<?php

// start up session
session_start();

// login isn't set, redirect
if (!isset($_SESSION['login']))
	header('Location: login.php');
	
else {
	header('Location: main.php');
}
	
	
?>