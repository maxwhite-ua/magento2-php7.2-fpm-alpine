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

RUN sed -i 's/pm.max_children = 5/pm.max_children = 6/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/pm.start_servers = 2/pm.start_servers = 4/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/pm.min_spare_servers = 1/pm.min_spare_servers = 2/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/pm.max_spare_servers = 3/pm.max_spare_servers = 5/' /usr/local/etc/php-fpm.d/www.conf \
    && touch /usr/local/etc/php/conf.d/magento.ini && echo 'memory_limit=2048M' >> /usr/local/etc/php/conf.d/magento.ini \
    && echo 'cgi.fix_pathinfo=0' >> /usr/local/etc/php/conf.d/magento.ini

# Get composer installed to /usr/local/bin/composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

VOLUME /root/.composer/cache

CMD ["php-fpm", "-R"]
