#!/bin/sh
function fn_CompareTime {
#[of]:  usage
  if [[ -z "$2" ]] ; then
    echo "Usage: fn CompareTime [-f] {{hour|day|dayhour}[.noholiday|bankholiday]} {{format} {string}|controltime|type} {-eq|gt|lt|ge|le} {{format} {string}|testtime}"
    echo "Error: must have at least 3 arguments"
    echo "Description:"
    echo "  sets var to a formatted time"
    echo "Examples:"
    echo '  fn CompareTime day.noholiday YYYYMMDD ${lc_main_ctltime} -eq YYYYMMDD ${lc_main_testtime}'
    echo '  fn CompareTime day.bankholiday yesterday.nearbusinessday -eq YYYYMMDD ${lc_main_headertime}'
    echo "Returns:"
    echo "Returns:"
    echo "  0 success"
    exit 1
  fi
#[c]test can be by day or hour or dayhour
#[c]input can be formated-string/time/type
#[cf]
  unset lc_CompareTime_range lc_CompareTime_ctltime lc_CompareTime_tsttime
  unset lc_CompareTime_ctltimetyped lc_CompareTime_tsttimetyped
  typeset lc_CompareTime_format lc_CompareTime_test
  typeset lc_CompareTime_forcetype lc_CompareTime_forcetime lc_CompareTime_ctltype

  lc_CompareTime_holidaytype=nonholiday

#[of]:  force src input to a time type
  if [[ "$1" = "-t" ]] ; then
    lc_CompareTime_forcetype="true"
    shift
  fi
#[cf]
#[of]:  read in and evaluate test range
  ##range of time to check i.e. day,hour etc..
  lc_CompareTime_range=$1
  shift
  asplit lc_CompareTime_range . "${lc_CompareTime_range}"
  while [[ "${#lc_CompareTime_range[@]}" -gt 0 ]] ; do
    case "${lc_CompareTime_range[0]}" in
      hour)
        lc_CompareTime_format="Hhmm"
        unset lc_CompareTime_holidaytype
        ;;
      day)
        lc_CompareTime_format="YYYYDDD"
        ;;
      noholiday)
        unset lc_CompareTime_holidaytype
        ;;
      bankholiday)
        lc_CompareTime_holidaytype=nonbankholiday
        ;;
      dayhour)
        lc_CompareTime_format="YYYYDDDHhmm"
        ;;
      *)
        ##using a custom test range
        lc_CompareTime_format="${lc_CompareTime_range[0]}"
        ;;
    esac
    ashift ! lc_CompareTime_range
  done
  unset lc_CompareTime_range
#[cf]
#[of]:  read in control time
  ##find position of -gt
  if ${lc_CompareTime_forcetype:-false} && [[ "$3" = "-"@(gt|ge|eq|le|lt) ]] ; then
    ##input time in is a type with time, translate to lit
    ##this is really only ment for testing
    lc_CompareTime_ctltype="$1"
    lc_CompareTime_forcetime="$2"
    fn FormatTime lc_CompareTime_ctltime "%s" "${lc_CompareTime_ctltype}" "${lc_CompareTime_forcetime}"
    shift;shift
  elif [[ "$3" = "-"@(gt|ge|eq|le|lt) ]] ; then
    ##input format is set, time is a string
    fn GetTime lc_CompareTime_ctltime "$1" "$2"
    shift;shift
  elif [[ "$2" = "-"@(gt|ge|eq|le|lt) ]] ; then
    ##no format, time is lit or type
    if ! isnum "$1" ; then
      ##time in is a type, translate to lit
      lc_CompareTime_ctltype="$1"
      fn FormatTime lc_CompareTime_ctltime "%s" "${lc_CompareTime_ctltype}"
    else
      lc_CompareTime_ctltime="$1"
    fi
    shift
  else
    die 1 "usage"
  fi
#[cf]
#[of]:  read in comparison type
  lc_CompareTime_test="$1"
  shift
#[cf]
#[of]:  read in test time
  if [[ -n "$2" ]] ; then
    #input format is set, time is a string
    fn GetTime lc_CompareTime_tsttime "$1" "$2"
    shift;shift
  elif [[ -n "$1" ]] ; then
    #no format, time is lit or type
    if ! isnum "$1" ; then
      die 1 "our test time must be a lit"
    fi
    lc_CompareTime_tsttime="$1"
    shift
  else
    die 1 "usage"
  fi
#[cf]
  msgdbg 2 "src $(fn FormatTime - "%a YYYY-MM-DD" ${lc_CompareTime_ctltime}) ${lc_CompareTime_test} tst $(fn FormatTime - "%a YYYY-MM-DD" ${lc_CompareTime_tsttime})"
#[of]:  format test times per range setting
  fn FormatTime lc_CompareTime_ctltimetyped ${lc_CompareTime_format} "${lc_CompareTime_ctltime}"
  fn FormatTime lc_CompareTime_tsttimetyped ${lc_CompareTime_format} "${lc_CompareTime_tsttime}"
  msgdbg 2 "ctl ${lc_CompareTime_ctltimetyped} ${lc_CompareTime_test} tst ${lc_CompareTime_tsttimetyped}"
#[cf]
#[of]:  perform time comparison
  if eval [[ \${lc_CompareTime_ctltimetyped} ${lc_CompareTime_test} \${lc_CompareTime_tsttimetyped} ]] ; then
    msgdbg 2 "time test ${lc_CompareTime_test} is true"
    unset lc_CompareTime_range lc_CompareTime_ctltime lc_CompareTime_tsttime
    unset lc_CompareTime_ctltimetyped lc_CompareTime_tsttimetyped lc_CompareTime_holidaytype
    return 0
  elif isset lc_CompareTime_holidaytype && [[ -n ${lc_CompareTime_ctltype} ]] ; then
#[of]:    adjust for holiday
    fn FormatTime lc_CompareTime_ctltimetyped "${lc_CompareTime_format}" "${lc_CompareTime_ctltype}.${lc_CompareTime_holidaytype}" ${lc_CompareTime_forcetime}
    msgdbg 2 "holiday ctl ${lc_CompareTime_ctltimetyped} ${lc_CompareTime_test} tst ${lc_CompareTime_tsttimetyped}"
#[cf]
#[of]:    perform comparison again
    if eval [[ \${lc_CompareTime_ctltimetyped} ${lc_CompareTime_test} \${lc_CompareTime_tsttimetyped} ]] ; then
      msgdbg 2 "holiday time test ${lc_CompareTime_test} is true"
      unset lc_CompareTime_range lc_CompareTime_ctltime lc_CompareTime_tsttime
      unset lc_CompareTime_ctltimetyped lc_CompareTime_tsttimetyped lc_CompareTime_holidaytype
      return 0
    else
      msgdbg 2 "holiday time test ${lc_CompareTime_test} is false"
    fi
#[cf]
  fi
  msgdbg 2 "time test ${lc_CompareTime_test} is false"
  unset lc_CompareTime_range lc_CompareTime_ctltime lc_CompareTime_tsttime
  unset lc_CompareTime_ctltimetyped lc_CompareTime_tsttimetyped lc_CompareTime_holidaytype
  return 1
#[cf]
}
# vim:number:tabstop=2:shiftwidth=2:autoindent:foldmethod=marker:foldlevel=0:foldmarker=#[of]\:,#[cf]
