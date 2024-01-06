# CPU debugger
The whole point of this project is to give a generic-as-possible wrapper that instantiates a CPU's top level module and simply drives the processor depending on some commands sent over UART.

Ultimately, the aim is to provide a simple interface to running a CPU on an FPGA, with the ability to be single-stepped through.

### Commands
Command | Description | 
--- | --- | 
ld [executable] | Load a binary file containing machine code to be loaded into memory, ready for execution  | 
peek [addr] | Read the value stored at memory location [addr]  | 
poke [addr, val] | Set the value at memory location [addr] with value [val]  | 
ss | single-step CPU instructions, one at a time  | 
run [addr] | run the program indefinitely, starting address [addr]  | 
halt | halt the execution of the processor  | 

### TODO
- at the top level include a decoder that maps the FPGA's onboard peripherals into memory. So the CPU can access the peripherals via a memory map. For example, assign a given byte in memory to the 8 LEDs onboard the ARTY A7 board so that the CPU can set/reset them arbitrarily.
