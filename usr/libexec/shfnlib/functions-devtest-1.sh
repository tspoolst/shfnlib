#!/bin/bash
#[of]:header

gl_logfile=${0%/*}/functions-devtest-1.log
rm -f ${gl_logfile}

#[of]:function pushd {
function pushd {
  if [ -z "$1" ] ; then
    echo "Usage: pushd dir"
    echo "Error: must have at least 1 argument"
    echo "Description:"
    echo "  pushes the current location onto the stack and changes to the dir specified"
    echo "  in other words - pushd saves the current location"
    echo "Examples: pushd /home/user"
    echo "Returns:"
    echo "  0  success"
    echo "  90 directory does not exist"
    echo "  91 dest exist but is not a directory"
    echo "  92 access denied"
    exit 1
  fi
  if [ -e "$1" ] ; then
    if [ -d "$1" ] ; then
      lc_pushd_cdir="`pwd`"
      cd "$1"
      if [ $? -gt 0 ] ; then
        [ ${gl_debuglevel:-0} -ge 0 ] && echo "pushd: $1 access denied" >&2
        return 92
      fi
      gl_pushpopstack="${lc_pushd_cdir}:${gl_pushpopstack}"
      [ ${gl_debuglevel:-0} -ge 4 ] && echo "pushd: pushpopstack=${gl_pushpopstack}" >&2
    else
      echo "pushd: $1 exist but is not a directory" >&2
      return 91
    fi
  else
    echo "pushd: $1 deos not exist" >&2
    return 90
  fi
  unset lc_pushd_cdir
  return 0
}
#[cf]
#[of]:function popd {
function popd {
#[of]:usage
  if false ; then
    echo "Usage: popd"
    echo "Error: none"
    echo "Description:"
    echo "  pops the topmost dir off the stack and changes to that location"
    echo "  in other words - popd returns us to the most recently saved dir"
    echo "Examples: popd"
    echo "Returns:"
    echo "  0  success"
    echo "  93 previously saved directory no longer exist"
    exit 1
  fi
#[cf]
  if [ -n "${gl_pushpopstack}" ] ; then
    cd "${gl_pushpopstack%%:*}"
    if [ $? -gt 0 ] ; then
      [ ${gl_debuglevel:-0} -ge 0 ] && echo "popd: previously saved directory no longer exist ${gl_pushpopstack%%:*}" >&2
      gl_pushpopstack="${gl_pushpopstack#*:}"
      #### an error level must be reserved
      return 93
    fi
    gl_pushpopstack="${gl_pushpopstack#*:}"
    [ ${gl_debuglevel:-0} -ge 4 ] && echo "popd: pushpopstack ${gl_pushpopstack}" >&2
  else
    echo "popd: directory stack is empty" >&2
    exit 1
  fi
  return 0
}
#[cf]
#[of]:function filepath {
function filepath {
  typeset lc_filepath_relative lc_filepath_path
  if [[ "$1" = "-r" ]] ; then
    lc_filepath_relative=true
    shift
  fi
#[of]:  usage
  if [ -z "$2" ] ; then
    echo "Usage: filepath [-r] {var|-} file"
    echo "Error: must have at least 2 arguments"
    echo "Description:"
    echo "  return the filepath only"
    echo "Options"
    echo "  -r returns relative path"
    echo "Examples:"
    echo "  filepath lc_RotateFiles_path \${lc_RotateFiles_file}"
    echo "Returns:"
    echo "  0 success"
    exit 1
  fi
#[cf]
  ## if file has a path grab the path else use pwd
  if [[ -z "${2##*/*}" ]] ; then
    lc_filepath_path="${2%/*}"
    ##if relative != true, try to grab the absolute path - else just use what was given
    if ! ${lc_filepath_relative:-false} ; then
      if pushd "${lc_filepath_path}" 2>/dev/null ; then
        lc_filepath_path="$(pwd)"
        popd
      fi
    fi
  else
    lc_filepath_path="$(pwd)"
  fi

  if [[ "$1" = "-" ]] ; then
    echo "${lc_filepath_path}"
  else
    eval $1=\"\${lc_filepath_path}\"
  fi
  return 0
}
#[cf]

