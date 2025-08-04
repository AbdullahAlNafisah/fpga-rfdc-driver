module rfdc_driver #(
    parameter DATA_WIDTH = 256,           
    parameter NUM_SAMPLES = 64           
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        enable,          
    output logic [255:0] s_axis_tdata,   
    output logic        s_axis_tvalid,
    input  logic        s_axis_tready
);

    // Lookup Table
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
            idx <= '0;
        end else if (enable && s_axis_tready) begin
            idx <= idx + 1;
        end else begin
            idx <= 0;
        end
    end

    // Output generation
    assign s_axis_tdata = sine_lut[idx];
    assign s_axis_tvalid = enable;

endmodule
