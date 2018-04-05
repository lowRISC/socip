module instr_wrap(
    input logic    clk_i,    // Clock
    input logic    rst_ni,  // Asynchronous reset active low
    input tracer_t tracer,
    output logic [1229:0] capture
);

instr_in capture1(
         .clk_i(clk_i),
         .rst_ni(rst_ni),
         .capture_out(capture),              // output wire [96 : 0] pc_status
         .capture_in(tracer));
 
endmodule

module instr_in(
input logic    clk_i,    // Clock
input logic    rst_ni,  // Asynchronous reset active low
input logic [1229:0] capture_in,
output logic [1229:0] capture_out
);

always @(posedge clk_i)
    if (rst_ni == 0)
    capture_out <= 0;
    else
    capture_out <= capture_in;
    
endmodule
