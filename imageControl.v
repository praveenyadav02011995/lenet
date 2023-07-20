`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// 
// Design Name: 
// Module Name: imageControl
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

module imageControl(
input                    i_clk,
input                    i_rst,
input [7:0]              i_pixel_data,// input is coming one pixel at a time 
input                    i_pixel_data_valid,
output reg [199:0]        o_pixel_data,// we are readng 5*5 element at a time and each having 8 bit so 25*8=200
output                   o_pixel_data_valid,
output reg               o_intr
);

reg [5:0] pixelCounter;// 32 input in one line hence 5 bit 
reg [2:0] currentWrLineBuffer;// because we have 5 line buffer so require 3 bit 
reg [5:0] lineBuffDataValid;// we are taking 6 line buffer for faster execution
reg [3:0] lineBuffRdData;//
reg [2:0] currentRdLineBuffer;
reg [2:0] temp;
wire [39:0] lb0data;
wire [39:0] lb1data;
wire [39:0] lb2data;
wire [39:0] lb3data;
wire [39:0] lb4data;
wire [39:0] lb5data;
reg [5:0] rdCounter;
reg rd_line_buffer;
reg [8:0] totalPixelCounter;// max is 32*6 i.e 2^8
reg rdState;

localparam IDLE = 'b0,
           RD_BUFFER = 'b1;

assign o_pixel_data_valid = rd_line_buffer;

always @(posedge i_clk)
begin
    if(i_rst)
        totalPixelCounter <= 0;
    else
    begin
        if(i_pixel_data_valid & !rd_line_buffer)
            totalPixelCounter <= totalPixelCounter + 1;
        else if(!i_pixel_data_valid & rd_line_buffer)
            totalPixelCounter <= totalPixelCounter - 1;
    end
end

always @(posedge i_clk)
begin
    if(i_rst)
    begin
        rdState <= IDLE;
        rd_line_buffer <= 1'b0;
        o_intr <= 1'b0;
    end
    else
    begin
        case(rdState)
            IDLE:begin
                o_intr <= 1'b0;
                if(totalPixelCounter >= 160)// 32*5 read only when all buffer are full 
                begin
                    rd_line_buffer <= 1'b1;
                    rdState <= RD_BUFFER;
                end
            end
            RD_BUFFER:begin
                if(rdCounter == 31 )
                begin
                    rdState <= IDLE;
                    rd_line_buffer <= 1'b0;
                    o_intr <= 1'b1;
                end
            end
        endcase
    end
end
    
// Here we are using logic that at first line 32 input 
always @(posedge i_clk)
begin
    if(i_rst)
        pixelCounter <= 0;
    else 
    begin
        if(i_pixel_data_valid) // whenver valid data come it will increment 
            pixelCounter <= pixelCounter + 1;
    end
end

// demultiplexer
always @(posedge i_clk)
begin
    if(i_rst)
        currentWrLineBuffer <= 0;
    else
    begin
        if(pixelCounter == 31 & i_pixel_data_valid) // we recieved 31 and one more data is comming  
            currentWrLineBuffer <= currentWrLineBuffer+1;
    end
end


always @(*)
begin
    lineBuffDataValid = 6'h0;
    lineBuffDataValid[currentWrLineBuffer] = i_pixel_data_valid;
end

always @(posedge i_clk)
begin
    if(i_rst)
        rdCounter <= 0;
    else 
    begin
        if(rd_line_buffer)
            rdCounter <= rdCounter + 1;
    end
end

always @(posedge i_clk)
begin
    if(i_rst)
    begin
        currentRdLineBuffer <= 0;
    end
    else
    begin
        if(rdCounter == 31 & rd_line_buffer)
            currentRdLineBuffer <= currentRdLineBuffer + 1;
    end
end


always @(posedge i_clk)
begin
    if(currentRdLineBuffer == 6)
    begin
        temp <= 0;
    end
    else if(currentRdLineBuffer == 7)
    begin 
        temp<=1;
    end
    else
    begin
        temp <= currentRdLineBuffer;
    end
end


always @(*)
begin
    case(temp)
        0:begin
            o_pixel_data = {lb4data,lb3data,lb2data,lb1data,lb0data};
        end
        1:begin
            o_pixel_data = {lb5data,lb4data,lb3data,lb2data,lb1data};
        end
        2:begin
            o_pixel_data = {lb0data,lb5data,lb4data,lb3data,lb2data};
        end
        3:begin
            o_pixel_data = {lb1data,lb0data,lb5data,lb4data,lb3data};
        end
       4:begin
           o_pixel_data = {lb2data,lb1data,lb0data,lb5data,lb4data};
         end
       5:begin
           o_pixel_data = {lb3data,lb2data,lb1data,lb0data,lb5data};
         end
          

    endcase
end
// now we are reading whole 5 line of input at a time .


always @(*)
begin
    case(temp)
        0:begin
            lineBuffRdData[0] = rd_line_buffer;
            lineBuffRdData[1] = rd_line_buffer;
            lineBuffRdData[2] = rd_line_buffer;
            lineBuffRdData[3] = rd_line_buffer;
            lineBuffRdData[4] = rd_line_buffer;
            lineBuffRdData[5] = 1'b0;
        end
       1:begin
            lineBuffRdData[0] = 1'b0;
            lineBuffRdData[1] = rd_line_buffer;
            lineBuffRdData[2] = rd_line_buffer;
            lineBuffRdData[3] = rd_line_buffer;
            lineBuffRdData[4] = rd_line_buffer;
            lineBuffRdData[5] = rd_line_buffer;

        end
       2:begin
             lineBuffRdData[0] = rd_line_buffer;
             lineBuffRdData[1] = 1'b0;
             lineBuffRdData[2] = rd_line_buffer;
             lineBuffRdData[3] = rd_line_buffer;
             lineBuffRdData[4] = rd_line_buffer;
             lineBuffRdData[5] = rd_line_buffer;
             
       end  
      3:begin
             lineBuffRdData[0] = rd_line_buffer;
             lineBuffRdData[1] = rd_line_buffer;
             lineBuffRdData[2] = 1'b0;
             lineBuffRdData[3] = rd_line_buffer;
             lineBuffRdData[4] = rd_line_buffer;
             lineBuffRdData[5] = rd_line_buffer;
            
       end 
      4:begin
             lineBuffRdData[0] = rd_line_buffer;
             lineBuffRdData[1] = rd_line_buffer;
             lineBuffRdData[2] = rd_line_buffer;
             lineBuffRdData[3] = 1'b0;
             lineBuffRdData[4] = rd_line_buffer;
             lineBuffRdData[5] = rd_line_buffer;
            
       end
       5:begin
             lineBuffRdData[0] = rd_line_buffer;
             lineBuffRdData[1] = rd_line_buffer;
             lineBuffRdData[2] = rd_line_buffer;
             lineBuffRdData[3] = rd_line_buffer;
             lineBuffRdData[4] = 1'b0;
             lineBuffRdData[5] = rd_line_buffer;
            
       end
             
    endcase
end
    
lineBuffer lB0(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data(i_pixel_data),
    .i_data_valid(lineBuffDataValid[0]),
    .o_data(lb0data),
    .i_rd_data(lineBuffRdData[0])
 ); 
 
 lineBuffer lB1(
     .i_clk(i_clk),
     .i_rst(i_rst),
     .i_data(i_pixel_data),
     .i_data_valid(lineBuffDataValid[1]),
     .o_data(lb1data),
     .i_rd_data(lineBuffRdData[1])
  ); 
  
  lineBuffer lB2(
      .i_clk(i_clk),
      .i_rst(i_rst),
      .i_data(i_pixel_data),
      .i_data_valid(lineBuffDataValid[2]),
      .o_data(lb2data),
      .i_rd_data(lineBuffRdData[2])
   ); 
   
   lineBuffer lB3(
       .i_clk(i_clk),
       .i_rst(i_rst),
       .i_data(i_pixel_data),
       .i_data_valid(lineBuffDataValid[3]),
       .o_data(lb3data),
       .i_rd_data(lineBuffRdData[3])
    );
   lineBuffer lB4(
       .i_clk(i_clk),
       .i_rst(i_rst),
       .i_data(i_pixel_data),
       .i_data_valid(lineBuffDataValid[4]),
       .o_data(lb4data),
       .i_rd_data(lineBuffRdData[4])
    );
   lineBuffer lB5(
       .i_clk(i_clk),
       .i_rst(i_rst),
       .i_data(i_pixel_data),
       .i_data_valid(lineBuffDataValid[5]),
       .o_data(lb5data),
       .i_rd_data(lineBuffRdData[5])
    );    
    
    
endmodule