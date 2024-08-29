FROM php:8.2-fpm
                                                                                                                 
# Arguments defined in docker-compose.yml
ARG user
ARG uid

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd sockets
RUN echo 'memory_limit = 10000M' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini
RUN echo 'pm.max_children = 200' >> /usr/local/etc/php-fpm.d/www.conf
RUN echo 'pm.start_servers = 20' >> /usr/local/etc/php-fpm.d/www.conf
RUN echo 'pm.min_spare_servers = 10' >> /usr/local/etc/php-fpm.d/www.conf
RUN echo 'pm.max_spare_servers = 20' >> /usr/local/etc/php-fpm.d/www.conf
RUN echo 'pm.process_idle_timeout = 900s' >> /usr/local/etc/php-fpm.d/www.conf
RUN echo 'pm.max_requests = 1000' >> /usr/local/etc/php-fpm.d/www.conf

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Install redis
#RUN pecl install -o -f redis \
#    &&  rm -rf /tmp/pear \
#    &&  docker-php-ext-enable redis

# Set working directory
WORKDIR /var/www

USER $user