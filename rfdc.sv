module rfdc_driver #(
    parameter DATA_WIDTH = 16,           // bits per sample
    parameter NUM_SAMPLES = 64           // samples per sine wave cycle
)(
    input  logic        clk,
    input  logic        resetn,
    input  logic        enable,          // switch input
    output logic [255:0] s_axis_tdata,   // 16 channels * 16 bits = 256 bits
    output logic        s_axis_tvalid,
    input  logic        s_axis_tready
);

    // -----------------------------------
    // Lookup Table for sine wave
    // Pre-computed signed samples (scaled)
    // One channel example, replicated for 16 samples
    // -----------------------------------
    logic signed [DATA_WIDTH-1:0] sine_lut[NUM_SAMPLES-1:0];

    initial begin : init_lut
        integer i;
        real pi = 3.1415926535;
        for (i = 0; i < NUM_SAMPLES; i = i + 1) begin
            sine_lut[i] = $rtoi($sin(2.0*pi*i/NUM_SAMPLES) * ((2**(DATA_WIDTH-1))-1));
        end
    end

    // -----------------------------------
    // Index counter
    // -----------------------------------
    logic [$clog2(NUM_SAMPLES)-1:0] idx;

    always_ff @(posedge clk) begin
        if (!resetn) begin
            idx <= 0;
        end else if (enable && s_axis_tready) begin
            idx <= (idx == NUM_SAMPLES-1) ? 0 : idx + 1;
        end
    end

    // -----------------------------------
    // Generate tdata: replicate sine sample across 16 channels
    // -----------------------------------
    integer ch;
    always_comb begin
        s_axis_tdata = '0;
        for (ch = 0; ch < 16; ch = ch + 1) begin
            s_axis_tdata[ch*DATA_WIDTH +: DATA_WIDTH] = sine_lut[idx];
        end
    end

    // -----------------------------------
    // Valid signal
    // -----------------------------------
    assign s_axis_tvalid = enable;

endmodule