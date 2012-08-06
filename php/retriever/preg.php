<?php

$msg = "@WhySoStewious YOLO http://t.co/eksTpFBA";


preg_match_all('!https?://[\S]+!', $argv[1], $matches);

print_r($matches);
echo ("[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]");
print_r($matches[0]);
echo ("[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]");
print_r($matches[1]);

?>
