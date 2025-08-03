module rfdc_driver #(
    parameter DATA_WIDTH = 16,           
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
            sine_lut[i] = temp[DATA_WIDTH-1:0];
        end
    end

    // Index counter
    localparam int IDX_WIDTH = $clog2(NUM_SAMPLES);
    // localparam logic [IDX_WIDTH-1:0] IDX_MAX = logic'(NUM_SAMPLES - 1);

    logic [IDX_WIDTH-1:0] idx;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            idx <= '0;
        end else if (enable && s_axis_tready) begin
            // if (idx == IDX_MAX)
            //     idx <= '0;
            // else
                idx <= idx + 1'b1;
        end
    end

    // Output generation
    integer ch;
    always_comb begin
        s_axis_tdata = '0;
        for (ch = 0; ch < 16; ch++) begin
            s_axis_tdata[ch*DATA_WIDTH +: DATA_WIDTH] = sine_lut[idx];
        end
    end

    assign s_axis_tvalid = enable;

endmodule
