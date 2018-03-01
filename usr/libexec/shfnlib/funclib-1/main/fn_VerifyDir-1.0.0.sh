#!/bin/sh
function fn_VerifyDir {
#[of]:usage
  if [ -z "$1" ] ; then
    echo "Usage: fn VerifyDir DIRECTORY [DIRECTORY]..."
    echo "Error: must have at least 1 argument"
    echo "Description:"
    echo "  checks for existence of one or more directories and rw permissions"
    echo "  if a directory does not exist it will be created"
    echo "Examples:"
    echo '  fn VerifyDir ${gl_tmpdir} ${gl_recvdir} ${gl_senddir} ${gl_logdir} ${gl_histdir}'
    echo "Returns:"
    echo "  0  success"
    echo "  20 location exist but is not a directory"
    echo "  21 requires at least rw access"
    exit 1
  fi
#[cf]
  while [[ -n "$1" ]]
  do
    lc_VerifyDir_dir="$1"
    if [ ! -e "${lc_VerifyDir_dir}" ] ; then
      msgdbg 0 "creating \"${lc_VerifyDir_dir}\""
      mkdir -p "${lc_VerifyDir_dir}"
    elif [[ ! -d "${lc_VerifyDir_dir}" ]] ; then
      msgdbg 0 "\"${lc_VerifyDir_dir}\" exist but is not a directory"
      exit 20
    fi
    (: > "${lc_VerifyDir_dir}"/permcheck-${lc_VerifyDir_dir##*/}.txt)
    if [ $? -ne 0 ] ; then
      msgdbg 0 "${gl_progname##*/} requires at least rw access to \"${lc_VerifyDir_dir}\""
      exit 21
    else
      rm -f "${lc_VerifyDir_dir}"/permcheck-${lc_VerifyDir_dir##*/}.txt
    fi
    shift
  done
  unset lc_VerifyDir_dir
  return 0
}
