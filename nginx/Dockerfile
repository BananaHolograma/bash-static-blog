FROM nginx:stable

RUN mkdir -p /var/www/html && \
    chown nginx:nginx /var/www/html && \
    chown nginx /var/log/nginx/*.log

COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/default.conf /etc/nginx/conf.d/default.conf