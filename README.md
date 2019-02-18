# Docker Infrastructure

This repo contains the configuration and documentation for hosting multiple WordPress sites on a single server using Docker/Docker Compose and Traefik

## Traefik

Note: The Traefik configuration is not currently part of the repo because I need to figure out how to safely commit it

The Traefik container must be running before the WordPress/MYSQL containers can run

https://www.digitalocean.com/community/tutorials/how-to-use-traefik-as-a-reverse-proxy-for-docker-containers-on-ubuntu-16-04  


## WordPress

Follow the [docker_wordpress_template/README.md](./docker_wordpress_template/README.md) for setup a new WordPress sites.

## Backups

To backup the WordPress sites run `sudo bash ./docker-backup.sh`  
This script will backup the `wp-content` folders for all containers with the `backup.site` label and will preform a SQL dump for all containers with the `backup.db` label. These labels are part of the docker_wordpress_conf/docker-compose.yml file by default

Backups are saved to `/srv/backups/SITE_NAME`

## Restoring Backups

Start (run `docker-compose up -d`) the containers you are restoring, then run the following

```sh 
# Restore Database
cat SQL_DUMP.sql | docker exec -i CONTAINER bash -c '/usr/bin/mysql -u root --password=$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE'

# Restore Site
docker run --rm --volumes-from=CONTAINER -v /srv/backups/SITE_NAME:/backup ubuntu bash -c "cd /var/www/html/wp-content && tar xvf /backup/BACKUP_FILE.tar"
```

## TODO:

- [ ] Schedule backups with cron
- [ ] Encrypt backups
- [ ] Write script to copy backups to another server
- [ ] Commit Traefik config
