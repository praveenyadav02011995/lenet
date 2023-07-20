`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2020 07:25:49 PM
// Design Name: 
// Module Name: lineBuffer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module lineBuffer(
input   i_clk,
input   i_rst,
input [7:0] i_data,// one pixel  is comming at a time 
input   i_data_valid,
output [39:0] o_data,// output 5 pixel (each having 8 bit)
input i_rd_data// there should be some signal which should indicate data should be read from line buffer
);

reg [7:0] line [31:0]; //line buffer is also memory . so each having 8  bit and there are (32)
reg [4:0] wrPntr;//we need wrpntr pointer in which location we are writing
reg [5:0] rdPntr;//  we need rdpntr to read 
// so we need some variable(wrpntr) over here we
//need some register which will basically
//tell me in which memory location this
//new data should be stored
//okay so let's call that register right
//point because it's similar to a point in
//software what should be the size of the
//right pointer and the size of the right
//pointer will be log to the base to the
//depth of your memory
//between 0 to Phi 4 right so log of 32
always @(posedge i_clk)
begin
    if(i_data_valid)
        line[wrPntr] <= i_data;
end

always @(posedge i_clk)
begin
    if(i_rst)
        wrPntr <= 'd0;
    else if(i_data_valid)
        wrPntr <= wrPntr + 'd1;
end

assign o_data = {line[rdPntr],line[rdPntr+1],line[rdPntr+2],line[rdPntr+3],line[rdPntr+4]};

always @(posedge i_clk)
begin
    if(i_rst)
        rdPntr <= 'd0;
    else if(i_rd_data)
        rdPntr <= rdPntr + 'd1;
end


endmodule 