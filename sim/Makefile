VERILOG=../src/

.PHONY: clean all

all: divider spi_slave spi_test_top

divider: $(VERILOG)divider.v \
         $(VERILOG)timer.v \
	 $(VERILOG)register.v \
	 divider_tb.v
	iverilog divider_tb.v \
	-l$(VERILOG)divider.v \
	-l$(VERILOG)timer.v \
	-l$(VERILOG)register.v \
	-o divider
	vvp divider

spi_slave: $(VERILOG)spi_slave.v spi_slave_tb.v
	iverilog spi_slave_tb.v -l$(VERILOG)spi_slave.v -o spi_slave
	vvp spi_slave

spi_test_top: $(VERILOG)spi_test_top.v \
              $(VERILOG)spi_slave.v \
	      $(VERILOG)spi_fsm.v \
	      $(VERILOG)register.v \
	      spi_test_top_tb.v
	iverilog spi_test_top_tb.v -l$(VERILOG)spi_test_top.v \
		-l$(VERILOG)spi_slave.v \
		-l$(VERILOG)spi_fsm.v \
		-l$(VERILOG)register.v \
		-DSIM \
		-o spi_test_top
	vvp spi_test_top

clean:
	rm -f ./divider
	rm -f ./divider.vcd
	rm -f ./spi_slave
	rm -f ./spi_slave.vcd
	rm -f ./spi_test_top
	rm -f ./spi_test_top.vcd
