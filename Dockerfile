FROM tusimo/docker-php

RUN apk upgrade && apk update && \
    apk add --no-cache nginx \
        bash \
        supervisor 

ENV TZ=Asia/Shanghai
ENV NGINX_LISTEN="80"
ENV NGINX_USER="www-data"
ENV NGINX_WORKER_PROCESSES="2"
ENV PHP_USER="www-data"
ENV PHP_GROUP="www-data"
ENV PHP_LISTEN="/dev/shm/php-cgi.sock"
ENV NGINX_FASTCGI_PASS="unix:/dev/shm/php-cgi.sock"
ENV NGINX_ROOT="/var/www/html"
ENV NGINX_ERROR_LOG="/dev/stderr  warn"
ENV NGINX_WORKER_CONNECTIONS="51200"
ENV NGINX_SERVER_NAMES_HASH_BUCKET_SIZE="128"
ENV NGINX_CLIENT_HEADER_BUFFER_SIZE="10m"
ENV NGINX_LARGE_CLIENT_HEADER_BUFFERS="4 10m"
ENV NGINX_CLIENT_MAX_BODY_SIZE="1024m"
ENV NGINX_CLIENT_BODY_BUFFER_SIZE="10m"
ENV NGINX_KEEPALIVE_TIMEOUT="120"
ENV NGINX_ACCESS_LOG="off"


COPY docker-entrypoint.sh /usr/local/bin/

COPY conf/nginx/conf.d/ /etc/nginx/conf.d/

COPY conf/nginx/nginx.conf /etc/nginx/nginx.conf

COPY conf/supervisord.conf /etc/supervisord.conf

COPY conf/supervisor.d/ /etc/supervisor.d/

COPY nginx-prometheus-exporter /usr/local/bin/

COPY php-fpm-exporter /usr/local/bin/

RUN mkdir -p $NGINX_ROOT && \
    chown -R www-data:www-data $NGINX_ROOT && \
    rm -fr /usr/local/etc/php-fpm.d/zz-docker.conf


WORKDIR $NGINX_ROOT

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 80 443 9253 9113

CMD ["supervisord", "-n", "-c", "/etc/supervisord.conf"]
