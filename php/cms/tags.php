<?php

// start the session engine
session_start();

if (!isset($_SESSION['login']))  
	header('Location: login.php');  
	

require './_db_open.php';

	
$query = 'SELECT * FROM `tblTags`;';
$result = mysql_query($query);
	
?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<meta http-equiv="Content-language" value="en" />
		<script type="text/javascript">
			function edit(tag_id) {
				location.href = "./edit_tag.php?id=" + tag_id;
			}
			
			function remove(tag_id) {
				var prompt = confirm("Delete this tag ["+ tag_id +"]?");
				
				if (prompt)
					location.href = "./delete_tag.php?id=" + tag_id;
			}
		</script>
	</head>
	
	<body>
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
			<tr>
				<td width="320" valign="top"><?php include './nav.php'; ?></td>
				<td><table cellspacing="0" cellpadding="0" border="0">
					<?php while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
						$pre_html = "<tr><td><table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" width=\"100%\">";
						$post_html = "</table></td></tr>";
						
						echo ($pre_html);
						echo ("<tr><td><input type=\"button\" value=\"Delete\" onclick=\"remove('". $row['id'] ."');\" /><input type=\"button\" value=\"Edit\" onclick=\"edit('". $row['id'] ."');\" /></td><td>#". $row['title'] ."</td></tr>");
						echo ("<tr><td colspan=\"2\"><hr /></td></tr>");
						echo ($post_html);
						
					} ?>
					<tr><td><input type="button" id="btnAdd" name="btnAdd" value="Add Tag" onclick="location.href='./add_tag.php'"></td></tr>
				</table></td>
			</tr>
		</table>
	</body>
</html>

<?php require './_db_close.php'; ?>