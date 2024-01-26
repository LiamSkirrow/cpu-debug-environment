`timescale 1ns / 1ps

// top level wrapper where we instantiate the CPU submodule project and drive it

module WrapperTop(
    input CLK100MHZ,
    input btn0,
    input btn1,
    input btn2,
    input btn3,
    input sw0,
    input sw1,
    input sw2,
    input sw3,
    output led0_out,
    output led1_out,
    output led2_out,
    output led3_out
);

// FSM
reg reset_n;
wire halt;
reg halt_reg;
reg [4:0] count;
reg led0_reg;
reg led1_reg;
reg led2_reg;
reg led3_reg;

assign halt = halt_reg;

// register file
reg [31:0] dmem_register_file [0:9];
wire [31:0] imem_register_file [0:19];

wire [31:0] rv_imem_data_bus;
wire [31:0] rv_imem_addr_bus;
wire        rv_read_wrn_strobe;
wire [31:0] rv_dmem_data_in_bus;
wire [31:0] rv_dmem_data_out_bus;
wire [31:0] rv_dmem_addr_bus;

// instantiate the riscv CPU
Top toprv(
    .CK_REF(CLK100MHZ), .RST_N(reset_n), .HALT(halt), .INST_MEM_DATA_BUS(rv_imem_data_bus), .INST_MEM_ADDRESS_BUS(rv_imem_addr_bus), 
    .MEM_ACCESS_DATA_IN_BUS(rv_dmem_data_in_bus), .MEM_ACCESS_READ_WRN(rv_read_wrn_strobe), 
    .MEM_ACCESS_DATA_OUT_BUS(rv_dmem_data_out_bus), .MEM_ACCESS_ADDRESS_BUS(rv_dmem_addr_bus)
);

// address decoder to drive LEDs
assign led0_out = led0_reg;
assign led1_out = led1_reg;
assign led2_out = led2_reg;
assign led3_out = led3_reg;

always @(*) begin
    if(rv_dmem_addr_bus == 32'h0000_0001) begin
        if(rv_dmem_data_out_bus[1:0] == 2'b00) begin
            led0_reg = 1'b1;
            led1_reg = 1'b0;
            led2_reg = 1'b0;
            led3_reg = 1'b0;
        end
        else if(rv_dmem_data_out_bus[1:0] == 2'b01) begin
            led0_reg = 1'b0;
            led1_reg = 1'b1;
            led2_reg = 1'b0;
            led3_reg = 1'b0;
        end
        else if(rv_dmem_data_out_bus[1:0] == 2'b10) begin
            led0_reg = 1'b0;
            led1_reg = 1'b0;
            led2_reg = 1'b1;
            led3_reg = 1'b0;
        end
        else if(rv_dmem_data_out_bus[1:0] == 2'b11) begin
            led0_reg = 1'b0;
            led1_reg = 1'b0;
            led2_reg = 1'b0;
            led3_reg = 1'b1;
        end
        else begin
            led0_reg = 1'b0;
            led1_reg = 1'b0;
            led2_reg = 1'b0;
            led3_reg = 1'b0;
        end
    end
    else begin
        led0_reg = 1'b0;
        led1_reg = 1'b0;
        led2_reg = 1'b0;
        led3_reg = 1'b0;
    end
end

// FSM to bring up and drive the CPU
always @(posedge CLK100MHZ) begin
    if(sw0) begin
        reset_n <= 1'b0;
        count <= 5'd0;
    end
    else begin
        reset_n <= 1'b1;
        count <= count + 5'b0_0001;
    end
end

wire tick;
// active low tick, acts as a slow halt pulse
// assign tick = !(count == 32'd10);

// TODO: create a timer that overflows every .5 seconds and hold the CPU in halt until then

always @(posedge count[0]) begin
    if(count >= 16 && count <= 24) begin
        halt_reg <= 1'b0;
    end
    else begin
        halt_reg <= 1'b0;
    end
end

// Temporary static registers to act as imem
assign imem_register_file[0]  = 32'b000000000001_01010_000_01010_0010011;   // addi r10, r10, 1
assign imem_register_file[1]  = 32'b000000000001_01010_000_01011_0010011;   // addi r11, r10, 1
assign imem_register_file[2]  = 32'b000000000001_01011_000_01100_0010011;   // addi r12, r11, 1
assign imem_register_file[3]  = 32'b000000001010_01011_000_01101_0010011;   // addi r13, r11, 10
assign imem_register_file[4]  = 32'b000000001011_01011_000_01110_0010011;   // addi r14, r11, 11
assign imem_register_file[5]  = 32'b0000000_01010_00000_010_00001_0100011;  // sw   r10, r0, 1
assign imem_register_file[6]  = 32'b00000000000000000000_10100_1101111;     // jal  r20, 0
assign imem_register_file[7]  = 32'b000000000000_00000_000_00000_0000000;   // null effect (de facto NOP)
assign imem_register_file[8]  = 32'b000000000000_00000_000_00000_0000000;   // null effect (de facto NOP)
assign imem_register_file[9]  = 32'b000000000000_00000_000_00000_0000000;   // null effect (de facto NOP)
assign imem_register_file[10] = 32'b000000000000_00000_000_00000_0000000;   // null effect (de facto NOP)
assign imem_register_file[11] = 32'b000000000000_00000_000_00000_0000000;   // null effect (de facto NOP)
assign imem_register_file[12] = 32'b000000000000_00000_000_00000_0000000;   // null effect (de facto NOP)

assign rv_imem_data_bus = imem_register_file[rv_imem_addr_bus];


// Temporary register file to act as dmem
assign rv_dmem_data_in_bus = dmem_register_file[rv_dmem_addr_bus];

always @(posedge CLK100MHZ) begin
    if(sw0) begin
        // reset_n all registers to zero... 
        dmem_register_file[0]  <= 32'd0; 
        dmem_register_file[1]  <= 32'd0; 
        dmem_register_file[2]  <= 32'd0; 
        dmem_register_file[3]  <= 32'd0; 
        dmem_register_file[4]  <= 32'd0; 
        dmem_register_file[5]  <= 32'd0; 
        dmem_register_file[6]  <= 32'd0; 
        dmem_register_file[7]  <= 32'd0; 
        dmem_register_file[8]  <= 32'd0; 
        dmem_register_file[9]  <= 32'd0; 
    end
    else begin
        if(!rv_read_wrn_strobe) begin
            dmem_register_file[rv_dmem_addr_bus] <= rv_dmem_data_out_bus;
        end
    end
end

endmodule