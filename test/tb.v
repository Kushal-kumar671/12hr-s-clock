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
    tt_um_clock_12h dut (
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
    wire [5:0] minutes = {uo_out[7:5], uio_out[7:4]};
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
        
        $display("Time\t\tHours\tMinutes\tSeconds\tAM/PM");
        $display("----\t\t-----\t-------\t-------\t-----");
        
        // Monitor for initial values
        #10;
        $display("%0t\t\t%0d\t%0d\t%0d\t%s", 
                 $time, hours, minutes, seconds, am_pm ? "PM" : "AM");
        
        // Wait for several clock cycles to test basic functionality
        repeat(50) begin
            #10;
            if ($time % 100 == 0) begin
                $display("%0t\t\t%0d\t%0d\t%0d\t%s", 
                         $time, hours, minutes, seconds, am_pm ? "PM" : "AM");
            end
        end
        
        // Test reset functionality
        $display("\nTesting reset...");
        rst_n = 1'b0;
        #50;
        rst_n = 1'b1;
        #10;
        $display("After reset: %0d:%02d:%02d %s", 
                 hours, minutes, seconds, am_pm ? "PM" : "AM");
        
        // Run for a longer period to test time progression
        $display("\nRunning longer test...");
        repeat(1000) begin
            #10;
            if ($time % 1000 == 0) begin
                $display("%0t\t\t%0d\t%0d\t%0d\t%s", 
                         $time, hours, minutes, seconds, am_pm ? "PM" : "AM");
            end
        end
        
        $display("\nTestbench completed successfully!");
        $finish;
    end
    
    // VCD dump for waveform viewing
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
    end
    
    // Timeout watchdog
    initial begin
        #1000000; // 1ms timeout
        $display("ERROR: Testbench timeout!");
        $finish;
    end

endmodule