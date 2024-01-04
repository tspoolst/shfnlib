#!/bin/bash
fn_CheckHeaderFooter() {
#[of]:  usage
  if [ -z "$3" ] ; then
    echo "Usage: fn CheckHeaderFooter file header footer"
    echo "Error: must have at least 3 arguments"
    echo "Description: checks file for both header and footer"
    echo "Examples:"
    echo '  fn CheckHeaderFooter ${lc_main_checkfreefilename} ${lc_main_header} ${lc_main_footer}'
    echo "Returns:"
    echo "  0 true"
    echo "  1 false"
    exit 1
  fi
#[cf]
  lc_CheckHeaderFooter_file="$1"
  lc_CheckHeaderFooter_headerstring="$2"
  lc_CheckHeaderFooter_footerstring="$3"
  head -n 1 "${lc_CheckHeaderFooter_file}" | grep "${lc_CheckHeaderFooter_headerstring}" > /dev/null 2>&1 && \
    tail -n 1 "${lc_CheckHeaderFooter_file}" | grep "${lc_CheckHeaderFooter_footerstring}" > /dev/null 2>&1
  if [ $? -gt 0 ] ; then
    return 1
  fi
  return 0
}
