#!/bin/bash

function docker_list()
{
  local REPOSITORY="$1"; shift
  docker images | \
    awk -v repo="${REPOSITORY}" '$1 ~ repo { print $3; printf "%s:%s\n", $1, $2  }' | \
    sort -u
}

function cleanall()
{
    docker rm $(docker ps -aq)

    IMAGES="$(docker_list homepage/dev)"
    [[ -z "${IMAGES}" ]] || docker rmi $IMAGES && logging_info "no dev images"

    IMAGES="$(docker_list homepage/prod)"
    [[ -z "${IMAGES}" ]] || docker rmi $IMAGES && logging_info "no prod images"

    IMAGES="$(docker_list '<none>')"
    [[ -z "${IMAGES}" ]] || docker rmi $IMAGES && logging_info "no none images"

}

function build()
{
  local LEVEL=$1
  pushd "${PWD}/docker"
  docker build -t homepage/${LEVEL}:${CONST_VERSION} --file Dockerfile-${LEVEL} --rm .
  popd
}

function run()
{
  local LEVEL=$1; shift
  local SOURCEDIR=$1; shift
  local COMMAND="docker"
  local IMAGE="homepage/${LEVEL}:${CONST_VERSION}"

  logging_info "CONST_TMPDIR: ${CONST_TMPDIR}"
  mkstaging_area || script_exit "creation of staging area failed"
  [[ -z "${STAGING_AREA}" ]] && script_exit "STAGING_AREA empty"
  logging_info "STAGING_AREA: ${STAGING_AREA}"

  mkdir -p ${STAGING_AREA}/webroot

  COMMAND="${COMMAND} run"
  COMMAND="${COMMAND} -v /dev/log:/dev/log"
  COMMAND="${COMMAND} -v ${SOURCEDIR}:/code"
  COMMAND="${COMMAND} -v ${STAGING_AREA}/webroot:/webroot"

  case $LEVEL in 
    prod)
      logging_info "COMMAND: ${COMMAND} -t ${IMAGE}"
      $COMMAND -t ${IMAGE}
      ;;
    dev)
      logging_info "COMMAND: ${COMMAND} -it ${IMAGE}"
      $COMMAND -it ${IMAGE}
      return ;;
  esac

  rsync --delete -a "${STAGING_AREA}/webroot/" "${CONST_OUTPUTDIR}/"

}





logging_start "${CONST_SCRIPTNAME}"

logging_info "$@"

G_ACTION=$1; shift
G_ADDRESS=$1; shift

case $G_ACTION in
  clean) cleanall ;;
  build) build "prod"; build "dev" ;;
  rebuild) cleanall; build "prod"; build "dev" ;;
  run-prod|run) run "prod" $G_ADDRESS;;
  run-dev) run "dev" $G_ADDRESS ;;
esac

logging_end "${CONST_SCRIPTNAME}"




