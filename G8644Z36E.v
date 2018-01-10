//	Copyright ? 2000.	GSI Technology
//						jeffd@gsitechnology.com
//  v 1.00  04/01/02    Jeff Daugherty  1) Created

`define		pipe
`define     SP250MHZ
//`define     SP220MHZ
//`define     SP225MHZ
//`define     SP166MHZ
//`define     SP150MHZ
//`define     SP133MHZ

`timescale 1ns / 100ps

module G8644Z36E(A, DQa, DQb, DQc, DQd, nBa, nBb, nBc, nBd, CK, nCKE, 
		nW, nE1, E2, nE3, nG, pADV, ZZ, nFT, nLBO, ZQ,
		TMS, TDI, TDO, TCK );
	parameter	ramtype		= 2,		// 1 burst
							// 2 NBT
							// 3 sigma
			ramversion	= 2,		// 0, 1, 2
			density 	= 64,		// 64M bit sram
			byteparl	= 4,		// 4 bytes in parallel
    			A_size 		= 21,		// +64M -4 bytes in parallel
			DQ_size 	= 9,
			bank_size 	= 1024*2048;	// *64M /4 bytes in parallel


	input	[A_size-1:0]	A; 		// address
	input			CK;		// clock
	input			nBa;		// bank A write enable
	input			nBb;		// bank B write enable
	input			nBc;		// bank C write enable
	input			nBd;		// bank D write enable
	input			nW; 		// byte write enable
	input			nE1;		// chip enable 1
	input			E2;		// chip enable 2
	input			nE3;		// chip enable 3
	input			nG;		// output enable
	input			pADV;		// Advance not / load
	input			nCKE;
	inout	[DQ_size:1]	DQa;		// byte A data
	inout	[DQ_size:1]	DQb;		// byte B data
	inout	[DQ_size:1]	DQc;		// byte C data
	inout	[DQ_size:1]	DQd;		// byte D data
	input			ZZ;		// power down
	input			nFT;		// Pipeline / Flow through
	input			nLBO;		// Linear Burst Order not
	input			ZQ;

	input			TMS;		// Scan Test Mode Select
	input			TDI;		// Scan Test Data In
	output			TDO;		// Scan Test Data Out
	input			TCK;		// Scan Test Clock

	wire			nBe=1,
				nBf=1,
				nBg=1,
				nBh=1;
	wire   [DQ_size:1]	DQe,
				DQf,
				DQg,
				DQh;

`ifdef SP250MHZ //-----------------------------------------------------------
   parameter 			tKQ_pipe = 2.5;
   parameter 			tKQ_flow = 6.5;
   specify
      specparam
    	tKC_pipe	= 4,	// clock cycle time
    	tKQX_pipe	= 1.5,	// clock to output invalid
    	tKC_flow	= 6.5,	// clock cycle time
    	tKQX_flow	= 3,	// clock to output invalid
    	tS_pipe		= 1.2,	// setup time
    	tH_pipe		= 0.2,	// hold time
    	tS_flow		= 1.5,	// setup time
    	tH_flow		= 0.5;	// hold time
   endspecify
`endif  // ------------------------------------------------------------------

`ifdef SP225MHZ //-----------------------------------------------------------
   parameter 			tKQ_pipe = 2.7;
   parameter 			tKQ_flow = 7.0;
   specify
      specparam
    	tKC_pipe	= 4.4,	// clock cycle time
    	tKQX_pipe	= 1.5,	// clock to output invalid
    	tKC_flow	= 7.0,	// clock cycle time
    	tKQX_flow	= 3,	// clock to output invalid
    	tS_pipe		= 1.3,	// setup time
    	tH_pipe		= 0.3,	// hold time
    	tS_Flow		= 1.5,	// setup time
    	tH_Flow		= 0.5;	// hold time
   endspecify
`endif  // ------------------------------------------------------------------

`ifdef SP200MHZ //-----------------------------------------------------------
   parameter 			tKQ_pipe = 3.0;
   parameter 			tKQ_flow = 7.5;
   specify
      specparam
    	tKC_pipe	= 5,	// clock cycle time
    	tKQX_pipe	= 1.5,	// clock to output invalid
    	tLZ_pipe	= 1.5,	// clock to output in LOW-Z
    	tKC_flow	= 7.5,	// clock cycle time
    	tKQX_flow	= 3,	// clock to output invalid
    	tS_pipe		= 1.4,	// setup time
    	tH_pipe		= 0.4,	// hold time
    	tS_flow		= 1.5,	// setup time
    	tH_flow		= 0.5;	// hold time
   endspecify
`endif  // ------------------------------------------------------------------

`ifdef SP166MHZ //-----------------------------------------------------------
   parameter 			tKQ_pipe = 3.4;
   parameter 			tKQ_flow = 8.0;
   specify
      specparam
    	tKC_pipe	= 6,	// clock cycle time
    	tKQX_pipe	= 1.5,	// clock to output invalid
    	tKC_flow	= 8.0,	// clock cycle time
    	tKQX_flow	= 3,	// clock to output invalid
    	tS_pipe		= 1.5,	// setup time
    	tH_pipe		= 0.5,	// hold time
    	tS_flow		= 1.5,	// setup time
    	tH_flow		= 0.5;	// hold time
   endspecify
`endif  // ------------------------------------------------------------------

`ifdef SP150MHZ //-----------------------------------------------------------
   parameter 			tKQ_pipe = 3.8;
   parameter 			tKQ_flow = 8.5;
   specify
      specparam
    	tKC_pipe	= 6.7,	// clock cycle time
    	tKQX_pipe	= 1.5,	// clock to output invalid
    	tKC_flow	= 8.5,	// clock cycle time
    	tKQX_flow	= 3,	// clock to output invalid
    	tS_pipe		= 1.5,	// setup time
    	tH_pipe		= 0.5,	// hold time
    	tS_flow		= 1.5,	// setup time
    	tH_flow		= 0.5;	// hold time
   endspecify
`endif  // ------------------------------------------------------------------

`ifdef SP133MHZ //-----------------------------------------------------------
   parameter 			tKQ_pipe = 4.0;
   parameter 			tKQ_flow = 8.5;
   specify
      specparam
    	tKC_pipe	= 7.5,	// clock cycle time
    	tKQX_pipe	= 1.5,	// clock to output invalid
    	tKC_flow	= 8.5,	// clock cycle time
    	tKQX_flow	= 3,	// clock to output invalid
    	tS_pipe		= 1.5,	// setup time
    	tH_pipe		= 0.5,	// hold time
    	tS_flow		= 1.5,	// setup time
    	tH_flow		= 0.5;	// hold time
   endspecify
`endif  // ------------------------------------------------------------------

`include	"D:/work/Projects/vivado/sim_sram/src/core.v"

endmodule
