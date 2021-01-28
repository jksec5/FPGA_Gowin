module smbus906(

                   //input from wb bus
                     slv_ext_stb_o,
                     slv_ext_we_o,
                     slv_ext_cyc_o,
                     slv_ext_adr_o,
                     slv_ext_wdata_o,
                     slv_ext_sel_o,
                   
                   //output for wb bus
                     slv_ext_ack_i,
                     slv_ext_rdata_i,
                     
                     
                 //GY906
                 sda,
                 sclk,
                 
                 //system
                 clk_in,
                 resetn_in
                 
                 //key for start
                // key_in  //active L
                 
                 //byte_on,
                 //rcvdata_rd,
                 //byte_cnt,
                 //sda_en,
                 //rcvdata
                 );
                 
   input slv_ext_stb_o;
   input slv_ext_we_o;
   input slv_ext_cyc_o;
   input [3:0] slv_ext_adr_o;  //6 regs adr
   input [31:0] slv_ext_wdata_o;
   input [3:0] slv_ext_sel_o;

   output reg slv_ext_ack_i;
   output reg [31:0] slv_ext_rdata_i;                    

                 
  input clk_in;
  input resetn_in;   
 // input key_in;            

  inout  sda;
  output reg sclk;
  
  reg sda_out;
  reg sda_en;
  wire sda_in;
  wire sda_clk_pos;  
  reg sda_start_flag;  
  reg sda_ack_flag;
  reg [3:0] byte_cnt;  
  reg restart_flag;  
  reg pktend_flag;  
  reg byte_on;  
  wire byte_on_neg;   
  reg wr_flag;
  reg rd_flag; 
  reg [7:0] rcvdata_rd;  
  reg [7:0] rcvdata;
  reg [9:0] cnt500;  //cnt1000
  reg [6:0]  stanum; 
  reg[3:0] c_state,n_state;
  
  
  reg [7:0] SAW,          //000
            CMD,          //001
            SAR,          //010
            LSB,          //011
            MSB,          //100
            OK;           //101
  


  //write reg  SAW 
  always@(posedge clk_in or negedge resetn_in)
    if (!resetn_in)
       SAW <= 8'h0;
    else if (slv_ext_stb_o && (slv_ext_we_o) && slv_ext_cyc_o && (slv_ext_adr_o==4'b0100) )
             SAW <= slv_ext_wdata_o[7:0];   //only use [7:0]
         else ;        


  //write reg  CMD 
  always@(posedge clk_in or negedge resetn_in)
    if (!resetn_in)
       CMD <= 8'h0;
    else if (slv_ext_stb_o && (slv_ext_we_o) && slv_ext_cyc_o && (slv_ext_adr_o==4'b0101) )
             CMD <= slv_ext_wdata_o[7:0];   //only use [7:0]
         else ;          
       
         
  
  //write reg  SAR 
  always@(posedge clk_in or negedge resetn_in)
    if (!resetn_in)
       SAR <= 8'h0;
    else if (slv_ext_stb_o && (slv_ext_we_o) && slv_ext_cyc_o && (slv_ext_adr_o==4'b0110) )
             SAR <= slv_ext_wdata_o[7:0];   //only use [7:0]
         else ; 

  //write reg  LSB 
  always@(posedge clk_in or negedge resetn_in)
    if (!resetn_in)
       LSB <= 8'h0;
    else if (slv_ext_stb_o && (slv_ext_we_o) && slv_ext_cyc_o && (slv_ext_adr_o==4'b0111) )
             LSB <= slv_ext_wdata_o[7:0];   //only use [7:0]
         else ;          
 
  //write reg  MSB 
  always@(posedge clk_in or negedge resetn_in)
    if (!resetn_in)
       MSB <= 8'h0;
    else if (slv_ext_stb_o && (slv_ext_we_o) && slv_ext_cyc_o && (slv_ext_adr_o==4'b1000) )
             MSB <= slv_ext_wdata_o[7:0];   //only use [7:0]
         else ; 

        
         
  //write reg  OK   ????
  always@(posedge clk_in or negedge resetn_in)
    if (!resetn_in)
       OK <= 8'h55;
   // else if (key_in_pos)
    //           OK <= 8'h55;
    else if (slv_ext_stb_o && (slv_ext_we_o) && slv_ext_cyc_o && (slv_ext_adr_o==4'b1001) )
             OK <= slv_ext_wdata_o[7:0];   //only use [7:0]  0x55 start 
        // else if ( c_state == IDLE )
          //       OK <= 8'h00;
         else ; 



  reg ok_start;
  always@(posedge clk_in or negedge resetn_in)
    if (!resetn_in)
       ok_start <= 1'b0;
    else if ( c_state == END )
               ok_start <= 1'b0;
    else if(OK == 'h55)
             ok_start <= 1'b1;

              else ;

  reg ok_start_d1;
  always@(posedge clk_in or negedge resetn_in)
    if (!resetn_in)
        ok_start_d1 <= 1'b0;
    else  
        ok_start_d1 <= ok_start;

  wire ok_start_pos;
  assign ok_start_pos = ok_start &(~ok_start_d1);



  ////******  read reg   *******
  /*
    always@(posedge clk_in or negedge resetn_in)
    if (!resetn_in)
       slv_ext_rdata_i <= 32'h00000055;
    else if (slv_ext_stb_o && (~slv_ext_we_o) && slv_ext_cyc_o &&(~slv_ext_adr_o))
             slv_ext_rdata_i <= {24'h0,SAW};
         else ;
  */
  
  
  always@(posedge clk_in or negedge resetn_in)
    if (!resetn_in)
       slv_ext_rdata_i <= 32'h0;
    else if (slv_ext_stb_o && (~slv_ext_we_o) && slv_ext_cyc_o)
            begin
               case(slv_ext_adr_o)               
                 4'b0100:   slv_ext_rdata_i <= {24'h0,SAW};   //only use [7:0]
                 4'b0101:   slv_ext_rdata_i <= {24'h0,CMD};   //only use [7:0]
                 4'b0110:   slv_ext_rdata_i <= {24'h0,SAR};   //only use [7:0]
                 4'b0111:   slv_ext_rdata_i <= {24'h0,LSB_D};   //only use [7:0]               
                 4'b1000:   slv_ext_rdata_i <= {24'h0,MSB_D};   //only use [7:0]
                 4'b1001:   slv_ext_rdata_i <= {24'h0,OK};    //only use [7:0]            
                 default:  slv_ext_rdata_i <= slv_ext_rdata_i;
               endcase
            end             
         else ;
         

//ack
always@(posedge clk_in or negedge resetn_in)
    if (!resetn_in)
       slv_ext_ack_i <= 1'h0;
    else if (slv_ext_stb_o && slv_ext_cyc_o )
             slv_ext_ack_i <= ~slv_ext_ack_i;
         else ;

  reg[7:0] LSB_D;
  always@(posedge clk_in or negedge resetn_in)
    if (!resetn_in)
       LSB_D <= 8'h0;
    else if (byte_cnt=='d4)
            LSB_D <= rcvdata_rd;
         else ;
  
  reg[7:0] MSB_D;  
  always@(posedge clk_in or negedge resetn_in)
    if (!resetn_in)
       MSB_D <= 8'h0;
    else if (byte_cnt=='d5)
            MSB_D <= rcvdata_rd;
         else ;     


  
  parameter IDLE     =  4'h0;
  parameter START    =  4'h1;
  parameter SENDDATA =  4'h2;
  parameter ACK      =  4'h3;
  parameter RSTART   =  4'h4;
  parameter RSTART1  =  4'h5;  
  parameter STOP     =  4'h6;  
  parameter END      =  4'h7;   



  assign sda = sda_en ? sda_out : 1'bz;
  assign sda_in = sda;
    
  
       
  /*     
  reg key_in_d1,key_in_d2;
  always@(posedge clk_in or negedge resetn_in)
    if(!resetn_in)
      begin
        key_in_d1 <= 1'b1;
        key_in_d2 <= 1'b1;
      end
    else
      begin
        key_in_d1 <= key_in;   //active L
        key_in_d2 <= key_in_d1;      
      end

  wire key_in_pos;
  assign key_in_pos = key_in_d1 & (~key_in_d2);*/
  
  reg start_en;
  always@(posedge clk_in or negedge resetn_in)
    if(!resetn_in)
       start_en <= 1'b0;
    else if (ok_start_pos)      //key_in_pos
            start_en <= 1'b1;
         else if (c_state == IDLE)
                start_en <= 1'b0;
              else ;           


  always@(posedge clk_in or negedge resetn_in)
    if(!resetn_in)
        c_state <= IDLE;
    else
        c_state <= n_state;
        
  always@(*)   
    case(c_state)
      IDLE:     begin
                  sda_en = 1'b1;
                   if(ok_start_pos)             //key_in_pos     ok_start_pos
                       n_state = START;
                  else 
                       n_state = IDLE;
                end
                       
      START:   begin
                  sda_en = 1'b1;   
                  if(sda_clk_pos)
                       n_state = SENDDATA;
                  else
                      n_state  = START;
               end       
      SENDDATA:  begin
                  if (wr_flag) sda_en = 1'b1;
                  else sda_en = 1'b0;
                  if(sda_ack_flag)
                       n_state = ACK;
                  else
                     n_state = SENDDATA;
                 end
                     
      ACK:     begin
                 if (rd_flag) sda_en = 1'b1;
                 else sda_en = 1'b0;
                  if (pktend_flag) n_state = STOP; 
                  else if(restart_flag)
                      n_state = RSTART; 
                  else if(sda_clk_pos)
                          n_state = SENDDATA;
                       else
                          n_state = ACK;  
                end        
                
                  
      RSTART:  begin   
                  //sda_en = sda_en ; 
                  if(sda_clk_pos)
                      n_state = RSTART1;
                  else 
                      n_state = RSTART;
               end
               
      RSTART1: begin
                    sda_en = 1'b1; 
                    if(sda_clk_pos)
                     n_state = SENDDATA;
                  else
                     n_state  = RSTART1;   
               end
                     
      STOP:   begin
                sda_en = 1'b1;  
                 if(sda_clk_pos)
                     n_state = END;
                  else
                     n_state = STOP;      
              end        
      END:    begin
               sda_en = 1'b1;  
               if(cnt500==100)
                   n_state = IDLE;
               else 
                   n_state = END;
              end
      default: begin
                sda_en = 1'b1;   
                n_state = IDLE;
               end
    endcase
    
    reg cnt_en;
        always@(posedge clk_in or negedge resetn_in)
           if (!resetn_in) 
              cnt_en <= 1'b0;
           else if(c_state == START)
                   cnt_en <= 1'b1;
                else if (c_state == END)
                        cnt_en <= 1'b0;
                     else ;
  

        always@(posedge clk_in or negedge resetn_in)
           if (!resetn_in)  
             cnt500 <= 'h0;
           else if (!start_en)
                   cnt500 <= 'h0;
                 else if (cnt500=='d999)
                  cnt500 <= 'h0;
                            else
                              cnt500 <= cnt500 + 1'b1;
  
  
  always@(posedge clk_in or negedge resetn_in)
    if(!resetn_in)
        sclk <= 1'b1;
    else if (cnt500=='d499)
                 sclk <= ~sclk;
                          else if (cnt500=='d999)
                                 sclk <= ~sclk;                 
                                    else ;    

  reg sda_clk;
  always@(posedge clk_in or negedge resetn_in)
    if(!resetn_in)
        sda_clk <= 1'b1;
    else if (cnt500=='d200)
                 sda_clk <= ~sda_clk;
                          else if (cnt500=='d799)
                                 sda_clk <= ~sda_clk;                   
                                    else ; 
   
   reg sda_clk_d1;
   always@(posedge clk_in or negedge resetn_in)
     if(!resetn_in)   
        sda_clk_d1 <= 1'b1;  //0??
     else 
        sda_clk_d1 <= sda_clk;
   

   assign sda_clk_pos = sda_clk & (~sda_clk_d1);
   
   reg[4:0] sda_cnt;
   always@(posedge sda_clk or negedge start_en)    //resetn_in
    // if(!resetn_in)   
     //  sda_cnt <= 'h0;
    // else if (!start_en)
          if (!start_en)
              sda_cnt <= 'h0;
          else if(c_state == RSTART)
              sda_cnt <= 'h0;
          else if(sda_cnt == 'd8)
                   sda_cnt <= 'h0;
               else
                   sda_cnt <= sda_cnt + 1'b1;
                   
 
        always@(negedge sclk or negedge start_en)  //resetn_in
           if (!start_en)  
             stanum <= 'h0;
           else if(c_state == IDLE)
              stanum <= 'h0;
                else if (stanum=='d80)
                  stanum <= 'd80;
                          else
                            stanum <= stanum + 1'b1;    
                            
                reg [7:0] senddata;
                always@(negedge sclk or negedge start_en)    //resetn_in
             if (!start_en)
                    senddata <= SAW;  //   00
             else if(byte_cnt == 'd1)
                      senddata <= CMD;  //  07
                  else if (byte_cnt == 'd2)
                          senddata <= SAR;  //01
                    //   else if (byte_cnt == 'd3)
                       //        senddata <= 'hD2;  //11010010   
                       //                 else if (byte_cnt == 'd4)
                        //             senddata <= 'h3A;  //00111010
                                 else ;
                                 
                                 
           reg rcv_906_ack;   //ack from 906
                 always@(posedge sclk or negedge resetn_in)
             if (!resetn_in)  
                rcv_906_ack <= 1'b1;
             else if ( (c_state == ACK) & wr_flag ) 
                     rcv_906_ack <= sda_in;
                  else
                     rcv_906_ack <= 1'b1;                 
                                 
                                 
                                 

                always@(posedge sclk or negedge resetn_in)
             if (!resetn_in)
                 rcvdata <= 'h00;
             else if (byte_on)
                     rcvdata <= {rcvdata[6:0],sda_in};
                  else ; 


    always@(posedge clk_in or negedge resetn_in)
       if(!resetn_in) 
          rcvdata_rd <= 'h0;
      // else if ((byte_on_neg) & (~wr_flag))
       else if (byte_on_neg)
                 rcvdata_rd <= rcvdata;
            else; 
            
            

   always@(posedge clk_in or negedge resetn_in)
     if(!resetn_in)             
                     sda_start_flag <= 1'b0;
                 else if  ((sda_cnt == 'd0) & (cnt500=='d149) )
                            sda_start_flag <= 1'b1;
                      else
                            sda_start_flag <= 1'b0;
                     

   always@(posedge clk_in or negedge resetn_in)
     if(!resetn_in)             
                     sda_ack_flag <= 1'b0;
                 else if  ((sda_cnt == 'd0) & (sda_clk_pos) & (c_state == SENDDATA))
                            sda_ack_flag <= 1'b1;
                      else
                            sda_ack_flag <= 1'b0;
                            

          always@(posedge clk_in or negedge resetn_in)
       if(!resetn_in)           
           byte_cnt <= 'h0;
       else if (c_state == IDLE)
                 byte_cnt <= 'h0;
            else if(sda_ack_flag)
                     byte_cnt <= byte_cnt + 1'b1;
                 else ;
            

          always@(posedge clk_in or negedge resetn_in)
       if(!resetn_in)   
             byte_on <= 1'b0;
       else if((sda_cnt == 'd0) & (sda_clk_pos))
                byte_on <= 1'b0;
            else if ((sda_cnt == 'd1) & (sda_clk_pos)) 
                     byte_on <= 1'b1;    
                 else ;
                 
    reg  byte_on_d1;
          always@(posedge clk_in or negedge resetn_in)
       if(!resetn_in)  
           byte_on_d1 <= 1'b0;
       else
           byte_on_d1 <= byte_on;
    

    assign  byte_on_neg = (~byte_on) & byte_on_d1;          
                 
 //    assign sda_en = (byte_on & wr_flag) || (c_state==IDLE) || (c_state==START) || (c_state==RSTART1) || ((c_state==ACK) & (rd_flag)) ||(c_state==STOP) ||(c_state==END);  
     
    // wire restart_test;
    // assign restart_test = (c_state==RSTART);
     

          always@(posedge clk_in or negedge resetn_in)
       if(!resetn_in)     
          restart_flag <= 1'b0;
       else if ((byte_cnt == 'd2) & (sda_start_flag))
                restart_flag <= 1'b1;
            else
               restart_flag <= 1'b0;
    

          always@(posedge clk_in or negedge resetn_in)  //clk_in  sclk
       if(!resetn_in)
          wr_flag <= 1'b0;
       else if(c_state == IDLE)
               wr_flag <= 1'b0;
            else if(c_state == START)
                     wr_flag <= 1'b1;
                // else if (stanum == 'd29)
                 else if ( (byte_cnt == 'd3) & (sda_clk_pos) )
                         wr_flag <= 1'b0 ;
                      else ;

          always@(posedge sclk or negedge start_en)  //clk_in  sclk  resetn_in
       if(!start_en)
          rd_flag <= 1'b0;
       else if(c_state == IDLE)
               rd_flag <= 1'b0;
            else if(wr_flag)
                     rd_flag <= 1'b0;
                 else 
                     rd_flag <= 1'b1;
                     
   /* wire send_906_ack;
    assign send_906_ack = rd_flag & byte_on;        
    
    wire sda_ack_flag_for_rd;
    assign sda_ack_flag_for_rd = rd_flag & sda_ack_flag;*/

          always@(posedge clk_in or negedge resetn_in)
       if(!resetn_in)
           pktend_flag <= 1'b0;
       else if (c_state == IDLE)
          pktend_flag <= 1'b0;
       else if( (byte_cnt == 'd6) & (sda_start_flag))    //byte_cnt == 'd6
                pktend_flag <= 1'b1;
            else ;           
            
     reg  pktend_flag_d1;
     always@(posedge clk_in or negedge resetn_in)
       if(!resetn_in)      
           pktend_flag_d1 <= 1'b0;
       else
           pktend_flag_d1 <= pktend_flag;
           
     wire pktend_flag_neg;
     assign pktend_flag_neg = (~pktend_flag)& pktend_flag_d1;
     
     
                                                    
   always@(posedge clk_in or negedge resetn_in)
     if(!resetn_in)
       sda_out <= 1'b1;
     else if (sda_start_flag)
            sda_out <= 1'b0;     //for START
          else if (c_state==RSTART)
                  sda_out <= 1'b1;
               else if(restart_flag &(c_state==RSTART1))               
                   sda_out <= 1'b0;
               else if(pktend_flag_neg)
                      sda_out <= 1'b1;   //for STOP
                    
               else if ( (c_state==ACK) & (rd_flag))
                     sda_out <= 1'b0;
          
          else if ((sda_cnt == 'd1) & (sda_clk_pos) )
                  sda_out <= senddata[7];
               else if ((sda_cnt == 'd2) & (sda_clk_pos) )
                       sda_out <= senddata[6];   
                                      else if ((sda_cnt == 'd3) & (sda_clk_pos) )
                            sda_out <= senddata[5];
                         else if ((sda_cnt == 'd4) & (sda_clk_pos) )
                                 sda_out <= senddata[4];
                              else if ((sda_cnt == 'd5) & (sda_clk_pos) )
                                       sda_out <= senddata[3]; 
                                   else if ((sda_cnt == 'd6) & (sda_clk_pos) )
                                             sda_out <= senddata[2];  
                                        else if ((sda_cnt == 'd7) & (sda_clk_pos) )
                                                sda_out <= senddata[1];  
                                              else if ((sda_cnt == 'd8) & (sda_clk_pos) )
                                                       sda_out <= senddata[0]; 
                                                   else ;

    

endmodule

