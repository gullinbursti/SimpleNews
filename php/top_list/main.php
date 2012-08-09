<?php

// start up session
session_start();

if (!isset($_SESSION['login']))  
	header('Location: login.php');	


require './_db_open.php'; 


$topic_arr = array();
while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) {
	array_push($topic_arr, $row);	
}

if (strlen($_GET['a']) > 0) {
	$form_act = $_GET['a'];
	
	
	if ($form_act == "1" || $form_act == "2") {
		$amount = $_POST['hidAmount'];
	
		$query = 'SELECT * FROM `tblArticles` WHERE `tweet_id` = "'. $_POST['hidTweetID'] .'";';
		$result = mysql_query($query);
		$row = mysql_fetch_assoc($result);
	
		if ($row) {
			$query = 'SELECT `tblUsersLikedArticles`.`article_id`, `tblUsers`.`id` FROM `tblUsersLikedArticles` INNER JOIN `tblUsers` ON `tblUsersLikedArticles`.`user_id` = `tblUsers`.`id` WHERE `tblUsersLikedArticles`.`article_id` = '. $row['id'] .' AND `tblUsers`.`type_id` = 5;';
			$user_result = mysql_query($query);
		
			while ($user_row = mysql_fetch_array($user_result, MYSQL_ASSOC)) {
				$query = 'DELETE FROM `tblUsersLikedArticles` WHERE `article_id` = '. $user_row['article_id'] .' AND `user_id` = '. $user_row['id'] .';';			
				$del_result = mysql_query($query);			
			}
		
			for ($i=0; $i<$amount; $i++) {
				$range_result = mysql_query(" SELECT MAX(`id`) AS max_id , MIN(`id`) AS min_id FROM `tblContributors`");
				$range_row = mysql_fetch_object($range_result); 
				$id_rnd = mt_rand($range_row->min_id , $range_row->max_id);
				$query = "SELECT * FROM `tblContributors` WHERE `id` >= $id_rnd LIMIT 0,1";
				$contrib_row = mysql_fetch_row(mysql_query($query));

				$query = 'SELECT `id` FROM `tblUsers` WHERE `handle` = "'. $contrib_row[1] .'";';
				$user_result = mysql_query($query);
		
				if (mysql_num_rows($user_result) == 0) {
					$query = 'INSERT INTO `tblUsers` (';
					$query .= '`id`, `type_id`, `twitter_id`, `handle`, `name`, `device_token`, `added`, `modified`) ';
					$query .= 'VALUES (NULL, "5", "0", "'. $contrib_row[1] .'", "", "", NOW(), CURRENT_TIMESTAMP);';
					$ins_result = mysql_query($query);
					$user_id = mysql_insert_id();

			   	} else {
					$user_row = mysql_fetch_row($user_result);
					$user_id = $user_row[0];
				}

				$query = 'INSERT INTO `tblUsersLikedArticles` (`user_id`, `article_id`, `added`) VALUES ('. $user_id .', '. $row['id'] .', NOW());';
			    $like_result = mysql_query($query);		            			    	  
			}
		
			$query = 'UPDATE `tblTopArticles` SET `article_id` = "'. $row['id'] .'" WHERE `id` = '. $_POST['hidID'] .' AND `type_id` = '. $form_act .';';
			$result = mysql_query($query);
			
			/*		
			switch ($form_act) {
				case "1":
					//echo ("MOST LIKED [". $row['id'] ."]");
					$query = 'UPDATE `tblTopArticles` SET `article_id` = "'. $row['id'] .'" WHERE `id` = '. $_POST['hidID'] .' AND `type_id` = '. $form_act .';';
					$result = mysql_query($query);
					break;
			
				case "2":
					//echo ("TOP 10 [". $row['id'] ."]");
					$query = 'UPDATE `tblTopArticles` SET `article_id` = "'. $row['id'] .'" WHERE `id` = '. $_POST['hidID'] .' AND `type_id` = 2;';
					$result = mysql_query($query);
					break;	
			}
			*/
		
			//echo ($query);
		}
	
	} else if ($form_act == "3") {
		$query = 'UPDATE `tblArticles` SET `active` = "N" WHERE `tweet_id` = "'. $_POST['txtDisable'] .'";';
		$result = mysql_query($query);
	}
}


$query = 'SELECT * FROM `tblTopArticles` WHERE `type_id` = 1 ORDER BY `total` DESC;';
$result = mysql_query($query);

$liked_arr = array();
while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) {
	$query = 'SELECT * FROM `tblArticles` WHERE `id` = '. $row['article_id'] .';';
	$article_result = mysql_query($query);
	$article_row = mysql_fetch_assoc($article_result);
	
	array_push($liked_arr, $article_row);
} 

$query = 'SELECT * FROM `tblTopArticles` WHERE `type_id` = 2 ORDER BY `total` DESC;';
$result = mysql_query($query);

$top10_arr = array();
while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) {
	$query = 'SELECT * FROM `tblArticles` WHERE `id` = '. $row['article_id'] .';';
	$article_result = mysql_query($query);
	$article_row = mysql_fetch_assoc($article_result);
	
	array_push($top10_arr, $article_row);
} 

$query = 'SELECT * FROM `tblTopics` WHERE `active` = "Y" ORDER BY `order` ASC;';
$result = mysql_query($query);

