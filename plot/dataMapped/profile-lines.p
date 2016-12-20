set encoding utf8

set term pdf font "Helvetica,8" size 6in,5in

#set term pdfcairo enhanced color solid font "Helvetica,14" linewidth 1.5 dashlength 1.5 size 6in,4in
#set terminal postscript portrait enhanced mono dashed lw 1 "Helvetica" 14

#set style histogram errorbars gap 1 title textcolor lt -1 lw 2.0
#set style data histograms

set style data lines
#set style fill solid 0.5
#set bars front

set style line 1 lc rgb "blue" lw 2.0 ps 0.4 pi 1
set style line 2 lc rgb "red" lw 2.0 ps 0.4 pi 1
set style line 3 lc rgb "green" lw 2.0 ps 0.4 pi 1
set style line 4 lc rgb "#555555" lw 2.0 ps 1.0 pi 1
set style line 5 lc rgb "#000000" lw 2.0 ps 0.4 pi 1

set key opaque outside right top vertical

set xtics out nomirror
set ytics out nomirror

#set offset 1.0,0,0,0

set xtics rotate by -30 #justify 'left'
#set xtics 0,1,4
#set xrange [0:5]
#set ytics 0,5,10
#set yrange [0:10]

#set xlabel ""

#set format y "%.0fms"

set output '../../figures/profile-lines.pdf'

# set size 1.0, 1.0

set title "Profile"


#plot '../results/latest/0-profile' u 2:3:4:xtic(1) ti '256x256 size JPG' ls 1, \
#	 '../results/latest/0-profile' u 6:7:8:xtic(1) ti '512x512 size JPG' ls 2, \

plot '../../results/dataMapped/2-profile-lines' u 1:3:xtic(2) ti '1 node' ls 1, \
	 '' u 1:3:4:5 w yerrorbars ls 5 notitle, \
	 '../results/latest/4-profile-lines' u 1:3:xtic(2) ti '2 nodes' ls 2, \
	 '' u 1:3:4:5 w yerrorbars ls 5 notitle, \
	 '../results/latest/8-profile' u 1:3:xtic(2) ti '3 nodes' ls 3, \
	 '' u 1:3:4:5 w yerrorbars ls 5 notitle, \
	 '../results/latest/16-profile' u 1:3:xtic(2) ti '4 nodes' ls 4, \
	 '' u 1:3:4:5 w yerrorbars ls 5 notitle, \
	 '../results/latest/32-profile' u 1:6:xtic(2) ti '1 node' ls 1, \
	 '' u 1:6:7:8 w yerrorbars ls 5 notitle, \
	#'../results/latest/2-profile' u 1:6:xtic(2) ti '2 nodes' ls 2, \
	#'' u 1:6:7:8 w yerrorbars ls 5 notitle, \
	#'../results/latest/3-profile' u 1:6:xtic(2) ti '3 nodes' ls 3, \
	#'' u 1:6:7:8 w yerrorbars ls 5 notitle, \
	#'../results/latest/4-profile' u 1:6:xtic(2) ti '4 nodes' ls 4, \
	#'' u 1:6:7:8 w yerrorbars ls 5 notitle

#plot '../results/latest/1-profile' u 2:3:4:xtic(1) w errorbars ti '512x512 size JPG' ls 1, \
	 #'../results/latest/2-profile' u 4:5:6:xtic(1) ti '512x512 size JPG' ls 2, \
	 #'../results/latest/3-profile' u 2:3:4:xtic(1) ti '512x512 size JPG' ls 3, \
	 #'../results/latest/4-profile' u 2:3:4:xtic(1) ti '512x512 size JPG' ls 4

unset output
reset
