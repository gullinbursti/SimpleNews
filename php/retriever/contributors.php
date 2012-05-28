<?php 

require './_db_open.php'; 

$query = 'SELECT * FROM `tblTopics`;';
$topic_result = mysql_query($query);

if ($_GET['postback'] == "1") {
	$topic_id = $_POST['selTopics'];
	$contributor_arr = explode(',', $_POST['txtContributors']);
	
	/*foreach ($_POST as $key => $val) {
		echo ("POST['". $key ."'] = '". $val ."'");
	}*/
	
	foreach ($contributor_arr as $val) {
		$query = 'SELECT `id` FROM `tblContributors` WHERE `handle` = "'. $val .'";';
		$result = mysql_query($query);
		
		if (mysql_num_rows($result) == 0) {
			echo ("Adding contributor @". $val ."<br />");
			$query = 'INSERT INTO `tblContributors` (';
			$query .= '`id`, `handle`, `name`, `avatar_url`, `type_id`, `active`, `added`) VALUES (';
			$query .='NULL, "'. $val .'", "'. $val .'", "https://api.twitter.com/1/users/profile_image?screen_name='. $val .'&size=reasonably_small", "1", "Y", NOW());';
			$result = mysql_query($query);
			$contributor_id = mysql_insert_id();
		
		} else {   	
			$row = mysql_fetch_row($result);
			$contributor_id = $row[0];
			echo ("Existing contributor @". $val ." as [". $contributor_id ."]<br />");
		}
		
		$query = 'SELECT * FROM `tblTopicsContributors` WHERE `topic_id` = '. $topic_id .' AND `contributor_id` = '. $contributor_id .';';
		if (mysql_num_rows(mysql_query($query)) == 0) {
			$query = 'INSERT INTO `tblTopicsContributors` (`topic_id`, `contributor_id`) VALUES ("'. $topic_id .'", "'. $contributor_id .'")';
			$result = mysql_query($query);
			echo ("Inserting contributor @". $val ." for topic [". $topic_id ."]<br />");
		
		} else {
			echo ("Topic [". $topic_id ."] already has contributor @". $val ."<br />");
		}
	}
	
	echo ("<hr />");
}
        
?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<meta http-equiv="Content-language" value="en" />
	</head>
	
	<body>
		<a href="./keywords.php">keywords</a><br />
		<a href="./hashtags.php">hashtags</a><br />
		<a href="./contributors.php">handles</a><br />
		<hr />
		<form id="frmContributors" name="frmContributors" method="post" action="./contributors.php?postback=1">
		Topics:<br /><select id="selTopics" name="selTopics">
		<?php while ($topic_row = mysql_fetch_array($topic_result, MYSQL_BOTH)) {
			echo ("<option value=\"". $topic_row['id'] ."\">[". $topic_row['id'] ."] ". $topic_row['title'] ."</option>");
		}
		?></select><br />
		Twitter Handles:<br />
		<textarea id="txtContributors" name="txtContributors" rows="3" cols="80"></textarea>
		<input type="submit" />
	</form></body>
</html>


<?php require './_db_close.php'; ?> 