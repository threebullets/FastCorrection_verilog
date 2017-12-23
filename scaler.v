  module Correction(
//---------------------------Module IO-----------------------------------------
//Clock and reset
input wire	clk0,
input wire	clk1,
input wire	rst,

//User interface
//Input
input wire [7:0] dIn,
input wire dInValid,
input wire dOuten,
//Output
output wire [7:0] dOut,
output wire  dOutValid
);

reg [17:0] inputaddr;
reg [17:0] outputaddr;
wire [17:0] locaddr;
wire [17:0] loc;
wire [17:0] dataAaddr;
wire [7:0] dataA;

always @ (posedge clk0 or posedge rst)
begin
	if (rst)
		begin
			inputaddr <= 18'b0;
		end
	else if (dInValid)
		begin
			inputaddr <= inputaddr + 18'b1;
		end
		
end

always @ (posedge clk0 or posedge rst)
begin
	if (rst)
		begin
			outputaddr <= 18'b0;
		end
	else if (dOuten)
		begin
			outputaddr <= outputaddr + 18'b1;
		end
		
end

BRAM BRAM0 (
  .clka(clk0), // input clka
  .wea(dInValid), // input [0 : 0] wea
  .addra(inputaddr), // input [17 : 0] addra
  .dina(dIn), // input [7 : 0] dina
  .clkb(clk1), // input clkb
    .enb(dOuten), // input enb
  .addrb(dataAaddr), // input [17 : 0] addrb
  .doutb(dataA) // output [7 : 0] doutb
  );
  
assign  dOutValid = dOuten;

Crc Crc0(
	.clk(clk1),
	.dataA(dataA),
	.loc(loc),
	.cnt(outputaddr),
	.dataAaddr(dataAaddr),
	.locaddr(locaddr),
	.dataout(dOut)
);

locROM locROM0 (
  .clka(clk1), // input clka
  .addra(locaddr), // input [17 : 0] addra
  .douta(loc) // output [17 : 0] douta
);

endmodule //ramFifo

