set encoding utf8

set terminal pdf
#set terminal postscript eps
#set output '| epstopdf --filter --outfile=plot.pdf'


#set term pdfcairo enhanced color solid font "Helvetica,24" linewidth 1.5 dashlength 1.5 size 6in,4in
#set terminal postscript portrait enhanced mono dashed lw 1 "Helvetica" 14

set style data boxerrorbars
#set style fill solid 

set style line 1 lc rgb "#000064" lw 1.5 ps 1.0 pi 1
set style line 2 lc rgb "#2B00FF" lw 1.5 ps 1.0 pi 1
set style line 3 lc rgb "#C72BD6" lw 1.5 ps 1.0 pt 7 pi 1
# set style line 4 lc rgb "#FF8C73" lw 1.5 ps 1.0 pi 1
# set style line 5 lc rgb "#CCCCCC" lw 1.5 ps 1.0 pi 1

set nokey

set xtics out nomirror
set ytics out nomirror

set offset 1.0,0,0,0

set xtics 0,1,20
set xrange [0:21]
set ytics 0,10,100
set yrange [0:100]

#set ylabel "CPU usage %"
# set y2label "Kahvihub execution time (ms)"
set xlabel "Number of nodes"

set format y "%.0f%%"

set output '../results/latest/mem-512.pdf'

# set size 1.0, 1.0

set title "Memory usage"


plot "../results/latest/mem-512.out" using 1:2:3:4:5 lc 3
