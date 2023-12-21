module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5); 
    input [3:0] KEY;
    input [9:0] SW;
    output [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    reg[15:0] dout, write_data, read_data;
    reg write, N, V, Z, loadLED, loadSW, correct_addr, correct_out, msel, validRead, validWrite, enable, clk;
    reg[8:0] mem_addr;
    reg[2:0] mem_cmd;

    assign clk = ~KEY[0];

    cpu CPU(.clk(clk),.reset(~KEY[1]),.in(read_data),.out(write_data),.N(N),.V(V),.Z(Z),.w(LEDR[9]), .mem_cmd(mem_cmd), .mem_addr(mem_addr));

    RAM MEM(.clk(clk),
            .read_address(mem_addr[7:0]),
            .write_address(mem_addr[7:0]),
            .write(write),
            .din(write_data),
            .dout(dout)); 

    //tests if the address is valid address
    assign msel = ~(1'b0 | mem_addr[8]);
    //tests if the command is read
    assign validRead = (1'b1 & mem_cmd[1]);
    assign validWrite = (1'b1 & mem_cmd[0]);

    assign enable  = msel & validRead;
    assign loadSW = validRead & correct_addr;
    assign loadLED = validWrite & correct_out;

    //write for RAM
	assign write = msel & validWrite; 

    loadEnableDFF #(8) led_out(write_data[7:0], loadLED, clk, LEDR[7:0]);

    always_comb begin
        //combinational logic to set the output of read_data.
        if(loadSW) begin
            read_data = {{8{1'b0}}, SW[7:0]};
        end
        else if (enable) begin
            read_data = dout;
        end
        else begin
            read_data = {16{1'bz}};
        end

        //combinational circuit for loadSW
        case(mem_addr)
            9'h140 : correct_addr = 1'b1;
            default : correct_addr = 1'b0;
        endcase

        //combinational circuit for loadLED
        case(mem_addr)
            9'h100 : correct_out = 1'b1;
            default : correct_out = 1'b0;
        endcase
    end

    assign HEX5[0] = ~Z;
    assign HEX5[6] = ~N;
    assign HEX5[3] = ~V; 

    // fill in sseg to display 4-bits in hexidecimal 0,1,2...9,A,B,C,D,E,F
    sseg H0(write_data[3:0],   HEX0);
    sseg H1(write_data[7:4],   HEX1);
    sseg H2(write_data[11:8],  HEX2);
    sseg H3(write_data[15:12], HEX3);
    assign HEX4 = 7'b1111111;
    assign {HEX5[2:1],HEX5[5:4]} = 4'b1111; // disabled
endmodule

module vDFF(clk, in, out);
    parameter n;
    input clk;
    input [n-1:0] in;
    output reg [n-1:0] out;

    always_ff @( posedge clk ) begin
        out <= in;
    end
endmodule

module sseg(in,segs);
  input [3:0] in;
  output reg [6:0] segs;

  always_comb begin
    case(in)
      0 : segs = 7'b1000000;
      1 : segs = 7'b1111001;
      2 : segs = 7'b0100100;
      3 : segs = 7'b0110000;
      4 : segs = 7'b0011001;
      5 : segs = 7'b0010010;
      6 : segs = 7'b0000010;
      7 : segs = 7'b1111000;
      8 : segs = 7'b0000000;
      9 : segs = 7'b0011000;
      10 : segs = 7'b0001000;
      11 : segs = 7'b0000011;
      12 : segs = 7'b1000110;
      13 : segs = 7'b0100001;
      14 : segs = 7'b0000100;
      15 : segs = 7'b0001110;
      default: segs = 7'bxxxxxxx;
    endcase
  end

endmodule
