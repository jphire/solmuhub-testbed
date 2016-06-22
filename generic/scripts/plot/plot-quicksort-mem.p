set encoding utf8

set terminal svg
#set terminal latex

#set term pdfcairo enhanced color solid font "Helvetica,24" linewidth 1.5 dashlength 1.5 size 6in,4in
#set terminal postscript portrait enhanced mono dashed lw 1 "Helvetica" 14

set boxwidth 0.3
set style fill solid

set style line 1 lc rgb "#000064" lw 1.5 ps 1.0 pi 1
set style line 2 lc rgb "#2B00FF" lw 1.5 ps 1.0 pi 1
set style line 3 lc rgb "#C72BD6" lw 1.5 ps 1.0 pt 7 pi 1
set style line 4 lc rgb "#FF8C73" lw 1.5 ps 1.0 pi 1
set style line 5 lc rgb "#CCCCCC" lw 1.5 ps 1.0 pi 1

set nokey

#set ylabel "Memory usage %"

#set output '../../results/latest/plot/quicksort.tex'
#set output '~/Opiskelu/GitGradu/gradu/quicksort.svg'
set output '../../results/latest/plot/quicksort-mem.svg'

#set size 1.0, 1.0

#set xrange [0:3]
#set yrange [1:100]

set grid x y

set xtics nomirror
set ytics nomirror
#set ytics 10

set title "Memory usage %"

plot '../../results/latest/quicksort-mem.dat' using 2:xtic(1) with boxes t 'Memory usage' ls 3

unset output
reset
