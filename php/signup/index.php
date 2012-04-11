<?php 

session_start();

require './_db_open.php'; 
require_once('twitteroauth/twitteroauth.php');
require_once('_oauth_cfg.php');

if (empty($_SESSION['access_token'])) {
	
	
} else {
	$access_token = $_SESSION['access_token'];
	$connection = new TwitterOAuth(CONSUMER_KEY, CONSUMER_SECRET, $access_token['oauth_token'], $access_token['oauth_token_secret']);
	
	if ($_POST['hidPostback'] == "true") {
		$follower_arr = array();
		
		if ($_POST['hidIDs'] != "")
			$follower_arr = explode('|', $_POST['hidIDs']);
			
		if ($_POST['txtAddlHandles'] != "") {
			$addlHandles_arr = explode(',', $_POST['txtAddlHandles']); 
			
			foreach ($addlHandles_arr as $twitter_handle) {
				$tweetLookup_obj = $connection->get('users/lookup', array('screen_name' => str_replace("@", "", $twitter_handle)));
				array_push($follower_arr, $tweetLookup_obj[0]->id_str);
			}       
		}
		
	    if ($_FILES['filCoverImage']['name'] != "") {
	        $upload_dir = $_SERVER['DOCUMENT_ROOT'] . str_replace(basename($_SERVER['PHP_SELF']), "", $_SERVER['PHP_SELF']) . "../app/images/";
			
			$uploadError_arr = array(
				1 => 'php.ini max file size exceeded', 
				2 => 'html form max file size exceeded', 
				3 => 'file upload was only partial', 
				4 => 'no file was attached'
			);
		
			// check for PHP's built-in uploading errors 
			($_FILES['filCoverImage']['error'] == 0) 
			    or error($uploadError_arr[$_FILES['filCoverImage']['error']], $_SERVER['SCRIPT_URI']); 
     
			// check that the file we are working on really was the subject of an HTTP upload 
			@is_uploaded_file($_FILES['filCoverImage']['tmp_name']) 
			    or error('not an HTTP upload', $_SERVER['SCRIPT_URI']); 
     
			// validation... since this is an image upload script we should run a check to make sure the uploaded file is in fact an image. Here is a simple check: getimagesize() returns false if the file tested is not an image. 
			@getimagesize($_FILES['filCoverImage']['tmp_name']) 
			    or error('only image uploads are allowed', $_SERVER['SCRIPT_URI']); 
        
			$file_name = implode('.', explode('.', $_FILES['filCoverImage']['name'], -1));
	        $file_ext = array_pop(explode('.', $_FILES['filCoverImage']['name']));

			// make a unique filename for the uploaded file and check it is not already taken... if it is already taken keep trying until we find a vacant one 
			// sample filename: 1140732936-filename.jpg 
			$now = time(); 
			//while (file_exists($upload_file = $upload_dir . $_FILES[$upload_field]['name'] ."-". $now)) { 
			while (file_exists($upload_file = $upload_dir . $file_name ."_". $now .".". $file_ext)) { 
			    $now++; 
			} 
       	
			$img_url = "http://". $_SERVER['HTTP_HOST'] ."/projs/simplenews/app/images/". array_pop(explode('/', $upload_file));   

        
			// now let's move the file to its final location and allocate the new filename to it 
			@move_uploaded_file($_FILES['filCoverImage']['tmp_name'], $upload_file) 
			    or error('receiving directory insufficient permission', $_SERVER['SCRIPT_URI']); 
        
		} else 
			$img_url = "http://dev.gullinbursti.cc/projs/simplenews/app/images/defaultListImage.jpg";

	    
		$tweetProfile_obj = $connection->get('account/verify_credentials');
		$query = 'SELECT `id` FROM `tblCurators` WHERE `handle` = "'. $tweetProfile_obj->screen_name .'";';
		$result = mysql_query($query);
		
		if (mysql_num_rows($result) == 0) {
			$query = 'INSERT INTO `tblCurators` (';
			$query .= '`id`, `handle`, `name`, `info`, `active`, `added`, `modified`) ';
			$query .= 'VALUES (NULL, "'. $tweetProfile_obj->screen_name .'", "'. $tweetProfile_obj->name .'", "'. $tweetProfile_obj->description .'", "Y", NOW(), CURRENT_TIMESTAMP);';
			$result = mysql_query($query);
			$curator_id = mysql_insert_id();
			
		} else {
			$row = mysql_fetch_row($result);
			$curator_id = $row[0];
		} 
	
		$query = 'INSERT INTO `tblLists` (';
		$query .= '`id`, `title`, `info`, `type_id`, `curator_id`, `thumb_url`, `image_url`, `active`, `added`, `modified`) ';
		$query .= 'VALUES (NULL, "'. $_POST['txtListName'] .'", "'. $_POST['txtTopic'] .'", 1, "'. $curator_id .'", "", "'. $img_url .'", "Y", NOW(), CURRENT_TIMESTAMP);';
		$result = mysql_query($query);
		$list_id = mysql_insert_id();
	
		foreach ($follower_arr as $follower_id) {
			$tweet_obj = $connection->get('users/lookup', array('user_id' => $follower_id));
			
			echo ($follower_id);
			print_r($tweet_obj);
		    
			//$twitter_handle = $tweet_obj[$key]->screen_name;
			//$twitter_name = $tweet_obj[$key]->name;
			//$twitter_info = $tweet_obj[$key]->description;
		
			$sendTweet_obj = $connection->post('statuses/update', array('status' => "@". $tweet_obj[0]->screen_name .", mentioned Test Tweet from PHP"));

			$query = 'SELECT `id` FROM `tblInfluencers` WHERE `handle` = "'. $tweet_obj[0]->screen_name .'";';
			$result = mysql_query($query);
	
			if (mysql_num_rows($result) == 0) {
				echo ($twitter_handle ." ". $twitter_name ." ". $avatar_url ." ". $twitter_info);
		
				$query = 'INSERT INTO `tblInfluencers` (';
				$query .= '`id`, `handle`, `name`, `avatar_url`, `description`, `active`, `added`, `modified`) ';
				$query .= 'VALUES (NULL, "'. $tweet_obj[0]->screen_name .'", "'. $tweet_obj[0]->name .'", "'. str_replace("_normal.", "_reasonably_small.", $tweet_obj[0]->profile_image_url) .'", "'. $tweet_obj[0]->description .'", "Y", NOW(), CURRENT_TIMESTAMP);';
				$result = mysql_query($query);
				$influencer_id = mysql_insert_id();
	
			} else {
				$row = mysql_fetch_row($result);
				$influencer_id = $row[0];
		
			}
	
			$query = 'INSERT INTO `tblListsInfluencers` (';
			$query .= '`list_id`, `influencer_id`) ';
			$query .= 'VALUES ("'. $list_id .'", "'. $influencer_id .'");';
			$result = mysql_query($query);
	
	
			$query = 'SELECT `id` FROM `tblArticles` WHERE `influencer_id` = "'. $influencer_id .'";';
			$article_result = mysql_query($query);
	
			while ($row = mysql_fetch_array($article_result, MYSQL_BOTH)) {
				$query = 'INSERT INTO `tblArticlesLists` (';
				$query .= '`article_id`, `list_id`) ';
				$query .= 'VALUES ("'. $row['id'] .'", "'. $list_id .'");';
				$result = mysql_query($query);	
			}
		}/**/
	}





	//print_r($tweet_obj);

	//$content = $connection->get('account/rate_limit_status');
	//echo "Current API hits remaining: {$content->remaining_hits}.";

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
}



