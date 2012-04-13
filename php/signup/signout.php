<?php

session_start();
unset($_SESSION['access_token']);
header('Location: ./index.php?lID='. $_SESSION['list_id']);

?>