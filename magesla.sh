#!/bin/bash

###################### SET COLOR SCHEME ######################
red="echo -e \033[31m\033[1m"
green="echo -e \033[32m\033[2m"
orange="echo -e \033[38;2;240;171;0m\033[2m"
nc="\033[0m" # No color

###################### SET FILES CONST ######################
env_file="./compose/env"
docker_file="-f ./compose/docker-compose.yml -f ./compose/docker-mapping.yml"

function setContainerName() {

  WEB_CONTAINER=$(grep '^LOCAL_URL=' "$env_file" | cut -d '=' -f 2 | sed 's/\r$//')
  export LOCAL_URL=$WEB_CONTAINER

}


function build() {

# 1. build project
  eval "LOCAL_URL=$WEB_CONTAINER ${DOCKER_COMPOSE} $docker_file build --no-cache"

}

function restart() {

 # 1. stop and start containers
   ${DOCKER_COMPOSE} $docker_file down
   ${DOCKER_COMPOSE} $docker_file up -d

   permission

}

function setupSSL() {
  # 1. setup ssl
    sudo docker exec -u root -it $WEB_CONTAINER  mkcert -cert-file /etc/nginx/certs/nginx.crt -key-file /etc/nginx/certs/nginx.key $WEB_CONTAINER &>/dev/null

  # 2. restart web server container
    sudo docker restart $WEB_CONTAINER &>/dev/null

  # 3. copy and update ssl on phpfpm
    sudo docker exec -u root -it phpfpm cp /etc/nginx/certs/nginx.crt /usr/local/share/ca-certificates/nginx.crt
    sudo docker exec -u root -it phpfpm update-ca-certificates

}

function updateCA() {
  # 1. copy crt to local machine
   sudo docker cp $WEB_CONTAINER:/etc/nginx/certs/nginx.crt /usr/local/share/ca-certificates/nginx.crt

  # 2. update crt
   sudo update-ca-certificates

}

function run() {

# 1. restart containers
  restart

# 2. setup ssl
  setupSSL
  updateCA

# 3. permission
  permission
}

function stop() {

# 1. stop
  ${DOCKER_COMPOSE} $docker_file down

}

function remove() {

# 1. stop
  eval "LOCAL_URL=$WEB_CONTAINER ${DOCKER_COMPOSE} $docker_file stop"

# 2. remove containers
  echo "y" | eval "LOCAL_URL=$WEB_CONTAINER ${DOCKER_COMPOSE} $docker_file rm"

# 3. remove volumes
  docker volume rm compose_ssldata

# 4. remove images
  docker rmi compose-web
  docker rmi compose-phpfpm
  docker rmi sahalchenko/repo-nginx
  docker rmi sahalchenko/repo-phpfpm

# 5. remove upload dir
  sudo rm -rf ./upload/

# 6. remove html dir
  sudo rm -rf ./html/

# 6. remove report
  sudo rm -rf ./extension.csv

}

function download() {

# 1. upload private repository
   sudo docker exec -it phpfpm /bin/bash -c "chmod +x /rlib/build.sh && /rlib/build.sh"

# 2. permission
  permission

}



function report() {

 # 1. generate report
   sudo docker exec -it phpfpm /bin/bash -c "chmod +x /rlib/report.sh && /rlib/report.sh"
   sudo docker cp $WEB_CONTAINER:/var/www/html/extension.csv ./

 # 2. permission
   permission

}

function sync() {

 # 1. sync
    sudo docker exec -it phpfpm /bin/bash -c "chmod +x /rlib/sync.sh && /rlib/sync.sh"
    sudo docker exec -it phpfpm /bin/bash -c "chmod +x /rlib/sync.sh && /rlib/sync.sh"
}


function permission() {

 # 1. get current user and group
   current_user=$(whoami)
   current_group=$(id -gn $current_user)

 # 2. set permission
   sudo chown -R $current_user:$current_group ./

}

function menu() {

# 1. check installed docker compose or not
  if docker-compose version &>/dev/null; then
      DOCKER_COMPOSE="docker-compose"
  elif docker compose version &>/dev/null; then
      DOCKER_COMPOSE="docker compose"
  else
      $orange 'Docker Compose is not installed.' $nc
      exit
  fi


# 2. set web container name
  setContainerName


# 3. menu
  #clear
  echo "Usage: magesla command"
  echo ""
  echo "Select number action:"
  $green  '0.  Exit '$nc "     - Stop and exit"
  $green  '1.  Build '$nc "    - Build images --no-cache (only dev mode)"
  $orange '2.  Start '$nc "    - Run containers before downloads"
  $orange '3.  Download '$nc " - Download repos. Check credentials.ini files - ./templates/VENDOR dir"
  $green  '4.  Report '$nc "   - Generate report all ext. See current dir    - ./extension.csv"
  $green  '5.  Sync '$nc "     - Sync html data to remote server. Check file - ./compose/env"

  $red '99. Remove '$nc "   - Stop and remove all data project"
  echo ""

}

while true; do
    menu

    read choice

    case $choice in
    0)
        stop
        break
        ;;
    1)
        build
        break
        ;;
    2)
        run
        break
        ;;
    3)
        download
        break
        ;;
    4)
        report
        break
        ;;
    5)
        sync
        break
        ;;
    99)
        remove
        break
        ;;

    *)
        echo "incorrect input. Try again."
        sleep 2
        ;;
    esac
    clear
    echo # clear line
done