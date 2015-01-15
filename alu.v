module alu {
	input precharge,
	//positive rail inputs
	input [3:0] alucontrol,
	input [31:0] rs,
	input [31:0] rt,
	//negative rail inputs
	input nalucontrol,
	input [31:0] nrs,
	input [31:0] nrt,
	//positive rail outputs
	output result,
	output zero,
	//negative rail outputs
	output nresult,
	output nzero,
	
	output complete

};

	always @(*) begin
		
		case (alucontrol[1:0])
		1'b0: begin 
			adder_in_2 = rt;
			adder_cin = 1'b0;		
			end
		1'b1: begin //prepare for subtraction (with additional logic maybe)
			adder_in_2 = ~rt;
			adder_cin = 1'b1;		
			end
		endcase
	
		case (alucontrol[1:0])
		2'b00: result = rs & adder_in_2; //AND
		2'b01: result = rs | adder_in_2; //OR
		2'b10: result = adder_out; //ADD/SUB
		2'b11: result = adder_out[31]; //SLT
		endcase
	end
	
	
	adder alu_adder ( //update with proper ref and negative rails as well
		.a(rs),
		.b(adder_in_2),
		.out(adder_out)
	);
	
	assign zero = (result == 0);
	assign nzero = (result == 32'hFFFFFFFF);
	
endmodule