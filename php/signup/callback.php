<?php

session_start();
require_once('twitteroauth/twitteroauth.php');
require_once('_oauth_cfg.php');

if (isset($_REQUEST['oauth_token']) && $_SESSION['oauth_token'] !== $_REQUEST['oauth_token']) {
	$_SESSION['oauth_status'] = 'oldtoken';
	header('Location: ./index.php');
}


$connection = new TwitterOAuth(CONSUMER_KEY, CONSUMER_SECRET, $_SESSION['oauth_token'], $_SESSION['oauth_token_secret']);

$access_token = $connection->getAccessToken($_REQUEST['oauth_verifier']);
$_SESSION['access_token'] = $access_token;

unset($_SESSION['oauth_token']);
unset($_SESSION['oauth_token_secret']);

if ($connection->http_code == 200) {
	$_SESSION['status'] = 'verified';
	header('Location: ./index.php?lID='. $_SESSION['list_id']);

} else
	header('Location: ./index.php?lID='. $_SESSION['list_id']);
