FROM ubuntu:16.04

# update software repo
RUN apt-get update

# packages installation
RUN apt-get install -y supervisor nginx php7.0-fpm && \
    rm -rf /var/lib/apt/lists/*

#Define the needed ENV variable
ENV nginx_vhost /etc/nginx/sites-available/default
ENV php_conf /etc/php/7.0/fpm/php.ini
ENV nginx_conf /etc/nginx/nginx.conf
ENV supervisor_conf /etc/supervisor/supervisord.conf
 
# Enable php-fpm on nginx virtualhost configuration
COPY default ${nginx_vhost}
RUN sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${php_conf} && \
    echo "\ndaemon off;" >> ${nginx_conf}
 
#Copy supervisor configuration
COPY supervisord.conf ${supervisor_conf}

# Make sure files & folders needed by processes are accessible
RUN mkdir -p /run/php && \
    chown -R www-data:www-data /var/www/html && \
    chown -R www-data:www-data /run/php

# Make the document root a volume
VOLUME /var/www/html

# Expose port 80 & 443
EXPOSE 80 443

# supervisord starts nginx & php-fpm
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
