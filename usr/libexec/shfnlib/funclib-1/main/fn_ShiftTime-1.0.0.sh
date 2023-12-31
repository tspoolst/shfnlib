#!/bin/bash
function fn_ShiftTime {
#[of]:  usage
  if [[ -z "$3" ]] ; then
    echo "Usage: fn ShiftTime {-|var} {shift} [type] {time}"
    echo "Error: must have at least 3 arguments"
    echo "Description:"
    echo "  shift time forward or backwards depending on type"
    echo "  shifts are in 1 day increments"
    echo "  supported types are"
    echo "    farbusinessday"
    echo "      weekends days are skipped"
    echo "      if the starting day is sat|sun, starting day is first shifted backward to fri"
    echo "    nearbusinessday"
    echo "      weekends days are skipped"
    echo "      if the starting day is sat|sun, starting day is first shifted forward to mon"
    echo "    if no type specified"
    echo "      all days are considered"
    echo "Examples:"
    echo "  go back one day"
    echo '    fn ShiftTime lc_main_time -1 ${lc_main_time}'
    echo "  go back one near businessday day"
    echo '    fn ShiftTime lc_main_time -1 businessday.near ${lc_main_time}'
    echo "Returns:"
    echo "  0    success"
    exit 1
  fi
#[cf]
  unset lc_ShiftTime_day
  typeset lc_ShiftTime_time lc_ShiftTime_type lc_ShiftTime_shift
  lc_ShiftTime_shift="$2"
  if [[ -n "$4" ]] ; then
    lc_ShiftTime_type="$3"
  fi
  eval lc_ShiftTime_time=\"\$$#\"
  isnum "${lc_ShiftTime_time}" || die 1 "last argument must be {time}"

  if [[ -n "${lc_ShiftTime_type}" ]] ; then
    case ${lc_ShiftTime_type} in
#[of]:      farbusinessday|nearbusinessday)
      farbusinessday|nearbusinessday)
        fn FormatTime lc_ShiftTime_day "%w" ${lc_ShiftTime_time}
        case ${lc_ShiftTime_type} in
#[of]:          farbusinessday)
          farbusinessday)
            #starting on sat|sun logical day is friday
            [[ ${lc_ShiftTime_day} -eq 0 ]] && lc_ShiftTime_time=$(( lc_ShiftTime_time + -2*gl_1day ))
            [[ ${lc_ShiftTime_day} -eq 6 ]] && lc_ShiftTime_time=$(( lc_ShiftTime_time + -1*gl_1day ))
            fn FormatTime lc_ShiftTime_day "%w" ${lc_ShiftTime_time}
            ;;
#[cf]
#[of]:          nearbusinessday)
          nearbusinessday)
            #starting on sat|sun logical day is monday
            [[ ${lc_ShiftTime_day} -eq 0 ]] && lc_ShiftTime_time=$(( lc_ShiftTime_time + 1*gl_1day ))
            [[ ${lc_ShiftTime_day} -eq 6 ]] && lc_ShiftTime_time=$(( lc_ShiftTime_time + 2*gl_1day ))
            fn FormatTime lc_ShiftTime_day "%w" ${lc_ShiftTime_time}
            ;;
#[cf]
#[of]:          *) unknown businessday shift type
          *)
            msgdbg 1 "unknown businessday shift type ${lc_ShiftTime_type}"
            exit 1
            ;;
#[cf]
        esac
        lc_ShiftTime_index=$(( lc_ShiftTime_shift + lc_ShiftTime_day ))
        while [[ ${lc_ShiftTime_index} -lt 1 ]] ; do
          lc_ShiftTime_index=$(( lc_ShiftTime_index + 5 ))
          lc_ShiftTime_shift=$(( lc_ShiftTime_shift - 2 ))
        done
        while [[ ${lc_ShiftTime_index} -gt 5 ]] ; do
          lc_ShiftTime_index=$(( lc_ShiftTime_index - 5 ))
          lc_ShiftTime_shift=$(( lc_ShiftTime_shift + 2 ))
        done
        ;;
#[cf]
#[of]:      *) unknown shift type
      *)
        msgdbg 1 "unknown shift type ${lc_ShiftTime_type}"
        exit 1
        ;;
#[cf]
    esac      
  fi
  lc_ShiftTime_time=$(( lc_ShiftTime_time + lc_ShiftTime_shift*gl_1day ))
  
  if [[ "$1" = "-" ]] ; then
    echo "${lc_ShiftTime_time}"
  else
    eval $1=\"\${lc_ShiftTime_time}\"
  fi
  unset lc_ShiftTime_day
  return 0
}
