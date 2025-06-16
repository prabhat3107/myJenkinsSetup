#!/bin/bash
function print_info {
  echo "########################################################################"
  echo " This will set up docker-compose and Dockerfile for jenkins to run in a "
  echo "container. This will aso install systemd service to start/stop the      "
  echo "docker containers at boot time."
  echo ""
  echo "Installation location : /opt/jenkins"
}

function usage() {
    echo "Usage :  $0 <env>"
    echo " <env> = prod or dev or uat ( in small case )"
}

NO_FORMAT="\033[0m"
F_BOLD="\033[1m"
C_RED="\033[38;5;9m"
C_YELLOW="\033[48;5;11m"

if [[ "$EUID" -ne 0 ]]; then
  echo -e "${F_BOLD}${C_RED}${C_YELLOW} Not running with sudo!! Exiting!!!${NO_FORMAT}"
  exit 1
fi

if [ $# != 1 ]; then
  usage
  exit 1
fi
DEPLOYMENT_ENV=$1

case "$DEPLOYMENT_ENV" in
 "dev"|"prod"|"uat")
 ;;
 *)
    echo "<env> can be prod, dev or uat"
    usage
    exit 1
  ;;
esac

BASE_DIR="/opt/jenkins"
JENKINS_DATA_DIR="$BASE_DIR/$DEPLOYMENT_ENV/jenkins-data"
JENKINS_DOCKER_CERTS="$BASE_DIR/$DEPLOYMENT_ENV/jenkins-docker-certs"

# Check if there is a previous installation


if [ -d "$JENKINS_DATA_DIR" ]; then
  echo -e "${F_BOLD}${C_RED}${C_YELLOW}There is existing installation!! Exiting!!!${NO_FORMAT}"
  exit 1
fi

#Create the necessary Directories
if [ ! -d "$BASE_DIR" ]; then
  install -o $USER -g `id -gn $USER` -d $JENKINS_DATA_DIR
  install -o $USER -g `id -gn $USER` -d $JENKINS_DOCKER_CERTS
fi

if [ ! -d "$BASE_DIR/$DEPLOYMENT_ENV" ]; then
  install -o $USER -g `id -gn $USER` -d $JENKINS_DATA_DIR
  install -o $USER -g `id -gn $USER` -d $JENKINS_DOCKER_CERTS
fi

chown -R $USER:`id -gn $USER` $BASE_DIR

sed -i "s#docker-compose-directory#$BASE_DIR/$DEPLOYMENT_ENV#" jenkins.service
sed -i "s#jenkins-data#$JENKINS_DATA_DIR#" docker-compose.yaml
sed -i "s#jenkins-docker-certs#$JENKINS_DOCKER_CERTS#" docker-compose.yaml

install -o $USER -g `id -gn $USER` docker-compose.yaml $BASE_DIR/$DEPLOYMENT_ENV
install -o $USER -g `id -gn $USER` Dockerfile $BASE_DIR/$DEPLOYMENT_ENV

install -m 644 jenkins.service /etc/systemd/system

systemctl daemon-reload