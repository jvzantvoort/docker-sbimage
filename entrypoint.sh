#!/bin/bash
#===============================================================================
#
#         FILE:  entrypoint.sh
#
#        USAGE:  entrypoint.sh
#
#  DESCRIPTION:  Bash script
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  John van Zantvoort, John@------------.org
#      COMPANY:  none
#      CREATED:  18-Jul-2017
#===============================================================================

declare -r CONST_SCRIPTPATH="$(readlink -f $0)"
declare -r CONST_SCRIPTNAME="$(basename $CONST_SCRIPTPATH .sh)"
declare -r CONST_SCRIPTDIR="$(dirname $CONST_SCRIPTPATH)"
declare -r CONST_FACILITY="local0"
declare -xr LANG="C"

function logging()
{
  local priority="$1"; shift
  logger -p ${CONST_FACILITY}.${priority} -i -s -t "${CONST_SCRIPTNAME}" -- "${priority} $@"
}

function logging_err()
{
  logging "err" "$@"
}

function logging_info()
{
  logging "info" "$@"
}

function script_exit()
{
  local STRING="$1"
  local RETV="${2:-0}"
  if [ "$RETV" = "0" ]
  then
    logging_info "$STRING"
  else
    logging_err "$STRING"
  fi
  exit $RETV
}

#------------------------------------------------------------------------------#
#                                    Main                                      #
#------------------------------------------------------------------------------#

logging_info "start"

UID=$1; shift
GID=$1; shift

# setup path
#---------------------------------------
sphinx-build -b html \
  -d /tmp/doctrees \
  -N -q \
  sphinxdoc /webroot || script_exit "failed" 1

chown -R "${UID}:${GID}" /webroot/*

rm -rf /tmp/doctrees || script_exit "failed to cleanup" 3

cp -rp  /webroot/* /output

script_exit "end"
#------------------------------------------------------------------------------#
#                                  The End                                     #
#------------------------------------------------------------------------------#
