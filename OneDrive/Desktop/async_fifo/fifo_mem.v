module fifo_mem #(
    parameter fifo_depth = 16,
    parameter datain_width = 8,
    parameter dataout_width = 8
)(
    input w_clk, w_rst, w_en, r_clk, r_rst, r_en, 
    input [datain_width-1:0] datain,
    output reg [dataout_width-1:0] data_read
);
wire [$clog2(fifo_depth):0]readaddrgrey,writeaddrgrey,write_addr_gray_sync,read_addr_gray_sync ;
wire full,empty;
wire[$clog2(fifo_depth)-1:0] write_addr,read_addr;

  reg [datain_width-1:0] fifo_mem[fifo_depth-1:0];
  reg [2:0] count = 0; 
  integer i; 
read  #(fifo_depth,datain_width,dataout_width) m1(r_en, r_clk, r_rst,write_addr_gray_sync,read_addr,empty,readaddrgrey);
write #(fifo_depth) m2(w_en,w_clk,w_rst,read_addr_gray_sync,write_addr,full,writeaddrgrey);
sync #(fifo_depth) m3(r_clk,r_rst,w_clk,w_rst,writeaddrgrey,readaddrgrey,write_addr_gray_sync,read_addr_gray_sync) ;
  always @(posedge w_clk or posedge w_rst) begin
    if (w_rst) begin
      for (i = 0; i < fifo_depth; i = i + 1) begin
        fifo_mem[i] = 0; 
      end
    end
    else if (w_en && !full) begin
      fifo_mem[write_addr] <= datain;
    end
  end

  always @(posedge r_clk or posedge r_rst) begin
    if (r_rst ) begin
      count <= 0;
      data_read <= 0 ;
    end
    else if (r_en && !empty) begin
      if (datain_width <= dataout_width) begin
        case (dataout_width / datain_width)
          1: data_read <= fifo_mem[read_addr];
          2: data_read <= {fifo_mem[read_addr+1], fifo_mem[read_addr]};
          4: data_read <= {fifo_mem[read_addr+3], fifo_mem[read_addr+2], fifo_mem[read_addr+1], fifo_mem[read_addr]};
        endcase
      end
      else begin
        count <= (count == (datain_width / dataout_width) - 1) ? 0 : count + 1 ;
        case (datain_width / dataout_width)
          2: begin
            if (count == 0)
              data_read <= fifo_mem[read_addr][(datain_width / 2) - 1 : 0];
            else if (count == 1)
              data_read <= fifo_mem[read_addr][datain_width - 1 : (datain_width / 2)];
          end
          4: begin
            if (count == 0)
              data_read <= fifo_mem[read_addr][(datain_width / 4) - 1 : 0];
            else if (count == 1)
              data_read <= fifo_mem[read_addr][(datain_width / 2) - 1 : (datain_width / 4)];
            else if (count == 2)
              data_read <= fifo_mem[read_addr][3 * (datain_width / 4) - 1 : (datain_width / 2)];
            else if (count == 3)
              data_read <= fifo_mem[read_addr][datain_width - 1 : 3 * (datain_width / 4)];
          end
        endcase
      end
    end
  end 

endmodule