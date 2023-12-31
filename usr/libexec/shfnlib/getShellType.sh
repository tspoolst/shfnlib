#!/bin/bash
echo "/bin/sh is different on different systems"
echo "ubuntu annoyingly switched /bin/sh to dash in 2017."
echo "at least they published a doc to help convert your code should you wish to."
echo "https://wiki.ubuntu.com/DashAsBinSh"
echo "they write about how much faster dash is, and yet you can't even directly get the version of this crippled shell."
echo "many operations that can be done natively within ksh88/ksh93/bash require using external tools in dash,"
echo "  incleasing your subshell calls and external dependencies"
echo "if speed is your worry, write better/tighter code and/or use another language."
echo
echo
echo -n "this shell is "
if [ -n "${KSH_VERSION}" ] ; then
  if set | grep ^KSH_VERSION | grep -q '\.sh\.version' ; then
    echo "ksh93"
  else
    echo "ksh88 or mksh"
  fi
elif [ -n "${BASH_VERSION}" ] ; then
  echo "bash"
else
  if ! type '[[' >/dev/null ; then
    echo "probably dash"
  else
    echo "unknown"
  fi
fi

