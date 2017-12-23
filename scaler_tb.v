/*-----------------------------------------------------------------------------

								Video Stream Scaler testbench
								
							Author: David Kronstein
							


Copyright 2011, David Kronstein, and individual contributors as indicated
by the @authors tag.

This is free software; you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as
published by the Free Software Foundation; either version 2.1 of
the License, or (at your option) any later version.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this software; if not, write to the Free
Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
02110-1301 USA, or see the FSF site: http://www.fsf.org.

-------------------------------------------------------------------------------

Testbench for streamScaler V1.0.0

*/
`timescale 1ms/1ms
`default_nettype none

//Input files. Raw data format, no header. 8 bits per pixel, 3 color channels.
`define INPUT640x512			"src/InputImgFree640x640.raw"
`define INPUT1280x1024			"src/input1280x1024RGB.raw"
`define INPUT1280x1024_21EXTRA	"src/input640x512_21extraRGB.raw"	//21 extra pixels at the start to be discarded

module scalerTestbench;
parameter BUFFER_SIZE = 6;

wire [7-1:0] done;

//640x512 to 1280x1024
	scalerTest #(
	.INPUT_X_RES ( 694-1 ),
	.INPUT_Y_RES ( 694-1 ),
	.OUTPUT_X_RES ( 376-1 ),   //Output resolution - 1
	.OUTPUT_Y_RES ( 376-1 ),   //Output resolution - 1
	//.X_SCALE ( X_SCALE ),
	//.Y_SCALE ( Y_SCALE ),

	.DATA_WIDTH ( 8 ),
	.DISCARD_CNT_WIDTH ( 8 ),
	.INPUT_X_RES_WIDTH ( 11 ),
	.INPUT_Y_RES_WIDTH ( 11 ),
	.OUTPUT_X_RES_WIDTH ( 11 ),
	.OUTPUT_Y_RES_WIDTH ( 11 ),
	.BUFFER_SIZE ( BUFFER_SIZE )				//Number of RAMs in RAM ring buffer
	) st_640x512to1280x1024 (
	.inputFilename( `INPUT640x512 ),
	.outputFilename( "out/OnputImgFree640x640.raw" ),

	//Control
	.inputDiscardCnt( 0 ),		//Number of input pixels to discard before processing data. Used for clipping
	.leftOffset( 0 ),
	.topFracOffset( 0 ),
	.nearestNeighbor( 0 ),
	.done ( done[0] )
	);



  



endmodule

module CorrectionTest #(
parameter INPUT_X_RES = 346-1,
parameter INPUT_Y_RES = 346-1,
parameter OUTPUT_X_RES = 173-1,   //Output resolution - 1
parameter OUTPUT_Y_RES = 173-1,   //Output resolution - 1
parameter X_SCALE = 32'h4000 * (INPUT_X_RES) / (OUTPUT_X_RES)-1,
parameter Y_SCALE = 32'h4000 * (INPUT_Y_RES) / (OUTPUT_Y_RES)-1,

parameter DATA_WIDTH = 8,
parameter CHANNELS = 1,
parameter DISCARD_CNT_WIDTH = 8,
parameter INPUT_X_RES_WIDTH = 11,
parameter INPUT_Y_RES_WIDTH = 11,
parameter OUTPUT_X_RES_WIDTH = 11,
parameter OUTPUT_Y_RES_WIDTH = 11,
parameter BUFFER_SIZE = 6				//Number of RAMs in RAM ring buffer
)(
input wire [50*8:0] inputFilename, outputFilename,

//Control
input wire [DISCARD_CNT_WIDTH-1:0]	inputDiscardCnt,		//Number of input pixels to discard before processing data. Used for clipping
input wire [INPUT_X_RES_WIDTH+14-1:0] leftOffset,
input wire [14-1:0]	topFracOffset,
input wire nearestNeighbor,

output reg done

);


reg clk0;
reg clk1;
reg rst;
reg dOuten;


reg [DATA_WIDTH*CHANNELS-1:0] dIn;
reg		dInValid;
reg	nextDin;
reg		start;

wire [DATA_WIDTH*CHANNELS-1:0] dOut;
wire	dOutValid;
reg		nextDout;
reg test;

integer r, rfile, wfile;

initial // Clock generator
  begin
    #10 //Delay to allow filename to get here
    clk0 = 0;
    #5 forever #5 clk0 = !clk0;
  end

 initial // Clock generator
  begin
    #1200000 //Delay to allow filename to get here
    clk1 = 0;
    #5 forever #5 clk1 = !clk1;
  end
  
  	initial
	begin
	  #10
	  test = 0;
	  while(done != 1)
	  begin
	   #10
	    test = 1;
	   end
	   test = 0;
		$stop;
	end
	
	
initial	// Reset
  begin

	done = 0;
    #10 //Delay to allow filename to get here
    rst = 0;
    #5 rst = 1;
    #4 rst = 0;
   // #50000 $stop;
  end

 initial	// nextDin
  begin
	nextDin = 0;
    #2060 
    nextDin = 1;
    #1197160
    nextDin = 0;
  end 
  
   initial	// 	dOuten
  begin
	dOuten = 0;
    #1200000
    dOuten = 1;
    #299290
    dOuten = 0;
  end 
  

  
reg eof;
reg [DATA_WIDTH*CHANNELS-1:0] readMem [0:0];
initial // Input file read, generates dIn data
begin
  #10 //Delay to allow filename to get here
	rfile = $fopen("src/create8row.raw", "rb");
	
	dIn = 0;
	dInValid = 0; 
	start = 0;

	#41
	start = 1;

	#10
	start = 0;

//	#20
	#2000
	r = $fread(readMem, rfile);
	dIn = readMem[0];
	while(! $feof(rfile))
	begin
		dInValid = 1;
		#10 
		if(nextDin) 
		begin
			r = $fread(readMem, rfile);
			dIn = readMem[0];
		end
	end

  $fclose(rfile);
end






//Read dOut and write to file
integer dOutCount;
initial
begin
  #10 //Delay to allow filename to get here
	wfile = $fopen("out/restore8.raw", "wb");
	dOutCount = 0;
	#1
	while(dOutCount < (OUTPUT_X_RES+1) * (OUTPUT_Y_RES+1))
	begin
		#10
		if(dOutValid == 1)
		begin
			//$fwrite(wfile, "%c", dOut[23:16]);
			//$fwrite(wfile, "%c", dOut[15:8]);
			$fwrite(wfile, "%c", dOut[7:0]);
			dOutCount = dOutCount + 1;
		end
	end
	$fclose(wfile);
	done = 1;
end

Correction Correction_inst (
.clk0( clk0 ),
.clk1( clk1 ),
.rst( rst ),
//Input
.dIn( dIn ),
.dInValid( dInValid ),
.dOuten(dOuten),
//Output
.dOut( dOut ),
.dOutValid( dOutValid )
);

endmodule
