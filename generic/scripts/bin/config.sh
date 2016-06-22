# declare files for scripts

declare -A kahvihubScripts=(["fibonacci"]="fibonacci-sm.js" ["quicksort"]="quicksort-sm.js" ["newton"]="newton-sm.js")
declare -A solmuhubScripts=(["fibonacci"]="fibonacci-sm.js" ["quicksort"]="quicksort-sm.js" ["newton"]="newton-sm.js")
declare -A duktapeScripts=(["fibonacci"]="fibonacci-nocall.js" ["quicksort"]="quicksort-nocall.js" ["newton"]="newton-nocall.js")
declare -A nodeScripts=(["fibonacci"]="fibonacci-sm.js" ["quicksort"]="quicksort-sm.js" ["newton"]="newton-sm.js")

#declare -A processNames=(["duktape"]="node duktape-server.js" ["duktape"]="node duktape-server.js" ["node"]="node server.js" ["solmuhub"]="node .")


# Get process numbers for different hub implementations
declare kahvihubPid=$(netstat -tulpn 2>/dev/null | grep 'tcp.*8080.*[0-9]*/java' | awk '{ print $7 }' | sed 's/\/java//g')

declare solmuhubPid=$(netstat -tulpn 2>/dev/null | grep 'tcp.*3300.*[0-9]*/node' | awk '{ print $7 }' | sed 's/\/node//g')

declare nodePid=$(netstat -tulpn 2>/dev/null | grep 'tcp.*3000.*[0-9]*/node' | awk '{ print $7 }' | sed 's/\/node//g') 

declare duktapePid=$(netstat -tulpn 2>/dev/null | grep 'tcp.*3030.*[0-9]*/node' | awk '{ print $7 }' | sed 's/\/node//g')
