<?php

// start the session engine
session_start();

if (!isset($_SESSION['login']))  
	header('Location: login.php');  
	

require './_db_open.php';

$follower_id = $_GET['id'];
$handle = $_GET['handle'];


require_once('twitteroauth/twitteroauth.php');
require_once('_oauth_cfg.php');
require_once('_twitter_conn.php');

$tweet_obj = $connection->get('statuses/user_timeline', array('screen_name' => $handle));
//print_r ($tweet_obj);	 

//echo ($tweet_obj->profile_image_url);


?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<meta http-equiv="Content-language" value="en" />
		<script> 
			function useTweet(tweet_id) {
				location.href = "./add_article.php?fID=<?php echo ($follower_id); ?>&handle=<?php echo ($handle); ?>&tID=" + tweet_id;
			}
		</script>
	</head>
	
	<body>
		<table cellpadding="0" cellspacing="0" border="0">
			<tr>
				<td width="320" valign="top"><?php include './nav.php'; ?></td>
				<td><table cellspacing="0"cellpadding="0" border="0">
					<tr><td></td></tr>
					<?php foreach($tweet_obj as $key => $val) {
						$tweet_msg = eregi_replace('(((f|ht){1}tp://)[-a-zA-Z0-9@:%_\+.~#?&//=]+)', '<a href="\\1" target="_blank">\\1</a>', $tweet_obj[$key]->text); 
						$tweet_msg = eregi_replace('([[:space:]()[{}])(www.[-a-zA-Z0-9@:%_\+.~#?&//=]+)', '\\1<a href="http://\\2">\\2</a>', $tweet_msg); 
						$tweet_msg = eregi_replace('([_\.0-9a-z-]+@([0-9a-z][0-9a-z-]+\.)+[a-z]{2,3})', '<a href="mailto:\\1">\\1</a>', $tweet_msg);
						$tweet_msg = eregi_replace('@([_\.0-9a-z-]+)', '<a href="https://twitter.com/#!/\\1" target="_blank">@\\1</a>', $tweet_msg);
						
						echo ("<tr><td>");
						echo ("Message: ". $tweet_msg ."<br />");        
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