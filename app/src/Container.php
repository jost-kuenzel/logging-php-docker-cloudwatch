<?php

namespace JostKuenzel\LoggingPhpDocker;

use Monolog\Formatter\JsonFormatter;
use Monolog\Handler\StreamHandler;
use Monolog\Logger;
use Psr\Log\LoggerInterface;

class Container
{
    public static function getInstance(): Container
    {
        return new self();
    }

    public function getLogger(): LoggerInterface
    {
        // Create formatter
        $formatter = new JsonFormatter();

        // Create a handler
        $handler = new StreamHandler('php://stderr');
        $handler->setFormatter($formatter);

        // create a log channel
        $logger = new Logger('');
        $logger->pushHandler($handler);

        return $logger;
    }
}
