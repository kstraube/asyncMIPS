module decode_stage {
	input precharge,
	//pos rail inputs
	input [31:0] instr,
	input zero,
	//neg rail inputs
	input [31:0] ninstr,
	input nzero,
	//pos rail outputs
	output memtoreg,
	output memwrite,
	output pcsrc,
	output alusrc,
	output regdst,
	output regwrite,
	output jump,
	output [2:0] alucontrol,
	//neg rail outputs
	output nmemtoreg,
	output nmemwrite,
	output npcsrc,
	output nalusrc,
	output nregdst,
	output nregwrite,
	output njump,
	output [2:0] nalucontrol,
	//complete signal
	output complete
};

	reg [8:0] controls, ncontrols;
	
	//reg nmemtoreg,memwrite,npcsrc,nalusrc,nregdst,nregwrite,njump;
	//reg [2:0] nalucontrol;

	assign opcode = instr[31:26];
	assign funct = instr[5:0];
	
	assign nopcode = ninstr[31:26];
	assign nfunct = ninstr[5:0];
	
	assign complete = (memtoreg ^ nmemtoreg) & (memwrite ^ nmemwrite) & (pcsrc ^ npcsrc) & (alusrc ^ nalusrc) & (&(alucontrol ^ nalucontrol)) & (regdst ^ nregdst) & (regwrite ^ nregwrite) & (jump ^ njump);
	
	pmos p1(memtoreg, 1, precharge);
	pmos p2(memwrite, 1, precharge);
	pmos p3(pcsrc, 1, precharge);
	pmos p4(alusrc, 1, precharge);
	pmos p5(regdst, 1, precharge);
	pmos p6(regwrite, 1, precharge);
	pmos p7(jump, 1, precharge);
	pmos p8(alucontrol[2], 1, precharge);
	pmos p9(alucontrol[1], 1, precharge);
	pmos p10(alucontrol[0], 1, precharge);
	
	pmos pn1(nmemtoreg, 1, precharge);
	pmos pn2(nmemwrite, 1, precharge);
	pmos pn3(npcsrc, 1, precharge);
	pmos pn4(nalusrc, 1, precharge);
	pmos pn5(nregdst, 1, precharge);
	pmos pn6(nregwrite, 1, precharge);
	pmos pn7(njump, 1, precharge);
	pmos pn8(nalucontrol[2], 1, precharge);
	pmos pn9(nalucontrol[1], 1, precharge);
	pmos pn10(nalucontrol[0], 1, precharge);

	always @(*) begin
		/**if (precharge) begin
			memtoreg = 1'b1;
			memwrite = 1'b1;
			pcsrc = 1'b1;
			alusrc = 1'b1;
			regdst = 1'b1;
			regwrite = 1'b1;
			jump = 1'b1;
			alucontrol = 3'b111;
			
			nmemtoreg = 1'b1;
			nmemwrite = 1'b1;
			npcsrc = 1'b1;
			nalusrc = 1'b1;
			nregdst = 1'b1;
			nregwrite = 1'b1;
			njump = 1'b1;
			nalucontrol = 3'b111;
		
		end
		else**/
		if (~precharge) begin
			pcsrc = branch & zero; //only works for single cycle cpu - needs control and pipelining
			//also needs to support other branches than only bez 
			
			[regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, aluop] = controls;
			
			//opcode decode
			case (opcode)
				6'h0: begin //r type
					controls = 9'b110000010;
					end
				6'd35: begin //load word
					controls = 9'b101001000;
					end
				6'd43: begin //store word
					controls = 9'b001010000;
					end
				/**6'd1: begin //bltz/bgez
					end**/
				6'd2: begin //jump
					controls = 9'b000000100;
					end
				/**6'd3: begin //jump and link
					end**/
				6'd4: begin //beq
					controls = 9'b000100001;
					end
				/**6'd5: begin //bne
					end
				6'd6: begin //blez
					end
				6'd7: begin //bgtz
					end**/
				default: begin //i type (no fp supp yet)
					controls = 9'b101000000; //update with different possible aluop values - currently set for addi only
					end
			endcase
			
			//aluop/funct decode
			case(aluop)
				2'b00: alucontrol = 3'b010; //add
				2'b01: alucontrol = 3'b110; //sub
				default: case(funct) //r type
					6'b100000: alucontrol = 3'b010; //add
					6'b100010: alucontrol = 3'b110; //sub
					6'b100100: alucontrol = 3'b000; //and
					6'b100101: alucontrol = 3'b001; //or
					6'b101010: alucontrol = 3'b111; //slt
					default: alucontrol = 3'bxxx; //???
				endcase
			endcase
			
			/**nmemtoreg = ~memtoreg;
			nmemwrite = ~memwrite;
			npcsrc = ~npcsrc;
			nalusrc = ~alusrc;
			nregdst = ~regdst;
			nregwrite = ~nregwrite;
			njump = ~jump;
			nalucontrol = ~alucontrol;**/
			
			npcsrc = nbranch | nzero; //only works for single cycle cpu - needs control and pipelining
			//also needs to support other branches than only bez 
			
			[nregwrite, nregdst, nalusrc, nbranch, nmemwrite, nmemtoreg, njump, naluop] = ncontrols;
			
			//opcode decode
			case (nopcode)
				6'h3F: begin //r type
					ncontrols = 9'b001111101;// 9'b110000010;
					end
				6'h1C: begin //load word
					ncontrols = 9'b010110111; //9'b101001000;
					end
				6'h14: begin //store word
					ncontrols = 9'b110101111;//9'b001010000;
					end
				/**6'd1: begin //bltz/bgez
					end**/
				6'd3D: begin //jump
					ncontrols = 9'b111111011;//9'b000000100;
					end
				/**6'd3: begin //jump and link
					end**/
				6'd3B: begin //beq
					ncontrols = 9'b111011110;//9'b000100001;
					end
				/**6'd5: begin //bne
					end
				6'd6: begin //blez
					end
				6'd7: begin //bgtz
					end**/
				default: begin //i type (no fp supp yet)
					ncontrols = 9'b010111111;//9'b101000000; //update with different possible aluop values - currently set for addi only
					end
			endcase
			
			//aluop/funct decode
			case(naluop)
				2'b11: nalucontrol = 3'b101;//3'b010; //add
				2'b10: nalucontrol = 3'b001;//3'b110; //sub
				default: case(nfunct) //r type
					6'b011111: nalucontrol = 3'b101;//6'b100000: alucontrol = 3'b010; //add
					6'b011101: nalucontrol = 3'b001;//6'b100010: alucontrol = 3'b110; //sub
					6'b011011: nalucontrol = 3'b111;//6'b100100: alucontrol = 3'b000; //and
					6'b011010: nalucontrol = 3'b110;//6'b100101: alucontrol = 3'b001; //or
					6'b010101: nalucontrol = 3'b000;//6'b101010: alucontrol = 3'b111; //slt
					default: alucontrol = 3'bxxx; //???
				endcase
			endcase
			
			
		end
	end
endmodule