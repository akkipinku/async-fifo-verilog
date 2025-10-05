module write #(parameter fifo_depth = 16)(wen,wclk,wrst,readaddrptrgreysync,writeaddr,full ,writeaddrptrgrey,
) ;
input wen,wclk,wrst ;
input [$clog2(fifo_depth):0]readaddrptrgreysync ;
output  [$clog2(fifo_depth)-1:0]writeaddr;
output full ;
output [$clog2(fifo_depth):0]writeaddrptrgrey ;
reg [$clog2(fifo_depth):0]writeaddrptr ;
assign writeaddrptrgrey = (writeaddrptr>>1) ^ writeaddrptr;
assign writeaddr = writeaddrptr[$clog2(fifo_depth)-1 : 0] ;
assign full = (writeaddrptrgrey[$clog2(fifo_depth):0]  == {~(readaddrptrgreysync[$clog2(fifo_depth) :($clog2(fifo_depth)-1)]),readaddrptrgreysync[$clog2(fifo_depth)-2:0]}) ;
always@(posedge wclk or posedge wrst) begin
if(wrst) begin
  writeaddrptr <= 0 ;
  end
else begin
if(wen && !full) 
writeaddrptr <= writeaddrptr + 1 ;
end
end
endmodule