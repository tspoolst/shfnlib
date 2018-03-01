#!/bin/sh
function uniqname {
#[of]:  usage
  if false ; then
    echo "Usage: uniqname"
    echo "Error: none"
    echo "Description:"
    echo "  produces a uniq name based on the date and current process"
    echo "  this can be used to generate filenames etc."
    echo "  output goes to stdout"
    echo "Examples:"
    echo '  filename="`uniqname`.dat"'
    echo "Returns:"
    echo "  0 success"
    exit 1
  fi
#[cf]
  "${gl_tooldir}/uniqname-0.sh"
  return 0
}
# vim:number:tabstop=2:shiftwidth=2:autoindent:foldmethod=marker:foldlevel=0:foldmarker=#[of]\:,#[cf]
