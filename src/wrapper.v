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
    output led0,
    output led1,
    output led2,
    output led3
);

// FSM
reg reset;
wire halt;
reg [31:0] count;

assign halt = btn0;

// register file
reg [31:0] dmem_register_file [0:9];
wire [31:0] imem_register_file [0:9];

wire [31:0] rv_imem_data_bus;
wire [31:0] rv_imem_addr_bus;
wire        rv_read_wrn_strobe;
wire [31:0] rv_dmem_data_in_bus;
wire [31:0] rv_dmem_data_out_bus;
wire [31:0] rv_dmem_addr_bus;

// instantiate the riscv CPU
Top toprv(
    .CK_REF(CLK100MHZ), .RST_N(reset), .HALT(tick), .INST_MEM_DATA_BUS(rv_imem_data_bus), .INST_MEM_ADDRESS_BUS(rv_imem_addr_bus), 
    .MEM_ACCESS_DATA_IN_BUS(rv_dmem_data_in_bus), .MEM_ACCESS_READ_WRN(rv_read_wrn_strobe), 
    .MEM_ACCESS_DATA_OUT_BUS(rv_dmem_data_out_bus), .MEM_ACCESS_ADDRESS_BUS(rv_dmem_addr_bus)
);

// address decoder to drive LEDs
assign led0 = (rv_dmem_data_out_bus[1:0] == 2'b00);
assign led1 = (rv_dmem_data_out_bus[1:0] == 2'b01);
assign led2 = (rv_dmem_data_out_bus[1:0] == 2'b10);
assign led3 = (rv_dmem_data_out_bus[1:0] == 2'b11);

// FSM to bring up and drive the CPU
always @(posedge CLK100MHZ) begin
    if(sw0) begin
        reset <= 1'b0;
        count <= 32'd0;
    end
    else begin
        reset <= 1'b1;
        count <= (count == 32'd10_000_000) ? 32'd0 : count + 1'b1;
    end
end

wire tick;
// active low tick, acts as a slow halt pulse
assign tick = !(count == 32'd50_000_000);

// TODO: create a timer that overflows every .5 seconds and hold the CPU in halt until then

// always @(posedge count) begin
//     if(count >= 16 && count <= 24) begin
//         halt <= 1'b1;
//     end
//     else begin
//         halt <= 1'b0;
//     end
// end

// Temporary static registers to act as imem
// always @(*) begin
assign imem_register_file[0] = 32'b000000000001_01010_000_01010_0010011;   // addi r10, r10, 1
assign imem_register_file[1] = 32'b0000000_01010_00000_010_00001_0100011;  // sw r10, r0, 1
assign imem_register_file[2] = 32'b00000000000000000000_00000_1101111;     // jal r0, 0
// end

assign rv_imem_data_bus = imem_register_file[rv_imem_addr_bus];


// Temporary register file to act as dmem
assign rv_dmem_data_in_bus = dmem_register_file[rv_dmem_addr_bus];

always @(posedge CLK100MHZ) begin
    if(sw0) begin
        // reset all registers to zero... 
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