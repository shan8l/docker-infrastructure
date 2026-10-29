*This activity has been created as part of the 42 curriculum by hqasqas.*

# Inception


## Description

Inception is a system administration project whose goal is to design and deploy a small, containerized web infrastructure using Docker and Docker Compose, built entirely from custom Dockerfiles (no pre-built third-party images).

```text
                        ┌─────────────────────┐
   HTTPS (443)          │        NGINX        │
   ────────────────────▶│  TLS 1.2/1.3 only  │
                        └──────────┬──────────┘
                                   │ FastCGI (9000)
                        ┌──────────▼───────────┐
                        │      WordPress       │
                        │      + PHP-FPM       │
                        └──────────┬───────────┘
                                   │ MySQL (3306)
                        ┌──────────▼───────────┐
                        │       MariaDB        │
                        └──────────────────────┘

        ┌─────────────┐   ┌─────────────┐     <.............>    ┌────┐ 
        │image docker │   │ volumes     │       line network     │port│
        └─────────────┘   └─────────────┘                        └────┘
```

The infrastructure comprises:
- NGINX: Reverse proxy and web server with TLS/SSL encryption
- WordPress + PHP-FPM: Application server for WordPress content management
- MariaDB: Database backend for WordPress data persistence
- Docker Network: Custom bridge network enabling secure inter-container communication
- Docker Volumes: Named volumes for database and website file persistence


## Instructions

### Prerequisites

Prerequisites

- Docker and Docker Compose installed
- A virtual machine or Linux environment
- make utility
- sudo privileges (for volume cleanup)

### Setup

1. **Clone/navigate to the project directory**
   ```bash
   cd 42_inception
   ```

2. **Configure your domain (hosts file)**
   Add the following line to `/etc/hosts`:
   ```
   127.0.0.1 hqasqas.42.fr
   ```

3. **Build and start services**
   ```bash
   make
   ```
   This will:
   - Create necessary data directories
   - Build Docker images
   - Start all containers

### Common Commands

| Target | Purpose |
|---|---|
| `make up` | Build and start everything (same as `make`) |
| `make down` | Stop and remove containers (keeps data and images) |
| `make down-v` | stop and remove volumes |
| `make clean` | `down-v` + clean up images and containers |
| `make fclean` | `clean` + remove volumes and host data directories |
| `make re` | Full rebuild from scratch (`fclean` then `up`) |
| `make logs` | Follow logs of all containers |
| `make ps` | Show container status |

### Access

- **Website**: https://hqasqas.42.fr
- **WordPress Admin**: https://hqasqas.42.fr/wp-admin
- **Default Admin**: Check `secrets/credentials.txt`


## Project Description: Docker and Design Choices


This project demonstrates core Docker concepts through a three-tier architecture:

1. **Frontend Layer**: NGINX container handling HTTP/HTTPS traffic
2. **Application Layer**: WordPress + PHP-FPM processing dynamic content
3. **Data Layer**: MariaDB storing application data

All containers communicate via a custom Docker bridge network, ensuring isolation and security.

#### Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker Containers |
|--------|------------------|-------------------|
| **Overhead** | High (full OS per VM) | Low (shared kernel) |
| **Boot Time** | Minutes | Seconds |
| **Portability** | Moderate (VM format dependent) | Excellent (container = image) |
| **Use Case** | Heavy isolation, legacy apps | Microservices, cloud-native |

**Choice**: Docker chosen for efficiency and modern infrastructure practices.

#### Secrets vs Environment Variables

| Aspect | Environment Variables | Docker Secrets |
|--------|----------------------|-----------------|
| **Visibility** | Accessible to processes, visible in `ps` | Only mounted, not in env |
| **Security** | Lower (process inspection) | Higher (file-based, not exposed) |
| **Persistence** | Ephemeral | Persisted in compose |
| **Use Case** | Non-sensitive config (domain, user IDs) | Sensitive data (passwords, keys) |

**Choice**: Secrets for passwords/credentials, environment variables for configuration.

#### Docker Network vs Host Network

| Aspect | Docker Network | Host Network |
|--------|---------------|--------------|
| **Isolation** | Full (containers isolated) | None (containers share host stack) |
| **Security** | High (network namespace) | Lower (exposed to host) |
| **Service Discovery** | Built-in DNS (service name) | Localhost only |
| **Port Conflicts** | Managed per container | Can conflict with host |

**Choice**: Custom bridge network for security, DNS resolution, and proper isolation.

#### Docker Volumes vs Bind Mounts

| Aspect | Docker Volumes | Bind Mounts |
|--------|----------------|------------|
| **Management** | Docker-managed | Host filesystem path |
| **Portability** | High (OS-independent) | Lower (path-dependent) |
| **Performance** | Optimized | Good |
| **Persistence** | Managed by Docker | Manual management |
| **Use Case** | Stateful apps, databases | Development, source code |

**Choice**: Named volumes for database and website files (production-grade, managed persistence).

### Security Considerations

- **TLS/SSL**: Self-signed certificates generated at startup, TLSv1.2+ enforced
- **Network Isolation**: Only NGINX exposed via port 443; other services isolated
- **Secrets Management**: Passwords stored in Docker Secrets, not environment variables
- **Image Security**: No latest tags, specific versions pinned
- **Database**: Separate admin and application users with limited privileges

### Data Persistence

- **Database**: `mariadb_data` volume → `/home/<user>/data/mariadb`
- **Website Files**: `wordpress_data` volume → `/home/<user>/data/wordpress`
- **Automatic Startup**: Containers restart on failure via `restart: always`


## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose file reference](https://docs.docker.com/compose/compose-file/)
- [WP-CLI documentation](https://wp-cli.org/)
- [WordPress Codex — wp-config.php](https://developer.wordpress.org/apis/wp-config-php/)
- [NGINX documentation — FastCGI](https://nginx.org/en/docs/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [Alpine Linux `apk` package index](https://pkgs.alpinelinux.org/packages)





### AI Usage

AI was used in this project for:
- **Documentation**: README and technical documentation drafting
- **Debugging**: Troubleshooting Docker networking and volume mount issues
- **Configuration**: NGINX configuration templates and PHP-FPM pool configuration

All AI-generated content was reviewed, tested, and modified to ensure correctness and compliance with project requirements.