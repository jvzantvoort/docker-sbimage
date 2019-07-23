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
declare -r CONST_PWD="${PWD}"
declare -xr LANG="C"

function logging()
{
  local priority="$1"; shift
  local lineno="$1"; shift
  printf "%s:%-4d [%s] %s\n" "${CONST_SCRIPTNAME}" "${lineno}" "${priority}" "$@"
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
  local STRING="$1"; shift
  local lineno="$1"; shift
  local RETV="${1:-0}"
  if [ "$RETV" = "0" ]
  then
    logging_info $LINENO "$STRING"
  else
    logging_err $LINENO "$STRING"
  fi
  exit $RETV
}

function cmd_start()
{
  local CMD=$1; shift
  printf " start %-32s\n" "${CMD}" | tr ' ' '-'
}

function cmd_end()
{
  local CMD=$1; shift
  printf " %33s end-\n\n" "${CMD}" | tr ' ' '-'
}

#------------------------------------------------------------------------------#
#                                    Main                                      #
#------------------------------------------------------------------------------#

logging_info $LINENO "start"

G_UID=$1; shift
G_GID=$1; shift
VERSION=$1; shift

VERSION=$(echo $VERSION|sed 's,.*\(........\)$,\1,')

[[ -z "${G_UID}" ]] && G_UID="1001"
[[ -z "${G_GID}" ]] && G_GID="1001"
[[ -z "${VERSION}" ]] && VERSION="none"

logging_info $LINENO "uid: ${G_UID}"
logging_info $LINENO "gid: ${G_GID}"

if [ -x "prebuild" ]
then
  cmd_start "prebuild"
  ./prebuild /webroot
  cmd_end "prebuild"
fi

STRING="sphinx-build"

cmd_start "${STRING}"
sphinx-build -b html \
  -d /tmp/doctrees \
  -N -q \
  -A VERSION="${VERSION}" \
  sphinxdoc /webroot || script_exit "failed" 1
cmd_end "${STRING}"


if [ -x "postprocessor" ]
then
  cmd_start "postprocessor"
  ./postprocessor /webroot
  cmd_end "postprocessor"
fi

cmd_start "fix ownership"
chown --recursive "${G_UID}:${G_GID}" /webroot/*
cmd_end "fix ownership"

STRING="cleanup /tmp/doctrees"
cmd_start "${STRING}"
rm -rf /tmp/doctrees || script_exit "failed to cleanup" 3
cmd_end "${STRING}"

STRING="copy build results to output"
cmd_start "${STRING}"
pushd /webroot
tar -cvf "${CONST_PWD}/output.tar.gz" .
popd
cmd_end "${STRING}"

script_exit $LINENO "end"
#------------------------------------------------------------------------------#
#                                  The End                                     #
#------------------------------------------------------------------------------#
