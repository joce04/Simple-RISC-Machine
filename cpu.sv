module cpu(clk,reset,in,out,N,V,Z,w, mem_cmd, mem_addr); 
    input clk, reset;
    input reg [15:0] in; //this is read_data
    output reg [15:0] out;
    output reg [2:0] mem_cmd;
    output reg [8:0] mem_addr;
    output reg N, V, Z, w;

    reg [2:0] nsel, opcode, readnum, writenum;
    reg loada, loadb, loadc, loads, write, asel, bsel, loadpc, resetpc, addrsel, load_ir, load_addr, ssel;
    reg[1:0] vsel, op, shift, sh;
    reg[2:0] Z_out;
    assign V = Z_out[2]; //overflow
    assign N = Z_out[1]; //negative
    assign Z = Z_out[0]; //zero

    reg[15:0] instructionReg, sximm8, sximm5, sximm;
    reg[8:0] PC, next_pc, addedpc, data_out;

    //load the instruction
    loadEnableDFF #(16) instructionRegister(in, load_ir, clk, instructionReg);

    //load the Program counter
    loadEnableDFF #(9) programCounter(next_pc, loadpc, clk, PC);

    //load the data address
    loadEnableDFF #(9) dataAddress(out[8:0], load_addr, clk, data_out);

    //multiplexer for reset pc
    assign next_pc = resetpc ? {9{1'b0}} : addedpc;

    //adder
    assign addedpc = PC + 1'b1;

    //multiplexer for address selection
    assign mem_addr = addrsel ? PC : data_out;

    //sign extending sximm8
    assign sximm8 = instructionReg[7] ? {8'b11111111, instructionReg[7:0]} : {8'b00000000, instructionReg[7:0]};

    //sign extending sximm5
    assign sximm5 = instructionReg[4] ? {{11{1'b1}}, instructionReg[4:0]} : {{11{1'b0}}, instructionReg[4:0]};

    //multiplexer for sxim
    assign sximm = ssel ? sximm8 : sximm5;

    //makes there be no shift in the LDR and STR instructions
    assign sh = ssel ? shift : 2'b00;

    //the instruction decoder
    instruction instruction(instructionReg, nsel, opcode, op, readnum, writenum, shift);
    //the datapath controller
    controller controller(opcode, op, clk, reset, w, loada, loadb, loadc, write, vsel, 
                        asel, bsel, nsel, loads, loadpc, resetpc, addrsel, load_ir, mem_cmd, load_addr, ssel);
    //the datapath
    datapath DP(.clk(clk), .readnum(readnum), .vsel(vsel), .loada(loada), .loadb(loadb), .shift(sh), .asel(asel), 
                .bsel(bsel), .ALUop(op), .loadc(loadc), .loads(loads), .writenum(writenum), .write(write), 
                .sximm8(sximm), .Z_out(Z_out), .datapath_out(out), .mdata(in));

endmodule
