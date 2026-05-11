// distributed under the mit license
// https://opensource.org/licenses/mit-license.php

`timescale 1 ns / 1 ps
`default_nettype none

module rptr_empty

    #(
    parameter ADDRSIZE = 4      )(
    input  wire                rclk,
    input  wire                rrst_n,
    input  wire                rinc, // Read enable, yêu cầu đọc dữ liệu từ FIFO. Khi rinc=1 và FIFO không empty, read pointer tăng
    input  wire [ADDRSIZE  :0] rq2_wptr, // Write pointer đã được đồng bộ sang read clock domain kiểm tra FIFO empty 
    output reg                 rempty, // FIFO thực sự empty, read pointer = write pointer -> rempty = 1 
    output reg                 arempty, // cảnh báo FIFO gần trống, dự đoán trước 1 bước
    output wire [ADDRSIZE-1:0] raddr, // Địa chỉ đọc từ RAM nội bộ của FIFO triển khai từ rbin 
    output reg  [ADDRSIZE  :0] rptr // Read pointer dạng Gray code, gửi sang write domain để so sánh với write pointer, xác định empty
                                    // Nó không dùng trực tiếp để truy cập RAM. RAM sử dụng binary pointer (rbin) làm địa chỉ đọc
    );

    reg  [ADDRSIZE:0] rbin; // Read pointer dạng binary, dùng để đọc memory, con trỏ đọc dạng binary
    wire [ADDRSIZE:0] rgraynext, rbinnext, rgraynextm1;
    wire              arempty_val, rempty_val;

    //-------------------
    // GRAYSTYLE2 pointer
    //------------  -------
    always @(posedge rclk or negedge rrst_n) begin

        if (!rrst_n)
            {rbin, rptr} <= 0;
        else
            {rbin, rptr} <= {rbinnext, rgraynext};

    end

    // Memory read-address pointer (okay to use binary to address memory)
    assign raddr     = rbin[ADDRSIZE-1:0];
    assign rbinnext  = rbin + ((rinc & ~rempty) ? 1 : 0);
    assign rgraynext = (rbinnext >> 1) ^ rbinnext;
    assign rgraynextm1 = ((rbinnext + 1'b1) >> 1) ^ (rbinnext + 1'b1);

    //---------------------------------------------------------------
    // FIFO empty when the next rptr == synchronized wptr or on reset
    //---------------------------------------------------------------
    assign rempty_val = (rgraynext == rq2_wptr); // Đọc xong hiện tại thì hết -> empty 
    assign arempty_val = (rgraynextm1 == rq2_wptr); // Đọc thêm 1 thì hết -> almost empty (kiểu dự đoán trước)

    always @ (posedge rclk or negedge rrst_n) begin

        if (!rrst_n) begin
            arempty <= 1'b0;
            rempty <= 1'b1;
        end
        else begin
            arempty <= arempty_val;
            rempty <= rempty_val;
        end

    end

endmodule

`resetall
