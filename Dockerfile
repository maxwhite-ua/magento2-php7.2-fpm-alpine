FROM php:7.2-fpm-alpine

LABEL mainteiner=maxwhite.nemetc@gmail.com

RUN set -xe \
    && apk add --no-cache --virtual .build-deps \
        mysql-client \
        freetype-dev \
        icu-dev \
        libmcrypt-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libxslt-dev \
        curl \
        zip \
        bash \
        vim \
        git

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \
    && docker-php-ext-configure hash --with-mhash \
    && docker-php-ext-install -j$(nproc) intl xsl gd zip pdo_mysql opcache soap bcmath json iconv

# Get composer installed to /usr/local/bin/composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

VOLUME /root/.composer/cache

CMD ["php-fpm", "-R"]
