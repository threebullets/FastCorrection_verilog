  module Correction(
//---------------------------Module IO-----------------------------------------
//Clock and reset
input wire	clk,
input wire	rst,

//User interface
//Input
input wire dInValid,
input wire dOutValid,
input wire nW,
input wire [7:0] dIn,
input wire [8:0] DQa_write,
input wire [8:0] DQb_write,
input wire [8:0] DQc_write,
input wire [8:0] DQd_write,

//Output
output wire [7:0] dOut,
output wire Eout
);

reg [18:0] inputaddr;
reg [18:0] outputaddr;
reg [18:0] BRAMinputaddr;

wire [20:0] address;

wire [18:0] locaddr;
wire [18:0] loc;
wire [18:0] dataAaddr;
wire [7:0] dataA;
wire [8:0] DQa;
wire [8:0] DQb;
wire [8:0] DQc;
wire [8:0] DQd;
wire [8:0] DQa_read;
wire [8:0] DQb_read;
wire [8:0] DQc_read;
wire [8:0] DQd_read;


always @ (posedge clk or posedge rst)
begin
	if (rst | !dInValid)
		begin
			inputaddr <= 18'b0;
		end
	else
		begin
			inputaddr <= inputaddr + 18'b1;
		end
		
end

always @ (posedge clk or posedge rst)
begin
	if (rst | !dOutValid)
		begin
			outputaddr <= 18'b0;
		end
	else
		begin
			outputaddr <= outputaddr + 18'b1;
		end
		
end

always @ (posedge clk or posedge rst)
begin
	if (rst | nW )
		begin
			BRAMinputaddr <= 18'b0;
		end
	else
		begin
			BRAMinputaddr <= BRAMinputaddr + 18'b1;
		end
		
end


BRAM BRAM0 (
  .clka(clk),    // input wire clka
  .wea(dInValid),      // input wire [0 : 0] wea
  .addra(inputaddr),  // input wire [18 : 0] addra
  .dina(dIn),    // input wire [7 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(dOutValid),      // input wire enb
  .addrb(dataAaddr),  // input wire [18 : 0] addrb
  .doutb(dataA)  // output wire [7 : 0] doutb
);  

Crc Crc0(
	.clk(clk),
	.cnt(outputaddr),
	.loc(loc),
	.dataA(dataA),
	.locaddr(locaddr),
	.dataAaddr(dataAaddr),
	.dataout(dOut),
	.Enout(Eout)
);


assign clk_opposition = ~clk;
assign address = (!nW==1)?BRAMinputaddr:locaddr;
assign DQa = (!nW==1)?DQa_write:9'bz;
assign DQb = (!nW==1)?DQb_write:9'bz;
assign DQc = (!nW==1)?DQc_write:9'bz;
assign DQd = (!nW==1)?DQd_write:9'bz;
assign DQa_read = DQa;
assign DQb_read = DQb;
assign DQc_read = DQc;
assign DQd_read = DQd;
assign loc = {DQc_read[0],DQb_read,DQa_read};
	
G8644Z36E m(
    .A              (address),
    .DQa            (DQa), 
    .DQb            (DQb), 
    .DQc            (DQc), 
    .DQd            (DQd), 
    .nBa            (1'b0), 
    .nBb            (1'b0), 
    .nBc            (1'b0), 
    .nBd            (1'b0), 
    .CK             (clk_opposition), 
    .nCKE           (1'b0), 
    .nW             (nW), 
    .nE1            (1'b0), 
    .E2             (1'b1), 
    .nE3            (1'b0), 
    .nG             (1'b0), 
    .pADV           (1'b0), 
    .ZZ             (1'b0), 
    .nFT            (1'b0), 
    .nLBO           (), 
    .ZQ             (1'b0),
    .TMS            (), 
    .TDI            (), 
    .TDO            (), 
    .TCK            ()
     );

endmodule //ramFifo

