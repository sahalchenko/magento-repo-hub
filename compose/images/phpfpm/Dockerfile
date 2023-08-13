FROM php:8.1-fpm-alpine

# install apk and enable php-zip
RUN apk update && apk add --no-cache dos2unix autoconf make gcc g++ zlib-dev libzip-dev bash rsync sshfs gnumeric ttf-dejavu
RUN pecl install zip
RUN docker-php-ext-enable zip

# install composer
COPY --from=composer:2.5.8 /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1

# install satis
RUN cd /usr/bin && composer create-project composer/satis satis dev-main
ENV PATH "$PATH:/usr/bin/satis/bin"

EXPOSE 9000

RUN mkdir -p /rlib/upload /runner

COPY ./lib/auth.json.tpl /rlib/auth.json.tpl
COPY ./lib/upload.json.tpl /rlib/upload.json.tpl
COPY ./lib/build.sh /rlib/build.sh
COPY ./lib/report.sh /rlib/report.sh
COPY ./lib/sync.sh /rlib/sync.sh

VOLUME /var/www
WORKDIR /var/www/html