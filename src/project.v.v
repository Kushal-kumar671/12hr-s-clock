module tt_um_clock_12h (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // Internal signals
    reg [3:0] hours;
    reg [5:0] minutes;
    reg [5:0] seconds;
    reg am_pm;
    
    // Reset is active low in TinyTapeout
    wire rst = ~rst_n;
    
    // Clock divider for 1 second timing (assuming 10MHz clock)
    // Adjust this value based on actual clock frequency
    reg [23:0] clk_div;
    wire sec_tick = (clk_div == 24'd9_999_999);
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_div <= 24'd0;
        end else if (sec_tick) begin
            clk_div <= 24'd0;
        end else begin
            clk_div <= clk_div + 1;
        end
    end
    
    // 12-hour clock logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            hours <= 4'd12;    // 12:00:00 AM
            minutes <= 6'd0;
            seconds <= 6'd0;
            am_pm <= 1'b0;     // AM
        end else if (sec_tick) begin
            if (seconds == 6'd59) begin
                seconds <= 6'd0;
                if (minutes == 6'd59) begin
                    minutes <= 6'd0;
                    if (hours == 4'd11) begin
                        hours <= 4'd12;
                        am_pm <= ~am_pm;
                    end else if (hours == 4'd12) begin
                        hours <= 4'd1;
                    end else begin
                        hours <= hours + 1;
                    end
                end else begin
                    minutes <= minutes + 1;
                end
            end else begin
                seconds <= seconds + 1;
            end
        end
    end
    
    // Output assignments
    assign uo_out[3:0] = hours;      // Hours on lower 4 bits
    assign uo_out[7:4] = {1'b0, am_pm, minutes[5:4]}; // AM/PM and upper minutes bits
    assign uio_out = {minutes[3:0], seconds[5:2]}; // Lower minutes bits and upper seconds bits
    assign uio_oe = 8'hFF;  // All IOs as outputs
    
    // Unused inputs
    wire _unused = &{ena, ui_in, uio_in, seconds[1:0], 1'b0};

endmodule