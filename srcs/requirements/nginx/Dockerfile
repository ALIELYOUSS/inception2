FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends openssl nginx netcat-openbsd

RUN mkdir -p /etc/nginx/ssl/certs /etc/nginx/ssl/private

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/private/inception.key \
    -out /etc/nginx/ssl/certs/inception.crt \
    -subj "/C=MA/ST=KH/OU=1337/CN=alel-you.42.fr"

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

ENTRYPOINT [ "nginx", "-g", "daemon off;" ] 