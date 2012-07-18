<?php 

session_start();

require './_db_open.php'; 
require_once('twitteroauth.php');
require_once('_oauth_cfg.php');
require_once('TwitterSearch.php');
// /var/lib/php/session/

$access_token = $_SESSION['access_token'];
$connection = new TwitterOAuth(CONSUMER_KEY, CONSUMER_SECRET, $access_token['oauth_token'], $access_token['oauth_token_secret']);
$tweetProfile_obj = $connection->get('account/verify_credentials');

/*
$friend_arr = array();
$tweetLookup_obj = $connection->get('friends/ids', array('screen_name' => 'andvari'));	
foreach ($tweetLookup_obj->ids as $key => $val) {
	print_r ("IDS:[". $val ."]");
}
*/

?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<meta http-equiv="Content-language" value="en" />
	</head>
	
	<body>
		<?php if (empty($_SESSION['access_token'])) {
			echo ("<a href=\"./redirect.php\">Sign in</a>");
		
		} else {
			echo ("Signed into Twitter as @". $tweetProfile_obj->screen_name ." <a href=\"./signout.php\">Signout</a>");
		} ?><hr />   
	</body>
</html>

<?php require './_db_close.php'; ?>



<?php
	//print_r($tweet_obj);

	//$content = $connection->get('account/rate_limit_status');
	//echo "Current API hits remaining: {$content->remaining_hits}.";

/*
	$tweet_obj = $connection->get('friends/ids', array('screen_name' => $handle));
	$follower_tot = count($tweet_obj->ids);

	$id_arr = array();
	foreach ($tweet_obj->ids as $key => $val)
		array_push($id_arr, $val);
	

	$paged_arr = array_chunk($id_arr, 100);
	$follower_arr = array();

	for ($i=0; $i<count($paged_arr); $i++) {
		$id_str = "";
	
		foreach ($paged_arr[$i] as $val)
			$id_str .= $val .",";	
	
		$id_str = substr_replace($id_str, "", -1);
		$tweet_obj = $connection->get('users/lookup', array('user_id' => $id_str));
	
		foreach ($tweet_obj as $key => $val) {
			array_push($follower_arr, array(
				"id" => $tweet_obj[$key]->id_str, 
				"name" => $tweet_obj[$key]->name, 
				"handle" => $tweet_obj[$key]->screen_name,  
				"avatar" => str_replace("_normal.", "_reasonably_small.", $tweet_obj[$key]->profile_image_url), 
				"info" => $tweet_obj[$key]->description
			));
		}
	}
*/	
?>