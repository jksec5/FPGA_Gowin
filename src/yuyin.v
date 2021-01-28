module yuyin(
    clk_50m,
    rst_n,
    SDA,
    slv_ext_stb_o,
    slv_ext_we_o,
    slv_ext_cyc_o,
    slv_ext_adr_o,
    slv_ext_wdata_o,  //32bit
    slv_ext_sel_o,

//output for wb bus
    slv_ext_ack_i,
    slv_ext_rdata_i,
    key  //32bit
);
	

    input slv_ext_stb_o;
    input slv_ext_we_o;
    input slv_ext_cyc_o;
    input [3:0]slv_ext_adr_o;  //only one reg  adr=0
    input [31:0] slv_ext_wdata_o;
    input [3:0] slv_ext_sel_o;
    input key;
    output reg slv_ext_ack_i;
    output reg [31:0] slv_ext_rdata_i;
 
	input clk_50m;
	input rst_n;
	output reg SDA;
    reg [31:0]DATA;
	reg d;

	reg [17:0]cnt3ms;
	reg cnt3ms_en;	
	
	reg [19:0]cnt16ms;
	reg cnt16ms_en;

	reg [19:0]cnt16ms2;
	reg cnt16ms_en2;
	
	reg [18:0]cnt1ms;
	reg cnt1ms_en;	

	reg tx_flag;
	
	reg [4:0]current_state;
	reg [4:0]next_state;
	localparam
		IDLE       =    5'b00001,   
        WAIT       =    5'b00010,
		START      =    5'b00100,
		WR_DATA    =    5'b01000,
		STOP       =    5'b10000;

    reg key_val;
    reg tx_done;
  wire keyin;
  assign keyin = slv_ext_stb_o && slv_ext_we_o && slv_ext_cyc_o && (slv_ext_adr_o == 4'b0000);
  
    reg keyin_d1,keyin_d2;

  always @(posedge clk_50m or negedge rst_n)
    if(!rst_n) 
        keyin_d1 <= 1'b0;
         else
              keyin_d1 <= keyin;
                        
   always @(posedge clk_50m or negedge rst_n)
    if(!rst_n) 
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
  always @(posedge clk_50m or negedge rst_n)
    if(!rst_n)
            DATA <= 32'h0000_0000;
                          else if(keyin_pos)
                             DATA <= slv_ext_wdata_o; //from cpu data
        else if(!key_val)
            DATA <= 32'h0000_0011;

         else if (tx_done)
                DATA <= 32'h0000_0000; //rgb_start=0

                                  else ;

  //CPU read reg
  always@(posedge clk_50m or negedge rst_n)
    if (!rst_n)
       slv_ext_rdata_i <= 32'h0;
    else if (slv_ext_stb_o && (~slv_ext_we_o) && slv_ext_cyc_o && (slv_ext_adr_o == 4'b0000) )
             slv_ext_rdata_i <= DATA;
         else ;

   //ack to CPU
   always@(posedge clk_50m or negedge rst_n)
    if (!rst_n)
       slv_ext_ack_i <= 1'h0;
    else if (slv_ext_stb_o && slv_ext_cyc_o )
             slv_ext_ack_i <= ~slv_ext_ack_i;
         else ;


    always@(posedge clk_50m or negedge rst_n)
        if(!rst_n)
            key_val <= 1'b1;
        else if(!key)
            key_val <= 1'b0;
        else
            key_val <= 1'b1;



    always@(posedge clk_50m or negedge rst_n)
        if(!rst_n)
            tx_flag <= 0;
        else
            tx_flag <= DATA[31];
    
	always@(posedge clk_50m or negedge rst_n)
		if(!rst_n)
			current_state <= IDLE;
		else
			current_state <= next_state;
			
	always@(current_state,tx_flag,cnt1ms,cnt3ms,cnt16ms,cnt16ms2)begin
		next_state <= IDLE;
		case(current_state)
			IDLE:
				begin
					if(tx_flag)
						next_state <= WAIT;
					else
						next_state <= IDLE;
				end
            WAIT:
                begin
                    if(cnt1ms == 19'd499999)
                        next_state <= START;
                    else
                        next_state <= WAIT;

                end
			START:
				begin
					if(cnt3ms == 18'd149999)
						next_state <= WR_DATA;
					else
						next_state <= START;
				end
			WR_DATA:
				begin
					if(cnt16ms == 20'd799_999)
						next_state <= STOP;
					else
						next_state <= WR_DATA;
				end
			STOP:
				begin
                    if(cnt16ms2 == 20'd799_999)
                        next_state <= IDLE;
                    else        
                        next_state <= STOP;
				end
		endcase
	end
	
	always@(posedge clk_50m or negedge rst_n)
		begin
			if(!rst_n)
				SDA <= 1'b1;
			else begin
				case(current_state)
					IDLE:
                        begin
                            SDA <= 1'b1;
                            cnt16ms_en2 <= 1'b0;
                            tx_done <= 1'b0;
                        end
                    WAIT:
                        begin
                            SDA <= 1'b1;
                            cnt1ms_en <= 1'b1;
                        end
					START:
						begin
							SDA <= 1'b0;
                            cnt1ms_en <= 1'b0;
							cnt3ms_en <= 1'b1;
						end
					WR_DATA:
						begin
							cnt3ms_en <= 1'b0;
							SDA <= d;
							cnt16ms_en <= 1'b1;
						end
					STOP: 
						begin
							SDA <= 1'b1;
							cnt16ms_en <= 1'b0;
                            cnt16ms_en2 <= 1'b1;
                            tx_done <= 1'b1; 
						end		
				endcase			
			end
		end
		

	always@(posedge clk_50m or negedge rst_n)  //计时3ms
		if(!rst_n)
			cnt3ms <= 1'b0;
		else if(cnt3ms_en)
			if(cnt3ms == 18'd149999)
				cnt3ms <= 1'b0;
			else
				cnt3ms <= cnt3ms + 1'b1;
		else
			cnt3ms <= 1'b0;		

			
	always@(posedge clk_50m or negedge rst_n)  //计时16ms
		if(!rst_n)
			cnt16ms <= 1'b0;
		else if(cnt16ms_en)
			if(cnt16ms == 20'd799_999)
				cnt16ms <= 1'b0;
			else
				cnt16ms <= cnt16ms + 1'b1;
		else
			cnt16ms <= 1'b0;		

	always@(posedge clk_50m or negedge rst_n)  //计时16ms
		if(!rst_n)
			cnt16ms2 <= 1'b0;
		else if(cnt16ms_en2)
			if(cnt16ms2 == 20'd799_999)
				cnt16ms2 <= 1'b0;
			else
				cnt16ms2 <= cnt16ms2 + 1'b1;
		else
			cnt16ms2 <= 1'b0;		

	always@(posedge clk_50m or negedge rst_n)  //计时1ms
		if(!rst_n)
			cnt1ms <= 1'b0;
		else if(cnt1ms_en)
			if(cnt1ms == 19'd49_9999)
				cnt1ms <= 1'b0;
			else
				cnt1ms <= cnt1ms + 1'b1;
		else
			cnt1ms <= 1'b0;	


		
	always@(posedge clk_50m or negedge rst_n)begin
		if(!rst_n)
			d <= 1'b1;
		else 
			case(cnt16ms)
				1'd0  				   :   d <= 1'b1;  
				20'd25000				   :   d <= DATA[0];
				20'd75000				   :   d <= 1'b0;
				20'd100000				:   d <= 1'b1; 
				20'd125000				:   d <= DATA[1];
				20'd175000				:   d <= 1'b0;
				20'd200000				:   d <= 1'b1; 
				20'd225000				:   d <= DATA[2];
				20'd275000				:	 d <= 1'b0;		
				20'd300000				:   d <= 1'b1; 
				20'd325000				:   d <= DATA[3];
				20'd375000				:   d <= 1'b0;			
				20'd400000				:   d <= 1'b1; 
				20'd425000				:   d <= DATA[4];
				20'd475000				:   d <= 1'b0;		
				20'd500000			   :   d <= 1'b1; 
				20'd525000				:   d <= DATA[5];
				20'd575000				:	 d <= 1'b0;		
				20'd600000				:   d <= 1'b1; 
				20'd625000				:   d <= DATA[6];
				20'd675000				:	 d <= 1'b0;		
				20'd700000				:   d <= 1'b1; 
				20'd725000				:   d <= DATA[7];
				20'd775000				:	 d <= 1'b0;		
				20'd799999				:   d <= 1'b1; 
				default           :   d <= d;
			endcase	
	end
endmodule
