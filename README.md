# Docker Infrastructure

This repo contains the configuration and documentation for hosting multiple WordPress sites on a single server using Docker/Docker Compose and Traefik

## Traefik

The Traefik container must be running before the WordPress/MYSQL containers can run

### Create an admin password for Traefik

```sh
sudo apt install apache2-utils
htpasswd -nb admin A_SECURE_PASSWORD
```

Replace `A_SECURE_PASSWORD` with your own password

### Update the `traefik/traefik.toml` file

`entryPoints.dashboard.auth.basic`, replace `USER_NAME:HTPASSWD` with the username and password from the previous command

`acme` set `email` to your email

`acme.domains` used for accessing the traefik admin panel. Update to your desired domain

`docker` set `domain` this should be your site domain

> Note: The linked example lists mutliple domains but for my setup I did not need to do that. Having just one domain listed here seems to work fine even though I am running multple sites.

### Start traefik

From the `traefik` directory run `docker-compose up -d`

Guide for doing some of the above steps: https://www.digitalocean.com/community/tutorials/how-to-use-traefik-as-a-reverse-proxy-for-docker-containers-on-ubuntu-16-04  


## WordPress

Follow the [docker_wordpress_template/README.md](./docker_wordpress_template/README.md) for setup a new WordPress sites.

## Backups

To backup the WordPress sites run `sudo bash ./docker-backup.sh`  
This script will backup the `wp-content` folders for all containers with the `backup.site` label and will perform a SQL dump for all containers with the `backup.db` label. These labels are part of the docker_wordpress_conf/docker-compose.yml file by default

Backups are saved to `/srv/backups/SITE_NAME`

## Restoring Backups

Start the containers you are restoring, then run the following

```sh 
# Restore Database
cat SQL_DUMP.sql | docker exec -i MYSQL_CONTAINER bash -c '/usr/bin/mysql -u root --password=$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE'

# Restore Site
docker run --rm --volumes-from=WP_CONTAINER -v /srv/backups/SITE_NAME:/backup ubuntu bash -c "cd /var/www/html/wp-content && tar xvf /backup/BACKUP_FILE.tar"
```

To find the MYSQL_CONTAINER name and the WP_CONTAINER name cd into the site directory and run `docker-compose.yml`

## TODO:

- [ ] Schedule backups with cron
- [ ] Encrypt backups
- [ ] Write script to copy backups to another server
