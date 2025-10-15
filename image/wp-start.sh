#!/bin/bash
echo "Starting..."
if [[ $PHP_MIN_WORKERS == "" ]]; then
	echo "Unable to read environment"
	exit 1
fi

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
	HYPHEN=""
	SUBDOM=""
	if [[ "$WP_LANG" != "" ]]; then
		HYPHEN="-${WP_LANG}"
		SUBDOM="${WP_LANG}."
	fi
	# Install Wordpress
	sha1=$(curl -s "https://${SUBDOM}wordpress.org/wordpress-${WP_VER}${HYPHEN}.tar.gz.sha1"); 
	wpurl="https://${SUBDOM}wordpress.org/wordpress-${WP_VER}${HYPHEN}.tar.gz"
	echo "Downloading from: $wpurl ..."
	curl -o wordpress.tar.gz -fL $wpurl
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
					patch_file="/var/www/wp-config.patch"
					dos2unix "$settings"
					dos2unix "$patch_file"

					patch -u "$settings" -i "$patch_file"
					apk del patch
					rm "$patch_file"

					# HTTPS Rules
					if [[ "$HTTPS_DOMAIN" != "" ]]; then
						sed -i "s/HTTPS_DOMAIN/$HTTPS_DOMAIN/" $settings
					  sed -i "s/ssl=false/ssl=true/" $settings
					else
					  sed -i "s/'HTTPS_DOMAIN'/\$_SERVER['HTTP_HOST']/" $settings
					fi
					# DB_NAME
					sed -i "s/database_name_here/$DB_NAME/" $settings
					# DB_USER
					sed -i "s/username_here/$DB_USER/" $settings
					# DB_PASSWORD
					sed -i "s/password_here/${DB_PASS:-$DB_PASSWORD}/" $settings
					# DB_HOST
					sed -i "s/localhost/${DB_HOST}/" $settings
					# DB_PORT
					sed -i "s/ 3306 / ${DB_PORT:-3306} /" $settings
					# DB_SSL
					sed -i "s/db_ssl_enabled/${DB_SSL}/" $settings
					# DB_CHARSET
					sed -i "s/utf8/${DB_CHARSET}/" $settings
					# WP_PREFIX
					sed -i "s/'wp_'/'${WP_PREFIX}'/" $settings
					# Keys: (sed in alpine needs to match somehow an index in order to replace once)
					for j in {50..65}; do
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

init_script=${INIT_SCRIPT:-"/home/init.sh"}
if [[ ! -f $init_script ]]; then
	init_script="/var/www/wp-content/init.sh";
fi
if [[ -f "$init_script" ]]; then
	echo "Starting custom script..."
	chmod +rx "$init_script"
	bash "$init_script"
	chmod -rwx "$init_script"
	echo "Custom script executed."
else
	echo "INFO: You can customize this site by adding 'init.sh' script under 'wp-content' directory";
fi

# Lock root:
chown root:root /var/www/
chown root:root /var/www/*
chown lighttpd:lighttpd /var/www/wp-content/

WP_CONF="/etc/lighttpd/lighttpd-wp.conf"
if [[ -f $WP_CONF ]]; then
	cat $WP_CONF >> /etc/lighttpd/lighttpd.conf
else
	echo "WP patch for lighttpd not found"
fi

# Executing PHP start.sh
/usr/local/bin/start.sh
