FROM nginx:1.23.3-alpine


# install app
RUN apk add --no-cache \
  curl \
  nss-tools \
  openssl \
  bash

# create folder
RUN mkdir -p /etc/nginx/certs

RUN curl -L https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64 -o /usr/local/bin/mkcert \
 && chmod +x /usr/local/bin/mkcert \
 && mkcert -install \
 && mkcert -cert-file /etc/nginx/certs/nginx.crt -key-file /etc/nginx/certs/nginx.key localhost

COPY ./conf/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
EXPOSE 443

VOLUME /var/www
WORKDIR /var/www/html