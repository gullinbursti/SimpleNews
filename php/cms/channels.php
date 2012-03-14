<?php

// start the session engine
session_start();

if (!isset($_SESSION['login']))  
	header('Location: login.php');

require './_db_open.php';

$query = 'SELECT * FROM `tblChannels`;';
$result = mysql_query($query);
	
?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<meta http-equiv="Content-language" value="en" />
		
		<script type="text/javascript">
			function remove(cat_id) {
				var prompt = confirm("Delete this channel?");
				
				if (prompt)
					location.href = "./delete_channel.php?id=" + cat_id;
			}
			
			function edit(cat_id) {
				location.href = "./edit_channel.php?id=" + cat_id;
			}
		</script>
	</head>
	
	<body>
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
			<tr>
				<td width="320" valign="top"><?php include './nav.php'; ?></td>
				<td><table cellspacing="0" cellpadding="0" border="0">
					<?php while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
						if ($row['active'] == "Y")
							echo ("<tr><td><input type=\"button\" id=\"btnDelete_". $row['id'] ."\" name=\"btnDelete_". $row['id'] ."\" value=\"Delete\" onclick=\"remove('". $row['id'] ."')\" /><input type=\"button\" id=\"btnEdit_". $row['id'] ."\" name=\"btnEdit_". $row['id'] ."\" value=\"Edit\" onclick=\"edit('". $row['id'] ."')\" /></td><td>". $row['title'] ."</td></tr>");
						
						else
						    echo ("<tr><td><input type=\"button\" id=\"btnDelete_". $row['id'] ."\" name=\"btnDelete_". $row['id'] ."\" value=\"Delete\" onclick=\"remove('". $row['id'] ."')\" /><input type=\"button\" id=\"btnEdit_". $row['id'] ."\" name=\"btnEdit_". $row['id'] ."\" value=\"Edit\" onclick=\"edit('". $row['id'] ."')\" /></td><td style=\"color:#c0c0c0;\">". $row['title'] ."</td></tr>");
					} ?>
					<tr><td colspan="2"><hr /></td></tr>
					<tr><td colspan="2"><input type="button" id="btnAdd" name="btnAdd" value="Add Channel" onclick="location.href='./add_channel.php'" /></td></tr>
				</table></td>
			</tr>
		</table>
	</body>
</html>

<?php require './_db_close.php'; ?>