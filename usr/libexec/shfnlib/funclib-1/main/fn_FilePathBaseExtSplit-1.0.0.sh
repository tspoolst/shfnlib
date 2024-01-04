#!/bin/bash
fn_FilePathBaseExtSplit() {
#[of]:  usage
  if [ -z "$2" ] ; then
    echo "Usage: fn FileBaseExtSplit pathvar [basevar] [extvar] file"
    echo "Error: must have at least 2 arguments"
    echo "Description:"
    echo "  splits a filename into path, base, and extion"
    echo "  a basevar"
    echo "  splits a filename into path, base, and extion"
    echo "Examples:"
    echo '  fn FileBaseExtSplit lc_RotateFiles_path lc_RotateFiles_base lc_RotateFiles_ext ${lc_RotateFiles_file}'
    echo "Returns:"
    echo "  0 success"
    exit 1
  fi
#[cf]
  typeset lc_FilePathBaseExtSplit_file
  eval lc_FilePathBaseExtSplit_file=\"\$$#\"
  
  eval $1=\$\(filepath - \"\${lc_FilePathBaseExtSplit_file}\"\)

  if [[ $# -eq 3 ]] ; then
    eval $2=\$\(filename - \"\${lc_FilePathBaseExtSplit_file}\"\)
  elif [[ $# -eq 4 ]] ; then
    eval $2=\$\(filebase - \"\${lc_FilePathBaseExtSplit_file}\"\)
    eval $3=\$\(fileext - \"\${lc_FilePathBaseExtSplit_file}\"\)
  fi

  msgdbg 3 "${lc_FilePathBaseExtSplit_file} ${lc_FilePathBaseExtSplit_base} ${lc_FilePathBaseExtSplit_ext}"
  return 0
}
