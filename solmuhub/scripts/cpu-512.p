set encoding utf8

set term pdf
#set term pdfcairo enhanced color solid font "Helvetica,14" linewidth 1.5 dashlength 1.5 size 6in,4in
#set terminal postscript portrait enhanced mono dashed lw 1 "Helvetica" 14

set style data boxerrorbars

set style fill solid 0.3
set bars front

set style line 1 lc rgb "#000000" lw 1.5 ps 1.0 pi 1

set nokey

set xtics out nomirror
set ytics out nomirror

set offset 1.0,0,0,0

set xtics 0,1,4
set xrange [0:5]
set ytics 0,20,100
set yrange [0:100]

set xlabel "Number of nodes"

set format y "%.0f%%"

set output '../../../src/Figures/cpu-512.pdf'

# set size 1.0, 1.0

set title "CPU usage"


plot "../results/latest/cpu-512.out" using 1:2:3:4:5 ls 1