function error($error, $location, $seconds = 5) { 
    header("Refresh: $seconds; URL=\"$location\""); 
    echo '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"'."\n". 
    '"http://www.w3.org/TR/html4/strict.dtd">'."\n\n". 
    '<html lang="en">'."\n". 
    '    <head>'."\n". 
    '        <meta http-equiv="content-type" content="text/html; charset=iso-8859-1">'."\n\n". 
    '        <link rel="stylesheet" type="text/css" href="stylesheet.css">'."\n\n". 
    '    <title>Upload error</title>'."\n\n". 
    '    </head>'."\n\n". 
    '    <body>'."\n\n". 
    '    <div id="Upload">'."\n\n". 
    '        <h1>Upload failure</h1>'."\n\n". 
    '        <p>An error has occured: '."\n\n". 
    '        <span class="red">' . $error . '...</span>'."\n\n". 
    '         The upload form is reloading</p>'."\n\n". 
    '     </div>'."\n\n". 
    '</html>'; 
    exit; 
} // end error handler 

?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<meta http-equiv="Content-language" value="en" />
		<script type="text/javascript">
			function submitList() {
				var tot = <?php echo($follower_tot); ?>;
				var followerIDs = "";
				var cnt = 0;

				for (var i=0; i<tot; i++) {
					var chkbox = document.getElementById('chkFollower_' + i);
					
					if (chkbox.checked) {
						var follower_id = chkbox.value;
					    
						if (cnt > 0)
							followerIDs += "|";
						
						followerIDs += follower_id;
						cnt++;
					}
				}
				
				document.frmAddList.hidIDs.value = followerIDs;
				document.frmAddList.hidPostback.value = "true";
				document.frmAddList.submit();
			}
		</script>
	</head>
	
	<body>
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
			<tr>
				<td width="320" valign="top"></td>
				<td><table cellspacing="0" cellpadding="0" border="0">
					<tr><td colspan="2"><a href="./redirect.php"><img src="./images/lighter.png" alt="Sign in with Twitter"/></a></td></tr>
				</table></td>
			</tr>
		</table>
		
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
			<tr>
				<td width="320" valign="top"></td>
				<td><form id="frmAddList" name="frmAddList" method="post" enctype="multipart/form-data" action="./index.php"><table cellspacing="0" cellpadding="0" border="0">
					<tr><td colspan="2"><hr /></td></tr>
					<tr><td>List Name:</td><td><input type="text" id="txtListName" name="txtListName" /></td></tr>
					<tr><td>Topic:</td><td><input type="text" id="txtTopic" name="txtTopic" /></td></tr>
					<tr><td>Cover Photo:</td><td><input type="file" id="filCoverImage" name="filCoverImage" /></td></tr>
					<tr><td>Add'l Influencers:</td><td><textarea id="txtAddlHandles" name="txtAddlHandles" cols="30" rows="5"></textarea></td></tr>
					<tr><td colspan="2"><hr /></td></tr>
					<tr><td colspan="2"><table cellspacing="0" cellpadding="0" border="1"><?php
						$col = 0;
						$row = 0;
						$tot = 0;
						foreach ($follower_arr as $key => $val) {
							$pre_html = "<td>";
							$chkbox_html = "<input type=\"checkbox\" id=\"chkFollower_". $tot ."\" name=\"chkFollower_". $tot ."\" value=\"". $follower_arr[$key]['id'] ."\" />";
							$handle_html = "<a href=\"https://twitter.com/#!/". $follower_arr[$key]['handle'] ."\" target=\"_blank\">@". $follower_arr[$key]['handle'] ."</a>";
							$avatar_html = "<img src=\"". $follower_arr[$key]['avatar'] ."\" alt=\"". $follower_arr[$key]['handle'] ."\" />";
							$post_html = "</td>";
							
							echo ($pre_html . $chkbox_html . $handle_html ."<br />". $avatar_html . $post_html);
							
							$col++;
							if ($col == 5) {
								$row++;
								$col = 0;
								
								echo ("</tr><tr>");
							}
							
							$tot++;
						}
						echo ("</tr>");
						
					?></table></td></tr>
					<tr><td><input type="hidden" id="hidIDs" name="hidIDs" value="" /><input type="hidden" id="hidPostback" name="hidPostback" value="false" /></td></tr>
					<tr><td><input type="button" id="btnAdd" name="btnAdd" value="Add My List" onclick="submitList();" /></td></tr>
				</table></form></td>
			</tr>
		</table>
	</body>
</html>

<?php require './_db_close.php'; ?>