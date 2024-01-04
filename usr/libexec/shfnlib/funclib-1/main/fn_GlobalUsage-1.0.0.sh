#!/bin/bash
fn_GlobalUsage() {
#[of]:  usage
  if false ; then
    echo "Usage: fn GlobalUsage [-h]"
    echo "Error: none"
    echo "Description:"
    echo "  dumps all usage blocks from this function library"
    echo "    -h produces html output"
    echo "Examples:"
    echo '  none'
    echo "Returns:"
    echo "  0 success"
    exit 1
  fi
#[cf]
  typeset lc_GlobalUsage_i
  {
#[of]:    build usage sections
  for lc_GlobalUsage_i in $(grep "funclib\-./" "${gl_funcdir}/${gl_funclib}" | grep -v -e "^[[:blank:]]*$" -e "^[[:blank:]]*#" | sed -e 's%.*\(funclib-.*\.sh\).*%\1%')
  do
    cat "${gl_funcdir}/${lc_GlobalUsage_i}"
  done | awk '
    /^[^# ].*() {$/{
      print "\n\n-------------------------------------------------------------------------------------\n",$1,$2;
      next;
    }
    /["'\'']Usage:/{
      while (/echo/) {
        gsub ("^[^\"'\'']*echo[^\"'\'']*[\"'\'']","");
        gsub ("[\"'\'']$","");
        if (/^Error/) { getline;continue; }
        if (/^Usage/ || /^Description/ || /^Examples/ || /^Returns/ ) {
          print "\n    ",$0;
          getline;
          continue;
        }
        print "        ",$0;
        getline;
      }
    }
  '
#[cf]
#[of]:    build message definitions
#[c]  [[ "$1" = "-h" ]] && echo "exit code definitions() {"
#[c]  for lc_GlobalUsage_i in $(grep "funclib\-./" "${gl_funcdir}/${gl_funclib}" | grep fn_MsgExpand | grep -v -e "^[[:blank:]]*$" -e "^[[:blank:]]*#" | sed -e 's%.*\(funclib-.*\.sh\).*%\1%')
#[c]  do
#[c]    echo cat "${gl_funcdir}/${lc_GlobalUsage_i}"
#[c]  done | awk '
#[c]    /[0-9] \)/{
#[c]      count=1
#[c]      print "\n-------------------------------------------------------------------------------------";
#[c]      print "EXIT Code",$1;
#[c]      getline;
#[c]      while (!/;;/) {
#[c]        if (/lc_MsgExpand_msg/) {
#[c]          gsub (".*lc_MsgExpand_msg=\"","         Message: ");
#[c]          gsub ("[\"'\'']$","");
#[c]          print;
#[c]          getline;
#[c]          continue;
#[c]        }
#[c]        if (/## ##/) {
#[c]          gsub (".*## ##","");
#[c]          print "                "$0;
#[c]          getline;
#[c]          continue;
#[c]        }
#[c]        if (/## #/) {
#[c]          gsub (".*## #","");
#[c]          print "           "count". "$0;
#[c]          ++count;
#[c]          getline;
#[c]          continue;
#[c]        }
#[c]        if (/## /) {
#[c]          gsub (".*## ","");
#[c]          print "    Likely Cause: "$0;
#[c]          print "Steps to Resolve:";
#[c]          getline;
#[c]          continue;
#[c]        }
#[c]        getline;
#[c]      }
#[c]    }
#[c]  '
#[cf]
  } | (
#[of]:  title
lc_GlobalUsage_title="Function Library ${gl_funcbranch} Branch Version ${gl_funcver}"
#[cf]
  if [[ "$1" = "-h" ]] ; then
#[of]:    build html
#[of]:    scan for first node
unset lc_GlobalUsage_node
while read -r lc_GlobalUsage_cline ; do
  [[ "${lc_GlobalUsage_cline}" !=  "${lc_GlobalUsage_cline##[^# ]*\() {}" ]] && {
    lc_GlobalUsage_node="${lc_GlobalUsage_cline% {}"
    break
  }
  [[ -z "${lc_GlobalUsage_node}" ]] && continue
done
#[cf]
#[of]:    scan for next node and save block
hashdel nodehash
while read -r lc_GlobalUsage_cline ; do
  [[ "${lc_GlobalUsage_cline}" !=  "${lc_GlobalUsage_cline##[^# ]*\() {}" ]] && {
    hashsetkey nodehash "${lc_GlobalUsage_node}" "${lc_GlobalUsage_block}"
    lc_GlobalUsage_block=""
    lc_GlobalUsage_node="${lc_GlobalUsage_cline% {}"
    continue
  }
  [[ "${lc_GlobalUsage_cline}" != "${lc_GlobalUsage_cline##---------}" ]] && continue
  [[ -z "${lc_GlobalUsage_cline}" && -z "${lc_GlobalUsage_block}" ]] && continue
  lc_GlobalUsage_block="${lc_GlobalUsage_block}
${lc_GlobalUsage_cline}"
done
#[cf]
#[of]:    save last block
hashsetkey nodehash "${lc_GlobalUsage_node}" "${lc_GlobalUsage_block}"
#[cf]
    hashkeys lc_GlobalUsage_nodes nodehash
#[c]    asort lc_GlobalUsage_nodes "${lc_GlobalUsage_nodes[@]}"
#[of]:    header
lc_GlobalUsage_header="
<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">
<html>
<head>
  <meta content=\"text/html;charset=ISO-8859-1\" http-equiv=\"Content-Type\">
  <title>${lc_GlobalUsage_title}</title>
</head>
<body>
<div align=\"center\">
<h2>${lc_GlobalUsage_title}</h2>
</div>
"
#[cf]
#[of]:    contents
lc_GlobalUsage_contents="<hr size=\"2\" width=\"100%\">
<h4>contents</h4>
<ol>
$(
#[of]:  fill contents
  for lc_GlobalUsage_node in "${lc_GlobalUsage_nodes[@]}" ; do
    asplit lc_GlobalUsage_ref " " "${lc_GlobalUsage_node%\()}"
    ajoin lc_GlobalUsage_ref _ "${lc_GlobalUsage_ref[@]}"
    echo "<li><a name=\"${lc_GlobalUsage_ref}_contents\"></a><a href=\"#${lc_GlobalUsage_ref}_block\">${lc_GlobalUsage_node}</a></li>"
  done
  lc_GlobalUsage_node="Scripting Conventions"
  lc_GlobalUsage_ref="scripting_conventions"
  echo "<li><a name=\"${lc_GlobalUsage_ref}_contents\"></a><a href=\"#${lc_GlobalUsage_ref}_block\">${lc_GlobalUsage_node}</a></li>"
#[cf]
)
</ol>
<br>
"
#[cf]
#[of]:    blocks
lc_GlobalUsage_blocks="$(
#[of]:  fill blocks
for lc_GlobalUsage_node in "${lc_GlobalUsage_nodes[@]}" ; do
  hashgetkey lc_GlobalUsage_block nodehash "${lc_GlobalUsage_node}"
  asplit lc_GlobalUsage_ref " " "${lc_GlobalUsage_node%\()}"
  ajoin lc_GlobalUsage_ref _ "${lc_GlobalUsage_ref[@]}"
  echo "<hr size=\"2\" width=\"100%\">
    <h4><a name=\"${lc_GlobalUsage_ref}_block\"></a><a href=\"#${lc_GlobalUsage_ref}_contents\">${lc_GlobalUsage_node}</a></h4>
    <pre>${lc_GlobalUsage_block}</pre>"
done
#[cf]
)"
#[cf]
#[of]:    trailer
lc_GlobalUsage_trailer="
</body>
</html>
"
#[cf]
    echo "${lc_GlobalUsage_header}"
    echo "${lc_GlobalUsage_contents}"
    echo "${lc_GlobalUsage_blocks}"

    . "${gl_funcdir}/docs/description.txt"
    lc_GlobalUsage_ref="scripting_conventions"
    lc_GlobalUsage_node="Scripting Conventions"
    echo "<hr size=\"2\" width=\"100%\">
    <h4><a name=\"${lc_GlobalUsage_ref}_block\"></a><a href=\"#${lc_GlobalUsage_ref}_contents\">${lc_GlobalUsage_node}</a></h4>
    <pre>$(commentblock_description)</pre>"

    echo "${lc_GlobalUsage_trailer}"
#[cf]
  else
#[of]:    build txt
    echo "${lc_GlobalUsage_title}"
    cat
    . "${gl_funcdir}/docs/description.txt"
    echo;echo
    commentblock_description
    echo
#[cf]
  fi
  )
}
