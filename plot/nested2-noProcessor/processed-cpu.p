set encoding utf8

set term pdf font "Helvetica,8" size 5in,3in

#set term pdfcairo enhanced color solid font "Helvetica,14" linewidth 1.5 dashlength 1.5 size 10in,6in
#set terminal postscript portrait enhanced mono dashed lw 1 "Helvetica" 14

set style histogram gap 1 title textcolor lt -1
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
set xrange [0:5]
set ytics 0,20,100
set yrange [0:100]

set xlabel "Number of nodes"

set ylabel ""

set format y "%.0f%%"

set output '../../figures/nested2-noProcessor/processed-cpu-nested2-noProcessor.pdf'
#set output '~/Opiskelu/gradu/Figures/urlMapped-noStringify/cpu-urlMapped.pdf'

# set size 1.0, 1.0

set title "CPU usage using URL mapper and depth 1"

plot '../../results/nested2-noProcessor/processed-cpu.out' u 2:xtic(1) ti '256x256 JPG' ls 1, \
	 '' u 3:xtic(1) ti '512x512 JPG' ls 2, \
	 '' u 4:xtic(1) ti '1024x1024 JPG' ls 3

unset output
reset
