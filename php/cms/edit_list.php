<?php

// start the session engine
session_start();

if (!isset($_SESSION['login']))  
	header('Location: login.php');

require './_db_open.php';

require_once('twitteroauth/twitteroauth.php');
require_once('_oauth_cfg.php');
require_once('_twitter_conn.php');

$query = 'SELECT * FROM `tblLists` WHERE `id` = "'. $_GET['id'] .'";';
$row = mysql_fetch_row(mysql_query($query));

$query = 'SELECT * FROM `tblListTypes`;';
$type_result = mysql_query($query);
 

if (isset($_GET['a'])) {
	$twitter_info = $_POST['txtBlurb'];
	$removeCurator_arr = explode('|', $_POST['hidCuratorIDs']);
	$removeInfluencer_arr = explode('|', $_POST['hidInfluencerIDs']);
	
	$img_url = uploadCoverImage($_SERVER['DOCUMENT_ROOT'] . str_replace(basename($_SERVER['PHP_SELF']), "", $_SERVER['PHP_SELF']) ."../app/images/". array_pop(explode('/', $row[5])));
	
	$addCurator_arr = array();
	if ($_POST['txtAddCurators'] != "")
		$addCurator_arr = explode(',', str_replace('@', '', $_POST['txtAddCurators']));
	
	$addInfluencer_arr = array();	
	if ($_POST['txtAddInfluencers'] != "")	
		$addInfluencer_arr = explode(',', str_replace('@', '', $_POST['txtAddInfluencers']));
	
	foreach ($removeCurator_arr as $val) {
		$query = 'SELECT `id` FROM `tblCurators` WHERE `handle` = "'. $val .'";';
		$curator_row = mysql_fetch_row(mysql_query($query));
		
		$query = 'DELETE FROM `tblListsCurators` WHERE `list_id` ='. $_GET['id'] .' AND `curator_id` ='. $curator_row[0] .';';
		$curator_result = mysql_query($query);
	}
	
	foreach ($removeInfluencer_arr as $val) {
		$query = 'SELECT `id` FROM `tblInfluencers` WHERE `handle` = "'. $val .'";';
		$influencer_row = mysql_fetch_row(mysql_query($query));
		
		$query = 'DELETE FROM `tblListsInfluencers` WHERE `list_id` ='. $_GET['id'] .' AND `influencer_id` ='. $influencer_row[0] .';';
		$influencer_result = mysql_query($query);
	}
	
	foreach ($addCurator_arr as $val) {
		$tweet_obj = $connection->get('users/lookup', array('screen_name' => $val));
		
		if (!$tweet_obj->errors) {			                      
			$query = 'SELECT `id` FROM `tblCurators` WHERE `handle` = "'. $tweet_obj[0]->screen_name .'";';
			$result = mysql_query($query);
		
			if (mysql_num_rows($result) == 0) {
				$query = 'INSERT INTO `tblCurators` (';
				$query .= '`id`, `handle`, `name`, `info`, `active`, `added`, `modified`) ';
				$query .= 'VALUES (NULL, "'. $tweet_obj[0]->screen_name .'", "'. $tweet_obj[0]->name .'", "'. $tweet_obj[0]->description .'", "Y", NOW(), CURRENT_TIMESTAMP);';
				$result = mysql_query($query);
				$curator_id = mysql_insert_id();
		
			} else {
				$curator_row = mysql_fetch_row($result);
				$curator_id = $curator_row[0];
			}
		
			$query = 'INSERT INTO `tblListsCurators` (';
			$query .= '`list_id`, `curator_id`) ';
			$query .= 'VALUES ("'. $_GET['id'] .'", "'. $curator_id .'");';
			$result = mysql_query($query);
		} 
	}
	
	foreach ($addInfluencer_arr as $val) {
		$tweet_obj = $connection->get('users/lookup', array('screen_name' => $val));
		
		if (!$tweet_obj->errors) {
			$query = 'SELECT `id` FROM `tblInfluencers` WHERE `handle` = "'. $tweet_obj[0]->screen_name .'";';
			$result = mysql_query($query);

			if (mysql_num_rows($result) == 0) {
				$query = 'INSERT INTO `tblInfluencers` (';
				$query .= '`id`, `handle`, `name`, `avatar_url`, `description`, `active`, `added`, `modified`) ';
				$query .= 'VALUES (NULL, "'. $tweet_obj[0]->screen_name .'", "'. $tweet_obj[0]->name .'", "'. str_replace("_normal.", "_reasonably_small.", $tweet_obj[0]->profile_image_url) .'", "'. $tweet_obj[0]->description .'", "Y", NOW(), CURRENT_TIMESTAMP);';
				$result = mysql_query($query);
				$influencer_id = mysql_insert_id();

			} else {
				$influencer_row = mysql_fetch_row($result);
				$influencer_id = $influencer_row[0];
	
			}

			$query = 'INSERT INTO `tblListsInfluencers` (';
			$query .= '`list_id`, `influencer_id`) ';
			$query .= 'VALUES ("'. $_GET['id'] .'", "'. $influencer_id .'");';
			$result = mysql_query($query);
		}
	}/**/
	
	
	//print_r($removeInfluencer_arr);
	//print_r($addCurator_arr);
	//print_r($addInfluencer_arr);
	
		
	$query = 'UPDATE `tblLists` SET ';
	$query .= '`title` = "'. $_POST['txtTitle'] .'", ';
	$query .= '`info` = "'. $_POST['txtInfo'] .'", ';
	$query .= '`type_id` ='. $_POST['selType'] .', '; 
	$query .= '`image_url` = "'. $img_url .'", '; 
	$query .= '`enc_name` = "'. base64_encode($_POST['txtTitle']) .'" ';
	$query .= 'WHERE `id` ='. $_GET['id'] .';';
	$result = mysql_query($query);
	
	header('Location: lists.php');
}

