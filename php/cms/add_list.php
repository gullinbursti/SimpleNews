<?php

// start the session engine
session_start();

if (!isset($_SESSION['login']))  
	header('Location: login.php');

require './_db_open.php';

require_once('twitteroauth/twitteroauth.php');
require_once('_oauth_cfg.php');
require_once('_twitter_conn.php');

if (isset($_GET['a'])) {
	$curator_arr = parseIDs($_POST['txtCurators']);
	$follower_arr = parseIDs($_POST['txtInfluencers']);
	$img_url = uploadCoverImage();	
	
	$query = 'INSERT INTO `tblLists` (';
	$query .= '`id`, `title`, `info`, `type_id`, `thumb_url`, `image_url`, `enc_name`, `active`, `added`, `modified`) ';
	$query .= 'VALUES (NULL, "'. $_POST['txtTitle'] .'", "'. $_POST['txtInfo'] .'", 3, "", "'. $img_url .'", "'. base64_encode($_POST['txtTitle']) .'", "Y", NOW(), CURRENT_TIMESTAMP);';
	$result = mysql_query($query);
	$list_id = mysql_insert_id();
	
	foreach ($curator_arr as $twitter_id) {
		$tweet_obj = $connection->get('users/lookup', array('user_id' => $twitter_id));
		$query = 'SELECT `id` FROM `tblCurators` WHERE `handle` = "'. $tweet_obj[0]->screen_name .'";';
		$result = mysql_query($query);
		
		if (mysql_num_rows($result) == 0) {
			$query = 'INSERT INTO `tblCurators` (';
			$query .= '`id`, `handle`, `name`, `info`, `active`, `added`, `modified`) ';
			$query .= 'VALUES (NULL, "'. $tweet_obj[0]->screen_name .'", "'. $tweet_obj[0]->name .'", "'. $tweet_obj[0]->description .'", "Y", NOW(), CURRENT_TIMESTAMP);';
			$result = mysql_query($query);
			$curator_id = mysql_insert_id();
		
		} else {
			$row = mysql_fetch_row($result);
			$curator_id = $row[0];
		}
		
		$query = 'INSERT INTO `tblListsCurators` (';
		$query .= '`list_id`, `curator_id`) ';
		$query .= 'VALUES ("'. $list_id .'", "'. $curator_id .'");';
		$result = mysql_query($query); 
	}
    

	foreach ($follower_arr as $twitter_id) {
		$tweet_obj = $connection->get('users/lookup', array('user_id' => $twitter_id));
		$query = 'SELECT `id` FROM `tblInfluencers` WHERE `handle` = "'. $tweet_obj[0]->screen_name .'";';
		$result = mysql_query($query);

		if (mysql_num_rows($result) == 0) {
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
	}/**/
		
	//header('Location: lists.php');
}


function parseIDs($csvIDs) {
	$id_arr = array();
	$connection = new TwitterOAuth(CONSUMER_KEY, CONSUMER_SECRET, $_SESSION['access_token']['oauth_token'], $_SESSION['access_token']['oauth_token_secret']);
	
	if ($csvIDs != "") {
		$handles_arr = explode(',', $csvIDs); 
		
		foreach ($handles_arr as $twitter_handle) {
			$tweetLookup_obj = $connection->get('users/lookup', array('screen_name' => str_replace("@", "", $twitter_handle)));
			array_push($id_arr, $tweetLookup_obj[0]->id_str);
		}       
	}
	
	return ($id_arr);
}


function uploadCoverImage() {
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
      	
		// now let's move the file to its final location and allocate the new filename to it 
		@move_uploaded_file($_FILES['filCoverImage']['tmp_name'], $upload_file) 
		    or error('receiving directory insufficient permission', $_SERVER['SCRIPT_URI']); 
		
		return ("http://". $_SERVER['HTTP_HOST'] ."/projs/simplenews/app/images/". array_pop(explode('/', $upload_file)));
       
	} else 
		return ("http://dev.gullinbursti.cc/projs/simplenews/app/images/defaultListImage.jpg");
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
	</head>
	
	<body>
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
			<tr>
				<td width="320" valign="top"><?php include './nav.php'; ?></td>
				<td><form id="frmAdd" name="frmAdd" method="post" enctype="multipart/form-data" action="./add_list.php?a=0"><table cellspacing="0" cellpadding="0" border="0">
					<tr><td>Name:</td><td><input type="text" id="txtTitle" name="txtTitle" /></td></tr>
					<tr><td>Info:</td><td><input type="text" id="txtInfo" name="txtInfo" size="60" /></td></tr>
					<tr><td>Curators:</td><td><textarea id="txtCurators" name="txtCurators" rows="3" cols="40"></textarea></td></tr>
					<tr><td>Influencers:</td><td><textarea id="txtInfluencers" name="txtInfluencers" rows="3" cols="40"></textarea></td></tr>
					<tr><td>Cover Photo:</td><td><input type="file" id="filCoverImage" name="filCoverImage" /></td></tr>
					<tr><td colspan="2"><hr /></td></tr>
					<tr><td colspan="2"><input type="submit" id="btnAdd" name="btnAdd" value="Add List" /></td></tr>
				</form></table></td>
			</tr>
		</table>
	</body>
</html>

<?php require './_db_close.php'; ?>