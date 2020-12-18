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
        echo '; Maximum CloudWatch log event size is 256KB https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/cloudwatch_limits_cwl.html'; \
        echo 'log_limit = 65536'; \
        echo '[www]'; \
        echo 'listen = /var/run/php-fpm.sock'; \
        echo 'listen.mode = 0666'; \
    } | tee /usr/local/etc/php-fpm.d/zz-docker.conf; \
    { \
        echo '; Maximum CloudWatch log event size is 256KB https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/cloudwatch_limits_cwl.html'; \
        echo 'log_errors_max_len = 65536'; \
    } | tee -a /usr/local/etc/php/php.ini

# Install composer
RUN curl https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Set container entrypoint and supervisord as command
CMD ["sh", "-c", "/usr/bin/supervisord -n -c /etc/supervisord.conf"]
ENTRYPOINT ["/docker-entrypoint.sh"]