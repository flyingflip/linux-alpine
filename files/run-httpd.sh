#!/bin/bash

export DOCROOT="/var/www/html/web"

# Symlink appropriate directories into the drupal document root
# It would be good to have a more dynamic way to do this
# to support other use cases
if [ -f "$DOCROOT/../.mounts" ]; then
  while read p; do
    src=$(echo $p | cut -f1 -d:)
    dst=$(echo $p | cut -f2 -d:)

    # Removes existing files and directories without existing symlinks as a precaution
    if [[ !(-L "$dst") && -e "$dst" ]]; then
      rm -fR "$dst"
    fi

    # Make sure the directory one level above $dest so the symbolic link will not fail
    mkdir -p ${dst%/*}

    ln -sf $src $dst
    chmod -R 777 $dst

    echo $src $dst
  done < $DOCROOT/../.mounts
fi

apachectl start
tail -f /var/log/apache2/error.log
