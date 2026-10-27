# User Documentation

## Overview

This infrastructure provides:

* NGINX web server with TLS
* WordPress with PHP-FPM
* MariaDB database

## Starting the Project

Run:

```bash
make
```

Check running services:

```bash
make ps
```

## Stopping the Project

Stop containers:

```bash
make down
```

Remove containers, volumes, and images:

```bash
make fclean
```

## Accessing the Website

Website:

```text
https://hqasqas.42.fr
```

WordPress Administration Panel:

```text
https://hqasqas.42.fr/wp-admin
```

## Credentials

Credentials are stored using environment variables.

Administrator credentials are configured during the WordPress setup process.

## Verifying Services

Check containers:

```bash
docker ps
```

Expected services:

* nginx
* wordpress
* mariadb

Verify website availability:

```bash
curl -kI https://hqasqas.42.fr
```

Expected result:

```text
HTTP/1.1 200 OK
```
