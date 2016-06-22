#!/bin/bash


function loopX {
	local total1=0 total2=0 total3=0 total4=0 total5=0 total6=0 total7=0 total8=0 total9=0 total10=0
    local total11=0 total12=0 total13=0 total14=0 total15=0
    local reqtime=0
    local i="0"
    local c=0
    local TYPE=$1
    local HOST=$2
    local PORT=$3
    local ADDR=$4
    local PID=$8
    local LOOPCOUNT=$5
    local SCRIPT="../js/$6"
    local METHOD=$7
    # local ACCESSTOKEN=$9
    # local stamp=$(date +"%s")
    local filename=$METHOD-$TYPE.out
    local meanfilename=avg-$filename
	
	echo "Starting iot hub tests with hub: $HOST"
	echo "Clearing output file $filename..
	"
    # Clear the output file
    echo -n > $filename
    echo "HOST TYPE: $TYPE"
    echo "METHOD: $METHOD"
    echo "SCRIPT: $SCRIPT"
    echo "LOOPCOUNT: $LOOPCOUNT"
    echo "FULL OUTPUT FILE: $filename"
    echo "MEAN OUTPUT FILE: $AVGPATH/$meanfilename"

    # IoT Hub tests
    # Get curl output format from curl-log.txt. Consult that file to find out what is the meaning
    # of each column. The output format should be machine readable, for e.g. gnuplot.
    # CURL_HEADER=""
    # CURL_HEADER="-H 'Content-Type:application/json' "
    # CURL_HEADER="$CURL_HEADER -H 'Accept: application/json' \n"

    # if [ "ACCESS_TOKEN" ]; then
    #     CURL_HEADER="$CURL_HEADER -H 'Authorization: $ACCESSTOKEN' \n"
    # fi

    # measure memory and cpu usage. The files are created first, because there may be a delay
    # before pidstat creates the files, and we need the files to exist immediately for monitoring
    # later
    touch "$STATSPATH/$METHOD-$TYPE-mem.dat"
    touch "$STATSPATH/$METHOD-$TYPE-cpu.dat"
    pidstat -r $MEMFRQ $MEMSAMPLE -p $PID >"$STATSPATH/$METHOD-$TYPE-mem.dat" &
    pidstat $CPUFRQ $CPUSAMPLE -p $PID >"$STATSPATH/$METHOD-$TYPE-cpu.dat" &

    if [ ! -e "$ALLPATH" ] ; then
        mkdir -p "$ALLPATH" 
    fi

    while [ $i -lt $LOOPCOUNT ]; do
        curl -XPOST "$CURL_HEADER" \
            -H 'Content-Type:text/plain' \
            -H 'Accept:text/plain' \
            -H 'Authorization: $ACCESSTOKEN' \
            --data-binary @"$SCRIPT" \
            "$HOST:$PORT$ADDR" -s >>$ALLPATH/$filename
            #-w "@../format/time-total-format.txt" \
        printf "\n" >>$ALLPATH/$filename
        i=$[$i+1]
        echo "
Request $i / $LOOPCOUNT"

    done

    # Print results to stdout in a convenient way, only mean is showed. To show total result listing, see
    # output files for each server
    echo "Results for $HOST:$PORT$ADDR"

    echo "________________________________________________________________________________________________________________________________"
    # echo "| Mean times                                                                                                     |"
    # echo "| ------------------------------------------------------------------------------------------------------------- |"

    # Check that stat files are in place
    while ! grep "Average*" $STATSPATH/$METHOD-$TYPE-mem.dat; do 
        echo "Waiting for $STATSPATH/$METHOD-$TYPE-mem.dat to appear.."
        sleep 1; 
    done

    while ! grep "Average*" $STATSPATH/$METHOD-$TYPE-cpu.dat; do
        echo "Waiting for $STATSPATH/$METHOD-$TYPE-cpu.dat to appear.."
        sleep 1; 
    done


    if [ ! -e "$LATESTPATH/$METHOD" ] ; then
        mkdir -p "$LATESTPATH/$METHOD" 
    fi

    # Note! the pidstat processes need to finish before the Average-row exists in the files
    cat "$STATSPATH/$METHOD-$TYPE-mem.dat" | grep Average* | sed 's/,/./g' |awk '{ printf "%f", $8 }' >"$LATESTPATH/$METHOD/$TYPE-mem.dat"
    cat "$STATSPATH/$METHOD-$TYPE-cpu.dat" | grep Average* | sed 's/,/./g' |awk '{ printf "%f", $7 }' >"$LATESTPATH/$METHOD/$TYPE-cpu.dat"

	# Get mean from each column and print it with awk.
    if [ ! -e "$AVGPATH/$meanfilename" ] ; then
        touch "$AVGPATH/$meanfilename"
    fi

    echo -n > "$AVGPATH/$meanfilename"

    # awk '{ total1+=$1; total2+=$2; total3+=$3; total4+=$4; total5+=$5; total6+=$6; total7+=$7; total8+=$8; total9+=$9; total10+=$10; reqtime+=$11; c++ } \
    #     END { printf "%f\t%f\t%i\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n", total1/c,reqtime/c*1000,c,total2/c,total3/c,total4/c,total5/c,total6/c,total7/c,total8/c,total9/c,total10/c}' "$filename" >>"$meanfilename"

    awk '{ total1+=$1; total2+=$2; total3+=$3; total4+=$4; total5+=$5; total6+=$6; total7+=$7; total8+=$8; total9+=$9; total10+=$10; c++ } \
        END { printf "%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n", total1/c,total2/c,total3/c,total4/c,total5/c,total6/c,total7/c,total8/c,total9/c,total10/c}' "$ALLPATH/$filename" >>"$AVGPATH/$meanfilename"

	echo "--------------------------------------------------------------------------------------------------------------------------------"
}


while [[ $# > 0 ]]; do
key="$1"

case $key in
    -h|--host) # which iothub instance to send to
    HOST="$2"
    shift
    ;;
    -n|--loopcount) # amount of requests to be send
    LOOPCOUNT="$2"
    shift
    ;;
    --host)
    HOST="$2"
    shift
    ;;
    --feed)
    FEED="$2"
    shift
    ;;
    --type)
    TYPE="$2"
    shift
    ;;
    --pid) # kahvihub server port
    PID="$2"
    shift
    ;;
    --access-token) # kahvihub server port
    ACCESS_TOKEN="$2"
    shift
    ;;
    --port) # kahvihub server port
    PORT="$2"
    shift
    ;;
    --script)
    SCRIPT="$2"
    shift
    ;;
    --method)
    METHOD="$2"
    shift
    ;;
    --default)
    DEFAULT=YES
    ;;
    *)
        # unknown option
    ;;
esac
shift # past argument or value
done

echo "$TYPE $HOST $PORT $FEED $LOOPCOUNT $SCRIPT $METHOD $PID $ACCESSTOKEN "
loopX $TYPE $HOST $PORT $FEED $LOOPCOUNT $SCRIPT $METHOD $PID


if [ ! -e "$LATESTPATH/$METHOD/$TYPE.dat" ] ; then
    touch "$LATESTPATH/$METHOD/$TYPE.dat"
fi
echo -n >"$LATESTPATH/$METHOD/$TYPE.dat"


paste "../templates/$METHOD-numbers" "$AVGPATH/avg-$METHOD-$TYPE.out" "$LATESTPATH/$METHOD/$TYPE-cpu.dat" \
"$LATESTPATH/$METHOD/$TYPE-mem.dat" >>"$LATESTPATH/$METHOD/$TYPE.dat"


