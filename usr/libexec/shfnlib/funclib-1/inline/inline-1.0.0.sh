#!/bin/sh

  #WARNING be sure your editor deos not break this WARNING
  #set IFS to a sane value
  IFS=' 	
'
  gl_systemIFS="${IFS}"

  ##inside a function ksh forgets who the originating script is.  so it must be saved within main
  gl_pathprogname="$0"
  gl_progname="${gl_pathprogname##*/}"
  gl_progargs="$@"

#[of]:  parse command line
##process command line into gl_progargs format.  the actual command line is not touched unless a -- is encountered.
##
##sample command line
##  ./sample-prog-1.0.0.ksh -a -f part0 -c -d="once two" parta partb "part1 part2" -r=i=something
##produces the following variables
##    contains all arguments in one variable
##      gl_progargs='-a -f part0 -c -d=once two parta partb part1 part2 -r=i=something'
##
##    every switch found sets a variable named gl_progargs_{switchname} equal to "true"
##      gl_progargs_a=true
##      gl_progargs_c=true
##      gl_progargs_d=true
##      gl_progargs_f=true
##      gl_progargs_r=true
##
##    arguments not associated with a switch are placed in an array
##      gl_progargs_array=([0]="part0" [1]="parta" [2]="partb" [3]="part1 part2")
##
##    data attached to a switch is stored in a variable name gl_progargs_{switchname}_data
##      gl_progargs_d_data='once two'
##
##    the total count of arguments not associated with a switch
##      gl_progargs_datacount=4
##
##      gl_progargs_r_data=i=something
##    summary of all switches found
##      gl_progargs_switchcount=5
##      gl_progargs_switchlist='a f c d r'
##
##sample code
##  if ${gl_progargs_a:-false} ; then
##    echo "ask switch is set"
##  else
##    echo "ask switch is not set"
##  fi
##  
##  if ${gl_progargs_d:-false} ; then
##    echo "${gl_progargs_d_data}"
##  else
##    echo "d switch is not set"
##  fi
##  

##unset any variables prefexed with gl_progargs_
for lc_main_currentvar in $(set | sed -ne '/^gl_progargs_/s/=.*//p' ) ; do
  unset ${lc_main_currentvar}
done

##begin parsing command line
aset lc_main_args "$@"
while ashift lc_main_currentarg lc_main_args ; do
  if [[ -n "${lc_main_currentarg}" ]] ; then
    ##if current arg not empty and
    ##  begins with a - or --
    ##  it is a switch
    ##  switches must begin with a letter
    if [[ "${lc_main_currentarg%%=*}" = -?(-)@("\?"|+([[:alpha:]])*([[:alnum:]])) ]] ; then
      ##strip off leading - or --
      lc_main_currentarg="${lc_main_currentarg##-?(-)}"
      if [[ -z "${lc_main_currentarg##*=*}" ]] ; then
        ##if current arg is a switch and has data --- split arg by switchname and data
        lc_main_currentdata="${lc_main_currentarg#*=}"
        lc_main_currentarg="${lc_main_currentarg%%=*}"
        ##if currentarg = ? replace it with help
        [[ "${lc_main_currentarg}" = "\?" ]] && lc_main_currentarg=help
        ##save switch data into the variable gl_progargs_{switchname}_data
        eval "gl_progargs_${lc_main_currentarg}_data=\"\${lc_main_currentdata}\""
      fi
      ##if currentarg = ? replace it with help
      [[ "${lc_main_currentarg}" = "\?" ]] && lc_main_currentarg=help
      ##set switch state in gl_progargs_{switchname}=true
      eval "gl_progargs_${lc_main_currentarg}=\"true\""
      ##append switch into gl_progargs_switchlist
      gl_progargs_switchlist="${gl_progargs_switchlist}${gl_progargs_switchlist:+ }${lc_main_currentarg}"
      gl_progargs_switchcount=$(( ${gl_progargs_switchcount:-0} + 1 ))
    elif [[ -z "${lc_main_currentarg#--}" ]] ; then
      ##stop parsing command line and overwrite with remander of input
      set -- "${lc_main_args[@]}"
      break
    else
      ##if current arg is data --- append data into the array gl_progargs_array
      apush gl_progargs_array "${lc_main_currentarg}"
    fi
  fi
done
gl_progargs_datacount=${#gl_progargs_array[@]}
unset lc_main_args
unset lc_main_currentarg
unset lc_main_currentdata
#[cf]
  
  ##grab the current username
  fn SetVars gl_username $(id)
  gl_username="${gl_username#*\(}";gl_username="${gl_username%\)}"

  #pushd/popd functions init
  #these commands are built in to bash not ksh
  unset gl_pushpopstack

  gl_tooldir="${gl_funcdir}/tools"
  gl_kernelver=$(tolower - $(uname -s));gl_kernelver="${gl_kernelver%%-*}"
  
  ##gnu tools
  gl_gnutooldir="${gl_funcdir}/gnu/${gl_kernelver}/bin"
  function gnudate { "${gl_gnutooldir}/date" "$@" ; }
  function gnused { "${gl_gnutooldir}/sed" "$@" ; }
  function gnutar { "${gl_gnutooldir}/tar" "$@" ; }

  function xdate { "${gl_tooldir}/kdate-0.sh" "$@" ; }
  gl_xdate="xdate"
  if [[ ! -x "${gl_tooldir}/kdate-0.sh" ]] ; then
    die 22 "\"${gl_tooldir}/kdate-0.sh\" not found, or not executable"
  fi

  ##set global date vars
  gl_1hour=$((60*60))
  gl_1day=$((24*gl_1hour))
  fn SetVars gl_year gl_month gl_day gl_totaldays gl_weekday gl_hour gl_min gl_sec gl_totaldaysec gl_monthname gl_dayname `${gl_xdate}`

  ##set gl_progdir
  fn ResolveProgdir
# vim:number:tabstop=2:shiftwidth=2:autoindent:foldmethod=marker:foldlevel=0:foldmarker=#[of]\:,#[cf]
