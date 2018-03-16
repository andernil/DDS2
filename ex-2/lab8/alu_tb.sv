timeunit 10ns; 
`include "alu_packet.sv"
//`include "alu_assertions.sv"

module alu_tb();
	reg clk = 0;
	bit [0:7] a = 8'h0;
	bit [0:7] b = 8'h0;
	bit [0:2] op = 3'h0;
	wire [0:7] r;

parameter NUMBERS = 10000;

//make your vector here
	alu_data test_data[NUMBERS];
//Make your loop here
	
	initial data_gen: begin
		#20		
		for(int i = 0; i < NUMBERS; i=i+1) begin
			test_data[i] = new();
			test_data[i].randomize();
			test_data[i].get(a, b, op);
			#20;
		end 	
	end: data_gen	

//Displaying signals on the screen
always @(posedge clk) 
  $display($stime,,,"clk=%b a=%b b=%b op=%b r=%b",clk,a,b,op,r);

//Clock generation
always #10 clk=~clk;

//Declaration of the VHDL alu
alu dut (clk,a,b,op,r);

//Make your opcode enumeration here
	enum{ADD, SUB, MULT, NOT, NAND, NOR, AND, OR} opcode;

//Make your covergroup here
	covergroup alu_cg @(posedge clk);
   		coverpoint op {
            		bins ADD = {ADD};
            		bins SUB = {SUB};
            		bins MULT = {MULT};
            		bins NOT = {NOT};
            		bins NAND = {NAND};
            		bins NOR = {NOR};
            		bins AND = {AND};
            		bins OR = {OR};
        	}
    
		coverpoint a {
			bins Zero = {0};
			bins Small = {[1:50]};
			bins Hunds = {[100:200]};
			bins Large = {[200:$]};
			bins others[] = default;
		}
		A: coverpoint a;
		B: coverpoint b;
		AB: cross A, B;
	endgroup

//Initialize your covergroup here
	alu_cg alu_cg_inst = new;

//Sample covergroup here
	always @(posedge clk) begin
		alu_cg_inst.sample();	
	end

endmodule:alu_tb
