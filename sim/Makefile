VERILOG=../src/

.PHONY: clean all

all: counter

counter: $(VERILOG)counter.v counter_tb.v
	iverilog counter_tb.v -l$(VERILOG)counter.v -o counter
	vvp counter

clean:
	rm ./counter
	rm ./counter.vcd
