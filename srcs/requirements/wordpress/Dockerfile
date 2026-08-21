FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y php8.2 \
						php-fpm \
						php-mysql \
						curl netcat-openbsd \
						default-mysql-client

COPY ./tools/wp.sh .

RUN chmod +x wp.sh

ENTRYPOINT [ "bash", "./wp.sh" ]
