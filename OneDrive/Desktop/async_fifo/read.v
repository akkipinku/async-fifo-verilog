module read #(parameter fifo_depth = 16,  parameter datain_width = 8,    parameter dataout_width = 8)           
(  input ren, rclk, rrst,
  input [$clog2(fifo_depth):0] writeaddrptrgreysync,
  output [$clog2(fifo_depth)-1:0] readaddr,
  output empty,
  output [$clog2(fifo_depth):0] readaddrptrgrey
); 
  reg [$clog2(fifo_depth):0] readaddrptr;
  reg [2:0] count = 0;

  assign readaddrptrgrey = (readaddrptr >> 1) ^ readaddrptr;
  
  assign readaddr = readaddrptr[$clog2(fifo_depth)-1 : 0];
  
  assign empty = (readaddrptrgrey == writeaddrptrgreysync);

  always @(posedge rclk or posedge rrst) begin
    if (rrst) begin
      count <= 0;
      readaddrptr <= 0;
    end else begin
      if (ren && !empty) begin
        if (dataout_width >= datain_width) begin
          readaddrptr <= readaddrptr + (dataout_width / datain_width);
        end else begin
          count <= (count == (datain_width / dataout_width) - 1) ? 0 : count + 1;
          if (count == (datain_width / dataout_width) - 1) begin
            readaddrptr <= readaddrptr + 1;
          end
        end
      end
    end
  end

endmodule
