<?php

// start the session engine
session_start();

if (!isset($_SESSION['login']))  
	header('Location: login.php');  
	

require './_db_open.php';


$handle = $_GET['handle'];	

$curl_handle = curl_init();
curl_setopt($curl_handle, CURLOPT_URL, "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=". $handle ."&count=2");
curl_setopt($curl_handle, CURLOPT_CONNECTTIMEOUT, 2);
curl_setopt($curl_handle, CURLOPT_RETURNTRANSFER, 1);
$timeline_json = curl_exec($curl_handle);
curl_close($curl_handle);

//echo ($timeline_json);

$tweet_obj = json_decode($timeline_json);

/*
foreach($tweet_obj as $key => $val) {
	//echo "Message number: $var <br/>";    
    //echo "Name: ". $obj[$var]->user->name ."<br/>";
    //echo "Handle: ". $obj[$var]->user->screen_name ."<br/>";        
    echo "Message: ". $tweet_obj[$key]->text ."<br />";        
    echo "Created: ". $tweet_obj[$key]->created_at ."<br/>";                    
    //echo "URL: ". $obj[$var]->user->url ."<br/>";
    //echo "Location: ". $obj[$var]->user->location ."<br/>";       
    echo "<br/>";
}
*/
	
?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<meta http-equiv="Content-language" value="en" />
		<script> 
			function useTweet(tweet_id) {
				location.href = "./add_article.php?tID=" + tweet_id;
			}
		</script>
	</head>
	
	<body>
		<table cellpadding="0" cellspacing="0" border="0">
			<tr>
				<td width="320"><?php include './nav.php'; ?></td>
				<td><table cellspacing="0"cellpadding="0" border="0">
					<tr><td></td></tr>
					<?php foreach($tweet_obj as $key => $val) {
						echo ("<tr><td>");
						echo ("Message: ". $tweet_obj[$key]->text ."<br />");        
						echo ("Created: ". $tweet_obj[$key]->created_at ."<br/><br />");
						echo ("<input type=\"button\" id=\"btnTweet_". $tweet_obj[$key]->id_str ."\" name=\"btnTweet_". $tweet_obj[$key]->id_str ."\" value=\"Make Article\" onclick=\"useTweet('".$tweet_obj[$key]->id_str  ."')\" /><br />");                    
						echo ("</td></tr><tr><td><hr /></td></tr>");
					} ?>
					
					<tr><td>						
					</td></tr>
				</table></td>
			</tr>
		</table>
	</body>
</html>

<?php require './_db_close.php'; ?>