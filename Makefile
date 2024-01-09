# main project Makefile, run compilation/simulation of entire design or individual submodules from here

SRC=src/
TARGET_SRC=riscv-cpu/src/
TB=tb/
CONF=config-files/
CC=verilator
ARGS=--trace-max-array 33 --trace-max-width 32


wrapper:
ifeq ($(SYNTAX), 1)
	@echo ">>> Syntax checking module: WrapperTop"
	@echo
	$(CC) -Wno-fatal --cc $(SRC)wrapper.v $(TARGET_SRC)top.v $(TARGET_SRC)alu.v $(TARGET_SRC)registerfile.v --lint-only $(ARGS)
else
ifeq ($(WAVES), 1)
	gtkwave wrapper.fst -a $(CONF)wrapper.gtkw
else
	@echo ">>> Verilating WrapperTop..."
	@echo
	$(CC) -Wno-fatal --trace-fst --cc $(SRC)wrapper.v $(TARGET_SRC)top.v $(TARGET_SRC)alu.v $(TARGET_SRC)registerfile.v --exe $(TB)$@_tb.cpp $(ARGS)
	make -C obj_dir -f Vwrapper.mk Vwrapper
	@echo ">>> Simulating WrapperTop..."
	@echo
	./obj_dir/Vwrapper
endif
endif
	@echo "DONE"

.PHONY: clean
clean:
	rm -rf obj_dir/ *.fst
