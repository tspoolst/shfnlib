#!/bin/bash

##if using bash insure extglob is on
[[ -n "$BASH_VERSION" ]] && shopt -s extglob

#[of]:function isdir {
function isdir {
#[of]:  usage
  if [[ -z "$1" ]] ; then
    echo "Usage: isdir dirname"
    echo "Error: must have at least 1 argument"
    echo "Description: a simplified way of testing if something is a directory."
    echo "Examples:"
    echo '  "if isdir /home ; then'
    echo '    echo is a dir'
    echo '  else'
    echo '    echo is not a dir'
    echo '  fi"'
    echo '  statement may also be negated'
    echo '    "if ! isdir /home ; then"'
    echo "Returns:"
    echo "  0 true"
    echo "  1 false"
    exit 1
  fi
#[cf]
  [[ -d "$1" ]] && return 0
  return 1
}
#[cf]
#[of]:function isdirempty {
function isdirempty {
#[of]:  usage
  if [[ -z "$1" ]] ; then
    echo "Usage: isdiremput dirname"
    echo "Error: must have at least 1 argument"
    echo "Description: check if a directory is empty."
    echo "Examples:"
    echo '  "if isdirempty /home ; then'
    echo '    echo dir is empty'
    echo '  else'
    echo '    echo dir containes files'
    echo '  fi"'
    echo '  statement may also be negated'
    echo '    "if ! isdirempty /home ; then"'
    echo "Returns:"
    echo "  0 true"
    echo "  1 false"
    exit 1
  fi
#[cf]
  ## if target is not a dir just return false
  [[ -d "$1" ]] || return 1
  
  ls -a "$1" | grep -q -v -e '^\.$' -e '^\..$' && return 1 || return 0
}
#[cf]
#[of]:function isfile {
function isfile {
#[of]:  usage
  if [[ -z "$1" ]] ; then
    echo "Usage: isfile filename"
    echo "Error: must have at least 1 argument"
    echo "Description: a simplified way of testing if something is a file."
    echo "Examples:"
    echo '  "if isfile /home/file ; then'
    echo '    echo is a file'
    echo '  else'
    echo '    echo is not a file'
    echo '  fi"'
    echo '  statement may also be negated'
    echo '    "if ! isfile /home/file ; then"'
    echo "Returns:"
    echo "  0 true"
    echo "  1 false"
    exit 1
  fi
#[cf]
  [[ -f "$1" ]] && return 0
  return 1
}
#[cf]
#[of]:function isfilelocked {
function isfilelocked {
#[of]:  usage
  if false ; then
    echo "Usage: isfilelocked {filename}"
    echo "Error: must have at least 1 argument"
    echo "Description: checks if {filename} is locked by a process"
    echo "Examples:"
    echo '  "if isfilelocked "testfile.txt" ; then'
    echo '    echo is locked'
    echo '  else'
    echo '    echo is unlocked'
    echo '  fi"'
    echo '  statement may also be negated'
    echo '    "if ! isfilelocked "testfile.txt" ; then"'
    echo "Returns:"
    echo "  0 true"
    echo "  1 false"
    exit 1
  fi
#[cf]
  [[ -n $(fuser "$1" 2>/dev/null) ]]
}
#[cf]
#[of]:function isinpath {
function isinpath {
#[of]:  usage
  if false ; then
    echo "Usage: isinpath arg"
    echo "Error: must have at least 1 argument"
    echo "Description: checks if a given prog is in the path"
    echo "Examples:"
    echo '  "if isinpath grep ; then'
    echo '    echo grep is installed'
    echo '  else'
    echo '    echo grep is missing'
    echo '  fi"'
    echo "Returns:"
    echo "  0 true"
    echo "  1 false"
    exit 1
  fi
#[cf]
  which "$1" >/dev/null 2>&1
}
#[cf]
#[of]:function isnum {
function isnum {
#[of]:  usage
  if false ; then
    echo "Usage: isnum arg"
    echo "Error: must have at least 1 argument"
    echo "Description: checks if arg is a number"
    echo "Examples:"
    echo '  "if isnum 50 ; then'
    echo '    echo is a number'
    echo '  else'
    echo '    echo is not a number'
    echo '  fi"'
    echo '  statement may also be negated'
    echo '    "if ! isnum 50 ; then"'
    echo "Returns:"
    echo "  0 true"
    echo "  1 false"
    exit 1
  fi
#[cf]
  #set IFS to a sane value
  typeset IFS=' 	
'
  if [[ "$1" == ?(+|-)+([0-9]) ]] ; then
   return 0
  fi
  return 1
}
#[cf]
#[of]:function isset {
function isset {
#[of]:  usage
  if false ; then
    echo "Usage: isset var"
    echo "Error: must have at least 1 argument"
    echo "Description: checks if a given variable is set (i.e. exist)"
    echo "Examples:"
    echo '  "if isset your_var ; then'
    echo '    echo your variable is set'
    echo '  else'
    echo '    echo your variable is not set'
    echo '  fi"'
    echo '  statement may also be negated'
    echo '    "if ! isset your_var ; then"'
    echo "Returns:"
    echo "  0 true"
    echo "  1 false"
    exit 1
  fi
#[cf]
  eval "(( \${$1+1} ))"
}
#[cf]
#[of]:function istextfile {
function istextfile {
#[of]:  usage
  if [[ -z "$1" ]] ; then
    echo "Usage: istextfile filename"
    echo "Error: must have at least 1 argument"
    echo "Description: checks if filename is a textfile"
    echo "Examples:"
    echo '  "if istextfile /home/file ; then'
    echo '    echo is a textfile'
    echo '  else'
    echo '    echo is not a textfile'
    echo '  fi"'
    echo '  statement may also be negated'
    echo '    "if ! istextfile /home/file ; then"'
    echo "Returns:"
    echo "  0 true"
    echo "  1 false"
    exit 1
  fi
#[cf]
  [[ `file "$1" | grep -c -e script -e ascii -e text 2>/dev/null` -gt 0 ]] && return 0
  return 1
}
#[cf]
#[of]:function isuser {
function isuser {
#[of]:  usage
  if [[ -z "$1" ]] ; then
    echo "Usage: isuser {user}"
    echo "Error: must have at least 1 argument"
    echo "Description: checks if the current user matches user"
    echo "Examples:"
    echo '  "if isuser batch ; then'
    echo '    echo user is batch'
    echo '  else'
    echo '    echo user is not batch'
    echo '  fi"'
    echo '  statement may also be negated'
    echo '    "if ! isuser batch ; then"'
    echo "Returns:"
    echo "  0 true"
    echo "  1 false"
    exit 1
  fi
#[cf]
  typeset _user="$1"
  [[ $(set -- $(id);a=${1#*\(};echo ${a%\)}) = "${_user}" ]]
}
#[cf]
