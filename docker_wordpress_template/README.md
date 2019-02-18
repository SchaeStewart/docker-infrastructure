# Create new WordPress site

``` bash
cp ./docker_wordpress_template ./site_name.com
chmod 775 ./site_name.com
cd ./site_name.com
chmod 664 docker-compose.yml sample.env
mv sample.env .env
nano .env
```

Fill the .env with secure database password and the domain name of your site

Next, start the site and increase the PHP max upload size
```bash
docker-compose up -d
docker-compose exec site bash -c "printf 'php_value upload_max_filesize 128M\nphp_value post_max_size 128M\nphp_value max_execution_time 300\n' >> .htaccess" 
```

Navigate to your domain name in the browser and install WordPress

# Turn off WordPress site

```bash
docker-compose down
```


