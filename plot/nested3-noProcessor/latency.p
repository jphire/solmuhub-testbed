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

#set nokey

set xtics out nomirror
set ytics out nomirror

set offset 1.0,0,0,0

set xtics 0,1,4
set xrange [0:4]
#set ytics 0,5,10
set yrange [0:80]

set xlabel "Number of nodes"

set ylabel "Latency (s)"

set format y "%.0fs"

set ytics format "%2.0f"

set output '../../figures/nested3-noProcessor/latency-nested3-noProcessor.pdf'

# set size 1.0, 1.0

set title "Latency using URL mapper and depth 3"

n = 1000
plot '../../results/nested3-noProcessor/latency.out' u ($2/n):($3/n):($4/n):xtic(1) ti '256x256 JPG' ls 1, \
	'' u ($6/n):($7/n):($8/n):xtic(1) ti '512x512 JPG' ls 2, \
	'' u ($10/n):($11/n):($12/n):xtic(1) ti '1024x1024 JPG' ls 3

unset output
reset
