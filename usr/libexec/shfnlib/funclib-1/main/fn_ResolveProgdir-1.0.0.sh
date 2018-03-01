#!/bin/sh
function fn_ResolveProgdir {
#[of]:  usage
  if false ; then
    echo "Usage: fn ResolveProgdir"
    echo "Error: none"
    echo "Description: determins and sets gl_progdir with a full qualified path"
    echo "  gl_basedir and gl_interface are both derived from gl_progdir"
    echo "  this allows a script and support files to be moved around without editing"
    echo "Examples: same as usage"
    echo "Returns:"
    echo "  0 success"
    exit 1
  fi
#[cf]
  ##if gl_basedir has not been set figure out where we are
  ##working dir is based on script location it must be placed in a bin dir but not /bin or /usr/bin
  ##the parent directory must be named bin and its parent should be a vendor shortname
  if [ "${gl_pathprogname%/*}" = "${gl_pathprogname}" ] ; then
    gl_progdir="`pwd`"
    msgdbg 3 "called from current dir ${gl_progdir}"
  else
    msgdbg 3 "called from dir `pwd`"
    if pushd "${gl_pathprogname%/*}" ; then
      gl_progdir="`pwd`"
      msgdbg 3 "script lives at ${gl_progdir}"
      popd
    else
      msgdbg 0 "very very strange - we could not change to the location the script is running from"
      msgdbg 0 "really - this should never happen - perhaps permissions are wrong"
      exit 1
    fi
  fi
  return 0
}
