set encoding utf8

set term pdf font "Helvetica,8" size 5in,3in

#set term pdfcairo enhanced color solid font "Helvetica,14" linewidth 1.5 dashlength 1.5 size 6in,4in
#set terminal postscript portrait enhanced mono dashed lw 1 "Helvetica" 14

set boxwidth 0.8 absolute
set style fill solid 0.9 border lt -1

set style data histogram
set style histogram clustered gap 1 title textcolor lt -1
set style fill solid 0.5

# Greyscale colors
set linetype 1 lc rgb '#000000' lw 1.5 ps 1.0 pi 1
set linetype 2 lc rgb '#555555'
set linetype 3 lc rgb '#999999'
set linetype 4 lc rgb '#eeeeee'

set output '../../../../src/Figures/mems.pdf'

set yrange [0:10]

set grid x y

set format y "%.0f%%"

set key opaque outside right top vertical

set xtics nomirror
set ytics nomirror
set ytics 5

set title "Mean memory usage"

plot '../../results/latest/new-plots/mems.dat' u 2:xtic(1) ti 'Quicksort' ls 1, \
'' using 3 ti 'Newton' ls 3,  \
'' using 4 ti 'Fibonacci' ls 4

unset output
reset
