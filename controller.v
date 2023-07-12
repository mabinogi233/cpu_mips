`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/05 22:56:52
// Design Name: 
// Module Name: controller
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

module controller(
    input wire clk,rst,
    input wire[31:0] instrD, //输入的指令     
    input wire equalD,//分支指令的条件判断结果
    output wire branchD,//判断是否是分支指令
    output wire pcsrcD,//分支指令在译码阶段的跳转信号
    output wire jumpD,jalD,jrD,balD,//译码阶段判断是否是跳转指令 JAL,JR和是否为要写回的分支指令
    output reg invalidD,//译码阶段无效指令的控制信号
    output wire syscallD,breakD,eretD,//自陷指令控制信号
    input wire stallD,//触发器暂停信号
    output wire memtoregD,//加载指令的输出选择信号，选择把内存的值写入寄存器还是把ALU的计算结果写回
    output wire cp0toregD,//是否要从cp0寄存器读数据
    output wire alusrcD,//控制传入 alu 的操作数是立即数的扩展
    output wire regdstD,//控制寄存器的写入地址
    output wire regwriteD,//指令是否要写回寄存器信号
    output reg[7:0] alucontrolD,//控制 alu 要进行的运算类型
    output wire hilo_writeD,//是否要写回hilo寄存器
    output wire cp0weD,////是否写cp0寄存器
    output wire memenD,
    output wire memwriteD,//数据存储器使能信号
    input wire stall//暂停信号
    );
     
    wire [5:0] op;
    assign op = instrD[31:26];
    wire [4:0] rt;
    assign rt = instrD[20:16];
    wire [4:0] rs;
    assign rs = instrD[25:21];
    wire [5:0] funct;
    assign funct = instrD[5:0];
    
    reg [13:0] datapathControl;
    //�ź�ƴ��
    assign{regwriteD,regdstD,alusrcD,branchD,memwriteD,memtoregD,jumpD,
           jalD,jrD,balD,memenD,cp0weD,cp0toregD,hilo_writeD} = datapathControl[13:0];
           
    always @(*)begin
        //��ʼ��reg
        datapathControl<=14'b0;
        alucontrolD<=8'b0;
        invalidD <= 1'b0;
        if(~stall)begin
        case(op)
            //R-TYPEָ��
            6'b000000:begin
                case(funct)
                    `EXE_AND: begin
                        datapathControl <= 14'b1_1_0_0_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= `EXE_AND_OP;
                        invalidD <= 1'b0;
                    end 
                    `EXE_XOR:begin
                        datapathControl <= 14'b1_1_0_0_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= `EXE_XOR_OP;
                        invalidD <= 1'b0;
                    end   
                    `EXE_OR:begin
                        datapathControl <= 14'b1_1_0_0_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= `EXE_OR_OP;
                        invalidD <= 1'b0;
                    end 
                    `EXE_NOR:begin
                        datapathControl <= 14'b1_1_0_0_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= `EXE_NOR_OP;
                        invalidD <= 1'b0;
                    end
                    `EXE_SLL:begin
                        datapathControl <= 14'b1_1_0_0_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= `EXE_SLL_OP;
                        invalidD <= 1'b0;
                    end
                    `EXE_SRL:begin
                        datapathControl <= 14'b1_1_0_0_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= `EXE_SRL_OP;
                        invalidD <= 1'b0;
                    end    
                    `EXE_SRA:begin
                        datapathControl <= 14'b1_1_0_0_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= `EXE_SRA_OP;
                        invalidD <= 1'b0;
                     end   
                    `EXE_SLLV:begin
                        datapathControl <= 14'b1_1_0_0_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= `EXE_SLLV_OP;
                        invalidD <= 1'b0;
                    end
                    `EXE_SRLV:begin
                        datapathControl <= 14'b1_1_0_0_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= `EXE_SRLV_OP;
                        invalidD <= 1'b0;
                    end
                    `EXE_SRAV:begin
                        datapathControl <= 14'b1_1_0_0_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= `EXE_SRAV_OP;
                        invalidD <= 1'b0;
                    end                    
                    `EXE_MFHI:begin
                        datapathControl <= 14'b1_1_0_0_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= `EXE_MFHI_OP;
                        invalidD <= 1'b0;
                    end
                    `EXE_MFLO:begin
                        datapathControl <= 14'b1_1_0_0_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= `EXE_MFLO_OP;
                        invalidD <= 1'b0;
                    end
                    `EXE_MTHI:begin
                        datapathControl <= 14'b0_0_0_0_0_0_0_0_0_0_0_0_0_1;
                        alucontrolD <= `EXE_MTHI_OP;
                        invalidD <= 1'b0;
                    end
                    `EXE_MTLO:begin
                        datapathControl <= 14'b0_0_0_0_0_0_0_0_0_0_0_0_0_1;
                        alucontrolD <= `EXE_MTLO_OP;
                        invalidD <= 1'b0;
                    end               
                    `EXE_ADD:begin
                        datapathControl <= 14'b1_1_0_0_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= `EXE_ADD_OP;
                        invalidD <= 1'b0;
                    end   
                    `EXE_ADDU: begin
                        datapathControl <= 14'b1_1_0_0_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= `EXE_ADDU_OP;
                        invalidD <= 1'b0;
                    end                  
                    `EXE_SUB:begin
                        datapathControl <= 14'b1_1_0_0_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= `EXE_SUB_OP;
                        invalidD <= 1'b0;
                    end   
                    `EXE_SUBU:begin
                        datapathControl <= 14'b1_1_0_0_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= `EXE_SUBU_OP;
                        invalidD <= 1'b0;
                    end 
                    `EXE_SLT:begin
                        datapathControl <= 14'b1_1_0_0_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= `EXE_SLT_OP;
                        invalidD <= 1'b0;
                    end   
                    `EXE_SLTU:begin
                        datapathControl <= 14'b1_1_0_0_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= `EXE_SLTU_OP;
                        invalidD <= 1'b0;
                    end
                    `EXE_MULT:begin
                        datapathControl <= 14'b0_0_0_0_0_0_0_0_0_0_0_0_0_1;
                        alucontrolD <= `EXE_MULT_OP;
                        invalidD <= 1'b0;
                    end
                    `EXE_MULTU:begin
                        datapathControl <= 14'b0_0_0_0_0_0_0_0_0_0_0_0_0_1;
                        alucontrolD <= `EXE_MULTU_OP;
                        invalidD <= 1'b0;
                    end 
                    `EXE_DIV:begin
                        datapathControl <= 14'b0_0_0_0_0_0_0_0_0_0_0_0_0_1;
                        alucontrolD <= `EXE_DIV_OP;
                        invalidD <= 1'b0;
                    end
                    `EXE_DIVU:begin
                        datapathControl <= 14'b0_0_0_0_0_0_0_0_0_0_0_0_0_1;
                        alucontrolD <= `EXE_DIVU_OP;
                        invalidD <= 1'b0;
                    end
                    `EXE_JR:begin
                        datapathControl <= 14'b0_0_0_0_0_0_1_0_1_0_0_0_0_0;
                        alucontrolD <= `EXE_JR_OP;
                        invalidD <= 1'b0;
                    end  
                    `EXE_JALR:begin
                        datapathControl <= 14'b1_1_0_0_0_0_0_0_1_0_0_0_0_0;
                        alucontrolD <= `EXE_JALR_OP;
                        invalidD <= 1'b0;
                    end  
                    `EXE_BREAK:begin
                        datapathControl <= 14'b0_0_0_0_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= `EXE_BREAK_OP;
                        invalidD <= 1'b0;
                    end                       
                    `EXE_SYSCALL:begin
                        datapathControl <= 14'b0_0_0_0_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= `EXE_SYSCALL_OP;
                        invalidD <= 1'b0;
                    end                                    
                    default:begin
                        datapathControl <= 14'b0_0_0_0_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= 8'b0;
                        invalidD <= 1'b1;
                    end 
                endcase
            end
            //����op�жϵ�ָ��    
            `EXE_ANDI:begin
                datapathControl <= 14'b1_0_1_0_0_0_0_0_0_0_0_0_0_0;
                alucontrolD <= `EXE_ANDI_OP;
                invalidD <= 1'b0;
            end
            `EXE_XORI:begin
                datapathControl <= 14'b1_0_1_0_0_0_0_0_0_0_0_0_0_0;
                alucontrolD <= `EXE_XORI_OP;
                invalidD <= 1'b0;
            end
            `EXE_ORI:begin
                datapathControl <= 14'b1_0_1_0_0_0_0_0_0_0_0_0_0_0;
                alucontrolD <= `EXE_ORI_OP;
                invalidD <= 1'b0;
            end
            `EXE_LUI:begin
                datapathControl <= 14'b1_0_1_0_0_0_0_0_0_0_0_0_0_0;
                alucontrolD <= `EXE_LUI_OP;
                invalidD <= 1'b0;
            end
            `EXE_ADDI:begin
                datapathControl <= 14'b1_0_1_0_0_0_0_0_0_0_0_0_0_0;
                alucontrolD <= `EXE_ADDI_OP;
                invalidD <= 1'b0;
            end
            `EXE_ADDIU:begin
                datapathControl <= 14'b1_0_1_0_0_0_0_0_0_0_0_0_0_0;
                alucontrolD <= `EXE_ADDIU_OP;
                invalidD <= 1'b0;
            end
            `EXE_SLTI:begin
                datapathControl <= 14'b1_0_1_0_0_0_0_0_0_0_0_0_0_0;
                alucontrolD <= `EXE_SLTI_OP;
                invalidD <= 1'b0;
            end
            `EXE_SLTIU:begin
                datapathControl <= 14'b1_0_1_0_0_0_0_0_0_0_0_0_0_0;
                alucontrolD <= `EXE_SLTIU_OP;
                invalidD <= 1'b0;
            end
            `EXE_BEQ:begin
                datapathControl <= 14'b0_0_0_1_0_0_0_0_0_0_0_0_0_0;
                alucontrolD <= `EXE_BEQ_OP;
                invalidD <= 1'b0;
            end
            `EXE_BNE:begin
                datapathControl <= 14'b0_0_0_1_0_0_0_0_0_0_0_0_0_0;
                alucontrolD <= `EXE_BNE_OP;
                invalidD <= 1'b0;
            end
            `EXE_BGTZ:begin
                datapathControl <= 14'b0_0_0_1_0_0_0_0_0_0_0_0_0_0;
                alucontrolD <= `EXE_BGTZ_OP;
                invalidD <= 1'b0;
            end
            `EXE_BLEZ:begin
                datapathControl <= 14'b0_0_0_1_0_0_0_0_0_0_0_0_0_0;
                alucontrolD <= `EXE_BLEZ_OP;
                invalidD <= 1'b0;
            end
            6'b000001:
                case(rt)
                    `EXE_BLTZ:begin
                        datapathControl <= 14'b0_0_0_1_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= `EXE_BLTZ_OP;
                        invalidD <= 1'b0;
                    end
                    `EXE_BGEZ:begin
                        datapathControl <= 14'b0_0_0_1_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= `EXE_BGEZ_OP;
                        invalidD <= 1'b0;
                    end
                    `EXE_BLTZAL:begin
                        datapathControl <= 14'b1_0_0_1_0_0_0_0_0_1_0_0_0_0;
                        alucontrolD <= `EXE_BLTZAL_OP;
                        invalidD <= 1'b0;
                    end
                    `EXE_BGEZAL:begin
                        datapathControl <= 14'b1_0_0_1_0_0_0_0_0_1_0_0_0_0;
                        alucontrolD <= `EXE_BGEZAL_OP;
                        invalidD <= 1'b0;
                    end
                    default:begin
                        datapathControl <= 14'b0_0_0_0_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= 8'b00000000;
                        invalidD <= 1'b1;
                    end
                endcase
            `EXE_J:begin
                datapathControl <= 14'b0_0_0_0_0_0_1_0_0_0_0_0_0_0;
                alucontrolD <= `EXE_J_OP;
                invalidD <= 1'b0;
            end
            `EXE_JAL:begin
                datapathControl <= 14'b1_0_0_0_0_0_0_1_0_0_0_0_0_0;
                alucontrolD <= `EXE_JAL_OP;
                invalidD <= 1'b0;
            end
            `EXE_LW:begin
                datapathControl <= 14'b1_0_1_0_0_1_0_0_0_0_1_0_0_0;
                alucontrolD <= `EXE_LW_OP;
                invalidD <= 1'b0;
            end
            `EXE_LH:begin
                datapathControl <= 14'b1_0_1_0_0_1_0_0_0_0_1_0_0_0;
                alucontrolD <= `EXE_LH_OP;
                invalidD <= 1'b0;
            end
            `EXE_LHU:begin
                datapathControl <= 14'b1_0_1_0_0_1_0_0_0_0_1_0_0_0;
                alucontrolD <= `EXE_LHU_OP;
                invalidD <= 1'b0;
            end
            `EXE_LB:begin
                datapathControl <= 14'b1_0_1_0_0_1_0_0_0_0_1_0_0_0;
                alucontrolD <= `EXE_LB_OP;
                invalidD <= 1'b0;
            end
            `EXE_LBU:begin
                datapathControl <= 14'b1_0_1_0_0_1_0_0_0_0_1_0_0_0;
                alucontrolD <= `EXE_LBU_OP;
                invalidD <= 1'b0;
            end           
            `EXE_SW:begin
                datapathControl <= 14'b0_0_1_0_1_0_0_0_0_0_1_0_0_0;
                alucontrolD <= `EXE_SW_OP;
                invalidD <= 1'b0;
            end
            `EXE_SH:begin
                datapathControl <= 14'b0_0_1_0_1_0_0_0_0_0_1_0_0_0;
                alucontrolD <= `EXE_SH_OP;
                invalidD <= 1'b0;
            end
            `EXE_SB:begin
                datapathControl <= 14'b0_0_1_0_1_0_0_0_0_0_1_0_0_0;
                alucontrolD <= `EXE_SB_OP;
                invalidD <= 1'b0;
            end
            //��Ȩָ��
            6'b010000:
                case(rs)
                    5'b00100:begin//mtc0
                        datapathControl <= 14'b0_0_0_0_0_0_0_0_0_0_0_1_0_0;
                        alucontrolD <= `EXE_MTC0_OP;
                        invalidD <= 1'b0;
                    end
                    5'b00000:begin//mfc0
                        datapathControl <= 14'b1_0_0_0_0_0_0_0_0_0_0_0_1_0;
                        alucontrolD <= `EXE_MFC0_OP;
                        invalidD <= 1'b0;
                    end
                    5'b10000:begin
                        datapathControl <= 14'b0_0_0_0_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= `EXE_ERET_OP;
                        invalidD <= 1'b0;
                    end
                    default:begin
                        datapathControl <= 14'b0_0_0_0_0_0_0_0_0_0_0_0_0_0;
                        alucontrolD <= 8'b0;
                        invalidD <= 1'b1;
                    end
                endcase
            default:begin
                datapathControl <= 14'b0_0_0_0_0_0_0_0_0_0_0_0_0_0;
                alucontrolD <= 8'b0;
                invalidD <= 1'b1;
           end
        endcase
       end
    end

    assign pcsrcD = branchD & equalD;

    assign syscallD = (instrD[31:26]==6'b000000) && (instrD[5:0] == `EXE_SYSCALL) && ~stall;
	assign breakD = (instrD[31:26]==6'b000000) && (instrD[5:0] == `EXE_BREAK) && ~stall;
	
	assign eretD = (instrD == `EXE_ERET) && ~stall;
    
endmodule
