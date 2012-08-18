<?php 

session_start();

require './_db_open.php'; 
require_once('twitteroauth.php');
require_once('_oauth_cfg.php');
require_once('TwitterSearch.php'); 


$search = new TwitterSearch();
$search->user_agent = 'assembly:retriever@getassembly.com';


echo ("\n@". $argv[1] ."\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n");
$results = $search->from($argv[1])->results();
foreach ($results as $key => $val) {
	echo ("RESULT --> [". $results[$key]->id_str ."] <". $results[$key]->text ."> (". $results[$key]->created_at .")\n");
}

require './_db_close.php'; 

?>



*/15	*	*	*	*	/usr/local/bin/content_update.sh >> /var/log/content-retriever.log 2>&1