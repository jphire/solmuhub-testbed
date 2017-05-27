set encoding utf8

set term pdf font "Helvetica,8" size 5in,3in

#set term pdfcairo enhanced color solid font "Helvetica,14" linewidth 1.5 dashlength 1.5 size 6in,4in
#set terminal postscript portrait enhanced mono dashed lw 1 "Helvetica" 14

set style histogram errorbars gap 1 title textcolor lt -1 lw 2.0
set style data histograms

set style fill solid 0.5
set bars front

set style line 1 lc rgb "#888888" lw 2.0 ps 1.0 pi 1
set style line 2 lc rgb "#555555" lw 2.0 ps 1.0 pi 1
set style line 3 lc rgb "#111111" lw 2.0 ps 1.0 pi 1

set xtics out nomirror
set ytics out nomirror

set offset 1.0,0,0,0

set xtics 0,1,4
set xrange [0:6]
set ytics 0,10,100
set yrange [1:50]

set xlabel "Number of hubs"
set ylabel "Memory usage"

set format y "%.0f%%"

set output '../../figures/final-4/mem-urlDataCompare.pdf'

#set title "Memory usage for one-hop execution"
set title ""

plot '../../results/urlMapped-noStringify/mem.out' u 10:11:12:xtic(1) ti 'Url mapped' ls 1, \
	'../../results/dataMapped-noStringify/mem.out' u 10:11:12:xtic(1) ti 'Data mapped' ls 2

unset output
reset
