FROM nginx:latest

WORKDIR /etc/nginx

# Create self-signed cert and set the nginx to use it for ssl/tls connections.
RUN set -x \ 
    && apt update \
    && mkdir certs \
    && apt install openssl -y\
    && openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
        -subj "/C=AU/ST=VIC/L=Mel/O=example inc/CN=www.example.com" \
        -keyout certs/www.example.com.key  -out certs/www.example.com.cert

COPY nginx.conf .

EXPOSE 443/tcp