$query = 'SELECT `tblCurators`.`id`, `tblCurators`.`handle` FROM `tblCurators` INNER JOIN `tblListsCurators` ON `tblCurators`.`id` = `tblListsCurators`.`curator_id` WHERE `tblListsCurators`.`list_id` ='. $_GET['id'] .';';
$curator_result = mysql_query($query);

$handles_str = "";
while ($curator_row = mysql_fetch_array($curator_result, MYSQL_BOTH)) {
	$handles_str .= $curator_row['handle'] .",";
}

$tweetLookup_obj = $connection->get('users/lookup', array('screen_name' => substr_replace($handles_str, "", -1)));
$curator_arr = array();
foreach ($tweetLookup_obj as $key => $val) {
	array_push($curator_arr, array(
		"twitterID" => $tweetLookup_obj[$key]->id_str, 
		"name" => $tweetLookup_obj[$key]->name, 
		"handle" => $tweetLookup_obj[$key]->screen_name,  
		"avatar" => $tweetLookup_obj[$key]->profile_image_url, 
		"info" => $tweetLookup_obj[$key]->description
	));	
}



$query = 'SELECT `tblInfluencers`.`handle` FROM `tblInfluencers` INNER JOIN `tblListsInfluencers` ON `tblInfluencers`.`id` = `tblListsInfluencers`.`influencer_id` WHERE `tblListsInfluencers`.`list_id` ='. $_GET['id'] .';';
$influencer_result = mysql_query($query);

$handles_str = "";
while ($influencer_row = mysql_fetch_array($influencer_result, MYSQL_BOTH)) {
	$handles_str .= $influencer_row['handle'] .",";
}

$tweetLookup_obj = $connection->get('users/lookup', array('screen_name' => substr_replace($handles_str, "", -1)));
$influencer_arr = array();
foreach ($tweetLookup_obj as $key => $val) {
	array_push($influencer_arr, array(
		"id" => $tweetLookup_obj[$key]->id_str, 
		"name" => $tweetLookup_obj[$key]->name, 
		"handle" => $tweetLookup_obj[$key]->screen_name,  
		"avatar" => $tweetLookup_obj[$key]->profile_image_url, 
		"info" => $tweetLookup_obj[$key]->description
	));	
}



function uploadCoverImage($existing_file) {
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
		
		if (file_exists($existing_file) && array_pop(explode('/', $existing_file)) != "defaultListImage.jpg")
			unlink($existing_file);
		
		return ("http://". $_SERVER['HTTP_HOST'] ."/projs/simplenews/app/images/". array_pop(explode('/', $upload_file)));
       
	} else 
		return ("http://dev.gullinbursti.cc/projs/simplenews/app/images/defaultListImage.jpg");
}
	
