#!/bin/bash

#[c]gl_debuglevel=2

gl_funcdir=$(cd ${0%/*};pwd)
gl_funclib=functions-${1:-1}.sh
if [[ ! -e "${gl_funcdir}/${gl_funclib}" ]] ; then
  echo "${gl_funcdir}/${gl_funclib} does not exist.  check your path" >&2
  exit 1
elif [[ ! -r "${gl_funcdir}/${gl_funclib}" ]] ; then
  echo "$0 does not have read permissions to ${gl_funcdir}/${gl_funclib}" >&2
  exit 2
else
  . "${gl_funcdir}/${gl_funclib}"
fi

###set $gl_basedir only if in a different location from the script
###set $gl_interface only if different from the directory derived name
gl_basedir=.

###########################################################################################################
## main
##
###########################################################################################################

#fn ScriptInit

fn GlobalUsage $2
