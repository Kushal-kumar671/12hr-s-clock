/*
 * Copyright (c) 2024 Your Name Here
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_12hr_s_clock (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // Always 1 when the design is powered, so we can ignore
    input  wire       clk,      // Clock
    input  wire       rst_n     // Reset_n - low to reset
);

    // Internal clock signals
    reg [3:0] hours;
    reg [5:0] minutes;
    reg [5:0] seconds;
    reg am_pm;
    
    // Clock divider for 1 second timing (10MHz -> 1Hz)
    reg [23:0] clk_div;
    localparam CLK_DIV_MAX = 24'd9_999_999; // 10MHz - 1
    wire sec_tick = (clk_div == CLK_DIV_MAX);
    
    // Clock divider logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div <= 24'd0;
        end else if (ena) begin
            if (sec_tick) begin
                clk_div <= 24'd0;
            end else begin
                clk_div <= clk_div + 1'b1;
            end
        end
    end
    
    // 12-hour clock logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hours <= 4'd12;    // 12:00:00 AM
            minutes <= 6'd0;
            seconds <= 6'd0;
            am_pm <= 1'b0;     // AM
        end else if (ena && sec_tick) begin
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
                        hours <= hours + 1'b1;
                    end
                end else begin
                    minutes <= minutes + 1'b1;
                end
            end else begin
                seconds <= seconds + 1'b1;
            end
        end
    end
    
    // Output assignments - spread across available pins
    assign uo_out[3:0] = hours;           // Hours (1-12)
    assign uo_out[4] = am_pm;             // AM/PM (0=AM, 1=PM)
    assign uo_out[7:5] = minutes[5:3];    // Upper 3 bits of minutes
    assign uio_out[3:0] = minutes[3:0];   // Lower 4 bits of minutes  
    assign uio_out[7:4] = seconds[5:2];   // Upper 4 bits of seconds
    
    // Configure all uio pins as outputs
    assign uio_oe = 8'hFF;
    
    // Prevent synthesis warnings for unused inputs
    wire _unused_ok = &{ui_in, uio_in, seconds[1:0], 1'b0};

endmodule

`default_nettype wire