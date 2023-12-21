`define RST 5'b00000
`define IF1 5'b00001
`define IF2 5'b00010 
`define GET 5'b00011 
`define ADD1 5'b00100 
`define ADD2 5'b00101 
`define ADD3 5'b00110 
`define ADD4 5'b00111
`define MOVNUM 5'b01000 
`define MOV1 5'b01001 
`define MOV2 5'b01010
`define MOV3 5'b01011
`define CMP 5'b01100 
`define MVN1 5'b01101 
`define MVN2 5'b01110 
`define MVN3 5'b01111 
`define UPDATE 5'b10000 
`define HALT 5'b10001 
`define LDR1 5'b10010 
`define LDR2 5'b10011 
`define LDR3 5'b10100 
`define LDR4 5'b10101 
`define LDR5 5'b10110 
`define STR1 5'b10111 
`define STR2 5'b11000 
`define STR3 5'b11001 
`define STR4 5'b11010 
`define STR5 5'b11011 

`define MNONE 3'b100 
`define MREAD 3'b010 
`define MWRITE 3'b001 


module controller(opcode, op, clk, reset, w, loada, loadb, loadc, write, 
                    vsel, asel, bsel, nsel, loads, loadpc, resetpc, addrsel, load_ir, mem_cmd, load_addr, ssel);
    input wire [2:0] opcode;
    input wire [1:0] op;
    input wire reset, clk;
    output reg w, loada, loadb, loadc, write, asel, bsel, loads, loadpc, resetpc, addrsel, load_ir, load_addr, ssel;
    output reg[1:0] vsel;
    output reg[2:0] nsel, mem_cmd;

    wire[4:0] current_state;
    reg[4:0] next_state_reset, next_state;

    assign next_state_reset = reset ? `RST : next_state;

    vDFF #(5) vdff(clk, next_state_reset, current_state);

    always_comb begin
        //logic for the next state
        case(current_state)
            `HALT : {next_state, w} = {`HALT, 1'b1};
            `RST : {next_state, w} = {`IF1, 1'b1};
            `IF1 : {next_state, w} = {`IF2, 1'b1};
            `IF2 : {next_state, w} = {`UPDATE, 1'b1};
            `UPDATE : {next_state, w} = {`GET, 1'b1};
            `GET : begin 
                case(opcode)
                    3'b101 : begin 
                        case(op)
                            2'b00 : {next_state, w} = {`ADD1, 1'b0}; //this is for ADD
                            2'b01 : {next_state, w} = {`ADD1, 1'b0}; //this is for CMP
                            2'b10 : {next_state, w} = {`ADD1, 1'b0}; //this is for AND
                            2'b11 : {next_state, w} = {`MVN1, 1'b0}; //this is for MVN
                            default : {next_state, w} = 6'bxxxxxx;
                        endcase 
                    end
                    3'b110 : begin 
                        case(op)
                            2'b10 : {next_state, w} = {`MOVNUM, 1'b0};
                            2'b00 : {next_state, w} = {`MOV1, 1'b0};
                            default : {next_state, w} = 6'bxxxxxx;
                        endcase
                    end
                    3'b011 : {next_state, w} = {`LDR1, 1'b0}; //this is LDR
                    3'b100 : {next_state, w} = {`STR1, 1'b0}; //this is STR
                    3'b111 : {next_state, w} = {`HALT, 1'b0}; //this is HALT
                    default : {next_state, w} = 6'bxxxxxx;
                endcase
            end
            `ADD1 : {next_state, w} = {`ADD2, 1'b0};
            `ADD2 : begin
                case(op)
                    2'b01 : {next_state, w} = {`CMP, 1'b0};
                    default : {next_state, w} = {`ADD3, 1'b0};
                endcase
            end
            `ADD3 : {next_state, w} = {`ADD4, 1'b0};
            `ADD4 : {next_state, w} = {`IF1, 1'b0};
            `MOVNUM : {next_state, w} = {`IF1, 1'b0};
            `MOV1 : {next_state, w} = {`MOV2, 1'b0};
            `MOV2 : {next_state, w} = {`MOV3, 1'b0};
            `MOV3 : {next_state, w} = {`IF1, 1'b0};
            `CMP : {next_state, w} = {`IF1, 1'b0};
            `MVN1 : {next_state, w} = {`MVN2, 1'b0};
            `MVN2 : {next_state, w} = {`MVN3, 1'b0};
            `MVN3 : {next_state, w} = {`IF1, 1'b0};
            `LDR1 : {next_state, w} = {`LDR2, 1'b0};
            `LDR2 : {next_state, w} = {`LDR3, 1'b0};
            `LDR3 : {next_state, w} = {`LDR4, 1'b0};
            `LDR4 : {next_state, w} = {`LDR5, 1'b0};
            `LDR5 : {next_state, w} = {`IF1, 1'b0};
            `STR1 : {next_state, w} = {`STR2, 1'b0};
            `STR2 : {next_state, w} = {`STR3, 1'b0};
            `STR3 : {next_state, w} = {`STR4, 1'b0};
            `STR4 : {next_state, w} = {`STR5, 1'b0};
            `STR5 : {next_state, w} =  {`IF1, 1'b0};
            default : {next_state, w} = 6'bxxxxxx;
        endcase

        //setting ssel, the multiplexer for sximm5 and sximm8
        case(current_state)
            `LDR1 : ssel = 1'b0;
            `LDR2 : ssel = 1'b0;
            `STR1 : ssel = 1'b0;
            `STR2 : ssel = 1'b0;
            `STR3 : ssel = 1'b0;
            `STR4 : ssel = 1'b0;
            default : ssel = 1'b1;
        endcase

        //logic for the outputs associated with each state
        case(current_state)
            `HALT : begin
                load_addr = 1'b0;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MNONE;
                loada = 1'b0;
                loadb = 1'b0;
                loadc = 1'b0;
                loads = 1'b0;
                asel = 1'b0;
                bsel = 1'b0;
                vsel = 2'b00;
                write = 1'b0;
                nsel = 3'b000;
            end
            `RST : begin
                load_addr = 1'b0;
                loadpc = 1'b1;
                resetpc = 1'b1;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MNONE;
                loada = 1'b0;
                loadb = 1'b0;
                loadc = 1'b0;
                loads = 1'b0;
                asel = 1'b0;
                bsel = 1'b0;
                vsel = 2'b00;
                write = 1'b0;
                nsel = 3'b000;
            end
            `IF1 : begin
                load_addr = 1'b0;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b1;
                load_ir = 1'b0;
                mem_cmd = `MREAD;
                loada = 1'b0;
                loadb = 1'b0;
                loadc = 1'b0;
                loads = 1'b0;
                asel = 1'b0;
                bsel = 1'b0;
                vsel = 2'b00;
                write = 1'b0;
                nsel = 3'b000;
            end
            `IF2 : begin
                load_addr = 1'b0;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b1;
                load_ir = 1'b1;
                mem_cmd = `MREAD;
                loada = 1'b0;
                loadb = 1'b0;
                loadc = 1'b0;
                loads = 1'b0;
                asel = 1'b0;
                bsel = 1'b0;
                vsel = 2'b00;
                write = 1'b0;
                nsel = 3'b000;
            end
            `UPDATE : begin
                load_addr = 1'b0;
                loadpc = 1'b1;
                resetpc = 1'b0;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MNONE;
                loada = 1'b0;
                loadb = 1'b0;
                loadc = 1'b0;
                loads = 1'b0;
                asel = 1'b0;
                bsel = 1'b0;
                vsel = 2'b00;
                write = 1'b0;
                nsel = 3'b000;
            end
            `GET : begin
                load_addr = 1'b0;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MNONE;
                loada = 1'b0;
                loadb = 1'b0;
                loadc = 1'b0;
                loads = 1'b0;
                asel = 1'b0;
                bsel = 1'b0;
                vsel = 2'b00;
                write = 1'b0;
                nsel = 3'b000;
            end
            `ADD1 : begin
                load_addr = 1'b0;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MNONE;
                loada = 1'b1;
                loadb = 1'b0;
                loadc = 1'b0;
                loads = 1'b0;
                asel = 1'b0;
                bsel = 1'b0;
                vsel = 2'b00;
                write = 1'b0;
                nsel = 3'b100;
            end
            `ADD2 : begin
                load_addr = 1'b0;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MNONE;
                loada = 1'b0;
                loadb = 1'b1;
                loadc = 1'b0;
                loads = 1'b0;
                asel = 1'b0;
                bsel = 1'b0;
                vsel = 2'b00;
                write = 1'b0;
                nsel = 3'b001;
            end
            `ADD3 : begin
                load_addr = 1'b0;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MNONE;
                loada = 1'b0;
                loadb = 1'b0;
                loadc = 1'b1;
                loads = 1'b1;
                asel = 1'b0;
                bsel = 1'b0;
                vsel = 2'b00;
                write = 1'b0;
                nsel = 3'b000;
            end
            `ADD4 : begin 
                load_addr = 1'b0;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MNONE;
                loada = 1'b0;
                loadb = 1'b0;
                loadc = 1'b0;
                loads = 1'b0;
                asel = 1'b0;
                bsel = 1'b0;
                vsel = 2'b00;
                write = 1'b1;
                nsel = 3'b010;
            end
            `MOVNUM : begin
                load_addr = 1'b0;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MNONE;
                loada = 1'b0;
                loadb = 1'b0;
                loadc = 1'b0;
                loads = 1'b0;
                asel = 1'b0;
                bsel = 1'b0;
                vsel = 2'b10;
                write = 1'b1;
                nsel = 3'b100;
            end
            `MOV1 : begin
                load_addr = 1'b0;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MNONE;
                loada = 1'b0;
                loadb = 1'b1;
                loadc = 1'b0;
                loads = 1'b0;
                asel = 1'b1;
                bsel = 1'b0;
                vsel = 2'b00;
                write = 1'b0;
                nsel = 3'b001;
            end
            `MOV2 : begin
                load_addr = 1'b0;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MNONE;
                loada = 1'b0;
                loadb = 1'b1;
                loadc = 1'b1;
                loads = 1'b0;
                asel = 1'b1;
                bsel = 1'b0;
                vsel = 2'b00;
                write = 1'b0;
                nsel = 3'b001;
            end
            `MOV3 : begin
                load_addr = 1'b0;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MNONE;
                loada = 1'b0;
                loadb = 1'b0;
                loadc = 1'b0;
                loads = 1'b0;
                asel = 1'b0;
                bsel = 1'b0;
                vsel = 2'b00;
                write = 1'b1;
                nsel = 3'b010;
            end
            `CMP : begin
                load_addr = 1'b0;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MNONE;
                loada = 1'b0;
                loadb = 1'b0;
                loadc = 1'b0;
                loads = 1'b1;
                asel = 1'b0;
                bsel = 1'b0;
                vsel = 2'b00;
                write = 1'b0;
                nsel = 3'b000;
            end
            `MVN1 : begin
                load_addr = 1'b0;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MNONE;
                loada = 1'b0;
                loadb = 1'b1;
                loadc = 1'b0;
                loads = 1'b0;
                asel = 1'b1;
                bsel = 1'b0;
                vsel = 2'b00;
                write = 1'b0;
                nsel = 3'b001;
            end
            `MVN2 : begin
                load_addr = 1'b0;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MNONE;
                loada = 1'b0;
                loadb = 1'b0;
                loadc = 1'b1;
                loads = 1'b0;
                asel = 1'b0;
                bsel = 1'b0;
                vsel = 2'b00;
                write = 1'b0;
                nsel = 3'b010;
            end
            `MVN3 : begin
                load_addr = 1'b0;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MNONE;
                loada = 1'b0;
                loadb = 1'b0;
                loadc = 1'b0;
                loads = 1'b0;
                asel = 1'b0;
                bsel = 1'b0;
                vsel = 2'b00;
                write = 1'b1;
                nsel = 3'b010;
            end
            `LDR1 : begin
                load_addr = 1'b0;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MNONE;
                loada = 1'b1;
                loadb = 1'b0;
                loadc = 1'b0;
                loads = 1'b0;
                asel = 1'b0;
                bsel = 1'b1;
                vsel = 2'b00;
                write = 1'b0;
                nsel = 3'b100;
            end
            `LDR2 : begin
                load_addr = 1'b0;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MNONE;
                loada = 1'b0;
                loadb = 1'b0;
                loadc = 1'b1;
                loads = 1'b1;
                asel = 1'b0;
                bsel = 1'b1;
                vsel = 2'b00;
                write = 1'b0;
                nsel = 3'b100;
            end
            `LDR3 : begin
                load_addr = 1'b1;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MNONE;
                loada = 1'b0;
                loadb = 1'b0;
                loadc = 1'b0;
                loads = 1'b0;
                asel = 1'b0;
                bsel = 1'b1;
                vsel = 2'b00;
                write = 1'b0;
                nsel = 3'b100;
            end
            `LDR4 : begin
                load_addr = 1'b0;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MREAD;
                loada = 1'b0;
                loadb = 1'b0;
                loadc = 1'b0;
                loads = 1'b0;
                asel = 1'b0;
                bsel = 1'b1;
                vsel = 2'b00;
                write = 1'b0;
                nsel = 3'b100;
            end
            `LDR5 : begin
                load_addr = 1'b0;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MREAD;
                loada = 1'b0;
                loadb = 1'b0;
                loadc = 1'b0;
                loads = 1'b0;
                asel = 1'b0;
                bsel = 1'b1;
                vsel = 2'b11;
                write = 1'b1;
                nsel = 3'b010;
            end
            `STR1 : begin
                load_addr = 1'b0;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MNONE;
                loada = 1'b1;
                loadb = 1'b0;
                loadc = 1'b0;
                loads = 1'b0;
                asel = 1'b0;
                bsel = 1'b1;
                vsel = 2'b00;
                write = 1'b0;
                nsel = 3'b100;
            end
            `STR2 : begin
                load_addr = 1'b0;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MNONE;
                loada = 1'b0;
                loadb = 1'b0;
                loadc = 1'b1;
                loads = 1'b1;
                asel = 1'b0;
                bsel = 1'b1;
                vsel = 2'b00;
                write = 1'b0;
                nsel = 3'b100;
            end
            `STR3 : begin
                load_addr = 1'b1;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MNONE;
                loada = 1'b0;
                loadb = 1'b1;
                loadc = 1'b0;
                loads = 1'b0;
                asel = 1'b1;
                bsel = 1'b0;
                vsel = 2'b00;
                write = 1'b0;
                nsel = 3'b010;
            end
            `STR4 : begin
                load_addr = 1'b0;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MNONE;
                loada = 1'b0;
                loadb = 1'b0;
                loadc = 1'b1;
                loads = 1'b0;
                asel = 1'b1;
                bsel = 1'b0;
                vsel = 2'b00;
                write = 1'b0;
                nsel = 3'b010;
            end
            `STR5 : begin
                load_addr = 1'b0;
                loadpc = 1'b0;
                resetpc = 1'b0;
                addrsel = 1'b0;
                load_ir = 1'b0;
                mem_cmd = `MWRITE;
                loada = 1'b0;
                loadb = 1'b0;
                loadc = 1'b0;
                loads = 1'b0;
                asel = 1'b1;
                bsel = 1'b0;
                vsel = 2'b00;
                write = 1'b0;
                nsel = 3'b010;
            end
            default : begin
                load_addr = 1'bx;
                loadpc = 1'bx;
                resetpc = 1'bx;
                addrsel = 1'bx;
                load_ir = 1'bx;
                mem_cmd = 3'bxxx;
                loada = 1'bx;
                loadb = 1'bx;
                loadc = 1'bx;
                loads = 1'bx;
                asel = 1'bx;
                bsel = 1'bx;
                vsel = 2'bxx;
                write = 1'bx;
                nsel = 3'bxxx;
            end
        endcase
    end
endmodule
