module wbrgb(

//input from wb bus
  slv_ext_stb_o,
  slv_ext_we_o,
  slv_ext_cyc_o,
  slv_ext_adr_o,
  slv_ext_wdata_o,  //32bit
  slv_ext_sel_o,

//output for wb bus
  slv_ext_ack_i,
  slv_ext_rdata_i,  //32bit

//sys input
        clkin,    
				resetn,

//wbrgb output
     rgb_out

     //ledtest

/* signal for debug
				cnt_rst,
				rst_50us,
				cnt_125us,
				clk_125us
				D_MSB,
				cnt_24bit,
				send_flag,
				c_state,
				n_state,
				rgb_start,*/
				
           );

//sys input
  input  clkin;
  input resetn;
 
//output to 2812RGB LED
  output  rgb_out;
  //output  ledtest;  //rgb_start


  
//wishbone signals
input slv_ext_stb_o;
input slv_ext_we_o;
input slv_ext_cyc_o;
input [3:0]slv_ext_adr_o;  //only one reg  adr=0
input [31:0] slv_ext_wdata_o;
input [3:0] slv_ext_sel_o;

output reg slv_ext_ack_i;
output reg [31:0] slv_ext_rdata_i;
 
  
   reg [11:0] cnt_rst;  //2500 * 20ns=50us
   reg  rst_50us;
  
   reg [5:0] cnt_125us;
   reg clk_125us;
  
   reg [31:0] RGBDATA;
   //reg [31:0] RGB_S;
  
   reg [23:0] rgbdata_d;
  
   reg [4:0] cnt_24bit;
   reg send_flag;
   reg  rgb_start;
   reg [1:0] c_state,n_state; 
   reg send_allend; 
   wire send_allend_pos;
   

  //output for 2812chip
    assign rgb_out = clk_125us;  //code for RGBLED
  
  wire keyin;
  assign keyin = slv_ext_stb_o && slv_ext_we_o && slv_ext_cyc_o && (slv_ext_adr_o == 4'b0010);
  
    reg keyin_d1,keyin_d2;
  always @(posedge clkin or negedge resetn)
    if(!resetn) 
        keyin_d1 <= 1'b0;
         else
              keyin_d1 <= keyin;
                        
   always @(posedge clkin or negedge resetn)
    if(!resetn) 
        keyin_d2 <= 1'b0;
         else
              keyin_d2 <= keyin_d1;                     
          
          wire keyin_pos;
          assign keyin_pos = ~keyin_d1 & (keyin_d2);
  
 /* //CPU write reg 
  always @(posedge clkin or negedge resetn)
    if(!resetn)
	    RGBDATA <= 32'h8000_0000;    //G-R-B

			  else if(slv_ext_stb_o && slv_ext_we_o && slv_ext_cyc_o && (~slv_ext_adr_o))

			          RGBDATA <= slv_ext_wdata_o; //from cpu data

	 else if (c_state == RST50US)
	         RGBDATA <= 32'h0000_0000;
			       else ;*/



  //CPU write reg 
  always @(posedge clkin or negedge resetn)
    if(!resetn)
            RGBDATA <= 32'h8000_0000;
         else if (send_allend_pos)
                 RGBDATA <= 32'h0000_0000; //rgb_start=0
                          else if(keyin_pos)
                             RGBDATA <= slv_ext_wdata_o; //from cpu data
                                  else ;


  //CPU read reg
  always@(posedge clkin or negedge resetn)
    if (!resetn)
       slv_ext_rdata_i <= 32'h0;
    else if (slv_ext_stb_o && (~slv_ext_we_o) && slv_ext_cyc_o && (slv_ext_adr_o == 4'b0010) )
             slv_ext_rdata_i <= RGBDATA;
         else ;

   //ack to CPU
   always@(posedge clkin or negedge resetn)
    if (!resetn)
       slv_ext_ack_i <= 1'h0;
    else if (slv_ext_stb_o && slv_ext_cyc_o )
             slv_ext_ack_i <= ~slv_ext_ack_i;
         else ;
         
 /*          
  //assign rgb_start = RGBDATA[31];     //1: start  0: rst  
  reg rgb_start;
  always @(posedge clkin or negedge resetn)
    if(!resetn)
	    rgb_start <= 1'b0;
	 else if (RGBDATA[31]== 1'b1)
	         rgb_start <= 1'b1;
			else 
			   rgb_start <= 1'b0;
*/

/*  assign ledtest = rgb_start;
 
 //assign rgbdata_d = RGBDATA[23:0];   //G-R-B	DATA	
   wire  D_MSB;
  assign D_MSB = rgbdata_d[23];
  
  always @(posedge clkin or negedge resetn)
    if(!resetn)
		  rgbdata_d <= 24'h0;
	 else if (rgb_start | (cnt_24bit == 5'd24))
		      rgbdata_d <= RGBDATA[23:0];
		   else if (cnt_125us == 6'd61)
			        rgbdata_d <= {rgbdata_d[22:0],1'b0};
				  else ;
	*/	 
 
  
  parameter  IDLE = 2'b00; 
  parameter  RST50US = 2'b01;   
  parameter  SENDDATA = 2'b10;
  parameter  SENDEND = 2'b11;  
  


  
 // assign rgb_start = RGBDATA[31];     //1: start  0: rst  

  always @(posedge clkin or negedge resetn)
  if(!resetn)
    rgb_start <= 1'b0;
  else
   if(c_state == IDLE)
            rgb_start <= RGBDATA[31];
         else if ( c_state == RST50US )
                 rgb_start <= 1'b0;
                        else 
                          ;
                           
 
 //assign rgbdata_d = RGBDATA[23:0];   //G-R-B  DATA    

  assign D_MSB = rgbdata_d[23];
  
  always @(posedge clkin or negedge resetn)
    if(!resetn)
                  rgbdata_d <= 24'h0;
         else if (rgb_start | (cnt_24bit == 5'd24))
                      rgbdata_d <= RGBDATA[23:0];
                   else if (cnt_125us == 6'd61)
                                rgbdata_d <= {rgbdata_d[22:0],1'b0};
                                  else ;
                 
  
  
  always @(posedge clkin or negedge resetn)
    if(!resetn)
            c_state <= IDLE;
         else
            c_state <= n_state;
                 
        
  always@(resetn or c_state or rst_50us_pos or send_flag or rgb_start or send_allend or keyin_pos)  
    begin
           case (c_state)
                  IDLE :  if (!resetn)  
                             n_state <= IDLE;
                          else if (rgb_start)
                                                 n_state <= RST50US;
                                                   else  
                                                           n_state <= IDLE;   
                  
                RST50US:  if (rst_50us_pos)  
                              n_state <= SENDDATA;
                          else  
                                             n_state <= RST50US;
          SENDDATA: if (send_flag)  
                        n_state <= SENDDATA;
                          else  
                                                n_state <= SENDEND;
           SENDEND:  
                          if(~send_allend  || keyin_pos ) n_state <= IDLE;   
                          else  
                                           n_state <= SENDEND;
           endcase
         end
                 
  
  //rst50us  2500*20ns=50us
  always @(posedge clkin or negedge resetn)
    if(!resetn)
             cnt_rst <= 12'd0;
        else if (c_state == IDLE)
                 cnt_rst <= 12'd0;
         else if (cnt_rst == 12'd50)    //2500
                        cnt_rst <= 12'd50;  //2500
                            // else if (c_state == RST50US)
                                 else   cnt_rst <= cnt_rst + 1'b1;
                                        //    else ;
  
 
  always @(posedge clkin or negedge resetn)
    if(!resetn)
             rst_50us <= 1'd0;
    else if (cnt_rst == 12'd50)  //2500
                 rst_50us <= 1'd1;
                        else 
                           rst_50us <= 1'd0; 
                                
                                
        reg rst_50us_d;                 
  always @(posedge clkin or negedge resetn)
    if(!resetn)
             rst_50us_d <= 1'd0;
    else 
       rst_50us_d <= rst_50us;
                                        
                            
        assign rst_50us_pos = rst_50us & (~rst_50us_d);
                                        
                                                        
  always @(posedge clkin or negedge  resetn)
    if(!resetn)
           cnt_125us <= 6'd0;    
        else    if (rst_50us==1'b0)  
                  cnt_125us <= 6'd0;     
            else   if (cnt_125us == 6'd61)
                      cnt_125us <= 6'd0; 
                   else if (send_flag)
                              cnt_125us <= cnt_125us + 1'b1;
                        else ;
  /*                      
  reg clk125us;
   always @(posedge clkin or negedge resetn)
    if(!resetn )     
        clk125us<=1'b0;
    else if (cnt_125us == 6'd0)  
               clk125us<=1'b1;
         else if (cnt_125us == 6'd31)
                clk125us<=1'b0;
              else;
*/
                   
 
  always @(posedge clkin or negedge resetn)
    if(!resetn )
             clk_125us <= 1'd0;
   // else if (send_flag==1'b0)
   else if(c_state == IDLE)
             clk_125us <= 1'd0;
         else if(rst_50us_pos)
                 clk_125us <= 1'd1;
         else if (( (cnt_125us == 6'd19) && (D_MSB == 1'b0)) ||  ( (cnt_125us == 6'd41) && (D_MSB == 1'b1)) )
                     clk_125us <= ~clk_125us;
                             else if (cnt_125us == 6'd61)
                                     clk_125us <= ~clk_125us;
                                  else  
                                          ;     
                                                         
                                                         
  always @(posedge clkin or negedge resetn)
    if(!resetn )
             cnt_24bit <= 5'd0;
    else if (rst_50us_pos)
              cnt_24bit <= 5'd0;
              else if (cnt_24bit== 5'd24)
                   cnt_24bit <= 5'd0;
                 else if (cnt_125us ==  6'd61)
                      cnt_24bit <= cnt_24bit + 1'b1;                           
                                  else   ;


  

  
  reg onedata_endflag;
  always @(posedge clkin or negedge resetn)
    if(!resetn)
      onedata_endflag <= 1'b0;
         else if(cnt_24bit == 5'd24)
        onedata_endflag <= 1'b1;
                  else 
                     onedata_endflag <= 1'b0;
                          
 /*                         
  always @(posedge clkin or negedge resetn)
    if(!resetn)
      onedata_endflag_d <= 1'b0;
         else 
          onedata_endflag_d <= onedata_endflag;
          
  wire onedata_endflag_pos;
  assign onedata_endflag_pos = onedata_endflag & (~onedata_endflag_d);    
  */
  
  reg [4:0] send_cnt;
  always @(posedge clkin or negedge resetn)
    if(!resetn)
             send_cnt <= 5'd0;                    
           else if(c_state == SENDEND)
             send_cnt <= 5'd0;          
          else if (onedata_endflag) //&&(c_state == SEND)) 
                  send_cnt <= send_cnt + 1'b1;
               else ;
                         
                         
  //assign send_allend = (send_cnt == 4'd1);
  
   always @(posedge clkin or negedge resetn)
      if(!resetn) 
                  send_allend <=1'b0;
                else if (keyin_pos)
                  send_allend <=1'b0;
                else if (send_cnt == 5'd20)
             send_allend <=1'b1;     
                                else ; 
                                
   reg  send_allend_d;
   always @(posedge clkin or negedge resetn)
      if(!resetn) 
           send_allend_d <=1'b0;
      else 
           send_allend_d <=send_allend;
           
  assign send_allend_pos= send_allend & (~send_allend_d);
           
                 
                        
  always @(posedge clkin or negedge resetn)
    if(!resetn)
             send_flag <= 1'd0;
    else if (send_allend_pos)  //9
                 send_flag <= 1'd0;
         else if(rst_50us_pos)
            send_flag <= 1'd1;
                 else ;



endmodule