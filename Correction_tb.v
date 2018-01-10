`timescale 1ns/100ps
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
parameter INPUT_X_RES = 640-1,
parameter INPUT_Y_RES = 512-1,
parameter OUTPUT_X_RES = 640-1,   //Output resolution - 1
parameter OUTPUT_Y_RES = 512-1,   //Output resolution - 1

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
output reg done

);


reg clk;
reg rst;
reg dOutValid;


reg [DATA_WIDTH*CHANNELS-1:0] dIn;
reg		dInValid;
reg	nextDin;
wire Eout0;
reg		start;


wire [DATA_WIDTH*CHANNELS-1:0] dOut;

integer r, rfile, wfile,r_Lut, rfile_Lut, wfile_Lut;

initial // Clock generator
  begin
    #10 //Delay to allow filename to get here
    clk = 0;
    #5 forever #5 clk = !clk;
  end


  
initial  // done
	begin
	  #10
	  while(done != 7'b1111111)
	   #10
	   ;
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
	dInValid = 0;
    #100 
    nextDin = 1;
	dInValid = 1;
    #3276800
    nextDin = 0;
	dInValid = 0;
  end 
  
   initial	// 	dOutValid
  begin
	dOutValid = 0;
    #3277000
    dOutValid = 1;
  end 
  

  
reg [DATA_WIDTH*CHANNELS-1:0] readMem [0:0];
initial // Input file read, generates dIn data
begin
  #10 //Delay to allow filename to get here
	rfile = $fopen("D:/work/Projects/vivado/FastCorrection/src/src/infrared.raw", "rb");
	
	dIn = 0;
	
	#90
	r = $fread(readMem, rfile);
	dIn = readMem[0];
	while(! $feof(rfile))
	begin
		
		#10 
		if(nextDin) 
		begin
			r = $fread(readMem, rfile);
			dIn = readMem[0];
		end
	end

  $fclose(rfile);
  
end


integer i;
reg nW;
reg [19:0] dIn_Lut;
reg [19:0] data[0:327680-1];
wire [8:0] DQa_w,DQb_w,DQc_w,DQd_w;
initial
begin
nW = 1;
#100
nW = 0;
$readmemh("D:/work/Projects/vivado/FastCorrection/src/src/LutMethod32H.txt",data);
for(i=0;i<327681;i=i+1)
    begin
		#10
		dIn_Lut = data[i];
		//$monitor($time,,"dIn_Lut=%h",dIn_Lut);
    end
nW = 1'bx;
#90
nW = 1;
end
assign DQa_w = dIn_Lut[8:0];
assign DQb_w = dIn_Lut[17:9];
assign DQc_w = {7'b0000000,dIn_Lut[19:18]};
assign DQd_w = 9'd0;

/*reg [35 :0] readMem_Lut [0:0];
reg [35:0] dIn_Lut;
wire [8:0] DQa_w,DQb_w,DQc_w,DQd_w;
reg nW;
initial  // Input file read, generates dIn data
begin
  #3276950 //Delay to allow filename to get here
	rfile_Lut = $fopen("D:/work/Projects/vivado/FastCorrection/src/src/LutMethod32H.txt", "rb");
	
	dIn_Lut = 0;


	#50
	r_Lut = $fread(readMem_Lut, rfile_Lut);
	dIn_Lut = readMem_Lut[0];
	nW = 0;
	while(! $feof(rfile_Lut))
	begin
		#10 
		r_Lut = $fread(readMem_Lut, rfile_Lut);
		dIn_Lut = readMem_Lut[0];
	end
    #3276800
	nW = 1;
  $fclose(rfile);
end
//assign DQa_w = dIn_Lut[8:0];
//assign DQb_w = dIn_Lut[17:9];
//assign DQc_w = dIn_Lut[26:18];
//assign DQd_w = dIn_Lut[35:27];
*/

//Read dOut and write to file
integer dOutCount;
initial
begin
  #10 //Delay to allow filename to get here
	wfile = $fopen("D:/work/Projects/vivado/FastCorrection/src/out/infrared_out.raw", "wb");
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

Correction Correction0 (
.clk( clk ),
.rst( rst ),
//Input
.dInValid( dInValid ),
.dOutValid(dOutValid),
.nW(nW),
.dIn( dIn ),
.DQa_write(DQa_w),
.DQb_write(DQb_w),
.DQc_write(DQc_w),
.DQd_write(DQd_w),
//Output
.dOut( dOut ),
.Eout(Eout0)
);

endmodule
