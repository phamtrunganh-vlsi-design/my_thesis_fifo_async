// distributed under the mit license
// https://opensource.org/licenses/mit-license.php

`timescale 1 ns / 1 ps
`default_nettype none

module fifomem // dung lượng = 2^4 x 8 = 128 bits 

    #(
        parameter  DATASIZE = 8,    // Memory data word width (mỗi ô nhớ rộng 8 bits)
        parameter  ADDRSIZE = 4,    // Number of mem address bits (có 4 ô nhớ)
        parameter  FALLTHROUGH = "TRUE" // First word fall-through
    ) (
        input  wire                wclk,
        input  wire                wclken,
        input  wire [ADDRSIZE-1:0] waddr,
        input  wire [DATASIZE-1:0] wdata,
        input  wire                wfull,
        input  wire                rclk,
        input  wire                rclken,
        input  wire [ADDRSIZE-1:0] raddr, // read address 
        output wire [DATASIZE-1:0] rdata
    );

    localparam DEPTH = 1<<ADDRSIZE; // Tính DEPTH = 2^ADDRSIZE  

    reg [DATASIZE-1:0] mem [0:DEPTH-1];
    reg [DATASIZE-1:0] rdata_r; // “buffer / register tạm thời” cho output khi dùng chế độ registered read

    integer i;
    initial begin
    for (i=0; i<DEPTH; i=i+1)
        mem[i] = 0;
    end

    always @(posedge wclk) begin
        if (wclken && !wfull)
            mem[waddr] <= wdata;
    end

    generate
        if (FALLTHROUGH == "TRUE")
        begin : fallthrough
            assign rdata = mem[raddr];
        end
        else // khi FALLTHROUGH = "FALSE" -> registered read, Latency = 1 chu kỳ read clock
        begin : registered_read
            always @(posedge rclk) begin
                if (rclken)
                    rdata_r <= mem[raddr];  // lưu dữ liệu vào register tạm, Đảm bảo dữ liệu ra rdata đồng bộ theo clock rclk
            end
            assign rdata = rdata_r; // output rdata luôn lấy từ register này, chứ không trực tiếp từ mem tránh glitch và comb path dài (delay lớn)
        end
    endgenerate

endmodule

`resetall
