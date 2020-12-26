<?php

require_once '../vendor/autoload.php';

use JostKuenzel\LoggingPhpDocker\Container;

$logger = Container::getInstance()->getLogger();

// add records to the log

// writes line below (134 characters)
// {"message":"","context":{},"level":100,"level_name":"DEBUG","channel":"","datetime":"2020-12-26T21:34:13.615988+00:00","extra":{}}
$logger->debug("");
// write full 256k characters (subtract the log message json overhead)
$logger->debug(str_repeat('x', (256 * 1024) - 130));
