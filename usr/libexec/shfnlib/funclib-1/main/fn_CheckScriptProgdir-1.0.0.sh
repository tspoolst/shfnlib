#!/bin/sh
function fn_CheckScriptProgdir {
#[of]:  usage
  if false ; then
    echo "Usage: fn CheckScriptProgdir"
    echo "Error: none"
    echo "Description: validates gl_progdir based on selected criteria"
    echo "  this allows a script and support files to be moved around without editing"
    echo "Examples: same as usage"
    echo "Returns:"
    echo "  0 success"
    exit 1
  fi
#[cf]
##working dir is based on script location it must be placed in a bin dir but not /bin or /usr/bin
##the parent directory must be named bin and its parent should be a customer shortname
  
  if [[ "${gl_progdir##*/}" != "bin" ]] ; then
    msgdbg 0 "this script must be ran from within a bin directory. i.e. /interfaces/vendor/bin"
    exit 1
  fi
  if [[ "${gl_progdir}" = "/bin" || "${gl_progdir}" = "/usr/bin" ]] ; then
    msgdbg 0 "refusing to run from system directories.  put this script somewhere else."
    exit 1
  fi
  return 0
}
