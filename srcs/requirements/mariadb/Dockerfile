FROM debian:bookworm

RUN apt update && apt upgrade -y && apt-get install mariadb-server netcat-openbsd -y

COPY tools/init-table.sh /home/init-table.sh

RUN chmod +x /home/init-table.sh

CMD ["bash", "/home/init-table.sh"]
