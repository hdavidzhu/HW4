`ifdef _regfileAsLibrary
  `include "regfile/decoders.v"
  `include "regfile/register32.v"
  `include "regfile/register32zero.v"
  `include "regfile/mux32to1by32.v"
`else
  `include "decoders.v"
  `include "register32.v"
  `include "register32zero.v"
  `include "mux32to1by32.v"
`endif

//------------------------------------------------------------------------------
// MIPS register file
//   width: 32 bits
//   depth: 32 words (reg[0] is static zero register)
//   2 asynchronous read ports
//   1 synchronous, positive edge triggered write port
//------------------------------------------------------------------------------

module regfile (
  output [31:0] ReadData1,	   // Contents of first register read
  output [31:0] ReadData2,	   // Contents of second register read
  input  [31:0]	WriteData,	   // Contents to write to register
  input  [4:0]	ReadRegister1, // Address of first register to read
  input  [4:0]	ReadRegister2, // Address of second register to read
  input  [4:0]	WriteRegister, // Address of register to write
  input		      RegWrite,	     // Enable writing of register when High
  input		      Clk		         // Clock (Positive Edge Triggered)
);

  // <<<<<<<< TEST: Uncomment this to have a broken write enable
  // assign RegWrite = 1'b1;
  // >>>>>>>>

  // <<<<<<<< TEST: Toggle this to have a broken decoder
  wire [31:0] registerEnable;
  decoder1to32 decoder1to32(registerEnable, RegWrite, WriteRegister);
  // ========
  // wire [31:0] registerEnable;
  // assign registerEnable = 32'hFFFFFFFF;
  // >>>>>>>>

  wire [31:0] [31:0] regOuts;
  // <<<<<<<< TEST: Toggle this to have a regular register
  register32zero connectZero(regOuts[0], WriteData, registerEnable[0], Clk);
  // ========
  // register32 connectZero(regOuts[0], WriteData, registerEnable[0], Clk);
  // >>>>>>>>

  genvar i;
  generate
    for (i = 1; i < 32; i = i + 1) begin:register32Connects
      register32 connectRegister(regOuts[i], WriteData, registerEnable[i], Clk);
    end
  endgenerate

  mux32to1by32 chooseReadData1(ReadData1, ReadRegister1, regOuts);

  // <<<<<<<< TEST: Toggle to have a broken port 2
  mux32to1by32 chooseReadData2(ReadData2, ReadRegister2, regOuts);
  // ========
  // mux32to1by32 chooseReadData2(ReadData2, 5'd17, regOuts);
  // >>>>>>>>
endmodule
