
module cpu #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
    input [DATA_WIDTH-1:0] mem,
    input [DATA_WIDTH-1:0] in,
    output we,
    output [ADDR_WIDTH-1:0] addr,
    output [DATA_WIDTH-1:0] data,
    output [DATA_WIDTH-1:0] out,
    output [ADDR_WIDTH-1:0] pc,
    output [ADDR_WIDTH-1:0] sp
);
    // PC
    reg pc_cl, pc_ld, pc_inc, pc_dec, pc_sr, pc_ir, pc_sl, pc_il;
    reg [ADDR_WIDTH-1:0] pc_in;
    register #(ADDR_WIDTH) pc_inst (clk, rst_n, pc_cl, pc_ld, pc_in, pc_inc, pc_dec, pc_sr, pc_ir, pc_sl, pc_il, pc);

    // SP
    reg sp_cl, sp_ld, sp_inc, sp_dec, sp_sr, sp_ir, sp_sl, sp_il;
    reg [ADDR_WIDTH-1:0] sp_in;
    register #(ADDR_WIDTH) sp_inst (clk, rst_n, sp_cl, sp_ld, sp_in, sp_inc, sp_dec, sp_sr, sp_ir, sp_sl, sp_il, sp);

    // IR
    reg ir_cl, ir_ld, ir_inc, ir_dec, ir_sr, ir_ir, ir_sl, ir_il;
    reg [DATA_WIDTH*2-1:0] ir_in;
    wire [DATA_WIDTH*2-1:0] ir_out;
    register #(32) ir_inst (clk, rst_n, ir_cl, ir_ld, ir_in, ir_inc, ir_dec, ir_sr, ir_ir, ir_sl, ir_il, ir_out);
    wire [3:0] opcode = ir_out[15:12];
    wire operandX_indirect = ir_out[11];
    wire [2:0] operandX_addr = ir_out[10:8];
    wire operandY_indirect = ir_out[7];
    wire [2:0] operandY_addr = ir_out[6:4];
    wire operandZ_indirect = ir_out[3];
    wire [2:0] operandZ_addr = ir_out[2:0];
    wire [DATA_WIDTH-1:0] constant = ir_out[DATA_WIDTH*2-1:DATA_WIDTH];
    localparam MOV=4'h00, ADD=4'h01, SUB=4'h02, MUL=4'h03, DIV=4'h04, IN=4'h07, OUT=4'h08;

    // MAR
    reg mar_cl, mar_ld, mar_inc, mar_dec, mar_sr, mar_ir, mar_sl, mar_il;
    reg [ADDR_WIDTH-1:0] mar_in;
    register #(ADDR_WIDTH) mar_inst (clk, rst_n, mar_cl, mar_ld, mar_in, mar_inc, mar_dec, mar_sr, mar_ir, mar_sl, mar_il, addr);

    // MDR
    reg mdr_cl, mdr_ld, mdr_inc, mdr_dec, mdr_sr, mdr_ir, mdr_sl, mdr_il;
    reg [DATA_WIDTH-1:0] mdr_in;
    register #(DATA_WIDTH) mdr_inst (clk, rst_n, mdr_cl, mdr_ld, mdr_in, mdr_inc, mdr_dec, mdr_sr, mdr_ir, mdr_sl, mdr_il, data);

    // ACC
    reg a_cl, a_ld, a_inc, a_dec, a_sr, a_ir, a_sl, a_il;
    reg [DATA_WIDTH-1:0] a_in;
    wire [DATA_WIDTH-1:0] a_out;
    register #(DATA_WIDTH) a_inst (clk, rst_n, a_cl, a_ld, a_in, a_inc, a_dec, a_sr, a_ir, a_sl, a_il, a_out);

    // ALU
    reg [2:0] oc;
    wire [DATA_WIDTH-1:0] alu_out;
    alu #(DATA_WIDTH) alu_inst (oc, a_out, data, alu_out);





    reg [7:0] state_reg, state_next;
    reg we_reg;
    reg [DATA_WIDTH-1:0] out_reg, out_next;
    
    assign we = we_reg;
    assign out = out_reg;
    

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            state_reg <= setup;
            out_reg <= {DATA_WIDTH{1'b1}};
        end else begin
            state_reg <= state_next;
            out_reg <= out_next;
        end
    end



    localparam setup = 0;
    localparam fetch_0 = 1;
    localparam fetch_1 = 2;
    localparam fetch_2 = 3;
    localparam fetch_3 = 4;
    localparam fetch_4 = 5;
    localparam in_0 = 10;
    localparam in_11 = 45;
    localparam in_1 = 11;
    localparam in_2 = 12;
    localparam in_3 = 13;
    localparam in_4 = 14;
    localparam in_5 = 15;
    localparam in_6 = 16;
    localparam out_0 = 30;
    localparam out_1 = 31;
    localparam out_2 = 32;
    localparam out_3 = 33;
    localparam out_4 = 34;
    localparam out_5 = 35;
    localparam out_6 = 36;
    localparam out_7 = 37;

    localparam mov_0 = 49;
    localparam mov_1 = 50;
    localparam mov_2 = 51;
    localparam mov_3 = 52;
    localparam mov_4 = 53;
    localparam mov_5 = 54;
    localparam mov_6 = 55;
    localparam mov_7 = 56;
    localparam mov_8 = 57;
    localparam mov_9 = 58;
    localparam mov_10 = 59;
    localparam mov_11 = 60;
    localparam mov_12 = 61;
    localparam mov_13 = 62;

    localparam add_decode_Y_0 = 100;
    localparam add_decode_Y_1 = 101;
    localparam add_decode_Y_2 = 102;
    localparam add_decode_Y_3 = 103;
    localparam add_decode_Y_4 = 104;
    localparam add_decode_Y_5 = 105;
    localparam add_decode_Y_6 = 106;

    localparam add_decode_Z_0 = 110;
    localparam add_decode_Z_1 = 111;
    localparam add_decode_Z_2 = 112;
    localparam add_decode_Z_3 = 113;
    localparam add_decode_Z_4 = 114;
    localparam add_decode_Z_5 = 115;
    localparam add_decode_Z_6 = 116;
    localparam add_decode_Z_7 = 117;
    localparam add_decode_Z_8 = 118;

    localparam add_exec_0 = 120;
    localparam add_exec_1 = 121;
    localparam add_exec_2 = 122;

    localparam error8 = 247;
    localparam error7 = 248;
    localparam error6 = 249;
    localparam error5 = 250;
    localparam error4 = 251;
    localparam error3 = 252;
    localparam error2 = 253;
    localparam error1 = 254;
    localparam error = 255;

    always @(*) begin
        state_next = state_reg;
        out_next = out_reg;

        pc_cl = 0;
        pc_ld = 0;
        pc_inc = 0;
        pc_dec = 0;
        pc_sr = 0;
        pc_ir = 0;
        pc_sl = 0;
        pc_il = 0;
        pc_in = 0;

        sp_cl = 0;
        sp_ld = 0;
        sp_inc = 0;
        sp_dec = 0;
        sp_sr = 0;
        sp_ir = 0;
        sp_sl = 0;
        sp_il = 0;
        sp_in = 0;

        ir_cl = 0;
        ir_ld = 0;
        ir_inc = 0;
        ir_dec = 0;
        ir_sr = 0;
        ir_ir = 0;
        ir_sl = 0;
        ir_il = 0;
        ir_in = 0;

        mar_cl = 0;
        mar_ld = 0;
        mar_inc = 0;
        mar_dec = 0;
        mar_sr = 0;
        mar_ir = 0;
        mar_sl = 0;
        mar_il = 0;
        mar_in = 0;

        mdr_cl = 0;
        mdr_ld = 0;
        mdr_inc = 0;
        mdr_dec = 0;
        mdr_sr = 0;
        mdr_ir = 0;
        mdr_sl = 0;
        mdr_il = 0;
        mdr_in = 0;

        a_cl = 0;
        a_ld = 0;
        a_inc = 0;
        a_dec = 0;
        a_sr = 0;
        a_ir = 0;
        a_sl = 0;
        a_il = 0;
        a_in = 0;

        we_reg = 0;

        case (state_reg)
            setup: begin
                out_next = 10'b1111001111;
                pc_in = 6'b001000;
                pc_ld = 1;
                sp_in = 6'b111111;
                sp_ld = 1;

                state_next = fetch_0;
            end
            fetch_0: begin
                out_next = 0;
                mar_in = pc;
                mar_ld = 1;
                pc_inc = 1;

                state_next = fetch_1;
            end
            fetch_1: begin
                state_next = fetch_2;
            end
            fetch_2: begin
                mdr_in = mem;
                mdr_ld = 1;

                state_next = fetch_3;
            end
            fetch_3: begin
                ir_in = data;
                ir_ld = 1;

                state_next = fetch_4;
            end
            fetch_4: begin
                //out_next = ir_out[15:8];
                case (opcode)
                    IN: begin
                        state_next = in_0;
                    end
                    OUT: begin
                        state_next = out_0;
                    end
                    MOV: begin
                        state_next = mov_0;
                    end
                    ADD,SUB,MUL: begin
                        state_next = add_decode_Y_0;
                    end
                    default: state_next = error;
                endcase
            end



            in_0: begin
                a_in = in;
                a_ld = 1;
                state_next = in_11;
            end
            in_11: begin
                mar_in = operandX_addr;
                mar_ld = 1;
                if (operandX_indirect == 0) begin
                    mdr_in = a_out;
                    mdr_ld = 1;

                    state_next = in_1;
                end else begin
                    state_next = in_4;
                end
            end
            in_1: begin
                //out_next = a_out[7:0];
                we_reg = 1;
                state_next = in_2;
            end
            in_2: begin
                state_next = in_3;
            end
            in_3: begin
                state_next = fetch_0;
            end
            in_4: begin
                state_next = in_5;
            end
            in_5: begin
                mdr_in = mem;
                mdr_ld = 1;

                state_next = in_6;
            end
            in_6: begin
                mar_in = {{(ADDR_WIDTH-3){1'b0}}, data[2:0]};
                mar_ld = 1;
                mdr_in = a_out;
                mdr_ld = 1;
                state_next = in_1; 
            end




            out_0: begin
                mar_in = operandX_addr;
                mar_ld = 1;

                state_next = out_1;
            end
            out_1: begin
                state_next = out_2;
            end
            out_2: begin
                mdr_in = mem;
                mdr_ld = 1;
                if (operandX_indirect) begin
                    state_next = out_5;
                end else begin
                    state_next = out_3;
                end
            end
            out_5: begin
                mar_in = {{(ADDR_WIDTH-3){1'b0}}, data[2:0]};
                mar_ld = 1;
                state_next = out_6;
            end
            out_6: begin
                state_next = out_7;
            end
            out_7: begin
                mdr_in = mem;
                mdr_ld = 1;
                state_next = out_3;
            end
            out_3: begin
                a_in = data;
                a_ld = 1;

                state_next = out_4;
            end

            out_4: begin
                out_next = a_out[7:0];

                state_next = fetch_0;
            end





            mov_0: begin
                if (operandZ_addr == 3'b000 && operandZ_indirect == 1'b0) begin
                    state_next = mov_1;
                end else begin
                    state_next = error1;
                end
            end
            mov_1: begin
                mar_in = {{(ADDR_WIDTH-3){1'b0}}, operandY_addr};
                mar_ld = 1;
                state_next = mov_2;
            end
            mov_2: begin
                state_next = mov_3;
            end
            mov_3: begin
                mdr_in = mem;
                mdr_ld = 1;
                if (operandY_indirect == 0) begin
                    state_next = mov_4;
                end else begin
                    state_next = mov_5;
                end
            end
            mov_4: begin
                a_in = data;
                a_ld = 1;
                state_next = in_11;
            end
            mov_5: begin
                mar_in = {{(ADDR_WIDTH-3){1'b0}}, data[2:0]};
                mar_ld = 1;
                state_next = mov_6;
            end
            mov_6: begin
                state_next = mov_7;
            end
            mov_7: begin
                mdr_in = mem;
                mdr_ld = 1;
                state_next = mov_4;
            end






            add_decode_Y_0: begin
                mar_in = {{(ADDR_WIDTH-3){1'b0}}, operandY_addr};
                mar_ld = 1;
                state_next = add_decode_Y_1;
            end

            add_decode_Y_1: begin
                state_next = add_decode_Y_2;
            end

            add_decode_Y_2: begin
                mdr_in = mem;
                mdr_ld = 1;
                if (operandY_indirect == 0) begin
                    state_next = add_decode_Y_3;
                end else begin
                    state_next = add_decode_Y_4;
                end
            end

            add_decode_Y_3: begin
                a_in = data;
                a_ld = 1;
                state_next = add_decode_Z_0;
            end

            add_decode_Y_4: begin
                mar_in = {{(ADDR_WIDTH-3){1'b0}}, data[2:0]};
                mar_ld = 1;
                state_next = add_decode_Y_5;
            end
            add_decode_Y_5: begin
                state_next = add_decode_Y_6;
            end

            add_decode_Y_6: begin
                mdr_in = mem;
                mdr_ld = 1;
                state_next = add_decode_Y_3;
            end



            add_decode_Z_0: begin
                mar_in = {{(ADDR_WIDTH-3){1'b0}}, operandZ_addr};
                mar_ld = 1;
                state_next = add_decode_Z_1;
            end

            add_decode_Z_1: begin
                state_next = add_decode_Z_2;
            end

            add_decode_Z_2: begin
                mdr_in = mem;
                mdr_ld = 1;
                if (operandZ_indirect) begin
                    state_next = add_decode_Z_3;
                end else begin
                    state_next = add_exec_0;
                end
            end

            add_decode_Z_3: begin
                mar_in = {{(ADDR_WIDTH-3){1'b0}}, data[2:0]};
                mar_ld = 1;
                state_next = add_decode_Z_4;
            end

            add_decode_Z_4: begin
                state_next = add_decode_Z_5;
            end

            add_decode_Z_5: begin
                mdr_in = mem;
                mdr_ld = 1;
                state_next = add_exec_0;
            end






            add_exec_0: begin
                //out_next = a_out;
                oc = opcode[2:0] - 1;

                state_next = add_exec_1;
            end
            add_exec_1: begin
                //out_next = data;
                a_in = alu_out;
                a_ld = 1;
                state_next = add_exec_2;
            end  

            add_exec_2: begin
                //out_next = a_out;
                state_next = in_11;
            end



            error: begin
                out_next = 10'b1100000000;
                state_next = error;
            end
            error1: begin
                out_next = 10'b1100000001;
                state_next = error1;
            end
            error2: begin
                out_next = 10'b1100000010;
                state_next = error2;
            end
            error3: begin
                out_next = 10'b1100000011;
                state_next = error3;
            end
            default: begin
                out_next = 10'b1010101010;
                state_next = error;
            end
        endcase

    end

endmodule
