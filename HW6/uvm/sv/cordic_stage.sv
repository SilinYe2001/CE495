module cordic_stage (
    input logic clk,
    input logic reset,
    input logic valid_in,
    input int k,
    input shortint c,
    input shortint xk,
    input shortint yk,
    input shortint zk,
    output logic valid_out,
    output shortint x_out,
    output shortint y_out,
    output shortint z_out
);
logic [15:0] d;
logic [15:0] tx_0, tx_1, tx_2, tx_3;
logic [15:0] ty_0, ty_1, ty_2, ty_3;
logic [15:0] tz;
// shortint signed d,tx,ty,tz;
// always_comb begin
//     if (zk>=0) begin
//         // d=0;
//         tx=xk-((yk>>k)^16'h0);
//         ty=yk+((xk>>k)^16'h0);
//         tz=zk-(c^16'h0);
//     end
//     else begin
//         // d=16'shffff;   //-1
//         tx=xk-((yk>>k)^16'shffff)+16'shffff;
//         ty=yk+((xk>>k)^16'shffff)+16'sh1;
//         tz=zk-(c^16'shffff)+16'shffff;
//     end
// end

always_comb begin 
    d = ($signed(zk) >= 0) ? 16'h0000 : 16'hFFFF;
    tx_0 = $signed(yk) >>> k;
    tx_1 = tx_0 ^ d;
    tx_2 = tx_1 - d;
    tx_3 = xk - tx_2; 
    ty_0 = $signed(xk) >>> k;
    ty_1 = ty_0 ^ d;
    ty_2 = ty_1 - d;
    ty_3 = yk + ty_2;
    tz = $signed($signed(zk) - $signed($signed(c ^ d) - $signed(d)));
end
always @(posedge clk or posedge reset) begin
    if (reset) begin
        x_out<='0;
        y_out<='0;
        z_out<='0;
        valid_out<='0;
    end
    else begin
        x_out<=tx_3;
        y_out<=ty_3;
        z_out<=tz;
        valid_out<=valid_in;
    end
end
endmodule