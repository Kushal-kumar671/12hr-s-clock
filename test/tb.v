`timescale 1ns / 1ps

module tb;
    // Testbench signals
    reg [7:0] ui_in;
    wire [7:0] uo_out;
    reg [7:0] uio_in;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    reg ena;
    reg clk;
    reg rst_n;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock (10ns period)
    end
    
    // Instantiate the DUT
    tt_um_12hr_s_clock dut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );
    
    // Extract clock values for monitoring
    wire [3:0] hours = uo_out[3:0];
    wire am_pm = uo_out[4];
    wire [5:0] minutes = {uo_out[7:5], uio_out[7:5]}; // Combined minutes bits
    wire [5:0] seconds = {uio_out[3:0], 2'b00}; // Only upper 4 bits available
    
    // Test procedure
    initial begin
        // Initialize signals
        ui_in = 8'h00;
        uio_in = 8'h00;
        ena = 1'b1;
        rst_n = 1'b0;
        
        // Wait for reset
        #100;
        rst_n = 1'b1;
        
        $display("=== 12-Hour Clock Testbench ===");
        $display("Time\t\tHours\tMinutes\tSeconds\tAM/PM");
        $display("----\t\t-----\t-------\t-------\t-----");
        
        // Monitor for initial values
        #20;
        $display("%0t ns\t\t%0d\t%0d\t%0d\t%s", 
                 $time, hours, minutes, seconds, am_pm ? "PM" : "AM");
        
        // Wait for several clock cycles to test basic functionality
        repeat(100) begin
            #10;
            if ($time % 500 == 0) begin
                $display("%0t ns\t\t%0d\t%0d\t%0d\t%s", 
                         $time, hours, minutes, seconds, am_pm ? "PM" : "AM");
            end
        end
        
        // Test reset functionality
        $display("\n=== Testing Reset ===");
        rst_n = 1'b0;
        #50;
        rst_n = 1'b1;
        #20;
        $display("After reset: %0d:%02d:%02d %s", 
                 hours, minutes, seconds, am_pm ? "PM" : "AM");
        
        // Verify initial state
        if (hours == 12 && minutes == 0 && am_pm == 0) begin
            $display("✓ Reset to 12:00:00 AM - PASS");
        end else begin
            $display("✗ Reset failed - Expected 12:00:00 AM, got %0d:%02d:%02d %s", 
                     hours, minutes, seconds, am_pm ? "PM" : "AM");
        end
        
        // Test enable/disable
        $display("\n=== Testing Enable Signal ===");
        ena = 1'b0;
        #100;
        $display("With ena=0: Clock should not advance");
        ena = 1'b1;
        #100;
        $display("With ena=1: Clock should advance");
        
        // Check I/O configuration
        if (uio_oe == 8'hFF) begin
            $display("✓ I/O enable configuration - PASS");
        end else begin
            $display("✗ I/O enable configuration - FAIL (expected 0xFF, got 0x%02X)", uio_oe);
        end
        
        // Run for a longer period
        $display("\n=== Extended Test ===");
        repeat(2000) begin
            #10;
            if ($time % 2000 == 0) begin
                $display("%0t ns\t\t%0d\t%0d\t%0d\t%s", 
                         $time, hours, minutes, seconds, am_pm ? "PM" : "AM");
            end
        end
        
        // Final checks
        if (hours >= 1 && hours <= 12) begin
            $display("✓ Hours in valid range (1-12) - PASS");
        end else begin
            $display("✗ Hours out of range - FAIL (got %d)", hours);
        end
        
        if (minutes <= 59) begin
            $display("✓ Minutes in valid range (0-59) - PASS");
        end else begin
            $display("✗ Minutes out of range - FAIL (got %d)", minutes);
        end
        
        $display("\n=== Testbench Complete ===");
        $finish;
    end
    
    // VCD dump for waveform viewing
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
    end
    
    // Timeout watchdog
    initial begin
        #100000; // 100us timeout
        $display("ERROR: Testbench timeout!");
        $finish;
    end

endmodule