#!/bin/bash
fn_SetVars() {
  ##read has a tendency of merging variables if not all accounted for
  ##the end result could be useless variables i.e. hour="14 5" not exactly the correct hour is it
  ##${gl_xdate} | read gl_year gl_month gl_day gl_totaldays gl_weekday 
  ##further a piped read depending on the shell may or may not create a subshell
  ##to keep read consistant across shells it should be forced into a subshell using ()

  ##setting data arrays is not too much fun either
    ##set -A gl_time `${gl_xdate}`
    ##gl_year=${gl_time[0]}
    ##gl_month=${gl_time[1]}
    ##gl_day=${gl_time[2]}
    ##gl_totaldays=${gl_time[3]}
    ##gl_weekday=${gl_time[4]}
    ##gl_hour=${gl_time[5]}
    ##gl_min=${gl_time[6]}
    ##gl_sec=${gl_time[7]}
    ##gl_totaldaysec=${gl_time[8]}
    ##gl_monthname=${gl_time[9]}
    ##gl_dayname=${gl_time[10]}

  if [ -z "$2" ] ; then
    echo "Usage: fn SetVars [-r num] [start offset] [num of vars to set] [next offset] (lc|gl)_var [(lc|gl)_var] dataset"
    echo "         -r 1-?  requires the dataset to be an exact length" 
    echo "Error: must have at least 2 arguments"
    echo "Description: sets variables from data in a controlled mannor.  used as a read replacement"
    echo "Examples:"
    echo '  "fn SetVars 1 3 11 lc_func_year lc_func_month lc_func_day lc_func_dayname `${gl_xdate} ${lc_func_dshift}`"'
    echo "     if used the first offset is required.  the second value is assumed 0 (meaning continue until there"
    echo "     are no more vars or no more data"
    echo "there is no limit to the number of offsets used"
    echo '  "fn SetVars 1 3 11 1 8 5 2 ........."'
    echo "     starting at data_1  3 vars are set"
    echo "     jumping to  data_11 1 var is set"
    echo "     jumping to  data_8  5 vars are set"
    echo "     jumping to  data_2  the remander of the vars are set"
    echo "     if there are more vars than data excess vars will be set empty"
    echo "Returns:"
    echo "  0 success"
    echo "  1 failure"
    exit 1
  fi
##offset start,current,fin,max  vars start,current,fin   data start,current,fin,required
##        os=0,oc=0,of=3,om=0        vs=of,vc=0,vf=7          ds=vf,dc=0,df=0,dr=0
##
  lc_SetVars_os=1
  lc_SetVars_oc=0
  lc_SetVars_of=1
  lc_SetVars_om=0
  lc_SetVars_vc=0
  lc_SetVars_dc=0
  lc_SetVars_df=0

  if [ "$1" = "-r" ] && isnum "$2" ; then
    lc_SetVars_dr="$2"
    shift
    shift
    msgdbg 3 "lc_SetVars_dr=${lc_SetVars_dr} - dataset is now required to this exact length"
  else
    lc_SetVars_dr=0
  fi

  msgdbg 5 "lc_SetVars_os=${lc_SetVars_os}"
  while eval [ -n \"\${${lc_SetVars_of}##*[a-zA-Z]*}\" ]
  do
    lc_SetVars_of=$(( lc_SetVars_of+1 ))
  done
  lc_SetVars_vs=${lc_SetVars_of}
  lc_SetVars_vf=${lc_SetVars_of}
  msgdbg 5 "lc_SetVars_of=${lc_SetVars_of}"

  msgdbg 5 "lc_SetVars_vs=${lc_SetVars_vs}"
  while eval [ -n \"\${${lc_SetVars_vf}}\" ] && eval [ -z \"\${${lc_SetVars_vf}##lc_*}\" -o -z \"\${${lc_SetVars_vf}##gl_*}\" ]
  do
    lc_SetVars_vf=$(( lc_SetVars_vf+1 ))
  done
  if [ ${lc_SetVars_vs} -eq ${lc_SetVars_vf} ] ; then
    msgdbg 0 "I can not set thin air.  You need to actually provide variable names."
    exit 1
  fi
  lc_SetVars_ds=${lc_SetVars_vf}
  lc_SetVars_df=${lc_SetVars_vf}
  msgdbg 5 "lc_SetVars_vf=${lc_SetVars_vf}"

  msgdbg 5 "lc_SetVars_ds=${lc_SetVars_ds}"
  lc_SetVars_df=$(( $#+1 ))
  msgdbg 5 "lc_SetVars_df=${lc_SetVars_df}"
  if [ ${lc_SetVars_dr} -gt 0 ] ; then
    if [ ${lc_SetVars_df} -gt $((lc_SetVars_ds+${lc_SetVars_dr})) ] ; then
      msgdbg 3 "dataset length is $((lc_SetVars_df-${lc_SetVars_ds})) - longer than the required length ${lc_SetVars_dr}"
      return 1
    elif [ ${lc_SetVars_df} -lt $((lc_SetVars_ds+${lc_SetVars_dr})) ] ; then
      msgdbg 3 "dataset length is $((lc_SetVars_df-${lc_SetVars_ds})) - shorter than the required length ${lc_SetVars_dr}"
      return 1
    fi
    msgdbg 5 "dataset length is $((lc_SetVars_df-${lc_SetVars_ds}))"
  fi
  while [ $((${lc_SetVars_vs}+${lc_SetVars_vc})) -lt ${lc_SetVars_vf} ]
  do
    if [ ${lc_SetVars_om} -eq 0 ] ; then
      if [ $((${lc_SetVars_os}+${lc_SetVars_oc})) -lt ${lc_SetVars_of} ] ; then
        eval lc_SetVars_dc=\$$((${lc_SetVars_os}+${lc_SetVars_oc}))
        lc_SetVars_dc=$((${lc_SetVars_dc}-1))
        if [ ${lc_SetVars_dc} -lt 0 ] ; then
          echo "gl_return=${gl_return:-0}  ${gl_funcname}: Position paramiters are not 0 based.  You need more coffie."
          exit 1
        fi
        lc_SetVars_oc=$((${lc_SetVars_oc}+1))
        lc_SetVars_om=${lc_SetVars_vf}
        msgdbg 5 "lc_SetVars_oc=${lc_SetVars_oc}"
        msgdbg 5 "lc_SetVars_om=${lc_SetVars_om}"
        if [ $((${lc_SetVars_os}+${lc_SetVars_oc})) -lt ${lc_SetVars_of} ] ; then
          eval lc_SetVars_om=\$$((${lc_SetVars_os}+${lc_SetVars_oc}))
          lc_SetVars_oc=$((${lc_SetVars_oc}+1))
        fi
      fi
    fi
    [ ${gl_debuglevel:-0} -ge 4 ] && eval echo \"gl_return=${gl_return:-0}\ \ ${gl_funcname}: \${$((${lc_SetVars_vs}+${lc_SetVars_vc}))}=\\\"\${$((${lc_SetVars_ds}+${lc_SetVars_dc}))}\\\"\" >&2
    eval eval \${$((${lc_SetVars_vs}+${lc_SetVars_vc}))}=\\\"\\\${$((${lc_SetVars_ds}+${lc_SetVars_dc}))}\\\"
    lc_SetVars_vc=$((${lc_SetVars_vc}+1));lc_SetVars_dc=$((${lc_SetVars_dc}+1))
    [ ${lc_SetVars_om} -gt 0 ] && lc_SetVars_om=$((${lc_SetVars_om}-1))
  done
  unset lc_SetVars_os lc_SetVars_oc lc_SetVars_of lc_SetVars_om
  unset lc_SetVars_vs lc_SetVars_vc lc_SetVars_vf
  unset lc_SetVars_ds lc_SetVars_dc lc_SetVars_df lc_SetVars_dr
  return 0
}
