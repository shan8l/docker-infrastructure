# Developer Documentation

## Prerequisites

Required software:

* VirtualBox
* Debian Virtual Machine
* Docker
* Docker Compose
* Make

## Project Structure

```text
Inception
├── Makefile
├── srcs
│   ├── docker-compose.yml
│   └── requirements
│       ├── mariadb
│       ├── nginx
│       └── wordpress
```

## Build and Launch

Build and start:

```bash
make
```

Stop:

```bash
make down
```

Restart:

```bash
make re
```

## Container Management

Show running containers:

```bash
docker ps
```

Show logs:

```bash
make logs
```

Show networks:

```bash
docker network ls
```

Show volumes:

```bash
docker volume ls
```

## Data Persistence

MariaDB data is stored in:

```text
/home/hqasqas/data/mariadb
```

WordPress files are stored in:

```text
/home/hqasqas/data/wordpress
```

Docker volumes ensure data remains available even if containers are recreated.

## Infrastructure Design

NGINX acts as the single entry point.
