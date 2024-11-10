# Set the output to an EPS file
set terminal postscript eps enhanced color  size 2.5, 1.4 font ",11"
set output 'performance_overhead_breakdown.eps'

# Set the title and labels

set ylabel "Overhead (%)"

# Set grid and style
set grid ytics
set style data histogram
set style histogram rowstacked
set style fill solid 0.7 border -1

# Rotate the x labels for better readability
set xtics  out nomirror rotate by 45 right 1, 4, 9 format "" font ",8"

# Set the range for y-axis
set yrange [0:*]
set bmargin 4.5
set rmargin 1

set key at 24,68 invert

# Define a box width and spacing
set boxwidth 0.6 absolute  # Controls the width of the bars
set offset 0.3,0.3,0,0  # Adds horizontal spacing between the clusters

# Define a color palette for the categories
set style line 1 lc rgb "#1f77b4" lt 1 lw 2  # Blue
set style line 2 lc rgb "#ff7f0e" lt 1 lw 2  # Orange
set style line 3 lc rgb "#2ca02c" lt 1 lw 2  # Green
set style line 4 lc rgb "#d62728" lt 1 lw 2  # Red

# Plot the data
plot 'performance_overhead_breakdown.dat' using 2:xtic(1) title 'Fork and COW' ls 1, \
     '' using 3 title 'Resource contention' ls 2, \
     '' using 4 title 'Last-checker sync' ls 3, \
     '' using 5 title 'Runtime work' ls 4

set terminal pngcairo
set output 'performance_overhead_breakdown.png'
replot
