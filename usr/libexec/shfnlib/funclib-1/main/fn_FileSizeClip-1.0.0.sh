#!/bin/bash
function fn_FileSizeClip {
#[of]:  usage
  if [[ -z "$2" ]] ; then
    echo "Usage: fn FileSizeClip file chopsize maxsize"
    echo "Error: must have at least 2 arguments"
    echo "Description:"
    echo "  clips file to specified size"
    echo "Examples:"
    echo '  fn FileSizeClip ${gl_logfile} ${gl_logchopsize:-5000} ${gl_logmaxsize:-10000}'
    echo "Returns:"
    echo "  0 success"
  fi
#[cf]
  lc_FileSizeClip_file="$1"
  lc_FileSizeClip_chopsize="$2"
  lc_FileSizeClip_maxsize="$3"
  
  if [[ -e "${lc_FileSizeClip_file}" && $(wc -l "${lc_FileSizeClip_file}" | (read lc_FileSizeClip_filesize;echo ${lc_FileSizeClip_filesize%% *})) -gt ${lc_FileSizeClip_maxsize} ]] ; then
    tail -n ${lc_FileSizeClip_chopsize} "${lc_FileSizeClip_file}" > "${lc_FileSizeClip_file}.tmp"
    mv -f "${lc_FileSizeClip_file}.tmp" "${lc_FileSizeClip_file}"
  fi
  unset lc_FileSizeClip_file
  unset lc_FileSizeClip_size
  unset lc_FileSizeClip_filesize
  return 0
}
