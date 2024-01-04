#!/bin/bash

#[of]:comments
#[c]add a build option to merge all modules, including user modules into a single monolithic include file.
#[c]    have to figure a way to deal with external calling functions like uniqname and xdate
#[c]  add option to directly insert/remove the lib into/from a target script.
#[c]create a function that can scan a script for functions used
#[c]  use that as input for the mono include file builder
#[c]figure out how to dynamically load base functions as well.
#[c]  needs to be a lighter function than fn
#[cf]

if ! { echo "${PATH}" | grep -q gnu ; } ; then
  gl_kernelver=$(uname -s | tr A-Z a-z);gl_kernelver="${gl_kernelver%%-*}"
  export PATH=${0%/*}/gnu/${gl_kernelver}/bin:$PATH
fi
[ -z "${BASH_VERSION}" ] && exec bash "$0" "$@"

#[of]:switch to function dir
if ! cd ${0%/*} ; then
  echo "strange, it looks like we have no read access to ${0%/*}"
  exit 1
fi
#[cf]
#[of]:fix library perms
find funclib-* gnu docs tools -type d -exec chmod 755 {} -c \;
#[c]chmod 775 tmp
find funclib-* -type f -exec chmod 644 {} -c \;
find gnu/*/bin tools -type f -exec chmod 755 {} -c \;
#[cf]
#[of]:includes
. funclib-1/base/file-1.0.0.sh
. funclib-1/base/array-1.0.0.sh
. funclib-1/base/string-1.0.0.sh
. funclib-1/base/hash-1.1.2.sh
. funclib-1/base/test-1.0.0.sh
#[cf]
#[of]:unset hashes
for _section in base main compat inline ; do
  hashdel _${_section}
  hashdel _dev${_section}
done
#[cf]
#[of]:create index files for each libver
for _dir in funclib-+([0-9]) ; do
  _libver=$(asplit 1 "-" "${_dir}")
#[of]:  write headers
#[of]:  write runtime headers
for _section in "" "dev" ; do
  {
    echo '#!/bin/bash'
    echo ""
    echo "gl_funcver=${_libver}"
    echo "gl_funcbranch=${_section:-prod}"
    echo "[[ -z \"\${gl_funcdir}\" ]] && gl_funcdir=\"/usr/libexec/shfnlib\""
    echo "##if using bash insure extglob is on"
    echo "[[ -n \"\$BASH_VERSION\" ]] && shopt -s extglob"
    echo ""
  } > "functions${_section:+-${_section}}-${_libver}.sh"
done
#[cf]
#[of]:  write testing headers
for _section in "" "dev" ; do
  {
    echo "#!/bin/$([[ -x /bin/bash ]] && echo bash || echo ksh)"
    echo "#[of]:header"
    echo ""
    echo "gl_logfile=\${0%/*}/functions-${_section}test-${_libver}.log"
    echo 'rm -f ${gl_logfile}'
    echo '
#[of]:pushd() {
pushd() {
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
#[of]:popd() {
popd() {
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
#[of]:filepath() {
filepath() {
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
'
    echo "filepath gl_funcdir \${0%/*}/functions-${_section:+${_section}-}${_libver}.sh"
    echo 'gl_funcdir="${gl_funcdir}"'
    echo 'unset -f pushd popd filepath'
    echo ". \"\${gl_funcdir}/functions-${_section:+${_section}-}${_libver}.sh\""
  } > "functions-${_section}test-${_libver}.sh"
  chmod ugo+x "functions-${_section}test-${_libver}.sh"
done

{
echo '
#[of]:checkresult() {
checkresult() {
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
'
echo "#[cf]"
} | tee -a "functions-test-${_libver}.sh" >> "functions-devtest-${_libver}.sh"
#[cf]
#[cf]
#[of]:  process each section
  for _section in base main inline compat ; do
#[of]:    parse file list
    [[ ! -e ${_dir}/${_section} ]] && mkdir -p ${_dir}/${_section}
    for _file in ${_dir}/${_section}/*.sh ; do
      [[ "${_file}" = "${_dir}/${_section}/*.sh" ]] && continue
      filename _name "${_file}"
      asplit a "-" "${_name%.sh}"
      asplit c "." "${a[1]}"
      a[2]="${a[2]:-999999}"
      [[ "${a[2]}" = "999999" ]] && hashsetkey _${_section} "${a[0]}" "$(printf "%s %04d %04d %04d %06d \"%s\" %d\n" "${a[0]}" "${c[@]}" "${a[2]#0}" "${_file}" "${c[0]}")"
      hashsetkey _dev${_section} "${a[0]}" "$(printf "%s %04d %04d %04d %06d \"%s\" %d\n" "${a[0]}" "${c[@]}" "${a[2]#0}" "${_file}" "${c[0]}")"
    done
#[cf]
#[of]:    write prod sections
    {
      echo "#[of]:${_section}"
      hashkeys _keys _${_section}
      for _key in $(asort - "${_keys[@]}") ; do
        hashgetkey _package _${_section} ${_key} || continue
        eval "aset _package ${_package}"
        if [[ $(tail -n +2 "${_package[5]}" | head -1) = "#deprecated" ]] ; then
          hashdelkey _${_section} "${_key}"
          continue
        fi
        if [[ "${_section}" = "main" ]] ; then
          echo "${_package[0]}=\". \\\"\${gl_funcdir}/${_package[5]}\\\"\""
        else
          echo ". \"\${gl_funcdir}/${_package[5]}\""
        fi
        echo "#[l]:${_package[0]}:${_package[5]}"
#[of]:        write test section
        {
          echo "#[of]:${_package[0]}-${_package[6]}"
          echo "#[c]"
          echo "#[c]  if the test link is blank, no tests have been built for this function"
          echo "#[c]"
          echo "#[l]:code $(filename - ${_package[5]}):${_package[5]}"
          echo "_deathmessage=\"${_package[0]}-${_package[6]} expected result did not match\""
          echo "#[l]:test ${_package[0]}-${_package[6]}:${_package[5]%/*}/${_package[0]}-${_package[6]}.test"
          echo "echo \"-----------------------------------------------\""
          echo "echo \"prod-${_package[6]} testing \\\"${_package[0]}\\\"\""
          echo "if [[ -s \"\${gl_funcdir}/${_package[5]%/*}/${_package[0]}-${_package[6]}.test\" ]] ; then"
          echo "echo \"-----------------------------------------------\""
          echo "("
          echo ". \"\${gl_funcdir}/${_package[5]%/*}/${_package[0]}-${_package[6]}.test\""
          echo ") || { _return=\$?;echo \"last process exited with a \${_return}\";exit 1; }"
          echo "echo \"-----------------------------------------------\""
          echo "echo \"test complete\""
          echo "else"
          echo "echo \"  no test has been created\""
          echo "fi"
          echo "echo \"-----------------------------------------------\""
          echo "echo \"\""
          echo "echo \"\""
          echo "echo \"\""
          echo "#[cf]"
        } >> "functions-test-${_libver}.sh"
#[cf]
      done
      echo "#[cf]"
    } >> "functions-${_libver}.sh"
#[cf]
#[of]:    write dev sections
    {
      echo "#[of]:${_section}"
      hashkeys _keys _dev${_section}
      for _key in $(asort - "${_keys[@]}") ; do
        hashgetkey _package _dev${_section} ${_key} || continue
        eval "aset _package ${_package}"
        if [[ $(tail -n +2 "${_package[5]}" | head -1) = "#deprecated" ]] ; then
          hashdelkey _dev${_section} "${_key}"
          continue
        fi
        if [[ "${_section}" = "main" ]] ; then
          echo "${_package[0]}=\". \\\"\${gl_funcdir}/${_package[5]}\\\"\""
        else
          echo ". \"\${gl_funcdir}/${_package[5]}\""
        fi
        if [[ "${_package[4]}" = "999999" ]] ; then
          echo "#[l]:prod-${_package[6]}  ${_package[0]}:${_package[5]}"
        else
          echo "#[l]:dev-${_package[6]}   ${_package[0]}:${_package[5]}"
        fi
#[of]:        write test section
        {
          if [[ "${_package[4]}" = "999999" ]] ; then
            echo "#[of]:prod-${_package[6]}  ${_package[0]}"
          else
            echo "#[of]: dev-${_package[6]}  ${_package[0]}"
          fi
          echo "#[c]"
          echo "#[c]"
          echo "#[c]"
          echo "#[c]  you are seeing this, because no test have been built for this function"
          echo "#[c]"
          echo "#[c]"
          echo "#[c]"
          echo "#[c]"
          echo "#[l]:code $(filename - ${_package[5]}):${_package[5]}"
          echo "_deathmessage=\"${_package[0]}-${_package[6]} expected result did not match\""
            echo "#[l]:test ${_package[0]}-${_package[6]}:${_package[5]%/*}/${_package[0]}-${_package[6]}.test"
            echo "echo \"-----------------------------------------------\""
            echo "echo \"prod-${_package[6]} testing \\\"${_package[0]}\\\"\""
            echo "if [[ -s \"\${gl_funcdir}/${_package[5]%/*}/${_package[0]}-${_package[6]}.test\" ]] ; then"
            echo "echo \"-----------------------------------------------\""
            echo "("
            echo ". \"\${gl_funcdir}/${_package[5]%/*}/${_package[0]}-${_package[6]}.test\""
            echo ") || { _return=\$?;echo \"last process exited with a \${_return}\";exit 1; }"
            echo "echo \"-----------------------------------------------\""
            echo "echo \"test complete\""
            echo "else"
            echo "echo \"  no test has been created\""
            echo "fi"
            echo "echo \"-----------------------------------------------\""

            echo "#[l]:test.dev ${_package[0]}-${_package[6]}:${_package[5]%/*}/${_package[0]}-${_package[6]}.dev.test"
            echo "echo \"-----------------------------------------------\""
            echo "echo \"dev-${_package[6]} testing  \\\"${_package[0]}\\\"\""
            echo "if [[ -s \"\${gl_funcdir}/${_package[5]%/*}/${_package[0]}-${_package[6]}.dev.test\" ]] ; then"
            echo "echo \"-----------------------------------------------\""
            echo "("
            echo ". \"\${gl_funcdir}/${_package[5]%/*}/${_package[0]}-${_package[6]}.dev.test\""
            echo ") || { _return=\$?;echo \"last process exited with a \${_return}\";exit 1; }"
            echo "echo \"-----------------------------------------------\""
            echo "echo \"test complete\""
            echo "else"
            echo "echo \"  no test has been created\""
            echo "fi"
            echo "echo \"-----------------------------------------------\""
          echo "echo \"\""
          echo "echo \"\""
          echo "echo \"\""
          echo "#[cf]"
        } >> "functions-devtest-${_libver}.sh"
#[cf]
      done
      echo "#[cf]"
    } >> "functions-dev-${_libver}.sh"
#[cf]
  done
  echo '# vim:number:tabstop=2:shiftwidth=2:autoindent:foldmethod=marker:foldlevel=0:foldmarker=#[of]\:,#[cf]' | \
    tee -a "functions-${_libver}.sh" >> "functions-dev-${_libver}.sh"
#[cf]
#[of]:  remove unneeded index files
  ##if this version is the same as the old version remove it
  if [[ -e "functions-${_libver}.sh" && "$(cat functions-${_libver}.sh | cksum)" = "$(cat functions-dev-${_libver}.sh | cksum)" ]] ; then
    rm -f "functions-devtest-${_libver}.sh"
    rm -f "functions-dev-${_libver}.sh"
  fi
  if [[ -e "functions-${_lastlibver}.sh" && "$(grep -v gl_funcver functions-${_libver}.sh | cksum)" = "$(grep -v gl_funcver functions-${_lastlibver}.sh | cksum)" ]] ; then
    rm -f "functions-${_libver}.sh"
    rm -f "functions-test-${_libver}.sh"
  fi
  _lastlibver=${_libver}
#[cf]
done
#[cf]
#[of]:fix link index perms
chmod 644 functions-*.sh
chmod 754 functions-test-*.sh functions-devtest-*.sh
#[cf]
#[of]:generate library docs
for _libver in functions-{,dev-}[1-9]*.sh ; do
  _libver="${_libver%.sh}"
  _libver="${_libver#*-}"
  ./gendocs-0.sh ${_libver} > docs/funcdocs-${_libver}.txt
  ./gendocs-0.sh ${_libver} -h > docs/funcdocs-${_libver}.html
done
#[cf]
exit 0
# vim:number:tabstop=2:shiftwidth=2:autoindent:foldmethod=marker:foldlevel=0:foldmarker=#[of]\:,#[cf]
