//'define instrs_fetch2exec 3
module control_hazard_controller {
	input precharge,
	input branch_dec,
	input zero,
	input branch_done,
	input exec_done,
	input exec_instr,
	input npc_in,
	
	input nprecharge,
	input nbranch_dec,
	input nzero,
	input nbranch_done,
	input nexec_done,
	input nexec_instr,
	input n_npc_in,
	
	output flush,
	output nflush,
	output npc,
	output n_npc
	
};

	assign branch_target = exec_instr[15:0]<<2;
	assign nbranch_target = nexec_instr[15:0]<<2;
	
	always @(*) begin
		if (curr_branch && zero) begin
			flush = 1'b1;
			npc = branch_target;
		end
		else begin
			flush = 1'b0;
			npc = npc_in + 32'd4; //use correct adder later
		end
		
		if (ncurr_branch || nzero) begin
			nflush = 1'b1;
			n_npc = n_npc_in + 32'hFFFFFFFB; //use correct adder later
		end
		else begin
			nflush = 1'b0;
			n_npc = nbranch_target;
		end
	end

	//placeholder fifos
	fifo branch_tracker(
		.rst(flush),
		.din(branch_dec),
		.we(branch_done),
		.dout(curr_branch),
		.re(exec_done)
	);
	
	fifo nbranch_tracker(
		.rst(flush),
		.din(nbranch_dec),
		.we(branch_done),
		.dout(ncurr_branch),
		.re(exec_done)
	);
	
endmodule