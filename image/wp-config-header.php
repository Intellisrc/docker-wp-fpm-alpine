<?php
$ssl=false;
define('MY_SITE','HTTPS_DOMAIN');
$_SERVER['HTTP_HOST'] = MY_SITE;
define('WP_HOME','http'.($ssl ? 's' : '').'://'.MY_SITE);
define('WP_SITEURL','http'.($ssl ? 's' : '').'://'.MY_SITE);
$_SERVER['HTTPS'] = $ssl ? 'on' : 'off';

define('FS_METHOD', 'direct');
