`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/05 22:56:52
// Design Name: 
// Module Name: alu
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

module alu(
    input wire [31:0] srcAE,
    input wire [31:0] srcBE,
    input wire [7:0] op,
    input wire [4:0] sa,  
    output reg [31:0] aluout,
    output reg overflow
	
);

wire [31:0] B_buma;
wire [31:0] A_B_cha;
//减法的需要
assign B_buma = ((~srcBE) +1);
//有符号数比较使用
assign A_B_cha = srcAE + B_buma;
//根据译码的aluout结果选择不同的alu计算方式
always @(*)begin
    case(op)
        `EXE_AND_OP,`EXE_ANDI_OP: begin
            aluout <= srcAE & srcBE;
            overflow <= 1'b0;
        end    
        `EXE_OR_OP,`EXE_ORI_OP:begin  
            aluout <= srcAE | srcBE;
            overflow <= 1'b0;
        end
        `EXE_XOR_OP,`EXE_XORI_OP:begin
             aluout <= srcAE^srcBE;
             overflow <= 1'b0;
         end    
        `EXE_NOR_OP:begin
            aluout <= ~(srcAE | srcBE);
            overflow <= 1'b0;
         end   
        `EXE_LUI_OP:begin  
            aluout <= {srcBE[15:0],16'b0};
            overflow <= 1'b0;
        end
        `EXE_SLL_OP:begin
            aluout <= (srcBE << sa);
            overflow <= 1'b0;
        end
        `EXE_SRL_OP:begin
            aluout <= (srcBE >> sa);
            overflow <= 1'b0;
        end
        `EXE_SRA_OP:begin //参考指导书
            aluout <= (({32{srcBE[31]}} << (6'd32-{1'b0,sa})) | srcBE >> sa);
            overflow <= 1'b0;
        end
        `EXE_SLLV_OP:begin 
            aluout <= (srcBE << srcAE[4:0]);
            overflow <= 1'b0;
        end
        `EXE_SRLV_OP:begin
            aluout <= (srcBE >> srcAE[4:0]);
            overflow <= 1'b0;
        end
        `EXE_SRAV_OP:begin 
            aluout <= (({32{srcBE[31]}} << (6'd32-{1'b0,srcAE[4:0]})) | srcBE >> srcAE[4:0]);
            overflow <= 1'b0;
        end
        `EXE_ADD_OP,`EXE_ADDI_OP:begin
            aluout <= srcAE + srcBE;
            overflow <= (srcAE[31] && srcBE[31] && ~aluout[31]) || (~srcAE[31] && ~srcBE[31] && aluout[31]);
        end
        `EXE_ADDU_OP,`EXE_ADDIU_OP,`EXE_LB_OP,`EXE_LBU_OP,`EXE_LH_OP,`EXE_LHU_OP,
        `EXE_LW_OP,`EXE_SB_OP,`EXE_SH_OP,`EXE_SW_OP: begin 
            aluout <= srcAE + srcBE;
            overflow <= 1'b0;
        end
        `EXE_SUB_OP:begin
            aluout <= srcAE + B_buma;
            overflow <= (srcAE[31] && ~srcBE[31] && ~aluout[31]) || (~srcAE[31] && srcBE[31] && aluout[31]);
        end
        `EXE_SUBU_OP:begin
            aluout <= srcAE + B_buma; 
            overflow <= 1'b0;
         end         
        `EXE_SLT_OP,`EXE_SLTI_OP: begin
            case({srcAE[31],srcBE[31]})
                2'b00:aluout<={31'b0,A_B_cha[31]};
                2'b11:aluout<={31'b0,A_B_cha[31]};
                2'b01:aluout<=32'b0;
                2'b10:aluout<=32'b1;
                default:aluout<=32'b0;
            endcase
            overflow <= 1'b0;
        end
        `EXE_SLTU_OP,`EXE_SLTIU_OP:begin 
            aluout <= (srcAE < srcBE) ? 32'h00000001: 32'h00000000;
            overflow <= 1'b0; 
        end    
        //mtc0 复用ALU
		`EXE_MTC0_OP:begin 
		    aluout <= srcBE;
		    overflow <= 1'b0;
		end    
        default:begin 
            aluout <= 32'b0;
            overflow <= 1'b0;
        end    
    endcase
end
                           
endmodule
