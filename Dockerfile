FROM alpine:3.20

LABEL name="FlyingFlip Apline Linux Based Development Image"
LABEL description="The LAMP Stack underpinning for the Development"
LABEL author="Michael R. Bagnall <hello@flyingflip.com>"
LABEL vendor="FlyingFlip Studios, LLC."

ENV TERM=xterm

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/src/vendor/bin:/src/vendor/drush/drush:/src/docroot/vendor/drush/drush

# Copy our Alpine compiled iconv library
# COPY files/preloadable_libiconv.so /usr/lib/preloadable_libiconv.so

# Install all of our base packages for making the image work.
RUN apk update && \
  apk add --no-cache \
  openrc mariadb-client php83-apache2 wget bash \
  php83 php83-bcmath php83-bz2 php83-curl php83-dba php83-mbstring \
  php83-opcache php83-fileinfo php83-pdo_mysql php83-xml php83-zip php83-pecl-redis \
  php83-pecl-memcached php83-pear git vim zip gzip curl php83-cgi \
  php83-common sudo php83-simplexml php83-cli mlocate php83-phar php83-dom php83-tokenizer \
  apache2-ctl redis memcached ncurses php83-ctype php83-iconv apache2-proxy \
  php83-gd gnu-libiconv apache2-ssl php83-xmlreader php83-xmlwriter lsof procps patch

# By default, alpine puts PHP in as "php7" or "php8". We need to homogenize it.
RUN ln -s /usr/bin/php83 /bin/php

# Attempt to resolve our iconv problems
# Currently does not work on ARM where we are doing dev, so commenting out.
# ENV LD_PRELOAD="/usr/lib/preloadable_libiconv.so php"

# Install composer and drush.
RUN apk add php83-cli && curl -sS https://getcomposer.org/installer | php -- \
  --install-dir=/usr/local/bin \
  --filename=composer

COPY files/apache-default-host.conf /etc/apache2/conf.d/apache-default-host.conf
COPY files/ssl_environment_variable.conf /etc/apache2/conf.d/ssl_environment_variable.conf
COPY files/httpd.conf /etc/apache2/httpd.conf
RUN mkdir -p /var/www/html

RUN rm /usr/bin/vi
RUN ln -s /usr/bin/vim /usr/bin/vi

ADD files/run-httpd.sh /run-httpd.sh
gi
CMD ["sh", "/run-httpd.sh"]
