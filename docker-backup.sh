#!/bin/bash

BACKUP_DIR="/srv/backups"

get_site_name () {
  local container_name=$1
  echo $(docker inspect --format='{{ index .Config.Labels "backup.domain"}}' $container_name)
}


backup_volume () {
  local container_name=$1
  local container_backup_path=$2 #/var/lib/mysql || /var/www/html/wp-content
  local backup_type=$3 # site || db

  local host_backup_path="$BACKUP_DIR/$site_name"
  mkdir -p $host_backup_path

  local file_name="$backup_type"_$(date "+%Y-%m-%d").tar.gz
  echo $file_name

  docker run --rm --volumes-from=$container_name -v $host_backup_path:/backup ubuntu bash -c "cd $container_backup_path; tar cfz /backup/"$file_name" ./"
}

site_containers=$(docker container ls --filter=label=backup.site --format='{{.Names}}')
db_containers=$(docker container ls --filter=label=backup.db --format='{{.Names}}')

# Backup wordpress sites
for container_name in $site_containers
do
 site_name=$(get_site_name $container_name)
 backup_volume $container_name "/var/www/html/wp-content" "site"
done

# Backup databases
for container_name in $db_containers
do
 site_name=$(get_site_name $container_name)
 host_backup_path="$BACKUP_DIR/$site_name"
 file_name=db_$(date "+%Y-%m-%d").sql.gz

 docker exec $container_name bash -c '/usr/bin/mysqldump -u root --password=$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE | gzip -c > /tmp/backup.sql'
 docker cp $container_name:/tmp/backup.sql $host_backup_path/$file_name
 docker exec $container_name bash -c "rm /tmp/backup.sql"
done 
