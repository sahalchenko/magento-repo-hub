#!/bin/bash

dirHtml="/var/www/html"

function prepare() {

# 1. prepare

    mkdir -p $dirHtml/sync
    cp $dirHtml/index.html $dirHtml/sync/index.html
    cp -R $dirHtml/include/ $dirHtml/sync/
    cp -R $dirHtml/p/ $dirHtml/sync/
    cp -R $dirHtml/p2/ $dirHtml/sync/

    find "$dirHtml/sync/" -type f -print0 | while IFS= read -r -d $'\0' file; do
        echo "replace url in file: $file"
        sed -i "s|https://$LOCAL_URL/|$REPO_SYNC_URL|g" "$file"
    done
}

function sync() {

  # 1. create mnt folder

    if [ ! -d "/mnt/$dirHtml" ]; then
       mkdir -p "/mnt/$dirHtml"
    fi


  # 2. mount folder
    echo $REPO_SYNC_PASS | sshfs \
      -o UserKnownHostsFile=/dev/null \
      -o StrictHostKeyChecking=no $REPO_SYNC_USER@$REPO_SYNC_IP:$REPO_SYNC_PATH /mnt/$dirHtml \
      -o password_stdin,allow_other,port=$REPO_SYNC_PORT

  # 3. sync repository
    rsync --progress -r -u -v \
          --exclude 'include' \
          --exclude 'p2' \
          --exclude 'p' \
          --exclude 'sync' \
          --exclude 'public.json' \
          --exclude 'repository' \
          --exclude 'vendor' \
        /$dirHtml/* /mnt/$dirHtml


  # 4. umount dir
    umount /mnt$dirHtml

}

function modified() {

  # 2. create mnt folder

    if [ ! -d "/mnt/$dirHtml" ]; then
       mkdir -p "/mnt/$dirHtml"
    fi


  # 3. mount folder
    echo $REPO_SYNC_PASS | sshfs \
      -o UserKnownHostsFile=/dev/null \
      -o StrictHostKeyChecking=no $REPO_SYNC_USER@$REPO_SYNC_IP:$REPO_SYNC_PATH /mnt/$dirHtml \
      -o password_stdin,allow_other,port=$REPO_SYNC_PORT


  # 4. sync index.html
    rsync --progress -r -u -v /$dirHtml/sync/* /mnt/$dirHtml

  # 5. umount dir
    umount /mnt$dirHtml

  # 6. remove tmp sync folder
    rm -rf $dirHtml/sync

}

prepare
sync
modified