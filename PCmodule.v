`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/05 22:56:52
// Design Name: 
// Module Name: PCmodule
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module PCmodule(
	input wire clk,
	input wire rst,
	input wire en,
	input wire flush,
	input wire[31:0] pcin,
	input wire[31:0] pcnew,
	output reg[31:0] pcout
    );
	always @(posedge clk,posedge rst) begin
		if(rst) begin
			pcout <= 32'hbfc00000;
		end else if(flush) begin
            pcout <= pcnew;
        end else if(en) begin
            pcout <= pcin;
		end else begin
		    pcout <= pcout;
		end
	end
endmodule