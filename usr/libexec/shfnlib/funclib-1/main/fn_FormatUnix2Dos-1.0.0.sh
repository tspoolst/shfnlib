#!/bin/sh
function fn_FormatUnix2Dos {
#[of]:  usage
  if [ -z "$1" ] ; then
    echo "Usage: fn FormatUnix2Dos {-|srcfilename} [dstfilename]"
    echo "Error: must have at least 2 argument"
    echo "Description: reformats data from unix to dos format"
    echo "Examples:"
    echo " convert srcfile to dstfile"
    echo '  fn FormatUnix2Dos ${lc_main_srcfilename} ${lc_main_dstfilename}'
    echo " convert srcfile to stdout"
    echo '  fn FormatUnix2Dos ${lc_main_srcfilename}'
    echo " convert stdin to dstfile"
    echo '  fn FormatUnix2Dos - ${lc_main_dstfilename}'
    echo "Returns:"
    echo "  0 success"
    echo " 21 dst file write permission error"
    echo " 22 src file read permission error"
    echo " 44 src file does not exist"
    exit 1
  fi
#[cf]
  fn FormatDos2Unix -r "$@"
}
# vim:number:tabstop=2:shiftwidth=2:autoindent:foldmethod=marker:foldlevel=0:foldmarker=#[of]\:,#[cf]
