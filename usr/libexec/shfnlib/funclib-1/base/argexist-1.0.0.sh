#!/bin/sh
function argexist {
#[of]:  usage
  if [[ -z "$1" ]] ; then
    echo "Usage: argexist arg [argline]"
    echo "Error: must have at least 1 argument"
    echo "Description: looks for arg in argline"
    echo "    note, this only searches one arg at a time.  also, if no argline is specified gl_progargs is used."
    echo "Examples:"
    echo '    argexist arg $gl_progargs'
    echo "  it works good in if blocks"
    echo '    if [ ${gl_return} -eq 0 ] || argexist arg ; then'
    echo "      echo do something"
    echo "    fi"
    echo "Returns:"
    echo "  0 true"
    echo "  1 false"
    exit 1
  fi
#[cf]
  lc_argexist_arg="$1"
  shift
  if [[ -n "$*" ]] ; then
    lc_argexist_argline="$@"
  else
    lc_argexist_argline="${gl_progargs}"
  fi
  if [[ -n "${lc_argexist_argline}" ]] ; then
    for lc_argexist_current in ${lc_argexist_argline}
    do
      [[ "${lc_argexist_arg}" = "${lc_argexist_current}" ]] && return 0
    done
  fi
  return 1
}
