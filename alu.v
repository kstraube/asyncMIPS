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
		
		//pos rail logic
		case (alucontrol[1:0])
		1'b0: begin 
			adder_in_2 = rt;
			adder_cin = 1'b0;		
			end
		1'b1: begin //prepare for subtraction (with additional logic maybe)
			adder_in_2 = nrt;
			adder_cin = 1'b1;		
			end
		endcase
	
		case (alucontrol[1:0])
		2'b00: result = rs & adder_in_2; //AND
		2'b01: result = rs | adder_in_2; //OR
		2'b10: result = adder_out; //ADD/SUB
		2'b11: result = adder_out[31]; //SLT
		endcase
		
		//neg rail logic
		case (nalucontrol[1:0])
		1'b0: begin //prepare for subtraction (with additional logic maybe)
			nadder_in_2 = rt;
			nadder_cin = 1'b0;		
			end
		1'b1: begin 
			nadder_in_2 = nrt;
			nadder_cin = 1'b1;		
			end
		endcase
	
		case (nalucontrol[1:0])
		2'b00: nresult = nadder_out[31]; //SLT
		2'b01: result = nadder_out; //ADD/SUB
		2'b10: result = nrs & nadder_in_2; //OR
		2'b11: nresult = nrs | nadder_in_2; //AND
		endcase
	end
	
	
	/**adder alu_adder ( //update with proper ref and negative rails as well
		.a(rs),
		.b(adder_in_2),
		.out(adder_out)
	);**/
	
	Martin_Add32 adder(
		.Req(),
		.df(),
		.dt(),
		.sf(),
		.st(),
		.af(nrs),
		.at(rs),
		.bf(nadder_in_2),
		.bt(adder_in_2),
		.cf(nadder_cin),
		.ct(adder_cin)
		); 
	
	assign zero = (result == 0);
	assign nzero = (result == 32'hFFFFFFFF);
	
endmodule