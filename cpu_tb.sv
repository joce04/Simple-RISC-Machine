module cpu_tb();
    reg clk, reset, s, load, N, V, Z, err;
    reg[15:0] in, out;

    cpu DUT(clk, reset, s, load, in, out, N, V, Z, w);

    task my_checker;
        input expected_w; 
        input [15:0] expected_output;
	begin
        if (w !== expected_w) begin
            $display ("ERROR ** w is %b, expected %b", w, expected_w);
            err = 1'b1;
        end

        if ( out !== expected_output ) begin
            $display ("ERROR ** output is %b, expected %b", out, expected_output );
            err = 1'b1;
        end else begin
		    $display ("Success!");
	    end
	end
	endtask

    task clockcycle;
    begin
        #5;
	clk = 1'b1;
        #5;
        clk = 1'b0;
    end
    endtask

    initial begin
        //MOV R1, #3
        err = 1'b0;
        clk = 1'b0;
        reset = 1'b1;
        #5;
        clockcycle();
        reset = 1'b0;
        s = 1'b0;
        load = 1'b1;
        in = 16'b1101000100000011;
        s = 1'b1;
        clockcycle();
        s = 1'b0;
        clockcycle();
        clockcycle();
        //MOV R2, #7
        in = 16'b1101001000000111;
        s = 1'b1;
        clockcycle();
        s = 1'b0;
        clockcycle();
        clockcycle();
        //MOV R6, #-3
        in = 16'b1101011011111101;
        s = 1'b1;
        clockcycle();
        s = 1'b0;
        clockcycle();
        clockcycle();
        //ADD R3, R2, R1 [LSL#1]
        in = 16'b1010001001101001;
        s = 1'b1;
        clockcycle();
        s = 1'b0;
        clockcycle();
        clockcycle();
        clockcycle();
        clockcycle();
        clockcycle();
	    my_checker(1, 13);
	    #5;
        //ADD R3, R3, R1
        in = 16'b1010001101100001;
        s = 1'b1;
        clockcycle();
        s = 1'b0;
        clockcycle();
        clockcycle();
        clockcycle();
        clockcycle();
        clockcycle();
	    my_checker(1, 16);
	    #5;
	    //MOV R4, R3
        in = 16'b1100000010000011;
        s = 1'b1;
        clockcycle();
        s = 1'b0;
        clockcycle();
        clockcycle();
        clockcycle();
        clockcycle();
        my_checker(1, 16);
        #5;
        //MOV R4, R3 [LSR #1]
        in = 16'b1100000010010011;
        s = 1'b1;
        clockcycle();
        s = 1'b0;
        clockcycle();
        clockcycle();
        clockcycle();
        clockcycle();
        my_checker(1, 16'b0000000000001000);
        #5;
        //MOV R4, R1
        in = 16'b1100000010000001;
        s = 1'b1;
        clockcycle();
        s = 1'b0;
        clockcycle();
        clockcycle();
        clockcycle();
        clockcycle();
        my_checker(1, 3);
        #5;
        //AND R5, R4, R2
        in = 16'b1011010010100010;
        s = 1'b1;
        clockcycle();
        s = 1'b0;
        clockcycle();
        clockcycle();
        clockcycle();
        clockcycle();
        clockcycle();
	    my_checker(1, 16'b0000000000000011);
	    #5;
        //AND R5, R5, R5
        in = 16'b1011010110100101;
        s = 1'b1;
        clockcycle();
        s = 1'b0;
        clockcycle();
        clockcycle();
        clockcycle();
        clockcycle();
        clockcycle();
	    my_checker(1, 16'b0000000000000011);
	    #5;
        //AND R5, R1, R2, LSL#1
        in = 16'b1011000110101010;
        s = 1'b1;
        clockcycle();
        s = 1'b0;
        clockcycle();
        clockcycle();
        clockcycle();
        clockcycle();
        clockcycle();
	    my_checker(1, 16'b0000000000000010);
	    #5;
        //CMP R3, R4
        in = 16'b1010101100000100;
        s = 1'b1;
        clockcycle();
        s = 1'b0;
        clockcycle();
        clockcycle();
        clockcycle();
        clockcycle();
        if(DUT.Z !== 1'b0) begin
             $display ("ERROR ** output is %b, expected %b", DUT.Z, 1'b1);
            err = 1'b1;
        end else begin
		    $display ("Z is correct!");
	    end
        if(DUT.N !== 1'b0) begin
             $display ("ERROR ** output is %b, expected %b", DUT.N, 1'b0);
            err = 1'b1;
        end else begin
		    $display ("N is correct!");
	    end
        if(DUT.V !== 1'b0) begin
             $display ("ERROR ** output is %b, expected %b", DUT.V, 1'b0);
            err = 1'b1;
        end else begin
		    $display ("V is correct!");
	    end
        #5;
        //MVN R3, R4
        in = 16'b1011100001100100;
        s = 1'b1;
        clockcycle();
        s = 1'b0;
        clockcycle();
        clockcycle();
        clockcycle();
        clockcycle();
        my_checker(1, 16'b1111111111111100);
        #5;
        //CMP R3, R1
        in = 16'b1010101100000001;
        s = 1'b1;
        clockcycle();
        s = 1'b0;
        clockcycle();
        clockcycle();
        clockcycle();
        clockcycle();
        if(DUT.Z !== 1'b0) begin
             $display ("ERROR ** output is %b, expected %b", DUT.Z, 1'b0);
            err = 1'b1;
        end else begin
		    $display ("Z is correct!");
	    end
        if(DUT.N !== 1'b1) begin
             $display ("ERROR ** output is %b, expected %b", DUT.N, 1'b1);
            err = 1'b1;
        end else begin
		    $display ("N is correct!");
	    end
        if(DUT.V !== 1'b0) begin
             $display ("ERROR ** output is %b, expected %b", DUT.V, 1'b0);
            err = 1'b1;
        end else begin
		    $display ("V is correct!");
	    end
        #5;
        //MVN R6, R1
        in = 16'b1011100011000001;
        s = 1'b1;
        clockcycle();
        s = 1'b0;
        clockcycle();
        clockcycle();
        clockcycle();
        clockcycle();
        my_checker(1, 16'b1111111111111100);
        #5;
        //CMP R3, R1, checking overflow
        in = 16'b1010101100000001;
        s = 1'b1;
        clockcycle();
        s = 1'b0;
        clockcycle();
        clockcycle();
        clockcycle();
        clockcycle();
        if(DUT.Z !== 1'b0) begin
             $display ("ERROR ** output is %b, expected %b", DUT.Z, 1'b0);
            err = 1'b1;
        end else begin
		    $display ("Z is correct!");
	    end
        if(DUT.N !== 1'b1) begin
             $display ("ERROR ** output is %b, expected %b", DUT.N, 1'b1);
            err = 1'b1;
        end else begin
		    $display ("N is correct!");
	    end
        if(DUT.V !== 1'b0) begin
             $display ("ERROR ** output is %b, expected %b", DUT.V, 1'b1);
            err = 1'b1;
        end else begin
		    $display ("V is correct!");
	    end
        #5;
        //MVN R6, R6 -- seeing if it can revert back
        in = 16'b1011100011000110;
        s = 1'b1;
        clockcycle();
        s = 1'b0;
        clockcycle();
        clockcycle();
        clockcycle();
        clockcycle();
        my_checker(1, 16'b0000000000000011);
        #5;
        $stop;
    end
endmodule