?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<meta http-equiv="Content-language" value="en" />
		
		<script type="text/javascript">
			function edit() {
				var curator_tot = <?php echo (count($curator_arr)); ?>;
				var curatorIDs = "";
				var curator_cnt = 0;
			
				for (var i=0; i<curator_tot; i++) {
					var chkbox = document.getElementById('chkCurator_' + i);
				
					if (!chkbox.checked) {
						var curator_id = chkbox.value;
						
						if (curator_cnt > 0)
							curatorIDs += "|";
						
						curatorIDs += curator_id;
						curator_cnt++;
					}
				}
				
				var influencer_tot = <?php echo (count($influencer_arr)); ?>;
				var influencerIDs = "";
				var influencer_cnt = 0;
			
				for (var i=0; i<influencer_tot; i++) {
					var chkbox = document.getElementById('chkInfluencer_' + i);
				
					if (!chkbox.checked) {
						var influencer_id = chkbox.value;
						
						if (influencer_cnt > 0)
							influencerIDs += "|";
						
						influencerIDs += influencer_id;
						influencer_cnt++;
					}
				}
			
			    document.frmEdit.hidCuratorIDs.value = curatorIDs;
				document.frmEdit.hidInfluencerIDs.value = influencerIDs;			
				document.frmEdit.submit();
			}
		</script>
	</head>
	
	<body>
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
			<tr>
				<td width="320" valign="top"><?php include './nav.php'; ?></td>
				<td><form id="frmEdit" name="frmEdit" method="post" enctype="multipart/form-data" action="./edit_list.php?id=<?php echo ($row[0]); ?>&a=0">
					<table cellspacing="0" cellpadding="0" border="0" width="100%">
						<tr>
							<td rowspan="7" width="137"><img src="<?php echo ($row[5]); ?>" width="137" height="194" /><input type="file" id="filCoverImage" name="filCoverImage" />
							</td><td width="100">Name:</td><td><input type="text" id="txtTitle" name="txtTitle" value="<?php echo ($row[1]); ?>" /></td>
						</tr>
					    <tr><td width="100">Info:</td><td><input type="text" id="txtInfo" name="txtInfo" value="<?php echo ($row[2]); ?>" /></td></tr>
						<tr><td width="100">Status:</td><td><select id="selType" name="selType"><?php while ($type_row = mysql_fetch_array($type_result, MYSQL_BOTH)) { 
							if ($row[3] == $type_row['id'])
								echo ("<option value=\"". $type_row['id'] ."\" selected>". $type_row['title'] ."</option>");
								
							else
								echo ("<option value=\"". $type_row['id'] ."\">". $type_row['title'] ."</option>");
							
						} ?></select></td></tr>
						<tr><td width="100">Curators:</td><td>
							<table cellspacing="0" cellpadding="4" border="0"><tr><?php
								$tot = 0;
								foreach ($curator_arr as $key => $val) {
									$pre_html = "<td>";
									$chkbox_html = "<input type=\"checkbox\" id=\"chkCurator_". $tot ."\" name=\"chkCurator_". $tot ."\" value=\"". $curator_arr[$key]['handle'] ."\" checked />";									
									$avatar_html = "<img src=\"". $curator_arr[$key]['avatar'] ."\" alt=\"". $curator_arr[$key]['handle'] ."\" />";
									$handle_html = "<a href=\"https://twitter.com/#!/". $curator_arr[$key]['handle'] ."\" target=\"_blank\">@". $curator_arr[$key]['handle'] ."</a>";
									$post_html = "</td>";
						
									echo ($pre_html . $chkbox_html . $avatar_html ."<br />". $handle_html . $post_html);
									$tot++;
								}					
							?></tr></table>
						</td></tr>
						<tr><td>Add Curators:</td><td><textarea id="txtAddCurators" name="txtAddCurators" rows="2" cols="50"></textarea></td></tr>
						<tr><td width="100">Influencers:</td><td>
							<table cellspacing="0" cellpadding="4" border="0"><tr><?php
								$tot = 0;
								foreach ($influencer_arr as $key => $val) {
									$pre_html = "<td>";
									$chkbox_html = "<input type=\"checkbox\" id=\"chkInfluencer_". $tot ."\" name=\"chkInfluencer_". $tot ."\" value=\"". $influencer_arr[$key]['handle'] ."\" checked />";
									$avatar_html = "<img src=\"". $influencer_arr[$key]['avatar'] ."\" alt=\"". $influencer_arr[$key]['handle'] ."\" />";
									$handle_html = "<a href=\"https://twitter.com/#!/". $influencer_arr[$key]['handle'] ."\" target=\"_blank\">@". $influencer_arr[$key]['handle'] ."</a>";
									$post_html = "</td>";
						
									echo ($pre_html . $chkbox_html . $avatar_html ."<br />". $handle_html . $post_html);
						            $tot++;
								}
							?></tr></table>
						</td></tr>
						<tr><td>Add Influencers:</td><td><textarea id="txtAddInfluencers" name="txtAddInfluencers" rows="2" cols="50"></textarea></td></tr>						
						<tr><td colspan="3">
							<input type="hidden" id="hidCuratorIDs" name="hidCuratorIDs" value="" />
							<input type="hidden" id="hidInfluencerIDs" name="hidInfluencerIDs" value="" />
							<input type="button" id="btnCancel" name="btnCancel" value="Cancel" onclick="history.back();" />
							<input type="button" id="btnEdit" name="btnEdit" value="Edit List" onclick="edit();" />
						</td></tr>
					</table>
				</form></td>
			</tr>
		</table>		
	</body>
</html>

<?php require './_db_close.php'; ?>