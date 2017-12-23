//    ---------------------------------------------------
//    |    Pixel order                                  |
//    |                                                 |
//    |    |         tu          |                       |                                  |
//    | -  -------------------     -------------------  |
//    |    |                 |     |                 |  |
//    |    |      dataA      |     |      dataB      |  |
//    |    |                 |     |                 |  |
//    |    -------------------     -------------------  |
//    | tv -------------------     -------------------  |
//    |    |                 |     |                 |  |
//    | -  |      dataC      |   * |      dataC      |  |
//    |    |                 |     |                 |  |
//    |    -------------------     -------------------  |
//    --- -----------------------------------------------
//   用流水线实现最近邻插值插值算法
//   dataAB = dataA + tu * (dataB - dataA);
//   dataCD = dataC + tu * (dataD - dataC);
//   dataout = dataAB + tv * (dataCD - dataAB);

module Crc(
input clk,
input [7:0] dataA,
input  [17:0] loc,
input [17:0] cnt,
output [17:0] dataAaddr,
output [17:0] locaddr,
output [7:0] dataout
);



reg [7:0] dataA_d0;

reg [17:0] locaddr_reg;
reg [17:0] dataAaddr_reg;


assign locaddr = locaddr_reg;
assign dataAaddr = dataAaddr_reg;
assign dataout = dataA_d0;



always @(posedge clk)
begin
//T1
locaddr_reg <= cnt;

//T2,T3
dataAaddr_reg <= loc;

//T5,T6    
dataA_d0 <= dataA;


end



endmodule
