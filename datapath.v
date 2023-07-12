`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/05 22:56:52
// Design Name: 
// Module Name: datapath
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


module datapath(
	input wire clk,rst,
	input wire[31:0] instrF,
	output wire [31:0] instrD,
	input wire jumpD,
	input wire regwriteD,memtoregD,
	input wire memwriteD,
	input wire[7:0] alucontrolD,
	input wire alusrcD,regdstD,
	input wire branchD,
	input wire pcsrcD,
	output wire equalD,
	output wire[31:0] pcF,
	output wire[31:0] aluoutM,writedataMnew,
	input wire[31:0] readdataM,
	output wire memwriteM,
	input  wire hilo_writeD,	
	input wire jalD,jrD,balD,
	input wire memenD,
	output wire[3:0] sel,
	output wire memenM,
	input wire cp0toregD,
    input wire cp0weD,
    input wire invalidD,
    input wire syscallD,eretD,breakD,
	output wire [31:0] excepttypeM,
	output wire [31:0] excepttypeW,
	input wire[5:0] int,
	//debug  
	output wire [31:0] pcW,
	output wire regwriteW,
	output wire [4:0] writeregW,
	output wire [31:0] resultW,
	
	//AXI暂停
	input wire instrStall,
	input wire dataStall,
	output wire axi_stall
    );
    wire [31:0] pcpie;
	wire stallF;
	wire [31:0] pcplus4F;
	wire [31:0] pcbranchD;
	wire [31:0] pcplus4D;
	wire [31:0] rd1D;
	wire [31:0] rd2D;
	wire [31:0] newrd1D,newrd2D;
	wire [31:0] signimmD;
	wire [31:0] signimmD2;
	wire stallD;
	wire stallE;
	wire [4:0] rsE,rtE,rdE;
	wire regwriteE,memtoregE,alusrcE,regdstE;
	wire memwriteE;
	wire [7:0] alucontrolE;
	wire [31:0] rd1E,rd2E;
	wire [31:0] signimmE;
	wire [31:0] srcAE;
	wire [1:0] forwardaE,forwardbE;
	wire [31:0]writedataE;
	wire memtoregM,regwriteM;
	wire [4:0] writeregE,writeregM;
	wire [31:0] aluoutE;
	wire [31:0] srcBE;
	wire [31:0] aluoutW,readdataW;
	wire forwardaD,forwardbD;
	wire memtoregW;
	wire [31:0] pcnextbrFD;
	//逻辑指令补充
	wire [4:0] saD;
	wire [4:0] saE;
	//hilo补充	
	wire hilo_writeE;
	wire [63:0] hilo_outE;
	wire [63:0] hilo_inE;	
	wire hilo_writeM;
	wire [63:0] hilo_inM;
	//ALU算数
	wire overflow;
	//乘法
	wire [31:0]aluoutE_old; 
	wire [31:0] mult_a, mult_b;
	wire [63:0] mult_result;    
	wire [63:0] hilo_only_mtE;
	wire [63:0] hilo_only_mt_multE;
	//除法
	wire [63:0] div_result;
	reg start_divE,stall_divE,signed_divE;
	wire div_readyE;
	//分支
	wire jalE,balE;
	wire [31:0] pcplus8D;
	wire [31:0] pcplus8E;
	wire [31:0] pc_no_jD;
	//访存
	wire memenE;
	wire [7:0] alucontrolM;
	wire [4:0] writeregtempE;
	wire [31:0] writedataM;
	wire [31:0] readdataMnew;
	wire [31:0] resultM;
	wire [3:0] selM;
	//cp0
	wire [31:0] cp0status,cp0cause,cp0data_out,cp0compare,cp0count,cp0epc,cp0config,cp0prid;
	wire [31:0] badvaddr;
	wire cp0timer_int;
	//mfc0 mtc0
    wire cp0weE;
	wire cp0toregE;
	wire cp0weM;
	wire cp0toregM;
	wire [4:0] rdM;
    wire cp0toregW;
	wire [31:0] cp0data_outW;
	//异常	
	wire flushF;
	wire flushD;
	wire flushE;
	wire flushM;
	wire flushW;
	wire pc_not_duiqiF,pc_not_duiqiD,pc_not_duiqiE,pc_not_duiqiM;
	wire is_in_delayslotF;
	wire is_in_delayslotD;
	wire is_in_delayslotE;
	wire is_in_delayslotM;
	wire [31:0] pcD;	 		
	wire [31:0] pcE;	
	wire [31:0] pcM;
	wire invalidE,invalidM;
	wire overflowM;	
	wire load_buduiqi,save_buduiqi; 
	wire [31:0] bad_addrM;
	wire syscallE,syscallM;
    wire breakE,breakM;
    wire eretE,eretM;	
	wire [31:0] newpcM;
	wire stallM;
    wire stallW;	

	//**************************************************************************************
    //                                     取址IF阶段
    //**************************************************************************************
    
	//考虑branch的选择条件分支，要么是下一条指令，要么是branch的跳转地址
	mux2 #(32) muxbranch (.d0(pcplus4F), .d1(pcbranchD),.s(pcsrcD),.y(pcnextbrFD));
	//进一步考虑JR的选择条件分支，选择newrd1D为考虑数据前推后的数据
	mux2 #(32) muxjr (.d0(pcnextbrFD),.d1(newrd1D),.s(jrD),.y(pc_no_jD));
	//再进一步考虑jump的选择条件分支，跳转目标由该分支指令对应的延迟槽指令的 PC 的最高 4 位与立即数 instr_index 左移2 位后的值拼接得到
	mux2 #(32) muxjump_jal( .d0(pc_no_jD),.d1({pcplus4D[31:28],instrD[25:0],2'b00}),.s((jumpD | jalD) & (~jrD)),.y(pcpie) );
	//flush清除流水线，newPC为异常跳转地址，如果清除了流水线，说明遇到了某种异常，就直接跳到异常地址，否则为上述选择器选择之后的PC，最终结果为PCF
	PCmodule mypc(.clk(clk),.rst(rst),.en(~stallF),.pcin(pcpie),.pcout(pcF),.flush(flushF),.pcnew(newpcM));
	//加4得到下一条地址               
	adder pcadd1(.a(pcF),.b(32'b100),.y(pcplus4F));
	//PC地址对齐异常，非整字取指
	assign pc_not_duiqiF = (pcF[1:0] != 2'b00);
	//是否是延迟槽指令
	assign is_in_delayslotF = (jumpD|jrD|jalD|branchD);
	//流水线寄存器，把取址阶段的数据送到译码阶段
    flopenrc #(32) pcplusFD(.clk(clk),.rst(rst),.en(~stallD),.clear(flushD),.d(pcplus4F),.q(pcplus4D));
	flopenrc #(32) instrFD(.clk(clk),.rst(rst),.en(~stallD),.clear(flushD),.d(instrF),.q(instrD));
	flopenrc #(32) pcFD(.clk(clk),.rst(rst),.en(~stallD),.clear(flushD),.d(pcF),.q(pcD));
	flopenrc #(1) pc_not_duiqiFD(.clk(clk),.rst(rst),.en(~stallD),.clear(flushD),.d(pc_not_duiqiF),.q(pc_not_duiqiD));
	flopenrc #(1) is_in_delayslotFD(.clk(clk),.rst(rst),.en(~stallD),.clear(flushD),.d(is_in_delayslotF), .q(is_in_delayslotD) );
	
	//**************************************************************************************
    //                                     译码ID阶段
    //**************************************************************************************
		
	//寄存器堆，根据指令的信号从寄存器中取出第一个输出接口rd1和第二个输出接口rd2的值，resultW为回写阶段写回寄存器的地址，
	regfile regfiles(.clk(~clk),.we3(regwriteW),.ra1(instrD[25:21]),.ra2(instrD[20:16]),.wa3(writeregW),.wd3(resultW),
	                 .rd1(rd1D),.rd2(rd2D));      
	//mips指令中的立即数sa，用于指定某些移位指令(sll,sra,srl)的位移量
	assign saD = instrD[10:6];
	//立即数扩展,根据instrD[29:28]决定是有符号扩展还是无符号扩展，如果instrD[29:28]为11，则为无符号扩展，否则是有符号扩展
	signext immSigned(.a(instrD[15:0]),.type(instrD[29:28]),.y(signimmD));
	//立即数左移两位
	sl2 immSl2(.a(signimmD),.y(signimmD2));
	//加法器，由PC的值加上立即数扩展之后的转移目标得到转移地址
	adder pcaddvranch (.a(pcplus4D),.b(signimmD2),.y(pcbranchD));
	//延迟槽的下一条指令，al需要
	adder pcaddal (.a(pcplus4D),.b(32'h4),.y(pcplus8D));
	//提前分支预测数据前推,rd1D为寄存器第一个端口的数据，resultM为要前推的数据(从内存中读出来的数据或者从cp0读出来的数据或者访存阶段ALU计算结果)，前推到译码阶段
	mux2 #(32) forwardamux(.d0(rd1D),.d1(resultM),.s(forwardaD),.y(newrd1D));
	mux2 #(32) forwardbmux(.d0(rd2D),.d1(resultM),.s(forwardbD),.y(newrd2D));
    //分支比较模块，对beq,bne,bgez,bgtz,blez,bltz,bgezal,bltzal指令确定是否跳转，结果为equalD             
	compare comp(.a(newrd1D),.b(newrd2D ),.op(instrD[31:26]),.rt(instrD[20:16]),.y(equalD ));
     //流水线寄存器，把译码阶段的数据送到执行阶段
    flopenrc #(32) rd1DE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(rd1D),.q(rd1E));
	flopenrc #(32) rd2DE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(rd2D),.q(rd2E));
	flopenrc #(32) signimmDE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(signimmD),.q(signimmE));
	flopenrc #(5) rsDE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(instrD[25:21]),.q(rsE));
	flopenrc #(5) rtDE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(instrD[20:16]),.q(rtE));
	flopenrc #(5) rdDE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(instrD[15:11]),.q(rdE));
	flopenrc #(5) saDE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(saD),.q(saE));
	flopenrc #(32) pcplus8DE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(pcplus8D),.q(pcplus8E));
	flopenrc #(32) pcDE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(pcD),.q(pcE));
	flopenrc #(1) memwriteDE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(memwriteD),.q(memwriteE));
	flopenrc #(1) memenDE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(memenD),.q(memenE));	
	flopenrc #(1) hilo_writeDE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(hilo_writeD),.q(hilo_writeE));
	flopenrc #(1) cp0weDE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(cp0weD),.q(cp0weE));
	flopenrc #(1) cp0toregDE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(cp0toregD),.q(cp0toregE));
	flopenrc #(1) memtoregDE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(memtoregD),.q(memtoregE));
	flopenrc #(1) alusrcDE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(alusrcD),.q(alusrcE));
	flopenrc #(1) regdstDE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(regdstD),.q(regdstE));
	flopenrc #(1) regwriteDE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(regwriteD),.q(regwriteE));
	flopenrc #(1) jalDE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(jalD),.q(jalE));
	flopenrc #(1) balDE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(balD),.q(balE));
	flopenrc #(8) alucontrolDE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(alucontrolD),.q(alucontrolE));
    flopenrc #(1) pc_not_duiqiDE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(pc_not_duiqiD),.q(pc_not_duiqiE));
    flopenrc #(1) syscallDE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(syscallD),.q(syscallE));
    flopenrc #(1) breakDE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(breakD),.q(breakE));
    flopenrc #(1) eretDE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(eretD),.q(eretE));
    flopenrc #(1) invalidDE(.clk(clk),.rst(rst),.en(~stallE),.clear(flushE),.d(invalidD),.q(invalidE));
	flopenrc #(1) is_in_delayslotDE(.clk(clk),.rst(rst),.en(~stallM),.clear(flushE),.d(is_in_delayslotD),.q(is_in_delayslotE));
	                   
	//**************************************************************************************
    //                                     执行EX阶段
    //**************************************************************************************
	
    //访存阶段ALU数据或者回写阶段要写回寄存器堆的数据前推到执行阶段，用于给ALU计算的两个数
    mux3 #(32) forwardmuxAE(.d0(rd1E),.d1(resultW),.d2(aluoutM),.s(forwardaE),.y(srcAE));
	mux3 #(32) forwardmuxBE(.d0(rd2E),.d1(resultW),.d2(aluoutM),.s(forwardbE),.y(writedataE));
	//R-type或J-type指令，如果alusrcE为1，则为跳转指令，要么是立即数，要么是考虑了数据前推执行阶段将要运算的结果B
	mux2 #(32) muxRJ(.d0(writedataE),.d1(signimmE),.s(alusrcE),.y(srcBE));
	
    //除了乘除法的运算，ALU,mtc0复用输出aluoutE ，srcAE为要运算的第一个数，srcBE为要运算的第二个数，得到运算结果aluoutE_old和是否溢出结果overflow             
	alu myalu(.srcAE(srcAE),.srcBE(srcBE),.op(alucontrolE),.sa(saE),.aluout(aluoutE_old),.overflow(overflow));
	
	//乘法器                 
	assign mult_a = ((alucontrolE == `EXE_MULT_OP) && (srcAE[31] == 1'b1) ) ? (~srcAE + 1) : srcAE;
    assign mult_b = ((alucontrolE == `EXE_MULT_OP) && (srcBE[31] == 1'b1) ) ? (~srcBE + 1) : srcBE;                        
	assign mult_result = (alucontrolE == `EXE_MULTU_OP) ? srcAE * srcBE :
	                     ((alucontrolE == `EXE_MULT_OP)&&(srcAE[31] ^ srcBE[31] == 1'b1)) ? ~(mult_a * mult_b) + 1 :
	                     ((alucontrolE == `EXE_MULT_OP)&&(srcAE[31] ^ srcBE[31] != 1'b1)) ? mult_a * mult_b :
	                     64'b0; 
	                     
	//数据移动指令复用aluout的输出（HILOto寄存器）
	//AL指令复用aluout的输出
	//mfhi:将寄存器 rs 的值写入到 HI 寄存器中,mflo:将寄存器 rs 的值写入到 LO 寄存器中
	assign aluoutE = (alucontrolE == `EXE_MFHI_OP) ? hilo_outE[63:32] :
	                 (alucontrolE == `EXE_MFLO_OP) ? hilo_outE[31:0] :
	                 ((alucontrolE == `EXE_JAL_OP)||(alucontrolE == `EXE_JALR_OP)||//需要延迟槽的转移指令的输出为后两条指令
	                 (alucontrolE == `EXE_BGEZAL_OP)||(alucontrolE == `EXE_BLTZAL_OP)) ? pcplus8E :
	                 aluoutE_old;
	                
	//数据移动指令
	mux2 #(32) himuxmthi(.d0( hilo_outE[63:32]),.d1(srcAE),.s((alucontrolE == `EXE_MTHI_OP)),.y(hilo_only_mtE[63:32])); 
	mux2 #(32) lomuxmtlo(.d0( hilo_outE[31:0]), .d1(srcAE),.s((alucontrolE == `EXE_MTLO_OP)),.y(hilo_only_mtE[31:0]));
	//进一步加选择乘法器
	mux2 #(32) himuxmult(.d0(hilo_only_mtE[63:32]),.d1(mult_result[63:32]),.s(((alucontrolE == `EXE_MULTU_OP)|(alucontrolE == `EXE_MULT_OP))),.y(hilo_only_mt_multE[63:32])); 
	mux2 #(32) lomuxmult(.d0(hilo_only_mtE[31:0]),.d1(mult_result[31:0]),.s(((alucontrolE == `EXE_MULTU_OP)|(alucontrolE == `EXE_MULT_OP))),.y(hilo_only_mt_multE[31:0]));                        
	//再进一步加选择除法器，得到最终的要写入hilo寄存器的内容
	mux2 #(32) himuxdiv(.d0(hilo_only_mt_multE[63:32]),.d1(div_result[63:32]),.s(((alucontrolE == `EXE_DIVU_OP)|(alucontrolE == `EXE_DIV_OP))),.y(hilo_inE[63:32])); 
	mux2 #(32) lomuxdiv(.d0(hilo_only_mt_multE[31:0]),.d1(div_result[31:0]),.s(((alucontrolE == `EXE_DIVU_OP)|(alucontrolE == `EXE_DIV_OP))),.y(hilo_inE[31:0]));
	//除法状态机                             
    always @(*)begin
        if(rst == 1'b1)begin
                start_divE <= 1'b0;
                signed_divE <= 1'b0;
                stall_divE <= 1'b0;
        end else begin
            if(alucontrolE==`EXE_DIV_OP)begin
                if(div_readyE==1'b0)begin
                    start_divE <= 1'b1;
                    signed_divE <= 1'b1;
                    stall_divE <= 1'b1;
                end else if(div_readyE==1'b1)begin
                    start_divE <= 1'b0;
                    signed_divE <= 1'b1;
                    stall_divE <= 1'b0;
                end else begin
                    start_divE <= 1'b0;
                    signed_divE <= 1'b0;
                    stall_divE <= 1'b0;
                end
            end else if(alucontrolE==`EXE_DIVU_OP)begin
                if(div_readyE==1'b0)begin
                    start_divE <= 1'b1;
                    signed_divE <= 1'b0;
                    stall_divE <= 1'b1;
                end else if(div_readyE==1'b1)begin
                    start_divE <= 1'b0;
                    signed_divE <= 1'b0;
                    stall_divE <= 1'b0;
                end else begin
                    start_divE <= 1'b0;
                    signed_divE <= 1'b0;
                    stall_divE <= 1'b0;
                end            
            end else begin
                start_divE <= 1'b0;
                signed_divE <= 1'b0;
                stall_divE <= 1'b0;
            end
        end
    end
    //除法模块，采用项目提供的模块 
    div my_div(
	.clk(clk),
	.rst(rst),
	.signed_div_i(signed_divE),
	.opdata1_i(srcAE),
	.opdata2_i(srcBE),
	.start_i(start_divE),
	.annul_i(1'b0),
	.result_o(div_result),
	.ready_o(div_readyE)
    );
	                            
    //判断写回地址  jalr的regdst=1 jal=0 复用datapath                
	mux2 #(5)  muxAddr(.d0(rtE),.d1(rdE),.s(regdstE),.y(writeregtempE));	
	mux2 #(5)  muxAl(.d0(writeregtempE),.d1(5'b11111),.s(jalE | balE),.y(writeregE));
    //流水线寄存器，把执行阶段的数据送到访存阶段
    flopenrc #(32) writedataEM(.clk(clk),.rst(rst),.en(~stallM),.clear(flushM),.d(writedataE),.q(writedataM));
	flopenrc #(32) aluoutEM(.clk(clk),.rst(rst),.en(~stallM),.clear(flushM),.d(aluoutE),.q(aluoutM));
	flopenrc #(5) writeregEM(.clk(clk),.rst(rst),.en(~stallM),.clear(flushM),.d(writeregE),.q(writeregM));
	flopenrc #(32) pcEM(.clk(clk),.rst(rst),.en(~stallM),.clear(flushM),.d(pcE),.q(pcM));
	flopenrc #(5) rdEM(.clk(clk),.rst(rst),.en(~stallM),.clear(flushM),.d(rdE),.q(rdM));	
	flopenrc #(1) hilo_writeEM(.clk(clk),.rst(rst),.en(~stallM),.clear(flushM),.d(hilo_writeE),.q(hilo_writeM));
	flopenrc #(64) hilo_inEM(.clk(clk),.rst(rst),.en(~stallM),.clear(flushM),.d(hilo_inE),.q(hilo_inM));
	flopenrc #(1) overflowEM(.clk(clk),.rst(rst),.en(~stallM),.clear(flushM),.d(overflow),.q(overflowM));
	flopenrc #(1) pc_not_duiqiEM(.clk(clk),.rst(rst),.en(~stallM),.clear(flushM),.d(pc_not_duiqiE),.q(pc_not_duiqiM));
    flopenrc #(1) syscallEM(.clk(clk),.rst(rst),.en(~stallM),.clear(flushM),.d(syscallE),.q(syscallM));
    flopenrc #(1) breakEM(.clk(clk),.rst(rst),.en(~stallM),.clear(flushM),.d(breakE),.q(breakM));
    flopenrc #(1) eretEM(.clk(clk),.rst(rst),.en(~stallM),.clear(flushM),.d(eretE),.q(eretM));
    flopenrc #(1) invalidEM(.clk(clk),.rst(rst),.en(~stallM),.clear(flushM),.d(invalidE),.q(invalidM));
	flopenrc #(1) is_in_delayslotEM(.clk(clk),.rst(rst),.en(~stallM),.clear(flushM),.d(is_in_delayslotE),.q(is_in_delayslotM));
	flopenrc #(1) memwriteEM(.clk(clk),.rst(rst),.en(~stallM),.clear(flushM),.d(memwriteE),.q(memwriteM));
	flopenrc #(1) memenEM(.clk(clk),.rst(rst),.en(~stallM),.clear(flushM),.d(memenE),.q(memenM));
	flopenrc #(1) cp0weEM(.clk(clk),.rst(rst),.en(~stallM),.clear(flushM),.d(cp0weE),.q(cp0weM));
	flopenrc #(1) cp0toregEM(.clk(clk),.rst(rst),.en(~stallM),.clear(flushM),.d(cp0toregE),.q(cp0toregM));
	flopenrc #(1) memtoregEM(.clk(clk),.rst(rst),.en(~stallM),.clear(flushM),.d(memtoregE),.q(memtoregM));
	flopenrc #(1) regwriteEM(.clk(clk),.rst(rst),.en(~stallM),.clear(flushM),.d(regwriteE),.q(regwriteM));
	flopenrc #(8) alucontrolEM(.clk(clk),.rst(rst),.en(~stallM),.clear(flushM),.d(alucontrolE),.q(alucontrolM));
	
	//**************************************************************************************
    //                                     访存MEM阶段
    //**************************************************************************************
    
    //HILO在访存阶段写回,如果写回信号为1而且没有异常，则写入
    hilo_reg hilo(.clk(clk),.rst(rst),.we(hilo_writeM && (excepttypeW == 32'h0)),
	                .hi(hilo_inM[63:32]),.lo(hilo_inM[31:0]), 
	                .hi_o(hilo_outE[63:32]),.lo_o(hilo_outE[31:0]));
	
	//存数修正，四位能端	
	assign selM = ((alucontrolM==`EXE_SW_OP)&&(aluoutM[1:0] == 2'b00)) ? 4'b1111 :
	              ((alucontrolM==`EXE_SH_OP)&&(aluoutM[1:0] == 2'b10)) ? 4'b1100 :
	              ((alucontrolM==`EXE_SH_OP)&&(aluoutM[1:0] == 2'b00)) ? 4'b0011 :
	              ((alucontrolM==`EXE_SB_OP)&&(aluoutM[1:0] == 2'b00)) ? 4'b0001 :
	              ((alucontrolM==`EXE_SB_OP)&&(aluoutM[1:0] == 2'b01)) ? 4'b0010 :
	              ((alucontrolM==`EXE_SB_OP)&&(aluoutM[1:0] == 2'b10)) ? 4'b0100 :
	              ((alucontrolM==`EXE_SB_OP)&&(aluoutM[1:0] == 2'b11)) ? 4'b1000 :	               
	              4'b0000; 
	
	assign writedataMnew = (alucontrolM==`EXE_SW_OP) ? writedataM :
	                       (alucontrolM==`EXE_SH_OP) ? {writedataM[15:0],writedataM[15:0]} :
	                       (alucontrolM==`EXE_SB_OP) ? {writedataM[7:0],writedataM[7:0],writedataM[7:0],writedataM[7:0]}:
	                       writedataM;           
	                       
	//读数修正，从内存中取出来的值	
	assign readdataMnew = (alucontrolM==`EXE_LW_OP) ? readdataM :
	                      ((alucontrolM==`EXE_LH_OP)&&(aluoutM[1:0] == 2'b00))?{{16{readdataM[15]}},readdataM[15:0]}:
	                      ((alucontrolM==`EXE_LH_OP)&&(aluoutM[1:0] == 2'b10))?{{16{readdataM[31]}},readdataM[31:16]}:
	                      ((alucontrolM==`EXE_LHU_OP)&&(aluoutM[1:0] == 2'b00))?{16'b0,readdataM[15:0]}:
	                      ((alucontrolM==`EXE_LHU_OP)&&(aluoutM[1:0] == 2'b10))?{16'b0,readdataM[31:16]}:
	                      ((alucontrolM==`EXE_LB_OP)&&(aluoutM[1:0] == 2'b00))?{{24{readdataM[7]}},readdataM[7 :0]}:
	                      ((alucontrolM==`EXE_LB_OP)&&(aluoutM[1:0] == 2'b01))?{{24{readdataM[15]}},readdataM[15:8]}:
	                      ((alucontrolM==`EXE_LB_OP)&&(aluoutM[1:0] == 2'b10))?{{24{readdataM[23]}},readdataM[23:16]}:
	                      ((alucontrolM==`EXE_LB_OP)&&(aluoutM[1:0] == 2'b11))?{{24{readdataM[31]}},readdataM[31:24]}:
	                      ((alucontrolM==`EXE_LBU_OP)&&(aluoutM[1:0] == 2'b00))?{24'b0,readdataM[7 :0]}:
	                      ((alucontrolM==`EXE_LBU_OP)&&(aluoutM[1:0] == 2'b01))?{24'b0,readdataM[15:8]}:
	                      ((alucontrolM==`EXE_LBU_OP)&&(aluoutM[1:0] == 2'b10))?{24'b0,readdataM[23:16]}:
	                      ((alucontrolM==`EXE_LBU_OP)&&(aluoutM[1:0] == 2'b11))?{24'b0,readdataM[31:24]}:
	                      readdataM;
	                       
	//地址不对齐异常
	//存数异常               
	assign save_buduiqi = ((alucontrolM==`EXE_SW_OP)&&(aluoutM[1:0] != 2'b00)) ? 1'b1 : 
	               ((alucontrolM==`EXE_SH_OP)&&(aluoutM[1:0] != 2'b00)&&(aluoutM[1:0] != 2'b10)) ? 1'b1:
	               1'b0;
	//取数异常
	assign load_buduiqi = ((alucontrolM==`EXE_LW_OP)&&(aluoutM[1:0] != 2'b00)) ? 1'b1 : 
	               ((alucontrolM==`EXE_LH_OP)&&(aluoutM[1:0] != 2'b00)&&(aluoutM[1:0] != 2'b10)) ? 1'b1:
	               ((alucontrolM==`EXE_LHU_OP)&&(aluoutM[1:0] != 2'b00)&&(aluoutM[1:0] != 2'b10)) ? 1'b1:
	               1'b0;	
	               
	//记录地址相关错误的发生地址，数据存储器访存地址异常时为aluoutM，指令存储器异常为pc                                              
    assign bad_addrM = (load_buduiqi == 1'b1 || save_buduiqi == 1'b1) ? aluoutM : pcM; //previous: pc - 8
	           
	//发生异常时不读数据                   
	assign sel = (excepttypeM == 32'h0) ? selM : 4'b0000;
	
	//生成异常类型
	//cp0cause[15:8]的位为1表示产生中断，cp0status[15:8]的位为0表示屏蔽某位对应的中断
	//cp0status[1]为1为核心态，屏蔽中断
	//cp0status[0]为0为中断屏蔽态，屏蔽中断      
	assign excepttypeM = (((cp0cause[15:8] & cp0status[15:8]) != 8'h00) && (cp0status[1] == 1'b0) && (cp0status[0] == 1'b1)) ? 32'h00000001:
	                     (pc_not_duiqiM == 1'b1 || load_buduiqi) ? 32'h00000004 :
	                     save_buduiqi ? 32'h00000005 :
	                     syscallM ? 32'h00000008 :
	                     breakM ? 32'h00000009 :
	                     eretM ?  32'h0000000e :
	                     invalidM ? 32'h0000000a :
	                     overflowM ? 32'h0000000c :
	                     32'b0;
		                    
	cp0_reg  mycp0(.clk(clk),
		         .rst(rst),
		         .we_i(cp0weM),//是否写寄存器
		         .waddr_i(rdM),//rd寄存器为写的地址（mtc0）
		         .raddr_i(rdM),//rd寄存器为读的地址（mfc0）
		         .data_i(aluoutM),//rt的数据  alu输出srcBE，复用，解决冒险
		         .int_i(int),//6个外部硬件中断
		         .excepttype_i(excepttypeM),//异常标识
		         .current_inst_addr_i(pcM),//指令的PC
		         .is_in_delayslot_i(is_in_delayslotM),//是否在延迟槽中
     	         .bad_addr_i (bad_addrM),//存储器出错地址
	             //寄存器输出
		         .data_o(cp0data_out),//mfc0读出的值，存入rt
		         .status_o(cp0status),
		         .cause_o(cp0cause),
		         .epc_o(cp0epc),
		         //以下输出暂时用不到 
		         .count_o(cp0count),
		         .compare_o(cp0compare),		                      
		         .config_o(cp0config),
		         .prid_o(cp0prid),  
		         .badvaddr(badvaddr),
		         .timer_int_o(cp0timer_int));//定时中断
	
	//异常跳转地址，直接写入PC
	assign newpcM = (excepttypeM == 32'h00000001)? 32'hBFC00380: 
	                (excepttypeM == 32'h00000004)? 32'hBFC00380:
	                (excepttypeM == 32'h00000005)? 32'hBFC00380:
	                (excepttypeM == 32'h00000008)? 32'hBFC00380:
	                (excepttypeM == 32'h00000009)? 32'hBFC00380:
	                (excepttypeM == 32'h0000000a)? 32'hBFC00380:
	                (excepttypeM == 32'h0000000c)? 32'hBFC00380:
	                (excepttypeM == 32'h0000000d)? 32'hBFC00380:
	                (excepttypeM == 32'h0000000e)? cp0epc :        //eret使用cp0的epc的输出
	                32'hBFC00380;
			           
    //数据前推
	assign resultM = (memtoregM==1'b1) ? readdataMnew:
					 (cp0toregM==1'b1) ? cp0data_out : 
					 aluoutM;
    
    flopenrc #(32) aluoutMW(.clk(clk),.rst(rst),.en(~stallW),.clear(flushW),.d(aluoutM),.q(aluoutW));
	flopenrc #(32) readdataMW(.clk(clk),.rst(rst),.en(~stallW),.clear(flushW),.d(readdataMnew),.q(readdataW));
	flopenrc #(5) writeregMW(.clk(clk),.rst(rst),.en(~stallW),.clear(flushW),.d(writeregM),.q(writeregW) );
	flopenrc #(32) pcMW(.clk(clk),.rst(rst),.en(~stallW),.clear(flushW),.d(pcM),.q(pcW));
    flopenrc #(1) cp0toregMW(.clk(clk),.rst(rst),.en(~stallW),.clear(flushW),.d(cp0toregM),.q(cp0toregW));
	flopenrc #(32) cp0data_outMW(.clk(clk),.rst(rst),.en(~stallW),.clear(flushW),.d(cp0data_out),.q(cp0data_outW));
	flopenrc #(32) excepttypeMW(.clk(clk),.rst(rst),.en(~stallW),.clear(flushW),.d(excepttypeM),.q(excepttypeW));
	flopenrc #(1) memtoregMW(.clk(clk),.rst(rst),.en(~stallW),.clear(flushW),.d(memtoregM),.q(memtoregW));
	flopenrc #(1) regwriteMW(.clk(clk),.rst(rst),.en(~stallW),.clear(flushW),.d(regwriteM),.q(regwriteW));	
	//**************************************************************************************
    //                                     回写WB阶段
    //**************************************************************************************
    
    //选择写回寄存器的数据，是从内存中读出来的还是从cp0读出来的还是alu的计算结果
	assign resultW = (memtoregW==1'b1) ? readdataW:
					 (cp0toregW==1'b1) ? cp0data_outW : 
					 aluoutW;
	//冒险模块				 	                   
	hazard myharzard(
		.stallF(stallF),
		.rsD(instrD[25:21]),
		.rtD(instrD[20:16]),
		.branchD(branchD),
		.forwardaD(forwardaD), 
		.forwardbD(forwardbD),
		.stallD(stallD),
		.rsE(rsE), 
		.rtE(rtE),
		.writeregE(writeregE),
		.regwriteE(regwriteE),
		.memtoregE(memtoregE),
		.forwardaE(forwardaE),
		.forwardbE(forwardbE),
		.flushE(flushE),
		.writeregM(writeregM),
		.regwriteM(regwriteM),
		.memtoregM(memtoregM),
		.writeregW(writeregW),
		.regwriteW(regwriteW),
		.jumpD(jumpD),
		.div_stallE(stall_divE),//除法器暂停
		.stallE(stallE),	
		.jalD(jalD), 
		.jrD(jrD),
	    //cp0数据前推
	    .cp0toregE(cp0toregE),
	    //异常控制
		.excepttypeM(excepttypeM),	
        .flushF(flushF),
		.flushD(flushD),
        .flushM(flushM),
        .flushW(flushW),
        .stallM(stallM),
        .stallW(stallW),		
		.instrStall(instrStall),
		.dataStall(dataStall),
		.axi_stall(axi_stall)
		);                   
endmodule