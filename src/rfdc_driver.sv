module rfdc_driver #(
    parameter DATA_WIDTH = 16,            // Each sample is 16 bits
    parameter NUM_SAMPLES = 64,
    parameter SAMPLES_PER_CYCLE = 5       // You want 5 samples per AXI cycle
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        enable,          
    output logic [DATA_WIDTH*SAMPLES_PER_CYCLE-1:0] s_axis_tdata,   
    output logic        s_axis_tvalid,
    input  logic        s_axis_tready
);

    // Lookup Table for 16-bit signed samples
    logic signed [DATA_WIDTH-1:0] sine_lut[NUM_SAMPLES-1:0];
    int temp;

    initial begin : init_lut
        integer i;
        real pi = 3.1415926535;
        for (i = 0; i < NUM_SAMPLES; i++) begin
            temp = $rtoi($sin(2.0*pi*i/NUM_SAMPLES) * ((2.0**(DATA_WIDTH-1))-1));
            sine_lut[i] = temp;
        end
    end

    // Index counter
    localparam int IDX_WIDTH = $clog2(NUM_SAMPLES);
    logic [IDX_WIDTH-1:0] idx;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            idx <= 0;
        end else if (enable && s_axis_tready) begin
            if (idx + SAMPLES_PER_CYCLE < NUM_SAMPLES)
                idx <= idx + SAMPLES_PER_CYCLE;
            else
                idx <= 0;  // wrap around
        end
    end

    // Output generation - pack 5 samples into s_axis_tdata
    always_comb begin
        for (int i = 0; i < SAMPLES_PER_CYCLE; i++) begin
            s_axis_tdata[i*DATA_WIDTH +: DATA_WIDTH] = sine_lut[(idx + i) % NUM_SAMPLES];
        end
    end

    assign s_axis_tvalid = enable;

endmodule
