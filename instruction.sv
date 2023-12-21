module instruction(instructionReg, nsel, opcode, op, readnum, writenum, shift);
    input [15:0] instructionReg;
    input [2:0] nsel;
    output reg [2:0] opcode, readnum, writenum;
    output reg [1:0] op, shift;

    //outputs of the instruction decoder
    assign opcode = instructionReg[15:13];
    assign op = instructionReg[12:11];
    assign shift = instructionReg[4:3];
    
    always_comb begin
        //setting the readnum and writenum values
        case(nsel)
            3'b001 : {readnum, writenum} = {instructionReg[2:0], instructionReg[2:0]};
            3'b010 : {readnum, writenum} = {instructionReg[7:5], instructionReg[7:5]};
            3'b100 : {readnum, writenum} = {instructionReg[10:8], instructionReg[10:8]};
            default : {readnum, writenum} = 6'bxxxxxx;
        endcase
    end
endmodule
