<?php

// make the connection
$db_conn = mysql_connect('localhost', 'db41232_sn_usr', 'dope911t') or die("Could not connect to database.");
//$db_conn = mysql_connect('internal-db.s41232.gridserver.com', 'db41232_sn_usr', 'dope911t') or die("Could not connect to database.");

// select the proper db
mysql_select_db('assembly2') or die("Could not select database.");
//mysql_select_db('db41232_assembly') or die("Could not select database.");

// get the current date / time from mysql
$ts_result = mysql_query("SELECT NOW();") or die("Couldn't get the date from MySQL");
$row = mysql_fetch_row($ts_result);
$sql_time = $row[0];
	
?>