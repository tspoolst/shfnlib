#!/bin/sh
function fn_DisplayUsage {
#[of]:  usage
  if false ; then
    echo "Usage: fn DisplayUsage"
    echo "Error: must have at least 0 arguments"
    echo 'Description: displays the "description" section of the current running script'
    echo "    section definitions are created using code-browser"
    echo "Examples:"
    echo '  fn DisplayUsage'
    echo "Returns:"
    echo "  0 success"
    exit 1
  fi
#[cf]
  cat "${gl_pathprogname}" | (
#[of]:      find opening marker
    while read -r lc_main_currentline ; do
      if [[ -n "${lc_main_currentline}" ]] ; then
        [[ "${lc_main_currentline}" = "#[of]:description" ]] && break
      fi
    done
#[cf]
#[of]:      display body of usage block
    while read -r lc_main_currentline ; do
      if [[ -n "${lc_main_currentline}" ]] ; then
        ##usage block is done if line is a closing marker
        [[ -z "${lc_main_currentline##\#\[cf\]*}" ]] && break
        ##if 4 #s or more skip
        [[ -z "${lc_main_currentline##\#\#\#\#*}" ]] && continue
        ##if line begins with a ## prefix print it
        if [[ -z "${lc_main_currentline##\#\#*}" ]] ; then
          ##force every " to be escaped i.e. \"
          lc_main_currentline="$(echo "${lc_main_currentline}" | sed -e 's%\${gl_progname}%'${gl_progname}'%g')"
          ##print line removing the ## prefix
          echo "${lc_main_currentline#\#\#}"
        fi
      fi
    done
#[cf]
    )
  return 0
}
