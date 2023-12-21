module datapath_tb();
    reg clk, write, loada, loadb, loadc, loads, asel, bsel, err;
    reg[2:0] readnum, writenum, Z_out;
    reg [1:0] ALUop, shift, vsel;
    reg [15:0] sximm8;
    reg [15:0] datapath_out;

    datapath DUT ( .clk         (clk),
                .readnum     (readnum),
                .vsel        (vsel),
                .loada       (loada),
                .loadb       (loadb),
                .shift       (shift),
                .asel        (asel),
                .bsel        (bsel),
                .ALUop       (ALUop),
                .loadc       (loadc),
                .loads       (loads),
                .writenum    (writenum),
                .write       (write),  
                .sximm8      (sximm8),
                .Z_out       (Z_out),
                .datapath_out(datapath_out));

    task my_checker;
        input [15:0] expected_output;
	begin
        if ( datapath_out !== expected_output ) begin
            $display ("ERROR ** output is %b, expected %b", datapath_out, expected_output);
            err = 1'b1;
        end 
	end
	endtask

    task clockcycle;
    begin
        clk = 0; #5;
        clk = 1; #5;
        clk = 0; #5;
    end
    endtask

    initial begin
        err = 1'b0;
        //TEST 1: checking equality
        sximm8 = 42;
        vsel = 2'b10;
        writenum = 3;
        write = 1;
        clockcycle(); //42 is stored in register 3.

        sximm8 = 13;
        vsel = 2'b10;
        writenum = 5;
        write = 1;
        clockcycle(); //13 is stored in register 5

        loada = 0;
        readnum = 3;
        write = 0;
        loadb = 1;
        clockcycle(); //load 42 into b

        loadb = 0;
        readnum = 5;
        loada = 1;
        clockcycle(); //load 13 into a
        loada = 0;
        ALUop = 2'b00;
        asel = 0;
        bsel = 0;
        shift = 2'b00;
        loadc = 1;
        loads = 1;
        clockcycle(); //loadc and loads are 1 so datapath_out is updated and Z out is updated
        loadc = 0;
        vsel = 0;
        write = 1;
        writenum = 2; //stored in register 2
        my_checker(55); //check that the datapath_output is 55.
        clockcycle();

        //TEST 2: Checking dividing a number (42/2 = 21)
        readnum = 3;
        loadb = 1;
        write = 0;
        loada = 0;
        clockcycle(); //load 42 from reg3 into b

        loadb = 0;
        ALUop = 2'b00;
        asel = 1; //we want just zeros in a
        bsel = 0;
        shift = 2'b10;
        loadc = 1;
        loads = 1;
        clockcycle();
        my_checker(21); //check that the datapath_output is 21
        loadc = 0; 
        vsel = 0;
        write = 1;
        writenum = 4; //write 21 to reg4
        clockcycle(); 
    end
endmodule
