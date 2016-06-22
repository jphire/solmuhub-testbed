set encoding utf8

set terminal svg

#set term pdfcairo enhanced color solid font "Helvetica,24" linewidth 1.5 dashlength 1.5 size 6in,4in
#set terminal postscript portrait enhanced mono dashed lw 1 "Helvetica" 14

#set style data yerrorlines
set style func linespoints
set style line 1 lc rgb "#000064" lw 1.5 ps 1.0 pi 1
set style line 2 lc rgb "#2B00FF" lw 1.5 ps 1.0 pi 1
set style line 3 lc rgb "#C72BD6" lw 1.5 ps 1.0 pt 7 pi 1
set style line 4 lc rgb "#FF8C73" lw 1.5 ps 1.0 pi 1
set style line 5 lc rgb "#CCCCCC" lw 1.5 ps 1.0 pi 1

set key top right

set ylabel "Performance factors"
set y2label "IoT-hub execution time (ms)"
set xlabel "Fibonacci number"

set output 'fibonacci.svg'

set size 1.0, 1.0

set xrange [23:32]
set x2range [23:32]
set yrange [0:250]
set y2range [0:5000]

set grid x y2

set xtics 2
set xtics nomirror
set y2tics 500


plot '../../results/latest/fibonacci.dat' u 1:(1) with linespoints t 'Iothub-node' ls 2, \
'' u 1:($2/$4) with linespoints t 'Duktape-node' ls 4, \
'' u 1:($2/$3) with linespoints t 'Plain NodeJS' ls 3, \
'../../results/latest/mean-fibonacci-iothub.out' using 1:2 axes x1y2 with lines t '' ls 5

unset output
reset
