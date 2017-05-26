// AUDIO_OSC.v
// AUDIO_OSC()
//
//
// twitter:@manga_koji
// hatena: id:mangakoji http://mangakoji.hatenablog.com/
// GitHub :@mangakoji
//
//
//170526fr      :adj VR loc stabiliser LPF C_SHIFT_LPF
//2017-05-25th :add wavevolume
//2017-05-20sa :1ce write up
//2017-05-16su  :1st

module AUDIO_OSC #(
      parameter C_FCK  =  48_000_000  // Hz
    , parameter C_FSCLK =  1_000_000  // Hz
    , parameter C_FPS   =        250  // cycle(Hz)
)(
      input         CK_i
    , input tri1    XARST_i
    , input tri1    EN_CK_i
    , input         LED_MISO_i
    , output        LED_MOSI_o
    , output        LED_MOSI_OE_o
    , output        LED_SS_o
    , output        LED_SCLK_o
    , output        VRLOC_PATN_P_o
    , output        VRLOC_PATN_N_o
    , input         VRLOC_DAT_i
    , input         VR_VRLOC_DAT_i
    , output        DAC_P_o 
    , output        DAC_N_o 
    , output        T_EN_WAVE_CTR_o
) ;
    function time log2;             //time is reg unsigned [63:0]
        input time value ;
    begin
        value = value-1;
        for (log2=0; value>0; log2=log2+1)
            value = value>>1;
    end endfunction


    wire EN_CK ;
    assign EN_CK = EN_CK_i ;
    //
    // ctl part
    //

    // clock divider
    //
    // if there is remainder ,round up
    localparam C_HALF_DIV_LEN = //24
        C_FCK / (C_FSCLK * 2) 
        + 
        ((C_FCK % (C_FSCLK * 2)) ? 1 : 0) 
    ;
    localparam C_HALF_DIV_W = log2( C_HALF_DIV_LEN ) ;

    wire            MISO_i          ;
    wire            MOSI            ;
    wire            MOSI_OE         ;
    wire            SCLK_o          ;
    wire            SS_o            ;
    wire    [ 7:0]  KEYS            ;
    reg     [ 7 :0] LEDS             ;
    wire            DB_FRAME_REQ_o  ;
    wire            DB_EN_SCLK_o    ;
    wire            DB_BUSY_o       ;
    wire            DB_BYTE_BUSY_o  ;
    wire            DB_KEY_STATE_o  ;
    reg             ENCBIN_XDIRECT ;
    wire            ENCBIN_XDIRECT_i  ;
    reg             BIN2BCD_ON        ;
    assign ENCBIN_XDIRECT_i = ENCBIN_XDIRECT ; //

    wire [14 :0] pulse_n ;
    wire [14+8:0] freq ;
    assign freq = pulse_n * 25 ;
    reg [7:0]   SUP_DIGITS ;
    TM1638_LED_KEY_DRV #(
          .C_FCK    ( C_FCK         )// Hz
        , .C_FSCLK  ( 1_000_000     )// Hz
        , .C_FPS    ( 250           )// cycle(Hz)
    ) TM1638_LED_KEY_DRV (
          .CK_i             ( CK_i          )
        , .XARST_i          ( XARST_i       )
        , .DIRECT7SEG0_i    ()
        , .DIRECT7SEG1_i    ()
        , .DIRECT7SEG2_i    ()
        , .DIRECT7SEG3_i    ()
        , .DIRECT7SEG4_i    ()
        , .DIRECT7SEG5_i    ()
        , .DIRECT7SEG6_i    ()
        , .DIRECT7SEG7_i    ()
        , .DOTS_i           ( 8'b0000_0100  )
        , .LEDS_i           ( LEDS          )
        , .BIN_DAT_i        ( freq)
        , .SUP_DIGITS_i     ()
        , .ENCBIN_XDIRECT_i ( 1'b1          )
        , .BIN2BCD_ON_i     ( 1'b1          )
        , .MISO_i           ( LED_MISO_i    )
        , .MOSI_o           ( LED_MOSI_o    )
        , .MOSI_OE_o        ( LED_MOSI_OE_o )
        , .SCLK_o           ( LED_SCLK_o    )
        , .SS_o             ( LED_SS_o      )
        , .KEYS_o           ( KEYS          )
    ) ; //TM1638_LED_KEY_DRV
    reg [7:0] KEYS_D ;
    always @ (posedge CK_i or negedge XARST_i )
        if ( ~ XARST_i)
            KEYS_D <= 8'h00 ;
        else if ( EN_CK )
            KEYS_D <= KEYS ;
    reg  [1:0] OCT_CTR ;
    always @(posedge CK_i or negedge XARST_i)
        if ( ~ XARST_i)
            OCT_CTR <= 2'b00 ;
        else if ( EN_CK ) begin
            if (KEYS[7] & ~KEYS_D[7] & ~(&OCT_CTR))
                OCT_CTR <= OCT_CTR + 2'b1 ;
            else if (KEYS[6] & ~KEYS_D[6] & (|OCT_CTR))
                OCT_CTR <= OCT_CTR - 2'b1 ;
        end
    
    reg [1:0]   WAVE_MODE ;
    always @(posedge CK_i or negedge XARST_i)
        if ( ~ XARST_i)
            LEDS <= 8'h00 ;
        else if ( EN_CK ) begin
            LEDS[3:2] <= WAVE_MODE ;
            if (OCT_CTR==0)
                LEDS[7:4] <= 4'b0001 ;
            else if (OCT_CTR==1)
                LEDS[7:4] <= 4'b0011 ;
            else if (OCT_CTR==2)
                LEDS[7:4] <= 4'b0111 ;
            else if (OCT_CTR==3)
                LEDS[7:4] <= 4'b1111 ;
        end
    


    wire    [ 7 :0] VR_LOC ;
    wire    [ 7 :0] VR_VR_LOC ;
    VR_LOC_DET #(
          .C_CH_N       (  2            )
        , .C_SHIFT_LPF  (  23           )//17:fc=58Hz:23:0.9Hz
    )VR_LOC_DET(
          .CK_i     ( CK_i          )
        , .XARST_i  ( XARST_i       )
        , .TPAT_P_o ( VRLOC_PATN_P_o)
        , .TPAT_N_o ( VRLOC_PATN_N_o)
        , .DAT_i    ( {VR_VRLOC_DAT_i , VRLOC_DAT_i}   )
        , . LOC_o   ({VR_VR_LOC,  VR_LOC}  )
    ) ; //VR_LOC_DET


//    wire [14 :0] pulse_n ;
    // 254*32=32512Hz max
    // 1111_1110_0000_0.00 max
    wire [ 3 :0]    oct_a ;
    wire [ 2 :0]    oct ;
    assign oct_a = 3*OCT_CTR + VR_LOC[6 +:2] ; //max 12
    assign oct = (oct_a >= 8) ? 8 : oct_a ; 
    // 10000.00
    assign pulse_n = ({1'b1 , VR_LOC[5:0]}) << (3*OCT_CTR + VR_LOC[6+:2]) ;
    wire    EN_WAVE_CTR ;
    SUBREG_TIM_DIV #(
          .C_PERIOD_W   ( log2(C_FCK)  ) //
    ) SUBREG_TIM_DIV (
          .CK_i             ( CK_i        )
        , .XARST_i          ( XARST_i     )
        , .EN_CK_i          ( EN_CK     )
        , .PERIOD_i         ( C_FCK     )
        , .PULSE_N_i        ( pulse_n << (12-2) )
        , .EN_CK_o          ( EN_WAVE_CTR    )
    ) ;
    assign T_EN_WAVE_CTR_o = EN_WAVE_CTR ;
    reg [11:0]  WAVE_CTR ;
    always @(posedge CK_i or negedge XARST_i)
        if ( ~ XARST_i )
            WAVE_CTR <= 12'h000 ;
        else if ( EN_CK )
            if ( EN_WAVE_CTR )
                WAVE_CTR <= WAVE_CTR + 12'h001 ;


    wire [11:0] SIN ;
    SIN_TBL_s11_s11 SIN_TBL (
          .CK_i     ( CK_i      )
        , .XARST_i  ( XARST_i   )
        , .EN_CK_i  ( EN_CK     )
        , .DAT_i    ( {~WAVE_CTR[11],WAVE_CTR[10:0]}  )//2's -h800 0 +7FFF
        , .SIN_o    ( SIN       )//2's -h800 0 +h800
    ) ;


    always @(posedge CK_i or negedge XARST_i)
        if ( ~ XARST_i )
            WAVE_MODE <= 2'b00 ;
        else
            if (EN_CK)
                if (KEYS[5] & ~ KEYS_D[5])
                    WAVE_MODE <= WAVE_MODE + 1 ;

    reg [11:0] WAVE_REGU ;
    always @(posedge CK_i or negedge XARST_i)
        if ( ~ XARST_i )
            WAVE_REGU <= 12'h000 ;
        else if ( EN_CK )
            if (~WAVE_MODE[0])// == 2'b00)
                WAVE_REGU <= { ~ SIN[11] , SIN[10:0]} ;
            else //if ( WAVE_MODE == 2'b01) //triangle wave
                WAVE_REGU <=  
                {
                    ~ WAVE_CTR[11]
                    , 
                    {11
                        {(
                            WAVE_CTR[11:10]==2'b01
                            |
                            WAVE_CTR[11:10]==2'b10
                        )}
                     } 
                     ^
                     {WAVE_CTR[9:0],1'b0}
                } ;
//            else if (WAVE_MODE == 2'b10)
//                WAVE_REGU <= SIN ;
//            else //==11
//                WAVE_REGU <= WAVE_CTR ;
    reg [11+8:0] WAVE ;
    always @(posedge CK_i or negedge XARST_i)
        if ( ~ XARST_i )
            WAVE <= 20'h000 ;
        else if ( EN_CK )
            WAVE <= {{9{~WAVE_REGU[11]}},WAVE_REGU[10:0]} * VR_VR_LOC ;



    DELTA_SIGMA_1BIT_DAC #(
        .C_DAT_W    ( 12 )
    )DELTA_SIGMA_1BIT_DAC (
          .CK       ( CK_i                      )
        , .XARST_i  ( XARST_i                   )
        , .DAT_i    ( {~WAVE[19] , WAVE [18:8]} ) //str ofs
        , .QQ_o     ( DAC_P_o                   )
        , .XQQ_o    ( DAC_N_o                   )
) ;
          


endmodule //AUDIO_OSC()



`timescale 1ns/1ns
module TB_AUDIO_OSC #(
    parameter C_C = 10.0
)(
) ;
    reg     CK  ;
    initial begin
        CK <= 1'b1 ;
        forever begin
            #( C_C /2) ;
            CK <= ~ CK ;
        end
    end
    reg XARST   ;
    initial begin
        XARST <= 1'b1 ;
        #( 0.1 * C_C) ;
            XARST <= 1'b0 ;
        #( 2.1 * C_C) ;
            XARST <= 1'b1 ;
    end

endmodule
