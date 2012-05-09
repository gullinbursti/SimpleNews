<?php

require './_db_open.php';  

$query = 'SELECT * FROM `tblLists` ORDER BY `added` DESC;';
$list_result = mysql_query($query);


if ($_GET['postback'] == "true") {
	$list_id = $_GET['id'];
	
	$query = 'SELECT * FROM `tblUsers` INNER JOIN `tblUsersLists` ON `tblUsers`.`id` = `tblUsersLists`.`user_id` WHERE `tblUsersLists`.`list_id` = '. $list_id .';';
	$user_result = mysql_query($query);
	$tot = mysql_num_rows($user_result);
	
	if ($_GET['a'] == 1) {
		$device_tokens = '[';
		
		foreach (explode("|", $_POST['hidIDs']) as $user_id) {
			$query = 'SELECT `device_token` FROM `tblUsers` WHERE `id` = '. $user_id .';';
			$user_row = mysql_fetch_row(mysql_query($query));
			
			if ($user_row[0] != "" && $user_row[0] != "0000000000000000000000000000000000000000000000000000000000000000")
				$device_tokens .= '"'. $user_row[0] .'", ';
		}
		
		$device_tokens = substr($device_tokens, 0, -2) .']';
		$ch = curl_init();
		
		curl_setopt($ch, CURLOPT_URL, 'https://go.urbanairship.com/api/push/');
		curl_setopt($ch, CURLOPT_USERPWD, "4ZBDEFZSSFaHtnjxVf5OSg:xigRRT-WRdu2pU2ZQK4uPQ");
		curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
		curl_setopt($ch, CURLOPT_POST, 1);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_POSTFIELDS, '{"device_tokens": '. $device_tokens .', "type": "1", "aps": {"alert": {"body": "Assembly Push Test"}, "sound": "default", "badge": "+1"}}');
	}
}	
	
?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<meta http-equiv="Content-language" value="en" />
		<title></title>
		<script type="text/javascript">
			function allUsers() {
				var tot = <?php echo($tot); ?>;
				var chkboxAll_obj = document.getElementById('chkAll');
				
				for (var i=0; i<tot; i++) {
					var chkbox_obj = document.getElementById('chkUser_' + i);
					chkbox_obj.checked = chkboxAll_obj.checked;
				}
			}
			
			function sendPush() {
				var tot = <?php echo($tot); ?>;
				var userIDs = "";
				var cnt = 0;
			
				for (var i=0; i<tot; i++) {
					var chkbox = document.getElementById('chkUser_' + i);
				
					if (chkbox.checked) {
						var user_id = chkbox.name.substring(8);
						
						if (cnt > 0)
							userIDs += "|";
						
						userIDs += user_id;
						cnt++;
					}
				}

			    document.frmListPush.hidIDs.value = userIDs;
				document.frmListPush.action = "./?postback=true&a=1&id=" + <?php echo($list_id); ?>;
				document.frmListPush.submit();
			}
		</script>
	</head>
    
	<body><form id="frmListPush" name="frmListPush" method="post" action="./?postback=true">
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
			<tr><td>List Topic:</td><td><select id="selLists" name="selLists" onchange="location.href='./?postback=true&id='+this.value;">
				<option value="0" selected="selected">Choose a list…</option><?php $cnt = 0;
				echo ("\n\t\t\t\t");
				while ($list_row = mysql_fetch_array($list_result, MYSQL_BOTH)) {
					if ($list_id == $list_row['id'])
					    echo ("<option value=\"". $list_row['id'] ."\" selected=\"selected\">". $list_row['title'] ."</option>");
					else
						echo ("<option value=\"". $list_row['id'] ."\">". $list_row['title'] ."</option>");
					
					$cnt++;	
					if ($cnt < mysql_num_rows($list_result))
						echo ("\n\t\t\t\t");
					
				} echo ("\n");?>
			<select></td></tr>
			<tr><td colspan="2"><hr /></td></tr><?php echo ("\n"); if ($user_result) {?>
			<tr><td valign="top">Subscribers:</td><td>
				<input type="checkbox" id="chkAll" name="chkAll" value="0" onclick="allUsers();" />Check All<br /><?php echo ("\n\t\t\t\t");
				$cnt = 0;
				while ($user_row = mysql_fetch_array($user_result, MYSQL_BOTH)) {
					echo ("<input type=\"checkbox\" id=\"chkUser_". $cnt ."\" name=\"chkUser_". $user_row['id'] ."\" value=\"". $user_row['id'] ."\" />". $user_row['name'] ."<br />");
					$cnt++;
					
					if ($cnt < mysql_num_rows($user_result))
						echo ("\n\t\t\t\t");
				}?> 
			</td></tr>
			<tr><td colspan="2"><input type="hidden" id="hidIDs" name="hidIDs" value="" /></td></tr>
			<tr><td colspan="2"><input type="button" value="submit" onclick="sendPush();" /></td></tr><?php echo ("\n");}?>
		</table>
	</form></body>
</html>


<?php require './_db_close.php'; ?>   