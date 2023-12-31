#!/bin/bash
function fn_GlobalUsage {
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
    /^function /{
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
  [[ "$1" = "-h" ]] && echo "function exit code definitions"
  for lc_GlobalUsage_i in $(grep "funclib\-./" "${gl_funcdir}/${gl_funclib}" | grep fn_MsgExpand | grep -v -e "^[[:blank:]]*$" -e "^[[:blank:]]*#" | sed -e 's%.*\(funclib-.*\.sh\).*%\1%')
  do
    echo cat "${gl_funcdir}/${lc_GlobalUsage_i}"
  done | awk '
    /[0-9] \)/{
      count=1
      print "\n-------------------------------------------------------------------------------------";
      print "EXIT Code",$1;
      getline;
      while (!/;;/) {
        if (/lc_MsgExpand_msg/) {
          gsub (".*lc_MsgExpand_msg=\"","         Message: ");
          gsub ("[\"'\'']$","");
          print;
          getline;
          continue;
        }
        if (/## ##/) {
          gsub (".*## ##","");
          print "                "$0;
          getline;
          continue;
        }
        if (/## #/) {
          gsub (".*## #","");
          print "           "count". "$0;
          ++count;
          getline;
          continue;
        }
        if (/## /) {
          gsub (".*## ","");
          print "    Likely Cause: "$0;
          print "Steps to Resolve:";
          getline;
          continue;
        }
        getline;
      }
    }
  '
#[cf]
  } | (
#[of]:  title
lc_GlobalUsage_title="Function Library ${gl_funcbranch} Branch Version ${gl_funcver}"
#[cf]
  if [[ "$1" = "-h" ]] ; then
#[of]:    scan for first node
unset lc_GlobalUsage_node
while read -r lc_GlobalUsage_cline ; do
  [[ "${lc_GlobalUsage_cline}" !=  "${lc_GlobalUsage_cline##function }" ]] && {
    lc_GlobalUsage_node="${lc_GlobalUsage_cline##function }"
    break
  }
  [[ -z "${lc_GlobalUsage_node}" ]] && continue
done
#[cf]
#[of]:    scan for next node and save block
hashdel nodehash
while read -r lc_GlobalUsage_cline ; do
  [[ "${lc_GlobalUsage_cline}" !=  "${lc_GlobalUsage_cline##function }" ]] && {
    hashsetkey nodehash "${lc_GlobalUsage_node}" "${lc_GlobalUsage_block}"
    lc_GlobalUsage_block=""
    lc_GlobalUsage_node="${lc_GlobalUsage_cline##function }"
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
    lc_GlobalUsage_name="${lc_GlobalUsage_node}"
    asplit lc_GlobalUsage_node " " "${lc_GlobalUsage_node}"
    ajoin lc_GlobalUsage_node _ "${lc_GlobalUsage_node[@]}"
    echo "<li><a name=\"${lc_GlobalUsage_node}_contents\"></a><a href=\"#${lc_GlobalUsage_node}_block\">${lc_GlobalUsage_name}</a></li>"
  done
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
  asplit lc_GlobalUsage_ref " " "${lc_GlobalUsage_node}"
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
    echo "${lc_GlobalUsage_trailer}"
  else
    echo "${lc_GlobalUsage_title}"
    cat
    echo
  fi
  )
}
