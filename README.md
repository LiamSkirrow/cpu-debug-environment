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
[Stretch Features]
- it'd be cool to write assembly commands into the terminal session and have them dynamically assemble into machine code as I go. So writing out one instruction in riscv asm, hitting enter and seeing that instruction run on the FPGA instantly, receiving the CPU state regfile/memory debug hexdump immediately, and then being able to write the next instruction etc...
  - this would involve some text processing in the client program, which reads in the asm, parses it and figures out whether it's a valid instruction or not, runs it on the CPU, and then halts it after this one instruction has completed.
  - this is kinda hard for pipelined processors, since they need to know the instructions ahead of the current one to fill up the pipeline, but doing it this way means that the CPU only sees the current instruction with no visibility of the road ahead. Might have to shoehorn in a 'single-cycle' mode, where my riscv cpu operates in a non-pipelined mode in order to support this. Alternatively, just write a new non-pipelined CPU that can be used with this feature...
