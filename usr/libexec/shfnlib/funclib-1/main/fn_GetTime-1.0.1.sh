#!/bin/sh
function fn_GetTime {
#[of]:  usage
  if [[ -z "$1" ]] ; then
    echo "Usage: fn GetTime {var|-} {time_src|format {string}}"
    echo "Error: must have at least 2 arguments"
    echo "Description: get unix epoch - seconds since 00:00:00 1970-01-01 UTC"
    echo ""
    echo "Examples:"
    echo '  fn GetTime lc_main_time now'
    echo "Returns:"
    echo "  0    success"
    exit 1
  fi
#[cf]
  unset lc_GetTime_monthnames lc_GetTime_string
  typeset lc_GetTime_time lc_GetTime_source
  unset lc_GetTime_position lc_GetTime_year lc_GetTime_dayofyear lc_GetTime_month lc_GetTime_monthname lc_GetTime_day lc_GetTime_hour lc_GetTime_min lc_GetTime_sec lc_GetTime_ampm
  lc_GetTime_source="${2:-now}"
  lc_GetTime_string="$3"
  case ${lc_GetTime_source} in
#[of]:    now|today)
    now|today)
      lc_GetTime_time="$(gnudate +%s)"
      ;;
#[cf]
#[of]:    *) formatted time
    *)
      if [[ -z "${lc_GetTime_string}" ]] ; then
        die 1 "parsing a date format requires an input string"
      fi

      lc_GetTime_topbottomswitch=+
      lc_GetTime_fielddelimiter=" "
      aset lc_GetTime_monthnames 0 jan feb mar apr may jun jul aug sep oct nov dec

      while [[ "${lc_GetTime_source}" = [LOF]+([[:digit:]])*(*) || "${lc_GetTime_source}" = [TBI]*(*) ]] ; do
        if [[ "${lc_GetTime_source}" = [I]*(*) ]] ; then
          lc_GetTime_preparse="${lc_GetTime_source%${lc_GetTime_source#I?}}"
          lc_GetTime_source="${lc_GetTime_source#I?}"
        else
          lc_GetTime_preparse="${lc_GetTime_source%${lc_GetTime_source##[TBLOF]*([[:digit:]])}}"
          lc_GetTime_source="${lc_GetTime_source##[TBLOF]*([[:digit:]])}"
        fi
        case "${lc_GetTime_preparse}" in
          T*)
            lc_GetTime_topbottomswitch=+
            ;;
          B*)
            lc_GetTime_topbottomswitch=-
            ;;
          I*)
            lc_GetTime_fielddelimiter="${lc_GetTime_preparse#?}"
            ;;
          L*)
            lc_GetTime_preparse="${lc_GetTime_preparse#?}"
            [[ -n "${lc_GetTime_string##*/*}" && -n "${gl_confdir}" ]] && lc_GetTime_string="${gl_tmpdir}/${lc_GetTime_string}"
            if [[ -s "${lc_GetTime_string}" ]] ; then
              lc_GetTime_string=$(tail -n ${lc_GetTime_topbottomswitch}$((lc_GetTime_preparse +1)) "${lc_GetTime_string}" | head -1)
            else
              die 1 "if format specifies a specific line _string must be a filename with data"
            fi
            ;;
          O*)
            lc_GetTime_preparse="${lc_GetTime_preparse#?}"
            substr lc_GetTime_string "${lc_GetTime_string}" ${lc_GetTime_preparse}
            ;;
          F*)
            lc_GetTime_preparse="${lc_GetTime_preparse#?}"
            lc_GetTime_string=$(asplit ${lc_GetTime_preparse} "${lc_GetTime_fielddelimiter}" "${lc_GetTime_string}")
            ;;
        esac
      done
      
      if instring lc_GetTime_position "${lc_GetTime_source}" YYYY ; then
        substr lc_GetTime_year "${lc_GetTime_string}" ${lc_GetTime_position} 4
      elif instring lc_GetTime_position "${lc_GetTime_source}" YY ; then
        substr lc_GetTime_year "${lc_GetTime_string}" ${lc_GetTime_position} 2
        lc_GetTime_year="${gl_year%??}${lc_GetTime_year}"
      else
        die 1 "time format is missing year"
      fi
      if instring lc_GetTime_position "${lc_GetTime_source}" DDD ; then
        substr lc_GetTime_dayofyear "${lc_GetTime_string}" ${lc_GetTime_position} 3
        lc_GetTime_dayofyear=$(( ${lc_GetTime_dayofyear#+( |0)} - 1 ))
        lc_GetTime_monthname=jan
      elif instring lc_GetTime_position "${lc_GetTime_source}" DD ; then
        substr lc_GetTime_day "${lc_GetTime_string}" ${lc_GetTime_position} 2
        if instring lc_GetTime_position "${lc_GetTime_source}" MM ; then
          substr lc_GetTime_month "${lc_GetTime_string}" ${lc_GetTime_position} 2
          ##using the month # as an index, removing the possible leading space or 0,
          ##  set monthname
          lc_GetTime_monthname=${lc_GetTime_monthnames[${lc_GetTime_month#@( |0)}]}
        elif instring lc_GetTime_position "${lc_GetTime_source}" CCC ; then
          substr lc_GetTime_monthname "${lc_GetTime_string}" ${lc_GetTime_position} 3
          tolower lc_GetTime_monthname
        else
          die 1 "time format is missing month"
        fi
      else
        die 1 "time format is missing day"
      fi

      if instring lc_GetTime_position "${lc_GetTime_source}" "Hh|hh" ; then
        substr lc_GetTime_hour "${lc_GetTime_string}" ${lc_GetTime_position} 2
      fi
      if instring lc_GetTime_position "${lc_GetTime_source}" mm ; then
        substr lc_GetTime_min "${lc_GetTime_string}" ${lc_GetTime_position} 2
      fi
      if instring lc_GetTime_position "${lc_GetTime_source}" ss ; then
        substr lc_GetTime_sec "${lc_GetTime_string}" ${lc_GetTime_position} 2
      fi
      if instring lc_GetTime_position "${lc_GetTime_source}" "pp|PP" ; then
        substr lc_GetTime_ampm "${lc_GetTime_string}" ${lc_GetTime_position} 2
      fi

#if no date is found we should return with an error code and message
      #echo "${lc_GetTime_monthname:-jan} ${lc_GetTime_day:-1} ${lc_GetTime_year} ${lc_GetTime_dayofyear}${lc_GetTime_dayofyear:+ day} ${lc_GetTime_hour:-0}:${lc_GetTime_min:-0}:${lc_GetTime_sec:-0}${lc_GetTime_ampm}" >&2
      if ! lc_GetTime_time="$(gnudate +%s -d "${lc_GetTime_monthname:-jan} ${lc_GetTime_day:-1} ${lc_GetTime_year} ${lc_GetTime_dayofyear}${lc_GetTime_dayofyear:+ day} ${lc_GetTime_hour:-0}:${lc_GetTime_min:-0}:${lc_GetTime_sec:-0}${lc_GetTime_ampm}")" ; then
        return 1
      fi
      ;;
#[cf]
  esac
  if [[ "$1" = "-" ]] ; then
    echo "${lc_GetTime_time}"
  else
    eval $1=\"\${lc_GetTime_time}\"
  fi
  unset lc_GetTime_monthnames lc_GetTime_string
  unset lc_GetTime_position lc_GetTime_year lc_GetTime_dayofyear lc_GetTime_month lc_GetTime_monthname lc_GetTime_day lc_GetTime_hour lc_GetTime_min lc_GetTime_sec lc_GetTime_ampm
}
# vim:number:tabstop=2:shiftwidth=2:autoindent:foldmethod=marker:foldlevel=0:foldmarker=#[of]\:,#[cf]
