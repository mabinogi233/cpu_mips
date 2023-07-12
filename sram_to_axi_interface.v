`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/05 22:56:52
// Design Name: 
// Module Name: sram_to_axi_interface
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
module sram_to_axi_interface(
    input wire clk,
    input wire resetn,
    output wire stallreq_from_if,
    output wire stallreq_from_mem,
    input wire flush,
    input wire axi_stall,
    //CPU sram�ź�
    input wire inst_sram_en,
    input wire[3:0] inst_sram_wen,
    input wire[31:0] inst_sram_addr,
    output wire[31:0] inst_sram_rdata,
    input wire[31:0] inst_sram_wdata,
    //CPU sram�ź�
    input wire data_sram_en,   
    input wire[3:0] data_sram_wen,
    input wire[31:0] data_sram_addr,
    output wire[31:0] data_sram_rdata,
    input wire[31:0] data_sram_wdata,  
    //axi port
    output wire[3:0] arid,     
    output wire[31:0] araddr, 
    output wire[3:0] arlen,    
    output wire[2:0] arsize,   
    output wire[1:0] arburst,  
    output wire[1:0] arlock,    
    output wire[3:0] arcache,  
    output wire[2:0] arprot,   
    output wire arvalid, 
    input wire arready,  
           
    input wire[3:0] rid, 
    input wire[31:0] rdata,
    input wire[1:0] rresp, 
    input wire rlast, 
    input wire rvalid,
    output wire rready, 
      
    output wire[3:0] awid,    
    output wire[31:0] awaddr, 
    output wire[3:0] awlen,  
    output wire[2:0] awsize,  
    output wire[1:0] awburst, 
    output wire[1:0] awlock,  
    output wire[3:0] awcache,
    output wire[2:0] awprot,
    output wire awvalid,     
    input wire awready,     
     
    output wire[3:0] wid,   
    output wire[31:0] wdata,   
    output wire[3:0] wstrb,    
    output wire wlast,       
    output wire wvalid,         
    input wire wready,          
             
    input  wire[3:0] bid, 
    input  wire[1:0] bresp,  
    input wire bvalid,  
    output wire bready  
    );
    //ʹ��cache��
    
    //ʹ��cache��ɾ����ע�ͣ���ע�͵���ʹ��cache�汾
//    sram_axi_interface_cache interface_1(
//        .clk(clk),
//        .resetn(resetn),
//        .inst_sram_en(inst_sram_en),
//        .inst_sram_wen(inst_sram_wen),
//        .inst_sram_addr(inst_sram_addr),
//        .inst_sram_rdata(inst_sram_rdata),
//        .inst_sram_wdata(inst_sram_wdata),

//        .data_sram_en(data_sram_en),
//        .data_sram_wen(data_sram_wen),
//        .data_sram_addr(data_sram_addr),
//        .data_sram_rdata(data_sram_rdata),
//        .data_sram_wdata(data_sram_wdata),   
    
//        .stallreq_from_if(stallreq_from_if),
//        .stallreq_from_mem(stallreq_from_mem),

//        .flush(flush),
//        .axi_stall(axi_stall),
             
//        .arid(arid),
//        .araddr(araddr),
//        .arlen(arlen),
//        .arsize(arsize),
//        .arburst(arburst),
//        .arlock(arlock),
//        .arcache(arcache),
//        .arprot(arprot),
//        .arvalid(arvalid),
//        .arready(arready),
                    
//        .rid(rid),
//        .rdata(rdata),
//        .rresp(rresp),
//        .rlast(rlast),
//        .rvalid(rvalid),
//        .rready(rready),
                
//        .awid(awid),
//        .awaddr(awaddr),
//        .awlen(awlen),
//        .awsize(awsize),
//        .awburst(awburst),
//        .awlock(awlock),
//        .awcache(awcache),
//        .awprot(awprot),
//        .awvalid(awvalid),
//        .awready(awready),
        
//        .wid(wid),
//        .wdata(wdata),
//        .wstrb(wstrb),
//        .wlast(wlast),
//        .wvalid(wvalid),
//        .wready(wready),
        
//        .bid(bid),
//        .bresp(bresp),
//        .bvalid(bvalid),
//        .bready(bready)
//    );
   
   
   
   //������cache�汾
   sram_axi_interface_nocache interface(
        .clk(clk),
        .resetn(resetn),
        
        .inst_sram_en(inst_sram_en),
        .inst_sram_wen(inst_sram_wen),
        .inst_sram_addr(inst_sram_addr),
        .inst_sram_rdata(inst_sram_rdata),
        .inst_sram_wdata(inst_sram_wdata),

        .data_sram_en(data_sram_en),
        .data_sram_wen(data_sram_wen),
        .data_sram_addr(data_sram_addr),
        .data_sram_rdata(data_sram_rdata),
        .data_sram_wdata(data_sram_wdata),   
    
        .stallreq_from_if(stallreq_from_if),
        .stallreq_from_mem(stallreq_from_mem),

        .flush(flush),
             
        .arid(arid),
        .araddr(araddr),
        .arlen(arlen),
        .arsize(arsize),
        .arburst(arburst),
        .arlock(arlock),
        .arcache(arcache),
        .arprot(arprot),
        .arvalid(arvalid),
        .arready(arready),
                    
        .rid(rid),
        .rdata(rdata),
        .rresp(rresp),
        .rlast(rlast),
        .rvalid(rvalid),
        .rready(rready),
                
        .awid(awid),
        .awaddr(awaddr),
        .awlen(awlen),
        .awsize(awsize),
        .awburst(awburst),
        .awlock(awlock),
        .awcache(awcache),
        .awprot(awprot),
        .awvalid(awvalid),
        .awready(awready),
        
        .wid(wid),
        .wdata(wdata),
        .wstrb(wstrb),
        .wlast(wlast),
        .wvalid(wvalid),
        .wready(wready),
        
        .bid(bid),
        .bresp(bresp),
        .bvalid(bvalid),
        .bready(bready)
    );
    
endmodule






//�ο���ϵ�ṹLAB_2
module sram_axi_interface_cache(
    input wire clk,
    input wire resetn,
    output wire stallreq_from_if,
    output wire stallreq_from_mem,
    input wire flush,
    input wire axi_stall,
    //CPU sram�ź�
    input wire inst_sram_en,
    input wire[3:0] inst_sram_wen,
    input wire[31:0] inst_sram_addr,
    output wire[31:0] inst_sram_rdata,
    input wire[31:0] inst_sram_wdata,
    //CPU sram�ź�
    input wire data_sram_en,   
    input wire[3:0] data_sram_wen,
    input wire[31:0] data_sram_addr,
    output wire[31:0] data_sram_rdata,
    input wire[31:0] data_sram_wdata,  
    //axi port
    output wire[3:0] arid,     
    output wire[31:0] araddr, 
    output wire[3:0] arlen,    
    output wire[2:0] arsize,   
    output wire[1:0] arburst,  
    output wire[1:0] arlock,    
    output wire[3:0] arcache,  
    output wire[2:0] arprot,   
    output wire arvalid, 
    input wire arready,  
           
    input wire[3:0] rid, 
    input wire[31:0] rdata,
    input wire[1:0] rresp, 
    input wire rlast, 
    input wire rvalid,
    output wire rready, 
      
    output wire[3:0] awid,    
    output wire[31:0] awaddr, 
    output wire[3:0] awlen,  
    output wire[2:0] awsize,  
    output wire[1:0] awburst, 
    output wire[1:0] awlock,  
    output wire[3:0] awcache,
    output wire[2:0] awprot,
    output wire awvalid,     
    input wire awready,     
     
    output wire[3:0] wid,   
    output wire[31:0] wdata,   
    output wire[3:0] wstrb,    
    output wire wlast,       
    output wire wvalid,         
    input wire wready,          
             
    input  wire[3:0] bid, 
    input  wire[1:0] bresp,  
    input wire bvalid,  
    output wire bready  
    );       
    wire cpu_inst_req;
    wire cpu_inst_wr;
    wire [1:0]cpu_inst_size;
    wire [31:0] cpu_inst_addr;
    wire [31:0] cpu_inst_wdata;
    wire [31:0] cpu_inst_rdata;
    wire cpu_inst_addr_ok;
    wire cpu_inst_data_ok;
        
    wire cache_inst_req;
    wire cache_inst_wr;
    wire [1:0]cache_inst_size;
    wire [31:0]cache_inst_addr;
    wire [31:0]cache_inst_wdata;
    wire [31:0]cache_inst_rdata;
    wire cache_inst_addr_ok;
    wire cache_inst_data_ok;
        
    wire cpu_data_req;
    wire cpu_data_wr;
    wire [1:0]cpu_data_size;
    wire [31:0]cpu_data_addr;
    wire [31:0]cpu_data_wdata;
    wire [31:0]cpu_data_rdata;
    wire cpu_data_addr_ok;
    wire cpu_data_data_ok;
        
    wire cache_data_req;
    wire cache_data_wr;
    wire [1:0]cache_data_size;
    wire [31:0]cache_data_addr;
    wire [31:0]cache_data_wdata;
    wire [31:0]cache_data_rdata;
    wire cache_data_addr_ok;
    wire cache_data_data_ok;
        
    //�����ַӳ�� 
    wire [31:0]data_sram_vaddr;
    assign data_sram_vaddr = (data_sram_addr[31:16] != 16'hbfaf) ? data_sram_addr : {16'h1faf,data_sram_addr[15:0]};
    //cpu�쳣������ηô�����
    wire [31:0] data_sram_vrdata;
    wire [31:0] inst_sram_vrdata;      
    assign data_sram_rdata = flush ? 32'b0 : data_sram_vrdata;
    assign inst_sram_rdata = flush ? 32'b0 : inst_sram_vrdata;
        
    //cpu����sram ��sramת��
    data_sram_to_sram_like datalike(
        .clk(clk),
        .rst(~resetn),
        .cpu_stall(axi_stall),   
        .cpu_data_stall(stallreq_from_mem),
        //cpu��sram 
        .cpu_data_en(data_sram_en),
        .cpu_data_wen(data_sram_wen),
        .cpu_data_addr(data_sram_vaddr),
        .cpu_data_wdata(data_sram_wdata),
        .cpu_data_rdata(data_sram_vrdata),       
        //cpu��sram      
        .data_req(cpu_data_req),
        .data_wr(cpu_data_wr),
        .data_size(cpu_data_size),
        .data_addr(cpu_data_addr),
        .data_wdata(cpu_data_wdata),
        .data_rdata(cpu_data_rdata),
        .data_addr_ok(cpu_data_addr_ok),
        .data_data_ok(cpu_data_data_ok)               
        );  
  
    //cpuָ��sram ��sramת��    
    inst_sram_to_sram_like instlike(
        .clk(clk),
        .rst(~resetn),
        .cpu_stall(axi_stall),    
        .cpu_inst_stall(stallreq_from_if),
        //CPU sram
        .cpu_inst_en(inst_sram_en),
        .cpu_inst_wen(inst_sram_wen),
        .cpu_inst_addr(inst_sram_addr),
        .cpu_inst_wdata(inst_sram_wdata),
        .cpu_inst_rdata(inst_sram_vrdata),       
        //cpu��sram    
        .inst_req(cpu_inst_req),
        .inst_wr(cpu_inst_wr),
        .inst_size(cpu_inst_size),
        .inst_addr(cpu_inst_addr),
        .inst_wdata(cpu_inst_wdata),
        .inst_rdata(cpu_inst_rdata),
        .inst_addr_ok(cpu_inst_addr_ok),
        .inst_data_ok(cpu_inst_data_ok)              
    );
        
    //����cache          
    d_cache data_cache(
        .clk(clk),
        .rst(~resetn),
        //����cpu����sram    
        .cpu_data_req(cpu_data_req),
        .cpu_data_wr(cpu_data_wr),
        .cpu_data_size(cpu_data_size),
        .cpu_data_addr(cpu_data_addr),
        .cpu_data_wdata(cpu_data_wdata),
        .cpu_data_rdata(cpu_data_rdata),
        .cpu_data_addr_ok(cpu_data_addr_ok),
        .cpu_data_data_ok(cpu_data_data_ok),
        //������о����sram to axi 
        .cache_data_req(cache_data_req),
        .cache_data_wr(cache_data_wr),
        .cache_data_size(cache_data_size),
        .cache_data_addr(cache_data_addr),
        .cache_data_wdata(cache_data_wdata),
        .cache_data_rdata(cache_data_rdata),
        .cache_data_addr_ok(cache_data_addr_ok),
        .cache_data_data_ok(cache_data_data_ok)
    );
        
    //ָ��cache    
    i_cache inst_cache(
        .clk(clk),
        .rst(~resetn),
        //����cpu����sram
        .cpu_inst_req(cpu_inst_req),
        .cpu_inst_wr(cpu_inst_wr),
        .cpu_inst_size(cpu_inst_size),
        .cpu_inst_addr(cpu_inst_addr),
        .cpu_inst_wdata(cpu_inst_wdata),
        .cpu_inst_rdata(cpu_inst_rdata),
        .cpu_inst_addr_ok(cpu_inst_addr_ok),
        .cpu_inst_data_ok(cpu_inst_data_ok),
        //������о����sram to axi  
        .cache_inst_req(cache_inst_req),
        .cache_inst_wr(cache_inst_wr),
        .cache_inst_size(cache_inst_size),
        .cache_inst_addr(cache_inst_addr),
        .cache_inst_wdata(cache_inst_wdata),
        .cache_inst_rdata(cache_inst_rdata),
        .cache_inst_addr_ok(cache_inst_addr_ok),
        .cache_inst_data_ok(cache_inst_data_ok)
    );
    
    //cacheʹ����о����
    cpu_axi_interface cpu_axis(
        .clk(clk),
        .resetn(resetn), 
        //��sram�ź�
        .inst_req(cache_inst_req),
        .inst_wr(cache_inst_wr),
        .inst_size(cache_inst_size),
        .inst_addr(cache_inst_addr),
        .inst_wdata(cache_inst_wdata),
        .inst_rdata(cache_inst_rdata),
        .inst_addr_ok(cache_inst_addr_ok),
        .inst_data_ok(cache_inst_data_ok),
 
        .data_req(cache_data_req),
        .data_wr(cache_data_wr),
        .data_size(cache_data_size),
        .data_addr(cache_data_addr),
        .data_wdata(cache_data_wdata),
        .data_rdata(cache_data_rdata),
        .data_addr_ok(cache_data_addr_ok),
        .data_data_ok(cache_data_data_ok),
        //AXI�ź�
        .arid(arid),
        .araddr(araddr),
        .arlen(arlen),
        .arsize(arsize),
        .arburst(arburst),
        .arlock(arlock),
        .arcache(arcache),
        .arprot(arprot),
        .arvalid(arvalid),
        .arready(arready),
                    
        .rid(rid),
        .rdata(rdata),
        .rresp(rresp),
        .rlast(rlast),
        .rvalid(rvalid),
        .rready(rready),
                
        .awid(awid),
        .awaddr(awaddr),
        .awlen(awlen),
        .awsize(awsize),
        .awburst(awburst),
        .awlock(awlock),
        .awcache(awcache),
        .awprot(awprot),
        .awvalid(awvalid),
        .awready(awready),
        
        .wid(wid),
        .wdata(wdata),
        .wstrb(wstrb),
        .wlast(wlast),
        .wvalid(wvalid),
        .wready(wready),
        
        .bid(bid),
        .bresp(bresp),
        .bvalid(bvalid),
        .bready(bready)
    );    
        
endmodule

//���ģ��ο���ѧ����axi_interface �� Ӳ���ۺ���ƽ���2
module sram_axi_interface_nocache(
    input wire clk,
    input wire resetn,
    output wire stallreq_from_if,
    output wire stallreq_from_mem,
    input wire flush,
    //CPU sram�ź�
    input wire inst_sram_en,
    input wire[3:0] inst_sram_wen,
    input wire[31:0] inst_sram_addr,
    output wire[31:0] inst_sram_rdata,
    input wire[31:0] inst_sram_wdata,
    //CPU sram�ź�
    input wire data_sram_en,   
    input wire[3:0] data_sram_wen,
    input wire[31:0] data_sram_addr,
    output wire[31:0] data_sram_rdata,
    input wire[31:0] data_sram_wdata,  
    //axi port
    output wire[3:0] arid,     
    output wire[31:0] araddr, 
    output wire[3:0] arlen,    
    output wire[2:0] arsize,   
    output wire[1:0] arburst,  
    output wire[1:0] arlock,    
    output wire[3:0] arcache,  
    output wire[2:0] arprot,   
    output wire arvalid, 
    input wire arready,  
           
    input wire[3:0] rid, 
    input wire[31:0] rdata,
    input wire[1:0] rresp, 
    input wire rlast, 
    input wire rvalid,
    output wire rready, 
      
    output wire[3:0] awid,    
    output wire[31:0] awaddr, 
    output wire[3:0] awlen,  
    output wire[2:0] awsize,  
    output wire[1:0] awburst, 
    output wire[1:0] awlock,  
    output wire[3:0] awcache,
    output wire[2:0] awprot,
    output wire awvalid,     
    input wire awready,     
     
    output wire[3:0] wid,   
    output wire[31:0] wdata,   
    output wire[3:0] wstrb,    
    output wire wlast,       
    output wire wvalid,         
    input wire wready,          
             
    input  wire[3:0] bid, 
    input  wire[1:0] bresp,  
    input wire bvalid,  
    output wire bready  
    );
    
    wire data_sram_write;
    wire[1:0] data_sram_size;
    assign data_sram_write = data_sram_wen[0] || data_sram_wen[1] || data_sram_wen[2] || data_sram_wen[3];
    assign data_sram_size  = (data_sram_wen == 4'b0000 || data_sram_wen == 4'b1111) ? 2'b10:
                             (data_sram_wen == 4'b0011 || data_sram_wen == 4'b1100) ? 2'b01:
                             (data_sram_wen == 4'b0001 || data_sram_wen == 4'b0010 || data_sram_wen == 4'b0100 || data_sram_wen == 4'b1000) ? 2'b00:
                             2'b00;
                              
    //AXI
    wire cache_miss,sel_i;
    wire[31:0] i_addr,d_addr,m_addr;
    wire m_fetch,m_ld_st,mem_access;
    wire mem_write,m_st;
    wire mem_ready,m_i_ready,m_d_ready,i_ready,d_ready;
    wire[31:0] mem_st_data,mem_data;
    wire[1:0] mem_size,d_size;// size not use
    wire[3:0] m_sel,d_wen;
    wire stallreq;
    
    reg inst_miss;
    //�ٲã�����ȡָ��
    always @(posedge clk) begin
        if (~resetn) begin
            inst_miss <= 1'b1;
        end
        if (m_i_ready & inst_miss) begin
            inst_miss <= 1'b0;
        end else if (~inst_miss & data_sram_en) begin
            inst_miss <= 1'b0;
        end else if (~inst_miss & data_sram_en & m_d_ready) begin
            inst_miss <= 1'b1;
        end else begin 
            inst_miss <= 1'b1;
        end
    end
    
    //ѡ��ȡָor����
    assign sel_i = inst_miss;  //instΪ1��ѡ���ָ�����ִ�����ݲ���
    assign d_addr = (data_sram_addr[31:16] != 16'hbfaf) ? data_sram_addr : {16'h1faf,data_sram_addr[15:0]}; // modify data address, to get the data from confreg
    assign i_addr = inst_sram_addr;
    assign m_addr = sel_i ? i_addr : d_addr;
   
    assign m_fetch = inst_sram_en & inst_miss; 
    assign m_ld_st = data_sram_en;

    assign inst_sram_rdata = mem_data;
    assign data_sram_rdata = mem_data;
    assign mem_st_data = data_sram_wdata;
    
    assign mem_access = sel_i ? m_fetch : m_ld_st; 
    assign mem_size = sel_i ? 2'b10 : data_sram_size;
    assign m_sel = sel_i ? 4'b1111 : data_sram_wen;
    assign mem_write = sel_i ? 1'b0 : data_sram_write;

    //ѡ��ȡָ or �ô�
    assign m_i_ready = mem_ready & sel_i;
    assign m_d_ready = mem_ready & ~sel_i;

    //ͣ��
    assign stallreq_from_if = ~m_i_ready;
    assign stallreq_from_mem = data_sram_en & ~m_d_ready;
    assign stallreq = stallreq_from_if | stallreq_from_mem;
	//AXI
    reg [3:0] write_wen;
    reg  read_req;
	reg  write_req;
	reg  [1:0]  read_size;
	reg  [1:0]  write_size;
	reg  [31:0] read_addr;
	reg  [31:0] write_addr;
	reg  [31:0] write_data;
	reg  read_addr_finish;
	reg  write_addr_finish;
	reg  write_data_finish;
		
	wire read_finish;
	wire write_finish;

    wire read = mem_access && ~mem_write;
    wire write = mem_access && mem_write;

    reg flush_reg;
    //�쳣��ֹ���ݽ�������
    always @(posedge clk) begin
        flush_reg <= ~resetn ? 1'b0:
                    flush ? 1'b1:
                    1'b0; 
    end
    //AIX���ֻ���
    always @(posedge clk) begin
        read_req   <= (~resetn) ? 1'b0 :
				 	  (read && ~read_req) ? 1'b1 :
			 		  (read_finish) ? 1'b0 : 
					  read_req;

        read_addr <= (~resetn || read_finish) ? 32'hffffffff : 
	                 (read && ~read_req || flush_reg) ? m_addr :
	                 read_addr;

        read_size  <= (~resetn) ? 2'b00 :
					  (read) ? mem_size :
					  read_size;

        write_req  <= (~resetn) ? 1'b0 :
					  (write && ~write_req) ? 1'b1 :
					  (write_finish) ? 1'b0 : 
					  write_req;

        write_addr <= (~resetn || write_finish) ? 32'hffffffff : 
                      (write && ~write_req) ? m_addr :                     
                      write_addr;

        write_size <= (~resetn) ? 2'b00 :
					  (write) ? mem_size :
					  write_size;

        write_wen <= (~resetn) ? 4'b0000 :
                    (write) ? m_sel:
                    write_wen;

        write_data <= (~resetn) ? 32'b0 :
                    (write) ? mem_st_data:
                    write_data;
    end

    always @(posedge clk) begin
		read_addr_finish  <= (~resetn) ? 1'b0 :
		                     (read_req && arvalid && arready) ? 1'b1 :
						 	 (read_finish) ? 1'b0 :
					 		 read_addr_finish;
		write_addr_finish <= (~resetn) ? 1'b0 :
							 (write_req && awvalid && awready) ? 1'b1 :
							 (write_finish) ? 1'b0 :
							 write_addr_finish;
		write_data_finish <= (~resetn) ? 1'b0 :
							 (write_req && wvalid && wready) ? 1'b1 :
							 (write_finish) ? 1'b0 :
							 write_data_finish;
	end

    assign mem_ready = read_req && read_finish && ~flush_reg|| write_req && write_finish;
	
	assign mem_data = rdata;	

    assign read_finish = read_addr_finish && rvalid && rready;
	assign write_finish = write_addr_finish && bvalid && bready;
		
	assign arid = 4'b0;
	assign araddr = read_addr;
    assign arlen = 4'b0;
	assign arsize = read_size;
    assign arburst = 2'b01;
    assign arlock = 2'b0;
    assign arcache = 4'b0;
    assign arprot = 3'b0;
	assign arvalid = read_req && ~read_addr_finish && ~flush && ~flush_reg;

	assign rready = 1'b1;
	
	assign awid = 4'b0;
	assign awaddr = write_addr;
    assign awlen = 4'b0;
	assign awsize = write_size;
    assign awburst = 2'b01;
    assign awlock = 2'b0;
    assign awcache = 4'b0;
    assign awprot = 3'b0;
	assign awvalid = write_req && ~write_addr_finish;

	assign wid = 4'b0;
	assign wdata = write_data;
	assign wstrb = write_wen;
    assign wlast = 1'b1;
	assign wvalid = write_req && ~write_data_finish;

	assign bready = 1'b1;
endmodule



//sram to ��sram �ο��������ϵ�ṹLAB_2
module inst_sram_to_sram_like(
    input wire clk,
    input wire rst,
    //CPU��ͣ�٣�ʱ��Ҫһ��
    input wire cpu_stall,
    //�ô�ʱ��ͣ��ˮ��
    output wire cpu_inst_stall, 
    //sram ����cpu
    input wire cpu_inst_en,
    input wire [3 :0] cpu_inst_wen,
    input wire [31:0] cpu_inst_addr,
    input wire [31:0] cpu_inst_wdata,
    output wire [31:0] cpu_inst_rdata,         
    //��sram ���������sram �� cache
    output wire inst_req,
    output wire inst_wr,
    output wire [1 :0] inst_size,
    output wire [31:0] inst_addr,
    output wire [31:0] inst_wdata,
    input wire [31:0] inst_rdata,
    input wire inst_addr_ok,
    input wire inst_data_ok
    );
    //��ַok�����ߣ�����ok������
    reg addr_rcv;
    //�Ƿ����һ�ηô����
    reg do_finish;
    //��ʱ���ֶ���������
    reg [31:0] inst_rdata_save;
    //״̬��,��ʾһ�������ķô����
    always @(posedge clk) begin
        addr_rcv <= rst ? 1'b0 :
                    inst_req & inst_addr_ok & ~inst_data_ok ? 1'b1 :    
                    inst_data_ok ? 1'b0 : addr_rcv;
        do_finish <= rst ? 1'b0 :
                     inst_data_ok ? 1'b1 :
                     ~cpu_stall ? 1'b0 : do_finish;
        inst_rdata_save <= rst ? 32'b0:
                           inst_data_ok ? inst_rdata : inst_rdata_save;
    end
    //��sram�ź�
    assign inst_req = cpu_inst_en & ~addr_rcv & ~do_finish;
    assign inst_wr = 1'b0;
    assign inst_size = 2'b10;
    assign inst_addr = cpu_inst_addr;
    assign inst_wdata = 32'b0;
    assign cpu_inst_rdata = inst_rdata_save;
    assign cpu_inst_stall = cpu_inst_en & ~do_finish;
endmodule


module data_sram_to_sram_like(
    input wire clk,
    input wire rst,
    //sram ����CPU
    input wire cpu_data_en,
    input wire [3:0] cpu_data_wen,
    input wire [31:0] cpu_data_addr,
    input wire [31:0] cpu_data_wdata,
    input wire cpu_stall,
    output wire [31:0] cpu_data_rdata,
    output wire cpu_data_stall,
    //��sram ���������sram �� cache
    output wire data_req,
    output wire data_wr,
    output wire [1 :0] data_size,
    output wire [31:0] data_addr,
    output wire [31:0] data_wdata,
    input wire [31:0] data_rdata,
    input wire data_addr_ok,
    input wire data_data_ok
    );
    //��ַok�����ߣ�����ok������
    reg addr_rcv;
    //�Ƿ����һ�ηô����
    reg do_finish;
    //��ʱ���ֶ���������
    reg [31:0] data_rdata_save;
    //״̬��,��ʾһ�������ķô����
    always @(posedge clk) begin
        addr_rcv <= rst ? 1'b0 :
                    data_req & data_addr_ok & ~data_data_ok ? 1'b1 : 
                    data_data_ok ? 1'b0 : addr_rcv;
        do_finish <= rst ? 1'b0 :
                     data_data_ok ? 1'b1:
                     ~cpu_stall ? 1'b0:do_finish;
        data_rdata_save <= rst ? 32'b0:
                           data_data_ok ? data_rdata : data_rdata_save;
    end
    
    //��sram�ź�
    assign data_req = cpu_data_en && ~addr_rcv && ~do_finish; 
    assign data_wr = cpu_data_en && (cpu_data_wen[3]||cpu_data_wen[2]||cpu_data_wen[1]||cpu_data_wen[0]);
    assign data_size = (cpu_data_wen==4'b0001 || cpu_data_wen==4'b0010 || 
                        cpu_data_wen==4'b0100 || cpu_data_wen==4'b1000) ? 2'b00:
                       (cpu_data_wen==4'b0011 || cpu_data_wen==4'b1100 ) ? 2'b01 : 2'b10;
    assign data_addr = cpu_data_addr;
    assign data_wdata = cpu_data_wdata;
    assign cpu_data_rdata = data_rdata_save;
    assign cpu_data_stall = cpu_data_en & ~do_finish; 
endmodule



//��о����
module cpu_axi_interface
(
    input         clk,
    input         resetn, 

    //inst sram-like 
    input         inst_req     ,
    input         inst_wr      ,
    input  [1 :0] inst_size    ,
    input  [31:0] inst_addr    ,
    input  [31:0] inst_wdata   ,
    output [31:0] inst_rdata   ,
    output        inst_addr_ok ,
    output        inst_data_ok ,
    
    //data sram-like 
    input         data_req     ,
    input         data_wr      ,
    input  [1 :0] data_size    ,
    input  [31:0] data_addr    ,
    input  [31:0] data_wdata   ,
    output [31:0] data_rdata   ,
    output        data_addr_ok ,
    output        data_data_ok ,

    //axi
    //ar
    output [3 :0] arid         ,
    output [31:0] araddr       ,
    output [7 :0] arlen        ,
    output [2 :0] arsize       ,
    output [1 :0] arburst      ,
    output [1 :0] arlock        ,
    output [3 :0] arcache      ,
    output [2 :0] arprot       ,
    output        arvalid      ,
    input         arready      ,
    //r           
    input  [3 :0] rid          ,
    input  [31:0] rdata        ,
    input  [1 :0] rresp        ,
    input         rlast        ,
    input         rvalid       ,
    output        rready       ,
    //aw          
    output [3 :0] awid         ,
    output [31:0] awaddr       ,
    output [7 :0] awlen        ,
    output [2 :0] awsize       ,
    output [1 :0] awburst      ,
    output [1 :0] awlock       ,
    output [3 :0] awcache      ,
    output [2 :0] awprot       ,
    output        awvalid      ,
    input         awready      ,
    //w          
    output [3 :0] wid          ,
    output [31:0] wdata        ,
    output [3 :0] wstrb        ,
    output        wlast        ,
    output        wvalid       ,
    input         wready       ,
    //b           
    input  [3 :0] bid          ,
    input  [1 :0] bresp        ,
    input         bvalid       ,
    output        bready       
);
//addr
reg do_req;
reg do_req_or; //req is inst or data;1:data,0:inst
reg        do_wr_r;
reg [1 :0] do_size_r;
reg [31:0] do_addr_r;
reg [31:0] do_wdata_r;
wire data_back;

assign inst_addr_ok = !do_req&&!data_req;
assign data_addr_ok = !do_req;
always @(posedge clk)
begin
    do_req     <= !resetn                       ? 1'b0 : 
                  (inst_req||data_req)&&!do_req ? 1'b1 :
                  data_back                     ? 1'b0 : do_req;
    do_req_or  <= !resetn ? 1'b0 : 
                  !do_req ? data_req : do_req_or;

    do_wr_r    <= data_req&&data_addr_ok ? data_wr :
                  inst_req&&inst_addr_ok ? inst_wr : do_wr_r;
    do_size_r  <= data_req&&data_addr_ok ? data_size :
                  inst_req&&inst_addr_ok ? inst_size : do_size_r;
    do_addr_r  <= data_req&&data_addr_ok ? data_addr :
                  inst_req&&inst_addr_ok ? inst_addr : do_addr_r;
    do_wdata_r <= data_req&&data_addr_ok ? data_wdata :
                  inst_req&&inst_addr_ok ? inst_wdata :do_wdata_r;
end

//inst sram-like
assign inst_data_ok = do_req&&!do_req_or&&data_back;
assign data_data_ok = do_req&& do_req_or&&data_back;
assign inst_rdata   = rdata;
assign data_rdata   = rdata;

//---axi
reg addr_rcv;
reg wdata_rcv;

assign data_back = addr_rcv && (rvalid&&rready||bvalid&&bready);
always @(posedge clk)
begin
    addr_rcv  <= !resetn          ? 1'b0 :
                 arvalid&&arready ? 1'b1 :
                 awvalid&&awready ? 1'b1 :
                 data_back        ? 1'b0 : addr_rcv;
    wdata_rcv <= !resetn        ? 1'b0 :
                 wvalid&&wready ? 1'b1 :
                 data_back      ? 1'b0 : wdata_rcv;
end
//ar
assign arid    = 4'd0;
assign araddr  = do_addr_r;
assign arlen   = 8'd0;
assign arsize  = do_size_r;
assign arburst = 2'd0;
assign arlock  = 2'd0;
assign arcache = 4'd0;
assign arprot  = 3'd0;
assign arvalid = do_req&&!do_wr_r&&!addr_rcv;
//r
assign rready  = 1'b1;

//aw
assign awid    = 4'd0;
assign awaddr  = do_addr_r;
assign awlen   = 8'd0;
assign awsize  = do_size_r;
assign awburst = 2'd0;
assign awlock  = 2'd0;
assign awcache = 4'd0;
assign awprot  = 3'd0;
assign awvalid = do_req&&do_wr_r&&!addr_rcv;
//w
assign wid    = 4'd0;
assign wdata  = do_wdata_r;
assign wstrb  = do_size_r==2'd0 ? 4'b0001<<do_addr_r[1:0] :
                do_size_r==2'd1 ? 4'b0011<<do_addr_r[1:0] : 4'b1111;
assign wlast  = 1'd1;
assign wvalid = do_req&&do_wr_r&&!wdata_rcv;
//b
assign bready  = 1'b1;

endmodule



