module datapath(clk, readnum, vsel, loada, loadb, shift, asel, 
                bsel, ALUop, loadc, loads, writenum, write, sximm8, Z_out, datapath_out, mdata);
    
    input clk, write, loada, loadb, loadc, loads, asel, bsel;
    input[2:0] readnum, writenum;
    input [1:0] ALUop, shift, vsel;
    input [15:0] sximm8, mdata;
    output reg [15:0] datapath_out;
    output reg [2:0] Z_out;

    reg [15:0] data_in, sout, output_a, output_b, input_b, Ain, Bin, out, data_out;
    reg [7:0] PC;
    assign PC = 8'b00000000;

    reg [2:0] Z;
    //multiplexer for vsel
    always_comb begin
        case (vsel)
            2'b00 : data_in = datapath_out;
            2'b01 : data_in = {8'b0, PC};
            2'b10 : data_in = sximm8;
            2'b11 : data_in = mdata;
            default: data_in = 16'bxxxxxxxxxxxxxxxx;
        endcase
    end
    
    //initialize regfile
    regfile REGFILE(data_in, writenum, write, readnum, clk, data_out);
    
    //initialize load enable dff for loada and loadb
    loadEnableDFF #(16) dffA(data_out, loada, clk, output_a);
    loadEnableDFF #(16) dffB(data_out, loadb, clk, output_b);

    //initialize shifter module
    shifter SHIFTER(output_b,shift,sout); 
    
    //Bsel multiplexer
    assign Bin = bsel ? sximm8 : sout;
    //Asel multiplexer
    assign Ain = asel ? 16'b0 : output_a;
    
    //initialize ALU
    ALU alu(Ain,Bin,ALUop,out,Z);
    
    //initialize load enable dff for loadc and loads (load status)
    loadEnableDFF #(16) dffC(out, loadc, clk, datapath_out);
    loadEnableDFF #(3) dffStatus(Z, loads, clk, Z_out);
endmodule
