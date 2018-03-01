#!/bin/sh
function fn_CheckScriptBasedir {
#[of]:  usage
  if false ; then
    echo "Usage: fn CheckScriptBasedir"
    echo "Error: none"
    echo "Description: determins gl_basedir and gl_interface based on selected criteria"
    echo "  this allows a script and support files to be moved around without editing"
    echo "Examples: same as usage"
    echo "Returns:"
    echo "  0 success"
    exit 1
  fi
#[cf]
##if gl_basedir has not been set figure out where we are
##working dir is based on script location it must be placed in a bin dir but not /bin or /usr/bin
##the parent directory must be named bin and its parent should be a customer shortname
  if [[ -z "${gl_basedir}" ]] ; then
    if [[ "${gl_pathprogname%/*}" = "${gl_pathprogname}" ]] ; then
      gl_basedir="`pwd`"
      msgdbg 3 "called from current dir ${gl_basedir}"
    else
      msgdbg 3 "called from dir `pwd`"
      if pushd "${gl_pathprogname%/*}" ; then
        gl_basedir="`pwd`"
        msgdbg 3 "script lives at ${gl_basedir}"
        popd
      else
        msgdbg 0 "very very strange - we could not change to the location the script is running from"
        msgdbg 0 "really - this should never happen - perhaps permissions are wrong"
        exit 1
      fi
    fi
    if [[ "${gl_basedir##*/}" != "bin" ]] ; then
      msgdbg 0 "this script must be ran from within a bin directory. i.e. /interfaces/vendor/bin"
      exit 1
    fi
    if [[ "${gl_basedir}" = "/bin" || "${gl_basedir}" = "/usr/bin" ]] ; then
      msgdbg 0 "refusing to run from system directories.  put this script somewhere else."
      exit 1
    fi
    gl_basedir="${gl_basedir%/*}"
    gl_interface="${gl_basedir##*/}"
    msgdbg 3 "gl_basedir=${gl_basedir}"
  fi
  return 0
}
# vim:number:tabstop=2:shiftwidth=2:autoindent:foldmethod=marker:foldlevel=0:foldmarker=#[of]\:,#[cf]
