module ALU(Ain,Bin,ALUop,out,Z); 
    input [15:0] Ain, Bin;
    input [1:0] ALUop;
    output reg [15:0] out;
    output reg [2:0] Z;
    
    always_comb begin
        //implemented the ALUop functionality
        case(ALUop)
            2'b00 : out = Ain + Bin;
            2'b01 : out = Ain - Bin;
            2'b10 : out = Ain & Bin;
            2'b11 : out = ~Bin;
            default : out = 16'bxxxxxxxxxxxxxxxx;
        endcase

        //N output -- if Ain < Bin
        case(out[15])
            1'b0 : Z[1] = 1'b0;
            1'b1 : Z[1] = 1'b1;
            default : Z[1] = 1'bx;
        endcase

        //Z output -- if Ain and Bin are equal
        case(out)
            0 : Z[0] = 1'b1;
            default: Z[0] = 1'b0;
        endcase

        //V output -- if there is overflow
        case({Ain[15], Bin[15]})
            2'b01: begin //Ain is positive, Bin is negative
                if(out[15] == 1'b1) //out is negative
                    Z[2] = 1'b1; //overflow
                else
                    Z[2] = 1'b0; //no overflow
            end
            2'b10: begin
                if(out[15] == 1'b0)
                    Z[2] = 1'b1; //overflow
                else
                    Z[2] = 1'b0; //no overflow
            end
            default: Z[2] = 1'b0; //no overflow
        endcase
    end

endmodule
