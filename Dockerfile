FROM php:fpm-alpine

ADD conf/supervisord.conf /etc/supervisord.conf
ADD conf/nginx-site.conf /etc/nginx/conf.d/site.conf
ADD conf/nginx-log-format.conf /etc/nginx/log_format.conf
ADD conf/docker-entrypoint.sh /docker-entrypoint.sh

# Install and update dependencies
RUN apk update \
    && apk upgrade \
    && apk add --no-cache \
        nginx \
        supervisor

# Configure nginx
RUN sed -e "s|http {|http {\n\tinclude /etc/nginx/log_format.conf;|" -i /etc/nginx/nginx.conf \
    && sed -e 's|access_log .*|access_log /dev/stdout json_http_combined;|' -i /etc/nginx/nginx.conf \
    && rm /etc/nginx/conf.d/default.conf \
    && mkdir -p /run/nginx/ \
    && chown -R www-data:www-data /var/www/html

# Configure php 
RUN set -eu; \
    mv /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini; \
    { \
        echo '[global]'; \
        echo '; Log limit for the logged lines which allows to log messages longer than 1024 characters without wrapping.'; \
        echo '; Default value: 1024. Available as of PHP 7.3.0. https://www.php.net/manual/en/install.fpm.configuration.php'; \
        echo '; Maximum CloudWatch log event size is 256KB https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/cloudwatch_limits_cwl.html'; \
        echo '; 256 KiloBytes x 1024 Bytes/KiloByte = 262144 Bytes'; \
        echo 'log_limit = 262144'; \
        echo '[www]'; \
        echo 'access.log = /dev/null'; \
    } | tee /usr/local/etc/php-fpm.d/zz-docker.conf; \
    { \
        echo '; Set the maximum length of log_errors in bytes. In error_log information about the source is added.'; \
        echo '; The default is 1024 and 0 allows to not apply any maximum length at all.'; \
        echo '; This length is applied to logged errors, displayed errors and also to \$php_errormsg, but not to explicitly called functions such as error_log().'; \
        echo '; When an int is used, the value is measured in bytes. Shorthand notation, as described in this FAQ, may also be used. '; \
        echo '; https://www.php.net/manual/en/errorfunc.configuration.php'; \
        echo '; Maximum CloudWatch log event size is 256KB https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/cloudwatch_limits_cwl.html'; \
        echo '; 256 KiloBytes x 1024 Bytes/KiloByte = 262144 Bytes'; \
        echo 'log_errors_max_len = 262144'; \
    } | tee -a /usr/local/etc/php/php.ini

# Install composer
RUN curl https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Set container entrypoint and supervisord as command
CMD ["sh", "-c", "/usr/bin/supervisord -n -c /etc/supervisord.conf"]
ENTRYPOINT ["/docker-entrypoint.sh"]