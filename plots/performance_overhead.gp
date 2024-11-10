# Set the output to an EPS file
set terminal postscript eps enhanced colour size 2.5, 1.4 font ",11"
set output 'performance_overhead.eps'


# Set the title and labels

set ylabel "Overhead (%)"
set x2tics out scale 0 format "" 0.5,1, 29
# Set grid and style
set grid x2 y
set bmargin 4.5
set style data histograms
set style histogram cluster gap 1
set style fill solid 0.7 border -1
set rmargin 1

# Rotate the x labels for better readability
set xtics  out nomirror rotate by 45 right 1, 4, 9 format "" font ",8"

# Set the range for y-axis
set yrange [0:*]

# Plot the data
plot 'performance_overhead.dat' using 2:xtic(1) title 'Parallaft' linecolor rgb "#44aaff", \
     '' using 3 title 'RAFT' linecolor rgb "red"
