`timescale 1ns / 1ps

// top level wrapper where we instantiate the CPU submodule project and drive it

module WrapperTop(
    input CLK100MHZ,
    input sw0,
    input sw1,
    input sw2,
    input sw3,
    output reg led0,
    output reg led1,
    output reg led2,
    output reg led3
);

// FSM
reg reset;

// register file
reg [31:0] dmem_register_file [0:9];
reg [31:0] imem_register_file [0:9];

wire [31:0] rv_imem_data_bus;
wire [31:0] rv_imem_addr_bus;
wire        rv_read_wrn_strobe;
wire [31:0] rv_dmem_data_in_bus;
wire [31:0] rv_dmem_data_out_bus;
wire [31:0] rv_dmem_addr_bus;

// instantiate the riscv CPU
Top toprv(
    .CK_REF(CLK100MHZ), .RST_N(reset), .INST_MEM_DATA_BUS(rv_imem_data_bus), .INST_MEM_ADDRESS_BUS(rv_imem_addr_bus), 
    .MEM_ACCESS_DATA_IN_BUS(rv_dmem_data_in_bus), .MEM_ACCESS_READ_WRN(rv_read_wrn_strobe), 
    .MEM_ACCESS_DATA_OUT_BUS(rv_dmem_data_out_bus), .MEM_ACCESS_ADDRESS_BUS(rv_dmem_addr_bus)
);

// address decoder to drive LEDs
always @(*) begin
    case (rv_dmem_addr_bus[1:0])
        2'b00 : begin
            led0 = rv_dmem_data_out_bus[0];
        end
        2'b01 : begin
            led1 = rv_dmem_data_out_bus[0];
        end
        2'b10 : begin
            led2 = rv_dmem_data_out_bus[0];
        end
        2'b11 : begin
            led3 = rv_dmem_data_out_bus[0];
        end
    endcase
end

// FSM to bring up and drive the CPU
always @(posedge CLK100MHZ) begin
    if(sw0) begin
        reset <= 1'b0;
    end
    else begin
        reset <= 1'b1;
    end
end

// Temporary static registers to act as imem
always @(*) begin
    imem_register_file[0] = 32'b000000000001_01010_000_01010_0010011;   // addi r10, r10, 1
    imem_register_file[1] = 32'b0000000_00000_01010_010_00001_0100011;  // sw r10, r0, 1
    imem_register_file[2] = 32'b00000000000000000000_00000_1101111;      // jal r0, 0
end

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