<?php 

require './_db_open.php'; 

$query = 'SELECT * FROM `tblTopics`;';
$topic_result = mysql_query($query);

if ($_GET['postback'] == "1") {
	$topic_id = $_POST['selTopics'];
	$keyword_arr = explode(',', $_POST['txtKeywords']);
	
	/*foreach ($_POST as $key => $val) {
		echo ("POST['". $key ."'] = '". $val ."'");
	}*/
	
	foreach ($keyword_arr as $val) {
		$query = 'SELECT `id` FROM `tblKeywords` WHERE `title` = "'. $val .'";';
		$result = mysql_query($query);
		
		if (mysql_num_rows($result) == 0) {
			echo ("Adding keyword \"". $val ."\"<br />");
			$query = 'INSERT INTO `tblKeywords` (`id`, `title`, `active`, `added`) VALUES (NULL, "'. $val .'", "Y", NOW());';
			$result = mysql_query($query);
			$keyword_id = mysql_insert_id();
		
		} else {   	
			$row = mysql_fetch_row($result);
			$keyword_id = $row[0];
			echo ("Existing keyword \"". $val ."\" as [". $keyword_id ."]<br />");
		}
		
		$query = 'SELECT * FROM `tblTopicsKeywords` WHERE `topic_id` = '. $topic_id .' AND `keyword_id` = '. $keyword_id .';';
		if (mysql_num_rows(mysql_query($query)) == 0) {
			$query = 'INSERT INTO `tblTopicsKeywords` (`topic_id`, `keyword_id`) VALUES ("'. $topic_id .'", "'. $keyword_id .'")';
			$result = mysql_query($query);
			echo ("Inserting keyword \"". $val ."\" for topic [". $topic_id ."]<br />");
		
		} else {
			echo ("Topic [". $topic_id ."] already has keyword \"". $val ."\"<br />");
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
		<form id="frmKeywords" name="frmKeywords" method="post" action="./keywords.php?postback=1">
		Topics:<br /><select id="selTopics" name="selTopics">
		<?php while ($topic_row = mysql_fetch_array($topic_result, MYSQL_BOTH)) {
			echo ("<option value=\"". $topic_row['id'] ."\">[". $topic_row['id'] ."] ". $topic_row['title'] ."</option>");
		}
		?></select><br />
		Keywords:<br />
		<textarea id="txtKeywords" name="txtKeywords" rows="3" cols="80"></textarea>
		<input type="submit" />
	</form></body>
</html>


<?php require './_db_close.php'; ?>