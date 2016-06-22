#!/bin/bash

# This shell script executes all the algorithms on every type of hub, and outputs results under the 'latest'
# directory. Old results in latest are saved and moved under a timestamped directory in 'results' folder, so the timestamp
# indicates when they have been moved there, not the date that the tests in those folders where run. Possibly the next former
# timestamped folder in results is the timestamp of the next latest tests.. pretty complicated but.. yeah. 

types=( "solmuhub" "node" "kahvihub" "duktape" )
methods=( "fibonacci" "quicksort" "newton")
times=200
scr="Scripts"
CONF="main.conf"

. "config.sh"

if [ -r "../conf.d/$CONF" ]; then
  echo "Reading user config for iothub from $CONF...." >&2
  . "../conf.d/$CONF"
else
    echo "$CONF file not found in conf.d"
    exit 1
fi

time_stamp=$(date +"%s")
pretty_date=$(date -d @$time_stamp)
BACKUPDIR=$time_stamp
TEMPLATE_DIR=templates
BIN_DIR=bin

mkdir -p $RESULTSPATH/$BACKUPDIR
mv $LATESTPATH $RESULTSPATH/$BACKUPDIR
#rm -r $LATESTPATH/*
mkdir -p $LATESTPATH

touch $LATESTPATH/TEST-SPEC
mkdir -p $STATSPATH
mkdir -p $AVGPATH
printf "Test was started at: %s\nLoop times: %d\n" "$pretty_date" "$times" >>"$LATESTPATH/TEST-SPEC"

echo -n >"../$TEMPLATE_DIR/methods"
# if servers are not currently running, start them
for type in "${types[@]}"; do
    echo "$type" >>"../$TEMPLATE_DIR/methods"
    tmpcom="${type^^}SCRIPT"
    tmppth="${type^^}PATH"
    script="${!tmpcom}"
    path="${!tmppth}"
    tmpPid="${type}Pid"
    # check if process with correct pid exists, see config.sh
    if [ -z "${!tmpPid}" ]; then
        cd "$path"
        . $($script) &
    else
        echo "$type already running, moving on.."
    fi
    if [ "$?" -gt "0" ]; then
        echo "Could not initialize script $script at $path"
        cd "$SCRIPTSPATH/bin"
        exit 1
    fi 
    cd "$SCRIPTSPATH/bin"
done


for method in "${methods[@]}";
do
    for type in "${types[@]}";
    do
        tmp=$type$scr[$method]
        tmp_script="${!tmp}"
        tmpPid="${type}Pid"
        pid="${!tmpPid}"
        feedName="${type^^}FEED"
        feed="${!feedName}"
        portName="${type^^}PORT"
        port="${!portName}"

        echo "./do-curl.sh -n $times --method $method --script $tmp_script --pid $pid --port $port --feed $feed --type $type --host $HOST"
        . do-curl.sh -n $times --method $method --script $tmp_script --pid $pid --port $port --feed $feed --type $type --host $HOST
    done
    # Uncomment to save intermediate results to files, for debugging
    # results_file="../../results/latest/all-$m-$t.out"
    # awk '{ total1+=$1; total2+=$2; total3+=$3; total4+=$4; total5+=$5; total6+=$6; total7+=$7; total8+=$8; total9+=$9; total10+=$10; reqtime+=$11; c++ } \
    #     END { printf "%f\t%f\t%i\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n", total1/c,reqtime/c*1000,c,total2/c,total3/c,total4/c,total5/c,total6/c,total7/c,total8/c,total9/c,total10/c}' \
    #     "$filename" >>"$results_file"
done

mkdir -p $LATESTPATH/plot

for method in "${methods[@]}"; do
    if [ ! -e "$LATESTPATH/$method.dat" ]; then
        touch "$LATESTPATH/$method.dat"
    fi

    # Paste execution time results
    paste $SCRIPTSPATH/$TEMPLATE_DIR/$method-numbers $AVGPATH/avg-$method*  >"$LATESTPATH/$method.dat"

    for type in "${types[@]}"; do
        # Paste CPU and memory monitoring results
        printf "%s\t" "$type" >>"$LATESTPATH/$method-cpu.dat"
        paste "$LATESTPATH/$method/$type-cpu.dat" >>"$LATESTPATH/$method-cpu.dat"

        printf "%s\t" "$type" >>"$LATESTPATH/$method-mem.dat"
        paste "$LATESTPATH/$method/$type-mem.dat" >>"$LATESTPATH/$method-mem.dat"
    done

    gnuplot $SCRIPTSPATH/plot/plot-$method.p
    gnuplot $SCRIPTSPATH/plot/plot-$method-cpu.p
    gnuplot $SCRIPTSPATH/plot/plot-$method-mem.p
done

end_stamp=$(date +"%s")
end_pretty_date=$(date -d @$end_stamp)
printf "\nTest ended at: %s\nLoop times: %d\n" "$end_pretty_date" "$times" >>"$LATESTPATH/TEST-SPEC"
