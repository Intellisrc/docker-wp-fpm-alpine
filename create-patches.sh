#!/bin/bash
diff -u wp-config-sample.php wp-config-custom.php > image/wp-config.patch
diff -u wp-config-sample-ja.php wp-config-custom-ja.php > image/wp-config-ja.patch
