<?php

if ($db_conn) {
	mysql_close($db_conn);
	$db_conn = null;
}
	
?>