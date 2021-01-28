module top(
          gpio_io,

          io_spi_clk,
          io_spi_csn,
          io_spi_mosi,
          io_spi_miso,

          jtag_TDI,
          jtag_TDO,
          jtag_TCK,
          jtag_TMS,


          wbuart_rx,
          wbuart_tx,

          clk_in,
          resetn_in,

          SDA_yuyin,
            key,
            Trig,
            Echo,
            Trig2,
            Echo2,
            rgb_out,
            rgb_out2,
            sda,
            sclk

);



    inout [0:0] gpio_io;

    wire slv_ext_stb_o;
    wire slv_ext_we_o;
    wire slv_ext_cyc_o;
    reg slv_ext_ack_i;
    wire [31:0] slv_ext_adr_o;
    wire [31:0] slv_ext_wdata_o;
    reg [31:0] slv_ext_rdata_i;
    wire [3:0] slv_ext_sel_o;

    inout io_spi_clk;
    inout io_spi_csn;
    inout io_spi_mosi;
    inout io_spi_miso;

    input jtag_TDI;
    output jtag_TDO;
    input jtag_TCK;
    input jtag_TMS;
    
    output wbuart_tx;
    input wbuart_rx;

    input clk_in;
    input resetn_in;

    input Echo;
    output Trig;
    input Echo2;
    output Trig2;
    output rgb_out;
    output rgb_out2;
    output SDA_yuyin;
    input key;

    output sclk;
    inout sda;
   

    wire slv_ext_ack_ia;
    wire slv_ext_ack_ib;
    wire slv_ext_ack_ic;
    wire slv_ext_ack_id;
    wire slv_ext_ack_ie;

    wire [31:0]slv_ext_rdata_ia;
    wire [31:0]slv_ext_rdata_ib;
    wire [31:0]slv_ext_rdata_ic;
    wire [31:0]slv_ext_rdata_id;
    wire [31:0]slv_ext_rdata_ie;

Gowin_PicoRV32_Top u0(

  .gpio_io(gpio_io),

  .slv_ext_stb_o(slv_ext_stb_o),
  .slv_ext_we_o(slv_ext_we_o),
  .slv_ext_cyc_o(slv_ext_cyc_o),
  .slv_ext_ack_i(slv_ext_ack_i),
  .slv_ext_adr_o(slv_ext_adr_o),
  .slv_ext_wdata_o(slv_ext_wdata_o),
  .slv_ext_rdata_i(slv_ext_rdata_i),
  .slv_ext_sel_o(slv_ext_sel_o),

  .io_spi_clk(io_spi_clk),
  .io_spi_csn(io_spi_csn),
  .io_spi_mosi(io_spi_mosi),
  .io_spi_miso(io_spi_miso),

  .jtag_TDI(jtag_TDI),
  .jtag_TDO(jtag_TDO),
  .jtag_TCK(jtag_TCK),
  .jtag_TMS(jtag_TMS),

  .wbuart_tx(wbuart_tx),
  .wbuart_rx(wbuart_rx),

  .clk_in(clk_in),
  .resetn_in(resetn_in)
);

yuyin u1(
    .clk_50m(clk_in),
    .rst_n(resetn_in),
    .SDA(SDA_yuyin),
    .slv_ext_stb_o(slv_ext_stb_o),
    .slv_ext_we_o(slv_ext_we_o),
    .slv_ext_cyc_o(slv_ext_cyc_o),
    .slv_ext_adr_o(slv_ext_adr_o[5:2]),
    .slv_ext_wdata_o(slv_ext_wdata_o),  //32bit
    .slv_ext_sel_o(slv_ext_sel_o),

//output for wb bus
    .slv_ext_ack_i(slv_ext_ack_ia),
    .slv_ext_rdata_i(slv_ext_rdata_ia),  //32bit
    .key(key)
);


us015 u2(
    .Echo(Echo),
    .Trig(Trig),
    //input from wb bus
    .slv_ext_stb_o(slv_ext_stb_o),
    .slv_ext_we_o(slv_ext_we_o),
    .slv_ext_cyc_o(slv_ext_cyc_o),
    .slv_ext_adr_o(slv_ext_adr_o[5:2]),
    .slv_ext_wdata_o(slv_ext_wdata_o),  //32bit
    .slv_ext_sel_o(slv_ext_sel_o),

    //output for wb bus
    .slv_ext_ack_i(slv_ext_ack_ib),
    .slv_ext_rdata_i(slv_ext_rdata_ib),  //32bit

    //sys input
    .clkin(clk_in),    
    .resetn(resetn_in)
);


