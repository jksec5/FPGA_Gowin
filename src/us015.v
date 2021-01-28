module us015(
    Echo,
    Trig,
cnt_echo1,
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
        flag
           );






//****************
    input Echo;
    output reg Trig;
    output reg [31:0]cnt_echo1;
	reg [7:0]cnt4_out;
    localparam 
        s0 = 3'b001,
        s1 = 3'b010,
        s2 = 3'b100;

    reg [2:0]state;

    reg [7:0]cnt4;
    reg [10:0]cnt12;
    reg cnt4_en;
    reg cnt12_en;
    reg [31:0]cnt_echo;
    output  flag;
	 reg sig_r0;
	 reg sig_r1;
    reg disrd_flag;
		reg [1:0]data_r;

 // reg [10:0]cnt50;
 //   reg cnt50_en;
//*********************

//sys input
  input  clkin;
  input resetn;
 



  
//wishbone signals
input slv_ext_stb_o;
input slv_ext_we_o;
input slv_ext_cyc_o;
input [3:0]slv_ext_adr_o;  //only one reg  adr=0
input [31:0] slv_ext_wdata_o;
input [3:0] slv_ext_sel_o;

output reg slv_ext_ack_i;
output reg [31:0] slv_ext_rdata_i;


  
   //reg [31:0] RGB_S;


   

  //output for 2812chip
  
  wire keyin;
  assign keyin = slv_ext_stb_o && slv_ext_we_o && slv_ext_cyc_o && ((slv_ext_adr_o == 4'b0001) || (slv_ext_adr_o == 4'b0011));
  
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


/*
  //CPU write reg 
  always @(posedge clkin or negedge resetn)
    if(!resetn)
            RGBDATA <= 32'h8000_0000;
         else if (send_allend_pos)
                 RGBDATA <= 32'h0000_0000; //rgb_start=0
                          else if(keyin_pos)
                             RGBDATA <= slv_ext_wdata_o; //from cpu data
                                  else ;
*/

  //CPU read reg
  always@(posedge clkin or negedge resetn)
    if (!resetn)
       slv_ext_rdata_i <= 32'h0;
    else if (slv_ext_stb_o && (~slv_ext_we_o) && slv_ext_cyc_o && ((slv_ext_adr_o == 4'b0001) || (slv_ext_adr_o == 4'b0011)) )
             slv_ext_rdata_i <= cnt_echo1;
         else ;

   //ack to CPU
   always@(posedge clkin or negedge resetn)
    if (!resetn)
       slv_ext_ack_i <= 1'h0;
    else if (slv_ext_stb_o && slv_ext_cyc_o )
             slv_ext_ack_i <= ~slv_ext_ack_i;
         else ;




//***********************************************************




    always@(posedge clkin or negedge resetn)
        if(!resetn)
            state <= s0;
        else 
            case(state)
                s0: if(cnt4 == 8'd199)begin
                        state <= s1;
                        cnt4_en <= 1'b0;
                    end
                    else begin
                        Trig <= 1'b0;
                        cnt4_en <= 1'b1;
								state <= s0;
                    end
                s1: if(cnt12 == 10'd599)begin
                        state <= s2;
                        cnt12_en <= 1'b0;
                    end
                    else begin
                        Trig <= 1'b1;
                        state <= s1;
                        cnt12_en <= 1'b1;
                    end
                s2: if(flag)
                        state <= s0;   
                    else begin
                        Trig <= 1'b0;
                        state <= s2;
                    end
            endcase

        
    


    always@(posedge clkin or negedge resetn)  //计数4us
        if(!resetn)
            cnt4 <= 1'b0;
        else if(cnt4_en)
            if(cnt4 == 8'd199)
                cnt4 <= 1'b0;
            else 
                cnt4 <= cnt4 + 1'b1;
        else
            cnt4 <= 1'b0;
    always@(posedge clkin or negedge resetn)  //计数12us
        if(!resetn)
            cnt12 <= 1'b0;
        else if(cnt12_en)
            if(cnt12 == 10'd599)
                cnt12 <= 1'b0;
            else
                cnt12 <= cnt12 + 1'b1;
        else
            cnt12 <= 1'b0;

    always@(posedge clkin)
        if(state == s0)begin
            cnt_echo[31] <= 1'b1;
            cnt_echo1 <= cnt_echo;
        end
        else if(state == s1)begin
            cnt_echo <= 31'b0;
        end
        else if(Echo)begin
            cnt_echo <= cnt_echo + 1'b1;
            cnt_echo[31] <= 1'b0;
        end



/*
always@(posedge clkin or negedge resetn)  //计数4us
        if(!resetn)
            cnt50 <= 1'b0;
        else if(cnt50_en)
            if(cnt50 == 8'd199)
                cnt50 <= 1'b0;
            else 
                cnt50 <= cnt50 + 1'b1;
        else
            cnt50 <= 1'b0;

*/
	always @(posedge clkin or negedge resetn)
	  begin
			if(!resetn)
			 begin
				sig_r0 <= 1'b0;
				sig_r1 <= 1'b0;
			end
		  else
			 begin
				sig_r0 <= Echo;
				sig_r1 <= sig_r0;
			end
	  end

assign flag = sig_r1 & ~sig_r0;
endmodule
