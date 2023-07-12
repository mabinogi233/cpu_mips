`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/05 22:56:52
// Design Name: 
// Module Name: mips
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


module mips(
    input wire[5:0] int,
	input wire clk,
	input wire resetn,
	input wire instrStall,
	input wire dataStall,
	output wire flush,
	output wire axi_stall,
	//sram
	output wire inst_sram_en,
    output wire [3:0] inst_sram_wen,
    output wire [31:0] inst_sram_addr,
    output wire [31:0] inst_sram_wdata,
    input wire [31:0] inst_sram_rdata,
    
    output wire data_sram_en,
    output wire [3:0] data_sram_wen,
    output wire [31:0] data_sram_addr,
    output wire [31:0] data_sram_wdata,
    input wire [31:0] data_sram_rdata,
    //debug 
    output wire[31:0] debug_wb_pc,
    output wire[3:0] debug_wb_rf_wen,
    output wire[4:0] debug_wb_rf_wnum,
    output wire[31:0] debug_wb_rf_wdata
    );
    wire [31:0] instrD;
	wire pcsrcD;
	wire branchD,jumpD,jalD, jrD, balD;
	wire [7:0] alucontrolD;
	wire invalidD;
	wire equalD;
    wire breakD,eretD,syscallD;
	wire memtoregD,cp0toregD,alusrcD,regdstD,regwriteD,hilo_writeD,cp0weD,memenD,memwriteD;
	wire [31:0]excepttypeM;
    wire [31:0] pcF;
    wire [31:0] instrF;
    wire memenM;
    wire [3:0] selM;
    wire [31:0] aluoutM,writedataM;
    wire [31:0] readdataM;
    wire [31:0] pcW;
	wire [4:0] writeregW;
	wire [31:0] resultW;
    wire regwriteW;
    wire stall;

    assign inst_sram_en = 1'b1;
    assign inst_sram_wen = 4'b0000;
    assign inst_sram_addr = pcF;
    assign inst_sram_wdata = 32'b0;
    assign instrF = inst_sram_rdata;
    
    assign data_sram_en = memenM & ~(|excepttypeM);                        
    assign data_sram_wen = selM;
    assign data_sram_addr = aluoutM;
    assign data_sram_wdata = writedataM;
    assign readdataM = data_sram_rdata;
    
    assign debug_wb_pc = pcW;
    assign debug_wb_rf_wen = {4{regwriteW}};
    assign debug_wb_rf_wnum = writeregW;
    assign debug_wb_rf_wdata = resultW;

    assign flush = (excepttypeM!=32'b0);
    assign stall = instrStall || dataStall;
    
	controller c(
		.clk(clk), 
		.rst(~resetn),
		.instrD(instrD),
		.equalD(equalD),
		.branchD(branchD),
		.pcsrcD(pcsrcD),
		.jumpD(jumpD),
		.jalD(jalD), 
		.jrD(jrD), 
		.balD(balD),
		.memtoregD(memtoregD),
		.memenD(memenD),
		.memwriteD(memwriteD),
		.alusrcD(alusrcD),
        .regdstD(regdstD),
        .regwriteD(regwriteD),
        .alucontrolD(alucontrolD),
        .hilo_writeD(hilo_writeD),
		.invalidD(invalidD),
		.syscallD(syscallD),
		.breakD(breakD),
		.eretD(eretD),
		.stall(stall),			
        .cp0toregD(cp0toregD),
        .cp0weD(cp0weD)
		);
		
	datapath dp(
		.clk(clk), 
		.rst(~resetn),
		.pcF(pcF),
		.instrF(instrF),
		.pcsrcD(pcsrcD),
		.branchD(branchD),
		.jumpD(jumpD),
		.jalD(jalD),
		.jrD(jrD),
		.balD(balD),
		.equalD(equalD),
		.instrD(instrD),
	    .memtoregD(memtoregD),
        .alusrcD(alusrcD),
        .regdstD(regdstD),
        .regwriteD(regwriteD),
        .alucontrolD(alucontrolD),
        .hilo_writeD(hilo_writeD),        
        .memenD(memenD),
		.memwriteD(memwriteD),
        .memenM(memenM),
		.memwriteM(memwriteM),
		.cp0toregD(cp0toregD),
		.cp0weD(cp0weD),
		.invalidD(invalidD),
		.syscallD(syscallD),
		.breakD(breakD),
		.eretD(eretD),
		.aluoutM(aluoutM),
		.writedataMnew(writedataM),
		.sel(selM),
		.readdataM(readdataM),
        .excepttypeM(excepttypeM),
		.regwriteW(regwriteW),
		.writeregW(writeregW),
		.pcW(pcW),
		.resultW(resultW),
		.int(int),
        .instrStall(instrStall),
        .dataStall(dataStall),
        .axi_stall(axi_stall)
	    );

endmodule