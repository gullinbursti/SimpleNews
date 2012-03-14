<?php

// start the session engine
session_start();

if (!isset($_SESSION['login']))  
	header('Location: login.php');

require './_db_open.php';

if (isset($_GET['a'])) {
	
	$twitter_active = "N";
	if ($_POST['chkActive'] == "Y")
		$twitter_active = "Y";
		
	$query = 'UPDATE `tblTwitterFollowers` SET `active` = "'. $twitter_active .'" WHERE `id` = "'. $_GET['id'] .'"';
	$result = mysql_query($query);
	
	header('Location: followers.php');
}

$query = 'SELECT * FROM `tblTwitterFollowers` WHERE `id` = "'. $_GET['id'] .'";';
$row = mysql_fetch_row(mysql_query($query));

$query = 'SELECT * FROM `tblCategories`;';
$cat_result = mysql_query($query); 

$cat_tot = 0;
while ($cat_row = mysql_fetch_array($cat_result, MYSQL_BOTH)) {
	$cat_tot++;
}
	
?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<meta http-equiv="Content-language" value="en" />
		
		<script type="text/javascript">
			function edit() {
				var tot = <?php echo ($cat_tot); ?>;
				var catIDs = "";
				var cnt = 0;    
				
				for (var i=0; i<tot; i++) {
					var chkbox = document.getElementById('chkCat_'+i);
					
					if (chkbox.checked) {
						var cat_id = chkbox.name.substring(7);
						
						if (cnt > 0)
							catIDs += "|";
						
						catIDs += cat_id;
						cnt++;
					}
				}
				
				var chkbox = document.getElementById('chkActive');				
				if (chkbox.checked)
					chkbox.value = "Y";
				
				else
					chkbox.value = "N";
				
				document.frmEdit.hidIDs.value = catIDs;
				document.frmEdit.submit();
			}
		</script>
	</head>
	
	<body>
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
			<tr>
				<td width="320" valign="top"><?php include './nav.php'; ?></td>
				<td><form id="frmEdit" name="frmEdit" method="post" action="./edit_follower.php?a=0&id=<?php echo ($row[0]); ?>"><table cellspacing="0" cellpadding="0" border="0">
					<tr><td colspan="2"><img src="<?php echo ($row[3]); ?>" /></td></tr>
					<tr><td>Handle:</td><td>@<input type="text" id="txtHandle" name="txtHandle" value="<?php echo ($row[1]); ?>" disabled="disabled" /></td></tr>
					<tr><td>Name:</td><td><input type="text" id="txtName" name="txtName" value="<?php echo ($row[2]); ?>" disabled="disabled" /></td></tr>
					<tr><td>Categories:</td><td><?php 
						$query = 'SELECT * FROM `tblCategories`;';
						$cat_result = mysql_query($query);
						
						$cnt = 0;
						while ($cat_row = mysql_fetch_array($cat_result, MYSQL_BOTH)) {
							echo ("<input type=\"checkbox\" id=\"chkCat_". $cnt ."\" name=\"chkCat_". $cat_row['id'] ."\" disabled=\"disabled\" />". $cat_row['title'] ."<br />");
							$cnt++;
						} 
					?><input type="hidden" id="hidIDs" name="hidIDs" value="" /></td></tr>
					<?php if ($row[4] == "Y")
						echo ("<tr><td>Active:</td><td><input type=\"checkbox\" id=\"chkActive\" name=\"chkActive\" value=\"Y\" checked /></td></tr>");
						
					else
						echo ("<tr><td>Active:</td><td><input type=\"checkbox\" id=\"chkActive\" name=\"chkActive\" value=\"N\" /></td></tr>");
					?>
					<tr><td colspan="2"><hr /></td></tr>
					<tr><td colspan="2"><input type="button" id="btnEdit" name="btnEdit" value="Edit Follower" onclick="edit();" /></td></tr>
				</form></table></td>
			</tr>
		</table>
	</body>
</html>

<?php require './_db_close.php'; ?>