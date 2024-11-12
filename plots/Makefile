PLOTS := $(wildcard *.gp)

all: $(PLOTS:%.gp=%.pdf)

%.pdf: %.gp %.dat
	gnuplot $<

clean:
	rm -rf *.pdf *.png

.PHONY: all clean