?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<meta http-equiv="Content-language" value="en" />
		
		<style type="text/css" rel="stylesheet" media="screen">
			table {border:1px solid #666666;}
		</style>
		
		<script type="text/javascript">
			function updateMostLiked(ind) {
				var tweetTxt_obj = document.getElementById('txtLiked_'+ind);
				var amountSel_obj = document.getElementById('selAmount1_'+ind);				
				var amt = amountSel_obj.options[amountSel_obj.selectedIndex].value;
				
				//alert ("MOST LIKED ["+ind+"]["+amt+"]");
								
				document.frmMostLiked.hidTweetID.value = tweetTxt_obj.value;
				document.frmMostLiked.hidID.value = parseInt(ind) + 1;
				document.frmMostLiked.hidAmount.value = amt;
				document.frmMostLiked.submit();
			}
			
			function updateTop10(ind) {
				var tweetTxt_obj = document.getElementById('txtTop10_'+ind);
				var amountSel_obj = document.getElementById('selAmount2_'+ind);				
				var amt = amountSel_obj.options[amountSel_obj.selectedIndex].value;
				
				//alert ("TOP 10 ["+ind+"]");
				
				document.frmTop10.hidTweetID.value = tweetTxt_obj.value;
				document.frmTop10.hidID.value = parseInt(ind) + 11;
				document.frmTop10.hidAmount.value = amt;
				document.frmTop10.submit();
			}
			
			function disableArticle() {
				document.frmDisableArticle.submit();					
			}
		</script>
	</head>
	
	<body>
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
			<tr><td align="right"><a href="logout.php">Logout</a></td></tr>
			<tr><td><strong>Most Liked</strong></td></tr>
			<tr>
				<td valign="top"><form id="frmMostLiked" name="frmMostLiked" method="post" action="main.php?a=1"><table cellpadding="0" cellspacing="0" border="0" width="100%"><?php echo ("\n");
					$cnt = 0;
					foreach ($liked_arr as $key => $val) {						
						echo ("\t\t\t\t\t<tr>");
						echo ("\t<td width=\"32\">". ($cnt + 1) ."</td>");
						echo ("<td><input type=\"text\" id=\"txtLiked_". $cnt ."\" name=\"txtLiked_". $cnt ."\" size=\"25\" value=\"". $liked_arr[$cnt]['tweet_id'] ."\" />");												
						echo ("<select id=\"selAmount1_". $cnt ."\" name=\"selAmount1_". $cnt ."\">");
						for ($i=0; $i<=9; $i++)
							echo ("<option value=\"". $i ."\">". $i ."</option>");
						echo ("</select>");
						echo ("<input type=\"button\" value=\"Update\" onclick=\"updateMostLiked('". $cnt ."')\" />");
						echo ("</td></tr>\n");
						echo ("\t\t\t\t\t<tr><td colspan=\"2\">". $liked_arr[$cnt]['tweet_msg'] ."</td></tr>\n");
						echo ("\t\t\t\t\t<tr><td colspan=\"2\"><hr /></td></tr>\n");
						
						$cnt++;
					}
				?></table><input type="hidden" id="hidID" name="hidID" value="" /><input type="hidden" id="hidAmount" name="hidAmount" value="" /><input type="hidden" id="hidTweetID" name="hidTweetID" value="" /></form></td>				
			</tr>
			<tr><td><br /><br /></td></tr>
			<tr><td><strong>Top 10</strong></td></tr>
			<tr>
				<td valign="top"><form id="frmTop10" name="frmTop10" method="post" action="main.php?a=2"><table cellpadding="0" cellspacing="0" border="0" width="100%"><?php echo ("\n");
					$cnt = 0;
					foreach ($top10_arr as $key => $val) {						
						echo ("\t\t\t\t\t<tr>");
						echo ("\t<td width=\"32\">". ($cnt + 1) ."</td>");
						echo ("<td><input type=\"text\" id=\"txtTop10_". $cnt ."\" name=\"txtTop10_". $cnt ."\" size=\"25\" value=\"". $top10_arr[$cnt]['tweet_id'] ."\" />");												
						echo ("<select id=\"selAmount2_". $cnt ."\" name=\"selAmount2_". $cnt ."\">");
						for ($i=0; $i<=9; $i++)
							echo ("<option value=\"". $i ."\">". $i ."</option>");
						echo ("</select>");
						echo ("<input type=\"button\" value=\"Update\" onclick=\"updateTop10('". $cnt ."')\" />");
						echo ("</td></tr>\n");
						echo ("\t\t\t\t\t<tr><td colspan=\"2\">". $top10_arr[$cnt]['tweet_msg'] ."</td></tr>\n");
						echo ("\t\t\t\t\t<tr><td colspan=\"2\"><hr /></td></tr>\n");
						
						$cnt++;
					}
				?></table><input type="hidden" id="hidAmount" name="hidAmount" value="" /><input type="hidden" id="hidID" name="hidID" value="" /><input type="hidden" id="hidTweetID" name="hidTweetID" value="" /></form></td>				
			</tr>
			<tr><td><hr /></td></tr>
			<tr><td><form id="frmDisableArticle" name="frmDisableArticle" method="post" action="main.php?a=3"><table cellpadding="0" cellspacing="0" border="0">
				<tr><td colspan="2"><strong>Remove Article by Tweet ID</strong></td></tr>
				<tr>
					<td><input type="text" id="txtDisable" name="txtDisable" size="25" value="" /></td>
					<td><input type="button" value="Disable" onclick="disableArticle()" /></td>
				</tr>
			</table></form></td></tr>
		</table>
	</body>
</html>