#!/bin/sh
function fn_FormatTime {
#[of]:  usage
  if [[ -z "$2" ]] ; then
    echo "Usage: fn FormatTime {-|var} {format} [type [time]|time]"
    echo "Error: must have at least 2 arguments"
    echo "Description:"
    echo "  sets var to a formatted time"
    echo "Examples:"
    echo '  fn FormatTime - "%a MM-DD-YYYY DDD Hh:mm:ss" previous.nearbusinessday'
    echo "Returns:"
    echo "Returns:"
    echo "  0 success"
    exit 1
  fi
#[cf]
  unset lc_FormatTime_type lc_FormatTime_time
  typeset lc_FormatTime_format lc_FormatTime_shift lc_FormatTime_timesource
  typeset lc_FormatTime_businessday lc_FormatTime_checkholiday lc_FormatTime_holidaytable
  ##read format and translate "YY YYYY DDD MM DD Hh hh mm ss PP pp" into date interpreted sequences
  lc_FormatTime_format="$(echo "$2" | sed -e '
    s/YYYY/%Y/g;
    s/YY/%y/g;
    s/MM/%m/g;
    s/DDD/%j/g;
    s/DD/%d/g;
    s/Hh/%H/g;
    s/hh/%I/g;
    s/mm/%M/g;
    s/ss/%S/g;
    s/PP/%p/g;
    s/pp/%P/g;')"
  lc_FormatTime_type="$3"
  lc_FormatTime_time="$4"

  if isnum "${lc_FormatTime_type}" ; then
    lc_FormatTime_time="${lc_FormatTime_type}"
  elif [[ -n "${lc_FormatTime_type}" ]] ; then
#[of]:    set time by type
    asplit lc_FormatTime_type . "${lc_FormatTime_type}"
    while [[ "${#lc_FormatTime_type[@]}" -gt 0 ]] ; do
      case "${lc_FormatTime_type[0]}" in
        previous|yesterday)
          lc_FormatTime_shift=-1
          ;;
        now|today)
          lc_FormatTime_timesource=${lc_FormatTime_type[0]}
          ;;
        nearbusinessday)
          lc_FormatTime_businessday=nearbusinessday
          ;;
        farbusinessday)
          lc_FormatTime_businessday=farbusinessday
          ;;
        nonholiday)
          lc_FormatTime_checkholiday=true
          lc_FormatTime_holidaytable="${gl_funcdir}/data/holidays.txt"
          ;;
        nonbankholiday)
          lc_FormatTime_checkholiday=true
          lc_FormatTime_holidaytable="${gl_funcdir}/data/holidays_bnk.txt"
          ;;
        *)
          msgdbg 1 "unknown type \"${lc_FormatTime_type[0]}\""
          exit 1
          ;;
      esac
      ashift ! lc_FormatTime_type
    done
    [[ -z "${lc_FormatTime_time}" ]] && fn GetTime lc_FormatTime_time ${lc_FormatTime_timesource:-now}
    fn ShiftTime lc_FormatTime_time ${lc_FormatTime_shift:-0} ${lc_FormatTime_businessday} ${lc_FormatTime_time}
    if ${lc_FormatTime_checkholiday:-false} && grep -q "$(fn FormatTime - MM/DD/YY ${lc_FormatTime_time})" "${lc_FormatTime_holidaytable}" ; then
      fn ShiftTime lc_FormatTime_time -1 ${lc_FormatTime_businessday} ${lc_FormatTime_time}
    fi
#[cf]
  fi
  
  [[ -z "${lc_FormatTime_time}" ]] && fn GetTime lc_FormatTime_time
  lc_FormatTime_time="$(gnudate +"${lc_FormatTime_format}" -d "1970-01-01 UTC ${lc_FormatTime_time} seconds")"
  if [[ "$1" = "-" ]] ; then
    echo "${lc_FormatTime_time}"
  else
    eval $1=\"\${lc_FormatTime_time}\"
  fi
  unset lc_FormatTime_type lc_FormatTime_time
  return 0  
}
# vim:number:tabstop=2:shiftwidth=2:autoindent:foldmethod=marker:foldlevel=0:foldmarker=#[of]\:,#[cf]
