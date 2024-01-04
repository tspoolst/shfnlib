#!/bin/bash
fn_AtomicLock() {
#[of]:  usage
  if [[ -z "$1" ]] ; then
    echo "Usage: fn AtomicLock lockfile [pid]"
    echo "Error: none"
    echo "Description:"
    echo "  creates an atomic lock"
    echo "  causes current process to wait until previous processes in the lock list finish"
    echo "  the lock list file is checked every 5 seconds and deleted when last lock pid is removed"
    echo "Examples:"
    echo '  fn AtomicLock ${gl_vardir}/${gl_progname}.lock $$'
    echo '  #creates lock'
    echo '  fn AtomicLock ${gl_vardir}/${gl_progname}.lock'
    echo '  #removes lock'
    echo "Returns:"
    echo "  0 success"
    exit 1
  fi

#[cf]
  lc_AtomicLock_filename="$1"
  lc_AtomicLock_progpid="$2"
  if [[ -z "${lc_AtomicLock_progpid}" ]] ; then
    msgdbg 3 "##removing lock"
    rm -f ${lc_AtomicLock_filename} 2>/dev/null
  else
    msgdbg 3 "##applying lock"
    echo "${lc_AtomicLock_progpid}" >> ${lc_AtomicLock_filename}
    while true
    do
      if [[ -s ${lc_AtomicLock_filename} ]] ; then
        if ! ps -p "$(head -1 ${lc_AtomicLock_filename} 2>/dev/null)" >/dev/null 2>&1 ; then
          rm -f ${lc_AtomicLock_filename} 2>/dev/null
        fi
      else
        echo "${lc_AtomicLock_progpid}" >> ${lc_AtomicLock_filename}
      fi
      if [[ "$(head -1 ${lc_AtomicLock_filename} 2>/dev/null)" = "${lc_AtomicLock_progpid}" ]] ; then
        break
      fi
      sleep 5
    done
  fi
  return 0
}
