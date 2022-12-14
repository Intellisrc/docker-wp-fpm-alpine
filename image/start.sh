#!/bin/bash
install=false
if [[ -f /var/www/wp-config.php ]]; then
	curr_ver=$(awk '/^\$wp_version/ { print $3 }' /var/www/wp-includes/version.php | sed "s/[';]//g")
	last_ver=$(curl -s "https://api.wordpress.org/core/version-check/1.7/" | grep -oE 'wordpress-[0-9.]+.zip' | head -n1 | sed -nr 's/.*wordpress-([0-9.]+)\.zip.*/\1/p')
	if [[ "$curr_ver" != "$WP_VER" && "$curr_ver" != "$last_ver" ]]; then
		echo "Updating Wordpress from $curr_ver to $WP_VER..."
		install=true
	fi
else
	echo "Wordpress not found. Installing Wordpress. Version: $WP_VER"
	install=true
fi
if [[ $install == true ]]; then
	# Install Wordpress
	sha1=$(curl -s "https://wordpress.org/wordpress-${WP_VER}.tar.gz.sha1"); 
	curl -o wordpress.tar.gz -fL "https://wordpress.org/wordpress-${WP_VER}.tar.gz"; 
	if echo "$sha1 *wordpress.tar.gz" | sha1sum -c -; then
		if tar -xzf wordpress.tar.gz -C /tmp/; then
			rm wordpress.tar.gz; 
			if chown -R lighttpd:lighttpd /tmp/wordpress/; then
				if [[ -f /var/www/wp-config.php ]]; then
					rm /tmp/wp-config*
					if ! rsync -ia /tmp/wordpress/ /var/www/; then
						echo "Failed to copy wp-content"
						exit 3
					fi
				else
					rsync -ia /tmp/wordpress/ /var/www/;
					settings="/var/www/wp-config-sample.php"
					# DB_NAME
					sed -i "s/database_name_here/$DB_NAME/" $settings
					# DB_USER
					sed -i "s/username_here/$DB_USER/" $settings
					# DB_PASSWORD
					sed -i "s/password_here/${DB_PASS:-$DB_PASSWORD}/" $settings
					# DB_HOST
					sed -i "s/localhost/${DB_HOST}/" $settings
					# DB_CHARSET
					sed -i "s/utf8/${DB_CHARSET}/" $settings
					# Keys: (sed in alpine needs to match somehow an index in order to replace once)
					for j in {30..60}; do
						KEY=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 64 ; echo '')
						sed -i "$j,/put your unique phrase here/{s/put your unique phrase here/$KEY/}" $settings
					done
					mv $settings /var/www/wp-config.php
				fi
				rm -rf /tmp/wordpress/
			else
				echo "Unable to set permissions in tmp"
				exit 2
			fi
		fi
	else
		echo "Wordpress fingerprint failed."
		exit 1
	fi
fi
echo "Starting PHP-FPM...."
php-fpm -D
echo "Starting lighttpd...."
lighttpd -D -f /etc/lighttpd/lighttpd.conf
