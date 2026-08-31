module top #(
    parameter DIVISOR = 50000000,
    parameter FILE_NAME = "mem_init.mif",
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
    input [1:0] kbd,
    input [2:0] btn,
    input [8:0] sw,
    output [8:0] mnt,
    output [9:0] led,
    output [27:0] hex
);

    wire clk_1;
    clk_div #(.DIVISOR(DIVISOR)) clk_div_inst (clk, rst_n, clk_1);


    wire we;
    wire [ADDR_WIDTH - 1:0] addr;
    wire [DATA_WIDTH - 1:0] data, mem_out;

    memory #(
        .FILE_NAME(FILE_NAME),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) MEM (
        .clk(clk_1),
        .we(we),
        .addr(addr),
        .data(data),
        .out(mem_out)
    );

    wire [DATA_WIDTH - 1:0] cpu_out;
    wire [ADDR_WIDTH - 1:0] pc;
    wire [ADDR_WIDTH - 1:0] sp;
    wire [DATA_WIDTH - 1:0] cpu_in = {{(DATA_WIDTH-4){1'b0}}, sw[3:0]};
    wire cpu_status;
    cpu #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) cpu_inst (
        .clk(clk_1),
        .rst_n(rst_n),
        .mem(mem_out),
        .in(cpu_in),
        .status(cpu_status),
        .we(we),
        .addr(addr),
        .data(data),
        .out(cpu_out),
        .pc(pc),
        .sp(sp)
    );

    assign led[4:0] = cpu_out[4:0];
    assign led[5] = cpu_status;
    assign led[9:8] = 2'b00;

    wire [3:0] bcd1_ones, bcd1_tens, bcd2_ones, bcd2_tens;
    bcd bcd_inst1(pc, bcd1_ones, bcd1_tens);
    bcd bcd_inst2(sp, bcd2_ones, bcd2_tens);

    ssd ssd_inst1(bcd1_ones, hex[6:0]);
    ssd ssd_inst2(bcd1_tens, hex[13:7]);
    ssd ssd_inst3(bcd2_ones, hex[20:14]);
    ssd ssd_inst4(bcd2_tens, hex[27:21]);

endmodule
