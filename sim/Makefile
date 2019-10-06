VERILOG=../src/

.PHONY: clean all

all: counter spi_slave

counter: $(VERILOG)counter.v counter_tb.v
	iverilog counter_tb.v -l$(VERILOG)counter.v -o counter
	vvp counter

spi_slave: $(VERILOG)spi_slave.v spi_slave_tb.v
	iverilog spi_slave_tb.v -l$(VERILOG)spi_slave.v -o spi_slave
	vvp spi_slave

clean:
	rm -f ./counter
	rm -f ./counter.vcd
	rm -f ./spi_slave
	rm -f ./spi_slave.vcd
