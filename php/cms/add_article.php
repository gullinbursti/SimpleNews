<?php

// start the session engine
session_start();

if (!isset($_SESSION['login']))  
	header('Location: login.php');  
	

// make the connection
$db_conn = mysql_connect('internal-db.s41232.gridserver.com', 'db41232_sn_usr', 'dope911t') or die("Could not connect to database.");

// select the proper db
mysql_select_db('db41232_simplenews') or die("Could not select database.");

// get the current date / time from mysql
$ts_result = mysql_query("SELECT NOW();") or die("Couldn't get the date from MySQL");
$row = mysql_fetch_row($ts_result);
$sql_time = $row[0];


$tweet_id = $_GET['tID'];	

$curl_handle = curl_init();
curl_setopt($curl_handle, CURLOPT_URL, "https://api.twitter.com/1/statuses/show.json?id=". $tweet_id ."&include_entities=true");
curl_setopt($curl_handle, CURLOPT_CONNECTTIMEOUT, 2);
curl_setopt($curl_handle, CURLOPT_RETURNTRANSFER, 1);
$tweet_json = curl_exec($curl_handle);
curl_close($curl_handle);

$tweet_obj = json_decode("[". $tweet_json ."]");

foreach($tweet_obj as $key => $val)
	$tweet_msg = $tweet_obj[$key]->text;	

$tweet_msg = eregi_replace('(((f|ht){1}tp://)[-a-zA-Z0-9@:%_\+.~#?&//=]+)', '<a href="\\1" target="_blank">\\1</a>', $tweet_msg); 
$tweet_msg = eregi_replace('([[:space:]()[{}])(www.[-a-zA-Z0-9@:%_\+.~#?&//=]+)', '\\1<a href="http://\\2">\\2</a>', $tweet_msg); 
$tweet_msg = eregi_replace('([_\.0-9a-z-]+@([0-9a-z][0-9a-z-]+\.)+[a-z]{2,3})', '<a href="mailto:\\1">\\1</a>', $tweet_msg);
	
?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<meta http-equiv="Content-language" value="en" />
		<script> 
		</script>
	</head>
	
	<body>
		<table cellpadding="0" cellspacing="0" border="0">
			<tr>
				<td width="320"><?php include './nav.php'; ?></td>
				<td><table cellspacing="0" cellpadding="0" border="0">
					<tr><td colspan="2"></td></tr>
					<tr><td colspan="2"><?php foreach($tweet_obj as $key => $val) { 
						echo ("Message: ". $tweet_msg ."<br />");
						echo ("Created: ". $tweet_obj[$key]->created_at ."<br />");
						echo ("Retweet Count: ". $tweet_obj[$key]->retweet_count ."<br />");
					} ?></td></tr>
					<tr><td colspan="2"><hr /></td></tr>
					<tr><td>Article Source:</td><td><input type="text" id="txtArticleSource" name="txtArticleSource" size="40" /></td></tr>
					<tr><td>Article URL:</td><td><input type="text" id="txtArticleURL" name="txtArticleURL" size="80" /></td></tr>
					<tr><td>Image URL:</td><td><input type="text" id="txtImageURL_1" name="txtImageURL_1" size="80" /></td></tr>
					<tr><td>Video URL:</td><td><input type="text" id="txtImageURL_1" name="txtImageURL_1" size="80" /></td></tr>
					<tr><td colspan="2"><hr /></td></tr>
					<tr><td colspan="2"><input type="button" id="idSubmit" name="btnSubmit" value="Add Article" onclick="submitArticle()" /></td></tr>
				</table></td>
			</tr>
		</table>
	</body>
</html> 

<?php require './_db_close.php'; ?>