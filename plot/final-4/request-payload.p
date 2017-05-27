set encoding utf8

set term pdf font "Helvetica,8" size 5in,3in

#set term pdfcairo enhanced color solid font "Helvetica,14" linewidth 1.5 dashlength 1.5 size 6in,4in
#set terminal postscript portrait enhanced mono dashed lw 1 "Helvetica" 14

set style histogram gap 1 title textcolor lt -1
set style data histograms

set style fill solid 0.5
set bars front

set style line 1 lc rgb "#888888" lw 2.0 ps 1.0 pi 1
set style line 2 lc rgb "#555555" lw 2.0 ps 1.0 pi 1
set style line 3 lc rgb "#111111" lw 2.0 ps 1.0 pi 1

#set nokey

#set key under nobox

set xtics out nomirror
set ytics out nomirror

set offset 1.0,0,0,0

#set xtics 0,1,4
set xrange [0:5]
#set ytics 0,5,10
#set yrange [0:1600]

set xlabel "Number of hubs"

set ylabel "Response size (kB)"

set format y "%.0f"

#set ytics format "%2.1f"

set logscale y 2

set output '../../figures/final-4/request-payload-urlDataCompare.pdf'

#set title "Request payloads for one-hop execution"
set title ""

n = 1
plot '../../results/dataMapped-noStringify/request-payload.out' u ($2/n):xtic(1) ti 'Data mapped 256x256' ls 1, \
	'' u ($3/n):xtic(1) ti 'Data mapped 512x512' ls 2, \
	'' u ($4/n):xtic(1) ti 'Data mapped 1024x1024' ls 3, \
	'' u ($5/n):xtic(1) ti 'Url mapped' ls 4
unset output
reset
