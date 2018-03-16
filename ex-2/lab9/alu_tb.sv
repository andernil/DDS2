timeunit 10ns;
`include "ex2-1.v"
`include "ex2-1-property.sv"

module alu_tb();

	reg clk = 0;
	logic rst, validi;
	logic [31:0] data_in;
	wire 	valido;
	wire [31:0]  data_out;


//Declaration of the Verilog DUT
   ex2_1 dut
     (
      clk, rst, validi,
      data_in,
      valido,
      data_out
      );
//Make your covergroup here
	covergroup alu_cg @(posedge clk);
		coverpoint data_in {
			bins Zero = {0};
			bins Small = {[1:50]};
			bins Hunds = {[100:200]};
			bins Large = {[200:$]};
			bins others[] = default;
		}

		coverpoint data_out {
			bins Zero = {0};
			bins Small = {[1:50]};
			bins Hunds = {[100:200]};
			bins Large = {[200:$]};
			bins others[] = default;
		}
	endgroup


//Initialize your covergroup here
	alu_cg alu_cg_inst = new;

//Make your loop here

	initial begin
		 clk=1'b0;
		 set_stim;
		 @(posedge clk); $finish(2);
	end



	task set_stim;
		 rst=1'b0; validi=0'b1; data_in=32'b1;
		 @(negedge clk) rst=1;
		 @(negedge clk) rst=0;

		 @(negedge clk); validi=1'b0; data_in+=32'b1; 
		 @(negedge clk); validi=1'b1; data_in+=32'b1; 
		 @(negedge clk); validi=1'b0; data_in+=32'b1; 
		 @(negedge clk); validi=1'b1; data_in+=32'b1; 
		 @(negedge clk); validi=1'b1; data_in+=32'b1; 
		 @(negedge clk); validi=1'b0; data_in+=32'b1; 
		 @(negedge clk); validi=1'b0; data_in+=32'b1; 
		 @(negedge clk); validi=1'b1; data_in+=32'b1; 
		 @(negedge clk); validi=1'b1; data_in+=32'b1; 
		 @(negedge clk); validi=1'b1; data_in+=32'b1; 
		 @(negedge clk); validi=1'b0; data_in+=32'b1; 

/************ Uncomment for task 5 ******************/
		 @(negedge clk); validi=1'b1; data_in+=32'b1; 
		 @(negedge clk); validi=1'b1; data_in+=32'b1; 
		 @(negedge clk); validi=1'b1; data_in+=32'b1; 
		 @(negedge clk); validi=1'b1; data_in+=32'b1; 
		 @(negedge clk); validi=1'b1; data_in+=32'b1; 
		 @(negedge clk); validi=1'b0; data_in+=32'b1; 
		 @(negedge clk); validi=1'b1; data_in+=32'b1; 
		 @(negedge clk); validi=1'b1; data_in+=32'b1; 
		 @(negedge clk); validi=1'b1; data_in+=32'b1; 
		 @(negedge clk); validi=1'b1; data_in+=32'b1; 
		 @(negedge clk); validi=1'b0; data_in+=32'b1;
		 @(negedge clk); validi=1'b0; data_in+=32'b1;
		 @(negedge clk); validi=1'b1; data_in+=32'b1; 
		 @(negedge clk); validi=1'b1; data_in+=32'b1; 
		 @(negedge clk); validi=1'b1; data_in+=32'b1;
		 @(negedge clk); validi=1'b1; data_in+=32'b1;
		 @(negedge clk); validi=1'b1; data_in+=32'b1;
		 @(negedge clk); validi=1'b1; data_in+=32'b1;
		 @(negedge clk); validi=1'b0; data_in+=32'b1;
/************ Uncomment for task 5 ******************/

		 @(negedge clk);
	endtask
//Sample
    always @(posedge clk)
        alu_cg_inst.sample();    

//Displaying signals on the screen
	always @(posedge clk)
		$display($stime,,,"rst=%b clk=%b validi=%b DIN=%0d valido=%b DOUT=%0d",
			 rst, clk, validi, data_in, valido, data_out);

//Clock generation
always #5 clk=~clk;

endmodule:alu_tb
