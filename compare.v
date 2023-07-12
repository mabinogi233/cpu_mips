`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/05 22:56:52
// Design Name: 
// Module Name: compare
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
`include "defines.vh"

module compare(
	input wire [31:0] a,b,
	input wire [5:0] op,
	input wire [4:0] rt,
	output wire y
    );
    assign y = (op==`EXE_BEQ)? a==b:
               (op==`EXE_BNE)? a!=b:
               (op==`EXE_BGTZ)? ((a[31]==1'b0)&&(a!=32'b0)):
               (op==`EXE_BLEZ)? ((a[31]==1'b1)||(a==32'b0)):
               ((op==6'b000001)&&(rt==`EXE_BGEZ))?(a[31]==1'b0):
               ((op==6'b000001)&&(rt==`EXE_BLTZ))?(a[31]==1'b1):
               ((op==6'b000001)&&(rt==`EXE_BGEZAL))?(a[31]==1'b0):
               ((op==6'b000001)&&(rt==`EXE_BLTZAL))?(a[31]==1'b1):
               1'b0;

endmodule