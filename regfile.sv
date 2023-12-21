
module regfile(data_in,writenum,write,readnum,clk,data_out); 
    input [15:0] data_in;
    input [2:0] writenum, readnum;
    input write, clk;
    output reg [15:0] data_out;

    reg [7:0] readDecoder;
    reg [7:0] writeDecoder;
    reg [7:0] active;
    reg [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
    
    
    always_comb begin
        //code a 3->8 decoder for writing
        case(writenum)
            0 : writeDecoder = 8'b00000001;
            1 : writeDecoder = 8'b00000010;
            2 : writeDecoder = 8'b00000100;
            3 : writeDecoder = 8'b00001000;
            4 : writeDecoder = 8'b00010000;
            5 : writeDecoder = 8'b00100000;
            6 : writeDecoder = 8'b01000000;
            7 : writeDecoder = 8'b10000000;
            default : writeDecoder = 8'bxxxxxxxx;
        endcase

        //a 3->8 decoder for reading
        case(readnum)
            0 : readDecoder = 8'b00000001;
            1 : readDecoder = 8'b00000010;
            2 : readDecoder = 8'b00000100;
            3 : readDecoder = 8'b00001000;
            4 : readDecoder = 8'b00010000;
            5 : readDecoder = 8'b00100000;
            6 : readDecoder = 8'b01000000;
            7 : readDecoder = 8'b10000000;
            default : readDecoder = 8'bxxxxxxxx;
        endcase

        //multiplexer for data_out
        case(readDecoder)
            8'b00000001 : data_out = R0;
            8'b00000010 : data_out = R1;
            8'b00000100 : data_out = R2;
            8'b00001000 : data_out = R3;
            8'b00010000 : data_out = R4;
            8'b00100000 : data_out = R5;
            8'b01000000 : data_out = R6;
            8'b10000000 : data_out = R7;
            default : data_out = 16'bxxxxxxxxxxxxxxxx;
        endcase
    end

    //AND gate for adding those bits to write
    assign active = {write, write, write, write, write, write, write, write} & writeDecoder;

    //write a load enable circuit
    loadEnableDFF #(16) dff7(data_in, active[7], clk, R7);
    loadEnableDFF #(16) dff6(data_in, active[6], clk, R6);
    loadEnableDFF #(16) dff5(data_in, active[5], clk, R5);
    loadEnableDFF #(16) dff4(data_in, active[4], clk, R4);
    loadEnableDFF #(16) dff3(data_in, active[3], clk, R3);
    loadEnableDFF #(16) dff2(data_in, active[2], clk, R2);
    loadEnableDFF #(16) dff1(data_in, active[1], clk, R1);
    loadEnableDFF #(16) dff(data_in, active[0], clk, R0);
endmodule

//module for load enable dff
module loadEnableDFF (in, load, clk, out);
    //load enable circuit
    parameter n;
    input [n-1:0] in;
    input load, clk;
    output reg [n-1:0] out;

    reg [n-1:0] temp;
    assign temp = load ? in : out;

    always_ff @(posedge clk) begin
        out = temp;
    end
endmodule
