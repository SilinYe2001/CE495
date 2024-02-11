module sobel_filter #(
    parameter GRAY_DATA_WIDTH = 8 
    // parameter BUFFER_WIDTH = 3;
)(
    input  logic [8:0][GRAY_DATA_WIDTH-1:0]din ,
    output logic [GRAY_DATA_WIDTH-1:0] dout
);


shortint h,v;
//logic [GRAY_DATA_WIDTH+2:0] abs_h,abs_v;
shortint result;

always_comb begin
    h = din[6]+2*din[7]+ din[8]- din[0]-2*din[1]- din[2];
    v = din[2]+2*din[5]+ din[8]- din[0]-2*din[3]- din[6];

    dout=(abs(h)+abs(v))/2;
    // if (result>'d255) begin
    //     dout='d255;
    // end
    // else begin
    //     dout=result[GRAY_DATA_WIDTH-1:0];
    // end
   // dout=result >'d255 ? 'd255:result[GRAY_DATA_WIDTH-1:0];
end

function shortint abs(input shortint a);
    if(a>=0) 
        return (a);
    else
        return (-a);  
endfunction 

endmodule