# Base image
FROM debian:bookworm

# Install MariaDB & delete the packege list
RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/list/*

# delete database initialized files
RUN rm -rf /var/lib/mysql/*

# make dirctory runtime for mariadb & logs
RUN mkdir -p /var/run/mysqld  /var/log/mysql \
    && chown -R mysql:mysql /var/run/mysqld var/log/mysql \
    && chmod 755 /var/run/mysqld

# bring the conf and the setup to the container
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/
COPY tools/init_madb.sh /usr/local/bin/

# give the file execute permission 
RUN chmod +x /usr/local/bin/init_madb.sh

# see the port 3306
EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/init_madb.sh"]
