`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/05 22:56:52
// Design Name: 
// Module Name: hazard
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



module hazard(
	output wire stallF,
	input wire [4:0] rsD,rtD,
	input wire branchD,
	output wire forwardaD,forwardbD,
	output wire stallD,
	input wire[4:0] rsE,rtE,
	input wire[4:0] writeregE,
	input wire regwriteE,
	input wire memtoregE,
	output reg [1:0] forwardaE,forwardbE,
	output wire flushE,
	input wire [4:0] writeregM,
	input wire regwriteM,
	input wire memtoregM,
	input wire[4:0] writeregW,
	input wire regwriteW,	
	input wire jumpD,
	input wire div_stallE,
    output wire stallE,
	input wire jalD,jrD,
	input wire cp0toregE,
	input wire [31:0] excepttypeM,
	output wire flushF,
	output wire flushD,
	output wire flushM,
	output wire flushW,
	output wire stallM,
	output wire stallW,
	input wire instrStall,
	input wire dataStall,
	output wire axi_stall
    );

    /*译码阶段的数据前推，regwriteM为访存阶段寄存器堆的使能信号，writeregM为写回寄存器的地址，如果访存阶段将要写回寄存器的地址和
    译码阶段将要从寄存器读的地址相同，把访存阶段的值前推*/
    assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
    //同理，二号端口的前推信号
	assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);
    //执行阶段的数据前推，10为选择访存阶段ALU的数据，01为选择写回阶段要写回寄存器的数据
	always @(*) begin
		forwardaE = 2'b00;
		forwardbE = 2'b00;
		if(rsE != 0) begin
		//如果执行阶段的地址和访存阶段将要写回寄存器的地址相同而且寄存器使能信号为1，前推ALU数据
			if(rsE == writeregM & regwriteM) begin
				forwardaE = 2'b10;
		//如果执行阶段的地址和回写阶段将要写回寄存器的地址相同而且寄存器使能信号为1，前推要写回寄存器的数据
			end else if(rsE == writeregW & regwriteW) begin
				forwardaE = 2'b01;
			end
		end
		//同理
		if(rtE != 0) begin
			if(rtE == writeregM & regwriteM) begin
				forwardbE = 2'b10;
			end else if(rtE == writeregW & regwriteW) begin
				forwardbE = 2'b01;
			end
		end
	end
    //访存指令导致的暂停,mfc0复用
    wire lwstall;               
    assign lwstall =  (cp0toregE | memtoregE) & (rsD==rtE | rtD==rtE); 
    //分支指令前推导致的暂停
    wire branchstall;
    assign branchstall = (branchD | jumpD | jalD | jrD) 
                   & ((regwriteE & (writeregE == rsD | writeregE == rtD))
                   | (memtoregM & (writeregM == rsD | writeregM == rtD)));
                   
    wire  flushpipeline;
    //收集异常后清空流水线
	assign flushpipeline = (excepttypeM != 32'b0);
    assign stallF = lwstall | branchstall  | div_stallE  | dataStall | instrStall;
    assign flushF = flushpipeline;
    assign stallD = lwstall | branchstall  | div_stallE  | dataStall | instrStall;
    assign flushD = flushpipeline;
    assign flushE = lwstall |  branchstall | flushpipeline;
    assign stallE = div_stallE | dataStall;
    assign stallM = dataStall;
    assign flushM = flushpipeline;
    assign stallW = dataStall;
    assign flushW = flushpipeline;
    assign axi_stall = (div_stallE  | dataStall | instrStall)&&~flushpipeline;
    
endmodule