wbrgb u3(

    //input from wb bus
    .slv_ext_stb_o(slv_ext_stb_o),
    .slv_ext_we_o(slv_ext_we_o),
    .slv_ext_cyc_o(slv_ext_cyc_o),
    .slv_ext_adr_o(slv_ext_adr_o[5:2]),
    .slv_ext_wdata_o(slv_ext_wdata_o),  //32bit
    .slv_ext_sel_o(slv_ext_sel_o),

    //output for wb bus
    .slv_ext_ack_i(slv_ext_ack_ic),
    .slv_ext_rdata_i(slv_ext_rdata_ic),  //32bit

    //sys input
    .clkin(clk_in),    
    .resetn(resetn_in),

    //wbrgb output
    .rgb_out(rgb_out)

);


us015 u4(
    .Echo(Echo2),
    .Trig(Trig2),
    //input from wb bus
    .slv_ext_stb_o(slv_ext_stb_o),
    .slv_ext_we_o(slv_ext_we_o),
    .slv_ext_cyc_o(slv_ext_cyc_o),
    .slv_ext_adr_o(slv_ext_adr_o[5:2]),
    .slv_ext_wdata_o(slv_ext_wdata_o),  //32bit
    .slv_ext_sel_o(slv_ext_sel_o),

    //output for wb bus
    .slv_ext_ack_i(slv_ext_ack_id),
    .slv_ext_rdata_i(slv_ext_rdata_id),  //32bit

    //sys input
    .clkin(clk_in),    
    .resetn(resetn_in)
);


smbus906 u5(               //GY906
    //input from wb bus
    .slv_ext_stb_o(slv_ext_stb_o),
    .slv_ext_we_o(slv_ext_we_o),
    .slv_ext_cyc_o(slv_ext_cyc_o),
    .slv_ext_adr_o(slv_ext_adr_o[5:2]),
    .slv_ext_wdata_o(slv_ext_wdata_o),
    .slv_ext_sel_o(slv_ext_sel_o),                  
                       //output for wb bus
    .slv_ext_ack_i(slv_ext_ack_ie),
    .slv_ext_rdata_i(slv_ext_rdata_ie),                                        
                     //GY906
    .sda(sda),
    .sclk(sclk),               
                     //system
    .clk_in(clk_in),
    .resetn_in(resetn_in)
);


always@(*)
    case(slv_ext_adr_o[5:2])
        4'b0000  :                            //语音模块
            begin
                slv_ext_ack_i = slv_ext_ack_ia;
                slv_ext_rdata_i = slv_ext_rdata_ia;
            end
        4'b0001  :                           //超声波1
            begin
                slv_ext_ack_i = slv_ext_ack_ib;
                slv_ext_rdata_i = slv_ext_rdata_ib;
            end
        4'b0010  :                           //RGB模块
            begin
                slv_ext_ack_i = slv_ext_ack_ic;
                slv_ext_rdata_i = slv_ext_rdata_ic;
            end
        4'b0011  :                           //超声波2
            begin
                slv_ext_ack_i = slv_ext_ack_id;
                slv_ext_rdata_i = slv_ext_rdata_id;
            end
        default :                            //测温
            begin
                slv_ext_ack_i = slv_ext_ack_ie;
                slv_ext_rdata_i = slv_ext_rdata_ie;               
            end

    endcase

assign rgb_out2 = rgb_out;

/*
assign slv_ext_ack_i = (~slv_ext_adr_o[3]) ? slv_ext_ack_ia : slv_ext_ack_ib;
assign slv_ext_ack_ia = (~slv_ext_adr_o[2]) ? slv_ext_ack_ic : slv_ext_ack_id;
assign slv_ext_ack_ib = (~slv_ext_adr_o[2]) ? slv_ext_ack_ie : slv_ext_ack_if;

assign slv_ext_rdata_i = (~slv_ext_adr_o[3]) ? slv_ext_rdata_ia : slv_ext_rdata_ib;
assign slv_ext_rdata_ia = (~slv_ext_adr_o[2]) ? slv_ext_rdata_ic : slv_ext_rdata_id;
assign slv_ext_rdata_ib = (~slv_ext_adr_o[2]) ? slv_ext_rdata_ie : slv_ext_rdata_if;
*/

endmodule

