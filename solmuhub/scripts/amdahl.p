set encoding utf8

set term pdf font "Helvetica,8" size 6in,5in lw 2

#set term pdfcairo enhanced color solid font "Helvetica,14" linewidth 1.5 dashlength 1.5 size 6in,4in
#set terminal postscript portrait enhanced mono dashed lw 1 "Helvetica" 14

set style data lines

set style line 1 lc rgb "blue" lw 2.0 ps 0.4 pi 1
set style line 2 lc rgb "red" lw 2.0 ps 0.4 pi 1
set style line 3 lc rgb "green" lw 2.0 ps 0.4 pi 1
set style line 4 lc rgb "#555555" lw 2.0 ps 1.0 pi 1
set style line 5 lc rgb "#000000" lw 2.0 ps 0.4 pi 1

#set key opaque outside right top vertical
set key title "Parallel portion"

set xtics out nomirror
set ytics out nomirror

#set offset 1.0,0,0,0

#set xtics rotate by -30 #justify 'left'
#set xtics ("1 node" 0 -1, "2 node" 0 -1, "3 node" 0 -1, "4" 0 -1)

#set xrange [0:5]
set ytics 0,2,20

set yrange [0:20]

set ylabel "Speedup"
set xlabel "Processors"

set format y "%.0f"

set output '../../../src/Figures/amdahl.pdf'

set title "Solmuhub compared Amdahl's law"

plot for [col=2:5] 'amdahl-numbers' u col:xtic(1) ti column(col)

unset output
reset