filepath gl_funcdir ${0%/*}/functions-dev-1.sh
gl_funcdir="${gl_funcdir}"
unset -f pushd popd filepath
. "${gl_funcdir}/functions-dev-1.sh"

#[of]:function checkresult {
function checkresult {
  typeset _lastexitcode=$?
  typeset _checktype="$1"
  shift
#[of]:  case "${_checktype}" in
  case "${_checktype}" in
#[of]:    -v)
    -v)
      if [ "$1" = "$2" ] ; then
        echo "result \"$1\" = \"$2\""
      else
        echo "result \"$1\" != \"$2\""
        echo "${_deathmessage}" >&2
        exit 1
      fi
      ;;
#[cf]
#[of]:    -a)
    -a)
      echo "checkresult option -a {array} checks has yet to be built" >&2
      exit 1
      ;;
#[cf]
#[of]:    -f)
    -f)
      typeset _file1 _file2 _control _test
      _file1="$1"
      _file2="$2"
      set -- $(cksum "${_file1}")
      _control=$(echo "$1 $2")
      set -- $(cksum "${_file2}")
      _test=$(echo "$1 $2")
      if [[ "${_control}" = "${_test}" ]] ; then
        echo "result \"${_file1}\" = \"${_file2}\""
      else
        echo "result \"${_file1}\" != \"${_file2}\""
        echo "${_deathmessage}" >&2
        exit 1
      fi
      ;;
#[cf]
#[of]:    -t)
    -t)
      typeset _test="${1:--eq}"
      typeset _expectedcode=${2:-0}
      if eval [[ \"\${_expectedcode}\" ${_test} \"\${_lastexitcode}\" ]] ; then
        echo "result \"${_expectedcode}\" = \"${_lastexitcode}\""
      else
        echo "result \"${_expectedcode}\" != \"${_lastexitcode}\""
        echo "${_deathmessage}" >&2
        exit 1
      fi
      ;;
#[cf]
#[of]:    *)
    *)
      echo "Usage: checkresult {-v|-a|-t {-eq|-lt|-gt}} {control} {testresult}" >&2
      exit 1
      ;;
#[cf]
  esac
#[cf]
  return 0
}
#[cf]

#[cf]
#[of]:prod-1  argexist
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code argexist-1.0.0.sh:funclib-1/base/argexist-1.0.0.sh
_deathmessage="argexist-1 expected result did not match"
#[l]:test argexist-1:funclib-1/base/argexist-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"argexist\""
if [[ -s "${gl_funcdir}/funclib-1/base/argexist-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/base/argexist-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev argexist-1:funclib-1/base/argexist-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"argexist\""
if [[ -s "${gl_funcdir}/funclib-1/base/argexist-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/base/argexist-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  array
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code array-1.0.0.sh:funclib-1/base/array-1.0.0.sh
_deathmessage="array-1 expected result did not match"
#[l]:test array-1:funclib-1/base/array-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"array\""
if [[ -s "${gl_funcdir}/funclib-1/base/array-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/base/array-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev array-1:funclib-1/base/array-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"array\""
if [[ -s "${gl_funcdir}/funclib-1/base/array-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/base/array-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  die
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code die-1.0.0.sh:funclib-1/base/die-1.0.0.sh
_deathmessage="die-1 expected result did not match"
#[l]:test die-1:funclib-1/base/die-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"die\""
if [[ -s "${gl_funcdir}/funclib-1/base/die-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/base/die-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev die-1:funclib-1/base/die-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"die\""
if [[ -s "${gl_funcdir}/funclib-1/base/die-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/base/die-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  errorlevel
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code errorlevel-1.0.0.sh:funclib-1/base/errorlevel-1.0.0.sh
_deathmessage="errorlevel-1 expected result did not match"
#[l]:test errorlevel-1:funclib-1/base/errorlevel-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"errorlevel\""
if [[ -s "${gl_funcdir}/funclib-1/base/errorlevel-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/base/errorlevel-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev errorlevel-1:funclib-1/base/errorlevel-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"errorlevel\""
if [[ -s "${gl_funcdir}/funclib-1/base/errorlevel-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/base/errorlevel-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  file
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code file-1.0.0.sh:funclib-1/base/file-1.0.0.sh
_deathmessage="file-1 expected result did not match"
#[l]:test file-1:funclib-1/base/file-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"file\""
if [[ -s "${gl_funcdir}/funclib-1/base/file-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/base/file-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev file-1:funclib-1/base/file-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"file\""
if [[ -s "${gl_funcdir}/funclib-1/base/file-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/base/file-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  fn
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code fn-1.0.0.sh:funclib-1/base/fn-1.0.0.sh
_deathmessage="fn-1 expected result did not match"
#[l]:test fn-1:funclib-1/base/fn-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"fn\""
if [[ -s "${gl_funcdir}/funclib-1/base/fn-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/base/fn-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev fn-1:funclib-1/base/fn-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"fn\""
if [[ -s "${gl_funcdir}/funclib-1/base/fn-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/base/fn-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  hash
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code hash-1.1.2.sh:funclib-1/base/hash-1.1.2.sh
_deathmessage="hash-1 expected result did not match"
#[l]:test hash-1:funclib-1/base/hash-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"hash\""
if [[ -s "${gl_funcdir}/funclib-1/base/hash-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/base/hash-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev hash-1:funclib-1/base/hash-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"hash\""
if [[ -s "${gl_funcdir}/funclib-1/base/hash-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/base/hash-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  msgdbg
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code msgdbg-1.0.0.sh:funclib-1/base/msgdbg-1.0.0.sh
_deathmessage="msgdbg-1 expected result did not match"
#[l]:test msgdbg-1:funclib-1/base/msgdbg-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"msgdbg\""
if [[ -s "${gl_funcdir}/funclib-1/base/msgdbg-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/base/msgdbg-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev msgdbg-1:funclib-1/base/msgdbg-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"msgdbg\""
if [[ -s "${gl_funcdir}/funclib-1/base/msgdbg-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/base/msgdbg-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  string
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code string-1.0.0.sh:funclib-1/base/string-1.0.0.sh
_deathmessage="string-1 expected result did not match"
#[l]:test string-1:funclib-1/base/string-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"string\""
if [[ -s "${gl_funcdir}/funclib-1/base/string-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/base/string-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev string-1:funclib-1/base/string-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"string\""
if [[ -s "${gl_funcdir}/funclib-1/base/string-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/base/string-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  test
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code test-1.0.0.sh:funclib-1/base/test-1.0.0.sh
_deathmessage="test-1 expected result did not match"
#[l]:test test-1:funclib-1/base/test-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"test\""
if [[ -s "${gl_funcdir}/funclib-1/base/test-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/base/test-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev test-1:funclib-1/base/test-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"test\""
if [[ -s "${gl_funcdir}/funclib-1/base/test-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/base/test-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  uniqname
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code uniqname-1.0.0.sh:funclib-1/base/uniqname-1.0.0.sh
_deathmessage="uniqname-1 expected result did not match"
#[l]:test uniqname-1:funclib-1/base/uniqname-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"uniqname\""
if [[ -s "${gl_funcdir}/funclib-1/base/uniqname-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/base/uniqname-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev uniqname-1:funclib-1/base/uniqname-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"uniqname\""
if [[ -s "${gl_funcdir}/funclib-1/base/uniqname-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/base/uniqname-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  fn_AtomicLock
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code fn_AtomicLock-1.0.0.sh:funclib-1/main/fn_AtomicLock-1.0.0.sh
_deathmessage="fn_AtomicLock-1 expected result did not match"
#[l]:test fn_AtomicLock-1:funclib-1/main/fn_AtomicLock-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"fn_AtomicLock\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_AtomicLock-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_AtomicLock-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev fn_AtomicLock-1:funclib-1/main/fn_AtomicLock-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"fn_AtomicLock\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_AtomicLock-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_AtomicLock-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  fn_CheckHeaderFooter
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code fn_CheckHeaderFooter-1.0.0.sh:funclib-1/main/fn_CheckHeaderFooter-1.0.0.sh
_deathmessage="fn_CheckHeaderFooter-1 expected result did not match"
#[l]:test fn_CheckHeaderFooter-1:funclib-1/main/fn_CheckHeaderFooter-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"fn_CheckHeaderFooter\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_CheckHeaderFooter-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_CheckHeaderFooter-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev fn_CheckHeaderFooter-1:funclib-1/main/fn_CheckHeaderFooter-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"fn_CheckHeaderFooter\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_CheckHeaderFooter-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_CheckHeaderFooter-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  fn_CheckScriptBasedir
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code fn_CheckScriptBasedir-1.0.0.sh:funclib-1/main/fn_CheckScriptBasedir-1.0.0.sh
_deathmessage="fn_CheckScriptBasedir-1 expected result did not match"
#[l]:test fn_CheckScriptBasedir-1:funclib-1/main/fn_CheckScriptBasedir-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"fn_CheckScriptBasedir\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_CheckScriptBasedir-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_CheckScriptBasedir-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev fn_CheckScriptBasedir-1:funclib-1/main/fn_CheckScriptBasedir-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"fn_CheckScriptBasedir\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_CheckScriptBasedir-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_CheckScriptBasedir-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  fn_CheckScriptProgdir
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code fn_CheckScriptProgdir-1.0.0.sh:funclib-1/main/fn_CheckScriptProgdir-1.0.0.sh
_deathmessage="fn_CheckScriptProgdir-1 expected result did not match"
#[l]:test fn_CheckScriptProgdir-1:funclib-1/main/fn_CheckScriptProgdir-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"fn_CheckScriptProgdir\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_CheckScriptProgdir-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_CheckScriptProgdir-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev fn_CheckScriptProgdir-1:funclib-1/main/fn_CheckScriptProgdir-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"fn_CheckScriptProgdir\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_CheckScriptProgdir-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_CheckScriptProgdir-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  fn_CompareTime
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code fn_CompareTime-1.0.0.sh:funclib-1/main/fn_CompareTime-1.0.0.sh
_deathmessage="fn_CompareTime-1 expected result did not match"
#[l]:test fn_CompareTime-1:funclib-1/main/fn_CompareTime-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"fn_CompareTime\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_CompareTime-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_CompareTime-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev fn_CompareTime-1:funclib-1/main/fn_CompareTime-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"fn_CompareTime\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_CompareTime-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_CompareTime-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  fn_DisplayUsage
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code fn_DisplayUsage-1.0.0.sh:funclib-1/main/fn_DisplayUsage-1.0.0.sh
_deathmessage="fn_DisplayUsage-1 expected result did not match"
#[l]:test fn_DisplayUsage-1:funclib-1/main/fn_DisplayUsage-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"fn_DisplayUsage\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_DisplayUsage-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_DisplayUsage-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev fn_DisplayUsage-1:funclib-1/main/fn_DisplayUsage-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"fn_DisplayUsage\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_DisplayUsage-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_DisplayUsage-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  fn_FilePathBaseExtSplit
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code fn_FilePathBaseExtSplit-1.0.0.sh:funclib-1/main/fn_FilePathBaseExtSplit-1.0.0.sh
_deathmessage="fn_FilePathBaseExtSplit-1 expected result did not match"
#[l]:test fn_FilePathBaseExtSplit-1:funclib-1/main/fn_FilePathBaseExtSplit-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"fn_FilePathBaseExtSplit\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_FilePathBaseExtSplit-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_FilePathBaseExtSplit-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev fn_FilePathBaseExtSplit-1:funclib-1/main/fn_FilePathBaseExtSplit-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"fn_FilePathBaseExtSplit\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_FilePathBaseExtSplit-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_FilePathBaseExtSplit-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  fn_FileSizeClip
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code fn_FileSizeClip-1.0.0.sh:funclib-1/main/fn_FileSizeClip-1.0.0.sh
_deathmessage="fn_FileSizeClip-1 expected result did not match"
#[l]:test fn_FileSizeClip-1:funclib-1/main/fn_FileSizeClip-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"fn_FileSizeClip\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_FileSizeClip-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_FileSizeClip-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev fn_FileSizeClip-1:funclib-1/main/fn_FileSizeClip-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"fn_FileSizeClip\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_FileSizeClip-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_FileSizeClip-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  fn_FormatDos2Unix
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code fn_FormatDos2Unix-1.0.1.sh:funclib-1/main/fn_FormatDos2Unix-1.0.1.sh
_deathmessage="fn_FormatDos2Unix-1 expected result did not match"
#[l]:test fn_FormatDos2Unix-1:funclib-1/main/fn_FormatDos2Unix-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"fn_FormatDos2Unix\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_FormatDos2Unix-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_FormatDos2Unix-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev fn_FormatDos2Unix-1:funclib-1/main/fn_FormatDos2Unix-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"fn_FormatDos2Unix\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_FormatDos2Unix-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_FormatDos2Unix-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  fn_FormatTime
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code fn_FormatTime-1.0.0.sh:funclib-1/main/fn_FormatTime-1.0.0.sh
_deathmessage="fn_FormatTime-1 expected result did not match"
#[l]:test fn_FormatTime-1:funclib-1/main/fn_FormatTime-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"fn_FormatTime\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_FormatTime-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_FormatTime-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev fn_FormatTime-1:funclib-1/main/fn_FormatTime-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"fn_FormatTime\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_FormatTime-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_FormatTime-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  fn_FormatUnix2Dos
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code fn_FormatUnix2Dos-1.0.0.sh:funclib-1/main/fn_FormatUnix2Dos-1.0.0.sh
_deathmessage="fn_FormatUnix2Dos-1 expected result did not match"
#[l]:test fn_FormatUnix2Dos-1:funclib-1/main/fn_FormatUnix2Dos-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"fn_FormatUnix2Dos\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_FormatUnix2Dos-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_FormatUnix2Dos-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev fn_FormatUnix2Dos-1:funclib-1/main/fn_FormatUnix2Dos-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"fn_FormatUnix2Dos\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_FormatUnix2Dos-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_FormatUnix2Dos-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  fn_GetTime
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code fn_GetTime-1.0.1.sh:funclib-1/main/fn_GetTime-1.0.1.sh
_deathmessage="fn_GetTime-1 expected result did not match"
#[l]:test fn_GetTime-1:funclib-1/main/fn_GetTime-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"fn_GetTime\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_GetTime-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_GetTime-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev fn_GetTime-1:funclib-1/main/fn_GetTime-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"fn_GetTime\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_GetTime-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_GetTime-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  fn_GlobalUsage
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code fn_GlobalUsage-1.0.0.sh:funclib-1/main/fn_GlobalUsage-1.0.0.sh
_deathmessage="fn_GlobalUsage-1 expected result did not match"
#[l]:test fn_GlobalUsage-1:funclib-1/main/fn_GlobalUsage-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"fn_GlobalUsage\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_GlobalUsage-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_GlobalUsage-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev fn_GlobalUsage-1:funclib-1/main/fn_GlobalUsage-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"fn_GlobalUsage\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_GlobalUsage-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_GlobalUsage-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  fn_ResolveProgdir
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code fn_ResolveProgdir-1.0.0.sh:funclib-1/main/fn_ResolveProgdir-1.0.0.sh
_deathmessage="fn_ResolveProgdir-1 expected result did not match"
#[l]:test fn_ResolveProgdir-1:funclib-1/main/fn_ResolveProgdir-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"fn_ResolveProgdir\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_ResolveProgdir-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_ResolveProgdir-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev fn_ResolveProgdir-1:funclib-1/main/fn_ResolveProgdir-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"fn_ResolveProgdir\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_ResolveProgdir-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_ResolveProgdir-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  fn_SetVars
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code fn_SetVars-1.0.0.sh:funclib-1/main/fn_SetVars-1.0.0.sh
_deathmessage="fn_SetVars-1 expected result did not match"
#[l]:test fn_SetVars-1:funclib-1/main/fn_SetVars-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"fn_SetVars\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_SetVars-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_SetVars-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev fn_SetVars-1:funclib-1/main/fn_SetVars-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"fn_SetVars\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_SetVars-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_SetVars-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  fn_ShiftTime
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code fn_ShiftTime-1.0.0.sh:funclib-1/main/fn_ShiftTime-1.0.0.sh
_deathmessage="fn_ShiftTime-1 expected result did not match"
#[l]:test fn_ShiftTime-1:funclib-1/main/fn_ShiftTime-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"fn_ShiftTime\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_ShiftTime-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_ShiftTime-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev fn_ShiftTime-1:funclib-1/main/fn_ShiftTime-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"fn_ShiftTime\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_ShiftTime-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_ShiftTime-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  fn_VerifyDir
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code fn_VerifyDir-1.0.0.sh:funclib-1/main/fn_VerifyDir-1.0.0.sh
_deathmessage="fn_VerifyDir-1 expected result did not match"
#[l]:test fn_VerifyDir-1:funclib-1/main/fn_VerifyDir-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"fn_VerifyDir\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_VerifyDir-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_VerifyDir-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev fn_VerifyDir-1:funclib-1/main/fn_VerifyDir-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"fn_VerifyDir\""
if [[ -s "${gl_funcdir}/funclib-1/main/fn_VerifyDir-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/main/fn_VerifyDir-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
#[of]:prod-1  inline
#[c]
#[c]
#[c]
#[c]  you are seeing this, because no test have been built for this function
#[c]
#[c]
#[c]
#[c]
#[l]:code inline-1.0.0.sh:funclib-1/inline/inline-1.0.0.sh
_deathmessage="inline-1 expected result did not match"
#[l]:test inline-1:funclib-1/inline/inline-1.test
echo "-----------------------------------------------"
echo "prod-1 testing \"inline\""
if [[ -s "${gl_funcdir}/funclib-1/inline/inline-1.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/inline/inline-1.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
#[l]:test.dev inline-1:funclib-1/inline/inline-1.dev.test
echo "-----------------------------------------------"
echo "dev-1 testing  \"inline\""
if [[ -s "${gl_funcdir}/funclib-1/inline/inline-1.dev.test" ]] ; then
echo "-----------------------------------------------"
(
. "${gl_funcdir}/funclib-1/inline/inline-1.dev.test"
) || { _return=$?;echo "last process exited with a ${_return}";exit 1; }
echo "-----------------------------------------------"
echo "test complete"
else
echo "  no test has been created"
fi
echo "-----------------------------------------------"
echo ""
echo ""
echo ""
#[cf]
