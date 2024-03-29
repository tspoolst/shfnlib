#!/bin/bash
fn() {
  lc_fn_return=$?
#[of]:  usage
  if [ -z "$1" ] ; then
    echo "Usage: fn [-d] funcname [args]"
    echo "         -d enable line tracing for current function call" 
    echo "Error: fn called with no arguments"
    echo "Description: fn is a wrapper used for:"
    echo "  loading new functions into memory."
    echo "  tracking and returning called function states."
    echo "  tracking the current call chain/tree."
    echo "  enabling/disabling verbose line tracing per each call."
    echo "all main functions labeled fn_* must be called through this function"
    echo "  gl_funcname = current function name"
    echo "  gl_funcfrom = parent calling current function"
    echo "  gl_functree = complete calling tree (used for tracking dependancies)"
    echo "  gl_return   = errorlevel of last called function"
    echo "Examples:"
    echo '  i.e. fn SetVars 1 1 3 lc_func_var1 lc_func_var2 data1 data2 data3'
    echo '  i.e. fn -d AtomicLock ${gl_vardir}/${gl_progname}.lock $$'
    echo "Returns: errerlevel from called function"
    exit 1
  fi
#[cf]
  typeset lc_fn_debug
  case "$1" in
    -d)
      lc_fn_debug=true
      shift
      ;;
    -*)
      echo "fn: \"$1\" is not a valid switch.";echo
      fn
      ;;
  esac
  ##save current errorlevel
  gl_return=${lc_fn_return}
  ##set from function,funcname 
  if [[ -z "${gl_funcname}" ]] ; then
    gl_funcname=${gl_progname}
  fi
  gl_funcfrom=${gl_funcname}
  gl_funcname=fn_$1
  ##add funcname to functree
  gl_functree=${gl_functree:-${gl_funcfrom}}:${gl_funcname}
  ##remove funcname from calling stack
  shift
  [[ ${gl_debuglevel:-0} -ge 2 && -n "${gl_funcname##fn_Msg*}" ]] || [[ ${gl_debuglevel:-0} -ge 5 ]] && \
    echo "$(date +%H%M%S) gl_return=${gl_return:-0} entering: ${gl_functree}" >&2
  [[ ${gl_debuglevel:-0} -ge 4 && -n "${gl_funcname##fn_Msg*}" ]] || [[ ${gl_debuglevel:-0} -ge 5 ]] && \
    echo "       gl_return=${gl_return:-0}  ${gl_funcname}: $# arglist=$@" >&2

  ##check if this function has been loaded
  typeset -f "${gl_funcname}" > /dev/null 2>&1 || {
    ##load the function if not already in memory
    eval "[[ -n \"\$${gl_funcname}\" ]]" && eval "eval \$${gl_funcname}"
    typeset -f "${gl_funcname}" > /dev/null 2>&1 || \
      die 1 "fn: function ${gl_funcname}: has not been defined"
  }

  ${lc_fn_debug:-false} && set -xv
  ##reset errorlevel to previously saved
  errorlevel ${gl_return}
  ##call function
  ${gl_funcname} "$@"
  ##save errorlevel from called function
  gl_return=$?
  ${lc_fn_debug:-false} && set +xv
  [[ ${gl_debuglevel:-0} -ge 2 && -n "${gl_funcname##fn_Msg*}" ]] || [[ ${gl_debuglevel:-0} -ge 5 ]] && \
    echo "$(date +%H%M%S) gl_return=${gl_return:-0} leaving:  ${gl_functree}" >&2
  ##remove called function from stack
  gl_functree=${gl_functree%:*}
  ##restore funcname to parent
  gl_funcname=${gl_funcfrom}
  ##restore funcfrom to next level parent
  gl_funcfrom=${gl_functree%:*}
  gl_funcfrom=${gl_funcfrom##*:}
  #echo name ${gl_funcname}
  #echo from ${gl_funcfrom}
  #echo tree ${gl_functree}
  ##return saved errorlevel
  unset lc_fn_return
  return ${gl_return}
}
