#!/bin/bash
#set -xv

#[of]:functions
###########################################################################################################
## functions
##
###########################################################################################################
#[of]:function setarray
setarray() {
  if [ -z "$2" ] ; then
    echo "Usage: setarray var val [val val ...]"
    echo "Error: must have at least 2 args"
    echo "Description:"
    echo "  this exist because, there is no common way of setting an array in ksh and bash"
    echo "Examples:"
    echo "  i.e.  setarray gl_BusinessDays mon tue wed thu fri"
    echo "Returns:"
    echo "  0 success"
    exit 1
  fi
  lc_setarray_array="$1"
  shift
  if [ -n "$BASH_VERSION" ] ; then
    eval "${lc_setarray_array}=($@)"
  else
    eval "set -A ${lc_setarray_array} $@"
  fi
  unset lc_setarray_array
  return 0
}
#[cf]
#[of]:function exit_malformed_date
exit_malformed_date() {
  echo "malformed date"
  exit 1
}
#[cf]
#[of]:function isleapyear
isleapyear() {
#if date matches any of these values it is a leap year
#returns 0/true or 1/false
  case $1 in
    *0[48] |\
    *[2468][048] |\
    *[13579][26] |\
    [2468][048]00 |\
    [13579][26]00 )
      return 0
      ;;
  esac
  return 1
}
#[cf]
#[of]:function fn_dateytddn
fn_dateytddn() {
  #day offset for 2000
  lc_dateytddn_doffet=6
  #starting year
  lc_dateytddn_year=2000
  lc_dateytddn_dtotal=0
  while [ $lc_dateytddn_year -lt $1 ] ; do
    if isleapyear $lc_dateytddn_year; then
      #echo "$year $dtotal+2"
      lc_dateytddn_dtotal=$((lc_dateytddn_dtotal + 2))
    else
      lc_dateytddn_dtotal=$((lc_dateytddn_dtotal + 1))
      #echo "$year $lc_dateytddn_dtotal+1"
    fi
    lc_dateytddn_year=$((lc_dateytddn_year + 1))
  done
  eval $3=$(( (lc_dateytddn_dtotal + lc_dateytddn_doffet + ${2:-1} - 1) %7 ))
  #eval $3=$lc_dateytddn_day
}
#[cf]
#[of]:function fn_dateymdtd
fn_dateymdtd() {
#calculates the total days from the beginning of the current year
#input    year,month,day
#returns  totaldays
  typeset lc_dateymdtd_year=$1
  typeset lc_dateymdtd_month=${2#0}
  typeset lc_dateymdtd_day=${3#0}
  typeset lc_dateymdtd_tdays=0
  #typeset lc_dateymdtd_mdata
  setarray lc_dateymdtd_mdata ${gl_mdata[@]}
  #adjusting for leap year
  if isleapyear $lc_dateymdtd_year ; then
    lc_dateymdtd_mdata[1]=29
    #echo leap total days
  fi
  typeset lc_dateymdtd_a=0
  while [ $lc_dateymdtd_a -lt $(( $lc_dateymdtd_month - 1 )) ] ; do
    lc_dateymdtd_tdays=$(( $lc_dateymdtd_tdays + ${lc_dateymdtd_mdata[$lc_dateymdtd_a]} ))
    lc_dateymdtd_a=$(( lc_dateymdtd_a + 1 ))
  done
  lc_dateymdtd_tdays=$(( lc_dateymdtd_tdays + lc_dateymdtd_day ))
  eval $4=$lc_dateymdtd_tdays
}
#[cf]
#[of]:function fn_datenowdays
fn_datenowdays() {
#set -xv
#calculates new date by subtracting x num of days
#input    year,totaldays,num of days to subtract
#returns  year,totaldays
  typeset lc_datenowdays_year=$1
  typeset lc_datenowdays_cdays=$2
  typeset lc_datenowdays_ndays=$3
  lc_datenowdays_ndays=$((lc_datenowdays_cdays + lc_datenowdays_ndays))
  while [ $lc_datenowdays_ndays -lt 1 ] ; do
    lc_datenowdays_year=$((lc_datenowdays_year - 1 ))
    lc_datenowdays_ndays=$((lc_datenowdays_ndays + 365 ))
    isleapyear $lc_datenowdays_year && lc_datenowdays_ndays=$((lc_datenowdays_ndays + 1))
  done
  isleapyear $lc_datenowdays_year && lc_datenowdays_tdays=366 || lc_datenowdays_tdays=365
  while [ $lc_datenowdays_ndays -gt $lc_datenowdays_tdays ] ; do
    lc_datenowdays_ndays=$((lc_datenowdays_ndays - lc_datenowdays_tdays))
    lc_datenowdays_year=$((lc_datenowdays_year + 1))
    isleapyear $lc_datenowdays_year && lc_datenowdays_tdays=366 || lc_datenowdays_tdays=365
  done
  eval $4=$lc_datenowdays_year
  eval $5=$lc_datenowdays_ndays
}
#[cf]
#[of]:function fn_dateytdmd
fn_dateytdmd() {
#set -xv
#determins month and day for specified year from totaldays into year
#input    year,totaldays
#returns  month, day
#if the input days are to high we get an infinite loop trying to count up to
# non existant days, as these calculations are only from pre calculated dates
# this should never happen, but it should still be fixed for reusability
  typeset lc_dateytdmd_year=$1
  typeset lc_dateytdmd_month=0
  typeset lc_dateytdmd_day=$2
  #typeset lc_dateytdmd_mdata
  setarray lc_dateytdmd_mdata ${gl_mdata[@]}
  #adjusting for leap year
  if isleapyear $lc_dateytdmd_year ; then
    lc_dateytdmd_mdata[1]=29
    #echo leap month day
  fi
  while [ $lc_dateytdmd_day -gt ${lc_dateytdmd_mdata[$lc_dateytdmd_month]} ] ; do
    lc_dateytdmd_day=$(( lc_dateytdmd_day - ${lc_dateytdmd_mdata[$lc_dateytdmd_month]} ))
    lc_dateytdmd_month=$((lc_dateytdmd_month + 1))
  done
  lc_dateytdmd_month=$((lc_dateytdmd_month + 1))
  eval $3=$lc_dateytdmd_month
  eval $4=$lc_dateytdmd_day
}
#[cf]
#[of]:function fn_calcdays
fn_calcdays() {
  fn_datenowdays $gl_inyear $gl_intday $gl_dayshift gl_outyear gl_outtday
  fn_dateytddn $gl_outyear $gl_outtday gl_outwday
  fn_dateytdmd $gl_outyear $gl_outtday gl_outmonth gl_outday
}
#[cf]

#[cf]
#[of]:main
###########################################################################################################
## main
##
###########################################################################################################


setarray gl_mdata 31 28 31 30 31 30 31 31 30 31 30 31
setarray gl_monthname jan feb mar apr may jun jul aug sep oct nov dec
setarray gl_dayname sun mon tue wed thu fri sat

if [[ $# -eq 0 ]] || [[ $# -eq 1 && $1 -eq 0 ]] ; then
  set -- `date +'%Y %-m %-d %-j %-w %-H %-M %-S'`
    gl_outyear=$1
    gl_outmonth=$2
    gl_outday=$3
    gl_outtday=$4
    gl_outwday=$5
    gl_inhour=$6
    gl_inmin=${7:-0}
    gl_insec=${8:-0}
elif [[ $# -eq 1 ]] ; then
  gl_dayshift=$1
  set -- `date +'%Y %-m %-d %-j %-H %-M %-S'`
    gl_inyear=$1
    gl_inmonth=$2
    gl_inday=$3
    gl_intday=$4
    gl_inhour=$5
    gl_inmin=${6:-0}
    gl_insec=${7:-0}
  fn_calcdays
elif [[ $# -eq 7 ]] ; then
  gl_dayshift=$1
  gl_inyear=$2      ;gl_inyear=${gl_inyear:-0}
  gl_inmonth=${3#0} ;gl_inmonth=${gl_inmonth:-0}
  gl_inday=${4#0}   ;gl_inday=${gl_inday:-0}
  gl_inhour=${5#0}  ;gl_inhour=${gl_inhour:-0}
  gl_inmin=${6#0}   ;gl_inmin=${gl_inmin:-0}
  gl_insec=${7#0}   ;gl_insec=${gl_insec:-0}
  [ ${gl_inyear}  -gt 2000                         ] || exit_malformed_date
  [ ${gl_inmonth} -ge 1    -a ${gl_inmonth} -le 12 ] || exit_malformed_date
  [ ${gl_inday}   -ge 1    -a ${gl_inday}   -le 31 ] || exit_malformed_date
  [ ${gl_inhour}  -ge 0    -a ${gl_inhour}  -le 23 ] || exit_malformed_date
  [ ${gl_inmin}   -ge 0    -a ${gl_inmin}   -le 59 ] || exit_malformed_date
  [ ${gl_insec}   -ge 0    -a ${gl_insec}   -le 59 ] || exit_malformed_date
  fn_dateymdtd $gl_inyear $gl_inmonth $gl_inday gl_intday
  fn_calcdays
else
  echo "wrong number of arguments"
  exit 1
fi

echo "$gl_outyear $gl_outmonth $gl_outday $gl_outtday $gl_outwday $gl_inhour $gl_inmin $gl_insec $((gl_inhour * 60 * 60 + gl_inmin * 60 + gl_insec)) ${gl_monthname[$((gl_outmonth - 1))]} ${gl_dayname[gl_outwday]}"

#[cf]
