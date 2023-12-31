//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2014 leishangwen@163.com                       ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
// Module:  div
// File:    div.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: ����ģ��
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.vh"

module div(

	input wire										clk,
	input wire										rst,
	
	input wire                    signed_div_i,
	input wire[31:0]              opdata1_i,
	input wire[31:0]		   				opdata2_i,
	input wire                    start_i,
	input wire                    annul_i,
	
	output reg[63:0]             result_o,
	output reg			             ready_o
);

	wire[32:0] div_temp;
	reg[5:0] cnt;
	reg[64:0] dividend;
	reg[1:0] state;
	reg[31:0] divisor;	 
	reg[31:0] temp_op1;
	reg[31:0] temp_op2;
	
	assign div_temp = {1'b0,dividend[63:32]} - {1'b0,divisor};

	always @ (posedge clk) begin
		if (rst == 1'b1) begin
			state <= 2'b00;
			ready_o <= 1'b0;
			result_o <= 64'b0;
		end else begin
		  case (state)
		  	2'b00:			begin               //DivFree״̬
		  		if(start_i == 1'b1 && annul_i == 1'b0) begin
		  			if(opdata2_i == 32'b0) begin
		  				state <= 2'b01;
		  			end else begin
		  				state <= 2'b10;
		  				cnt <= 6'b000000;
		  				if(signed_div_i == 1'b1 && opdata1_i[31] == 1'b1 ) begin
		  					temp_op1 = ~opdata1_i + 1;
		  				end else begin
		  					temp_op1 = opdata1_i;
		  				end
		  				if(signed_div_i == 1'b1 && opdata2_i[31] == 1'b1 ) begin
		  					temp_op2 = ~opdata2_i + 1;
		  				end else begin
		  					temp_op2 = opdata2_i;
		  				end
		  				dividend <= 64'b0;
              dividend[32:1] <= temp_op1;
              divisor <= temp_op2;
             end
          end else begin
						ready_o <= 1'b0;
						result_o <= 64'b0;
				  end          	
		  	end
		  	2'b01:		begin               //DivByZero״̬
         	dividend <= 64'b0;
          state <= 2'b11;		 		
		  	end
		  	2'b10:				begin               //DivOn״̬
		  		if(annul_i == 1'b0) begin
		  			if(cnt != 6'b100000) begin
               if(div_temp[32] == 1'b1) begin
                  dividend <= {dividend[63:0] , 1'b0};
               end else begin
                  dividend <= {div_temp[31:0] , dividend[31:0] , 1'b1};
               end
               cnt <= cnt + 1;
             end else begin
               if((signed_div_i == 1'b1) && ((opdata1_i[31] ^ opdata2_i[31]) == 1'b1)) begin
                  dividend[31:0] <= (~dividend[31:0] + 1);
               end
               if((signed_div_i == 1'b1) && ((opdata1_i[31] ^ dividend[64]) == 1'b1)) begin              
                  dividend[64:33] <= (~dividend[64:33] + 1);
               end
               state <= 2'b11;
               cnt <= 6'b000000;            	
             end
		  		end else begin
		  			state <= 2'b00;
		  		end	
		  	end
		  	2'b11:			begin               //DivEnd״̬
        	result_o <= {dividend[64:33], dividend[31:0]};  
          ready_o <= 1'b1;
          if(start_i == 1'b0) begin
          	state <= 2'b00;
						ready_o <= 1'b0;
						result_o <= 64'b0;       	
          end		  	
		  	end
		  endcase
		end
	end

endmodule