FROM php:7.4.16-fpm

LABEL maintainer="Mauro Suarez <mauritosuarez@gmail.com>, Jorge Diaz <diazjorgeluis10@gmail.com>"

# Installing dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    default-mysql-client \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    supervisor \
    python-pip \
    libgd-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libonig-dev

# Add facedetect
ADD ./etc/facedetect /usr/local/bin/facedetect

# Add images for test
ADD ./doc/image.jpg /tmp/

# Install python dependencies
RUN apt-get update && apt-get -y install wget unzip python python-opencv libopencv-dev python-numpy && chmod +x /usr/local/bin/facedetect

# Install node dependencies
RUN apt-get update && apt-get -y install nodejs

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Installing extensions
RUN docker-php-ext-install pdo_mysql zip exif pcntl bcmath opcache
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd

# Installing composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Setting locales
RUN echo fr_FR.UTF-8 UTF-8 > /etc/locale.gen && locale-gen

# Changing Workdir
WORKDIR /var/www

# Add supervisor conf
ADD ./supervisor/supervisord.conf /etc/supervisor/supervisord.conf

# Add php conf
ADD ./php.ini /usr/local/etc/php/conf.d/

# override any previous entrypoint
RUN service supervisor restart \
    && supervisord -c /etc/supervisor/supervisord.conf \
    && supervisorctl reread \
    && supervisorctl update \
    && supervisorctl start laravel-worker:* 