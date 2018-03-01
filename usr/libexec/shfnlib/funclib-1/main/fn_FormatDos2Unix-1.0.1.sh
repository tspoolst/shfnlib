#!/bin/sh
function fn_FormatDos2Unix {
#[of]:  setup vars
  typeset lc_FormatDos2Unix_reverse lc_FormatDos2Unix_append
  typeset lc_FormatDos2Unix_src lc_FormatDos2Unix_dst lc_FormatDos2Unix_csrc lc_FormatDos2Unix_cdst
  if [[ "$1" = "-r" ]] ; then
    ##if reverse=true do Unix2Dos
    lc_FormatDos2Unix_reverse=true
    shift
  fi
  if [[ "$1" = "-a" ]] ; then
    ##if append=true set dst to append else overwrite
    lc_FormatDos2Unix_append=true
    shift
  fi

  lc_FormatDos2Unix_src="$1"
  lc_FormatDos2Unix_dst="$2"

#[cf]
#[of]:  usage
  if [ -z "$1" ] ; then
    echo "Usage: fn FormatDos2Unix {-|srcfilename} [dstfilename]"
    echo "Error: must have at least 2 argument"
    echo "Description: reformats data from dos to unix format"
    echo "Examples:"
    echo " convert srcfile to dstfile"
    echo '  fn FormatDos2Unix ${lc_main_srcfilename} ${lc_main_dstfilename}'
    echo " convert srcfile to stdout"
    echo '  fn FormatDos2Unix ${lc_main_srcfilename}'
    echo " convert stdin to dstfile"
    echo '  fn FormatDos2Unix - ${lc_main_dstfilename}'
    echo "Returns:"
    echo "  0 success"
    echo " 21 dst file write permission error"
    echo " 22 src file read permission error"
    echo " 44 src file does not exist"
    exit 1
  fi
#[cf]
#[of]:  setup src
  if [[ "${lc_FormatDos2Unix_src}" != "-" ]] ; then
    ##if src is not stdin check if it exist
    if [[ ! -e "${lc_FormatDos2Unix_src}" ]] ; then
      return 44
    fi
    ##if src is not stdin check for read access
    if [[ ! -r "${lc_FormatDos2Unix_src}" ]] ; then
      return 22
    fi
    lc_FormatDos2Unix_csrc="< \"${lc_FormatDos2Unix_src}\""
  fi
#[cf]
#[of]:  setup dst
  if [[ -n "${lc_FormatDos2Unix_dst}" ]] ; then
    ##if dst is set check for write access, this also creates an empty dst file
    if ! touch "${lc_FormatDos2Unix_dst}" >/dev/null 2>&1 ; then
      return 21
    fi
    ##if src is empty, just return success
    [[ "${lc_FormatDos2Unix_src}" != "-" && ! -s "${lc_FormatDos2Unix_src}" ]] && return 0

    if [[ "${lc_FormatDos2Unix_src}" = "${lc_FormatDos2Unix_dst}" ]] ; then
      ##if src and dst are equal, use temporary file
      lc_FormatDos2Unix_randomfile="$(uniqname).dat_+1"
      lc_FormatDos2Unix_cdst="${gl_tmpdir:-/tmp}/${lc_FormatDos2Unix_randomfile}"
      ##check cdst for write access
      if ! touch "${lc_FormatDos2Unix_cdst}" >/dev/null 2>&1 ; then
        return 21
      fi
    else
      lc_FormatDos2Unix_cdst="${lc_FormatDos2Unix_dst}"
    fi
    msgdbg 4 "lc_FormatDos2Unix_cdst=${lc_FormatDos2Unix_cdst}"
  fi
  msgdbg 4 "file src and cdst"
  msgdbg 4 "src=${lc_FormatDos2Unix_src}"
  msgdbg 4 "cdst=${lc_FormatDos2Unix_cdst}"
#[cf]
#[of]:  convert data
  ##if not reverse do Dos2Unix conversion, else do Unix2Dos
  if ! ${lc_FormatDos2Unix_reverse:-false} ; then
    eval "
      awk '{
        gsub(\"\\f\",\"\\n\");
        gsub(\"\\r\",\"\");
        print;
      }' ${lc_FormatDos2Unix_csrc} ${lc_FormatDos2Unix_cdst:+>${lc_FormatDos2Unix_append:+>} \"${lc_FormatDos2Unix_cdst}\"}
    "
  else
    eval "
      awk '{
        gsub(\"\\r\",\"\");
        print \$0\"\\r\";
      }' ${lc_FormatDos2Unix_csrc} ${lc_FormatDos2Unix_cdst:+>${lc_FormatDos2Unix_append:+>} \"${lc_FormatDos2Unix_cdst}\"}
    "
  fi
#[cf]
#[of]:  cleanup cdst
  if [[ "${lc_FormatDos2Unix_dst}" != "${lc_FormatDos2Unix_cdst}" ]] ; then
    ##cleanup tmpfile if used
    if ${lc_FormatDos2Unix_append:-false} ; then
      cat "${lc_FormatDos2Unix_cdst}" >> "${lc_FormatDos2Unix_dst}"
      rm -f "${lc_FormatDos2Unix_cdst}"
    else
      mv -f "${lc_FormatDos2Unix_cdst}" "${lc_FormatDos2Unix_dst}"
    fi
  fi
  return 0
#[cf]
}
