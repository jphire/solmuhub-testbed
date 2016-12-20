set encoding utf8

set term pdf font "Helvetica,8" size 6in,5in

#set term pdfcairo enhanced color solid font "Helvetica,14" linewidth 1.5 dashlength 1.5 size 6in,4in
#set terminal postscript portrait enhanced mono dashed lw 1 "Helvetica" 14

set style data histogram
set style histogram rowstacked gap 0.8 title textcolor lt -1 offset character 0, -0.5, 0

set boxwidth 0.7 relative
set style fill solid 0.5

set style line 1 lc rgb "blue" lw 2.0 ps 0.4 pi 1
set style line 2 lc rgb "red" lw 2.0 ps 0.4 pi 1
set style line 3 lc rgb "green" lw 2.0 ps 0.4 pi 1
set style line 4 lc rgb "#555555" lw 2.0 ps 1.0 pi 1
set style line 5 lc rgb "#000000" lw 2.0 ps 0.4 pi 1

set tmargin 3
#set key opaque outside right top vertical
set key outside bottom horizontal Left reverse noenhanced autotitle columnhead nobox height 4

set xtics out nomirror
set ytics out nomirror

#set offset 1.0,0,0,0

#set xtics rotate by -30 #justify 'left'
#set xtics ("1 node" 0 -1, "2 node" 0 -1, "3 node" 0 -1, "4" 0 -1)

#set xrange [0:5]
set ytics 0,10,100

set yrange [0:100]

#set xlabel ""

set format y "%.0f%%"

set output '../../figures/profiles-dataMapped.pdf'

set title "Solmuhub profile using data mapper"


plot newhistogram "2-Nodes" lt 1, '../../results/dataMapped/2-nodes-1-depth-profile-stacked' u (100.*$2/$9):xtic(1) ti column(2), for [i=3:9] '' using (100.*(column(i)-column(i-1))/$9) ti column(i), \
	 newhistogram "4-Nodes" lt 1, '../../results/dataMapped/4-nodes-1-depth-profile-stacked' u (100.*$2/$9):xtic(1) notitle, for [i=3:9] '' using (100.*(column(i)-column(i-1))/$9) notitle, \
	 newhistogram "8-Nodes" lt 1, '../../results/dataMapped/8-nodes-1-depth-profile-stacked' u (100.*$2/$9):xtic(1) notitle, for [i=3:9] '' using (100.*(column(i)-column(i-1))/$9) notitle, \
     newhistogram "Local" lt 6, '../../results/dataMapped/0-nodes-1-depth-profile-stacked' u (100.*$2/$5):xtic(1) ti column(2), for [i=3:5] '' using (100.*column(i)/$5) title column(i), \


unset output
reset