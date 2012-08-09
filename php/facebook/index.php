<?php session_start();

require './_db_open.php'; 

if (isset($_GET['aID'])) {
	$article_id = $_GET['aID'];
	
	$query = 'SELECT `title`, `content_txt` FROM `tblArticles` WHERE `id` = '. $article_id .';';
	$row = mysql_fetch_row(mysql_query($query));
	$title = $row[0];
	$blurb = $row[1];
	
	$query = 'SELECT `url` FROM `tblArticleImages` WHERE `article_id` = '. $article_id .';';
	$row = mysql_fetch_row(mysql_query($query));
	$img_url = $row[0];
}


require './_db_close.php'; ?>


<html>
  <head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# getassembly: http://ogp.me/ns/fb/getassembly#">
    <meta property="fb:app_id"      content="316539575066102" /> 
    <meta property="og:type"        content="getassembly:quote" /> 
    <meta property="og:url"         content="http://<?php echo ($_SERVER['SERVER_NAME'] . $_SERVER['REQUEST_URI']); ?>" /> 
    <meta property="og:title"       content="<?php echo ($title); ?>" /> 
    <meta property="og:image"       content="<?php echo ($img_url); ?>" />
    <meta property="og:description" content="<?php echo ($blurb); ?>" />
  </head>  
</html>

<!--
<html>
  <head prefix="og: http://ogp.me/ns# product: http://ogp.me/ns/product#">
    <meta property="fb:app_id"      content="316539575066102" />
	<meta property="og:url"         content="http://data.whicdn.com/images/32789792/tumblr_lzxcu4hpwr1r80jjso1_500_large_large.jpg" />
    <meta property="og:type"        content="getassembly:quote" />
    <meta property="og:title"       content="QUOTE THAT TALK" />
    <meta property="og:image"       content="http://data.whicdn.com/images/32789792/tumblr_lzxcu4hpwr1r80jjso1_500_large_large.jpg" />
    <meta property="og:description" content="QUOTE THAT TALK on we heart it / visual bookmark #32770603 on we heart it / visual bookmark #32789792" />
    
    <title>QUOTE THAT TALK</title>
  </head>
  <body></body>
</html>  
-->