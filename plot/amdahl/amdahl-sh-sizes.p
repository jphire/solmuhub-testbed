set encoding utf8

set term pdf font "Helvetica,8" size 6in,5in lw 2

#set term pdfcairo enhanced color solid font "Helvetica,14" linewidth 1.5 dashlength 1.5 size 6in,4in
#set terminal postscript portrait enhanced mono dashed lw 1 "Helvetica" 14

set style data lines

set for [i=1:5] linetype i dt i

set style line 1 lc rgb "black" lw 2.0 ps 0.4 pi 1
set style line 2 lc rgb "black" lw 2.0 ps 0.4 pi 1
set style line 3 lc rgb "orange" lw 2.0 ps 0.4 pi 1
set style line 4 lc rgb "blue" lw 2.0 ps 1.0 pi 1
set style line 5 lc rgb "green" lw 2.0 ps 0.4 pi 1

#set key opaque outside right top vertical
#set key title "Parallel portion"

set xtics out nomirror
set ytics out nomirror

#set offset 1.0,0,0,0

#set xtics rotate by -30 #justify 'left'
#set xtics ("1 node" 0 -1, "2 node" 0 -1, "3 node" 0 -1, "4" 0 -1)

#set xrange [0:5]
set ytics 0,2,20

set yrange [0:10]

set ylabel "Speedup factor"
set xlabel "Amount of hubs"

set format y "%.0f"

set output '../../figures/amdahl-solmuhub-sizes.pdf'

set title "Solmuhub and Amdahl's law"

plot '../../data/amdahl-sh-sizes' u 3:xtic(1) ti 'Solmuhub-512' lt 1 lc 3 lw 2, \
'' u 4:xtic(1) ti 'Solmuhub-256' lt 3 lc 3 lw 2, \
'' u 2:xtic(1) ti 'Solmuhub-1024' lt 5 lc 3 lw 2, \
'' u 6:xtic(1) ti '70% distributed' ls 3, \
'' u 7:xtic(1) ti '80% distributed' ls 4, \
'' u 8:xtic(1) ti '90% distributed' ls 5, \

#'' u 6:xtic(1) ti '95%' ls 1, \

#plot for [col=2:5] '../../data/amdahl-solmuhub' u col:xtic(1) ti column(col)

unset output
reset
