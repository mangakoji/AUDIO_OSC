// AUDIO_OSC_TOP.v
//      AUDIO_OSC_TOP()
// 
// TM1638 LED KEY BOARD using driver
//    demo top on CQ MAX10-FB(Altera MAX10:10M08SAE144C8G)
//
// test in aitendo board vvv this
// http://www.aitendo.com/product/12887
// maybe move on many boards used TM1638
//
//
// twitter:@manga_koji
// hatena: id:mangakoji http://mangakoji.hatenablog.com/
// GitHub :@mangakoji
//
//170516su 001:branch to AUDIO_OSC
//170506s     :BIN2BCD append , append check circuit 
//170501m  002 :1st. compile is passed , and debug start
//170430u   001 :1st. cp from VR_LOC_DET_TOP.v
//170408s   004:append SOUNDER
//          003 :append SERVO
//          002 :enlarge VR_LOC 00-FF , debug LED7SEG
//          001 :W MSEQ blanched , P-N combine
//170407f   001 :W MSEQ PN conbine
//170406r   001 throw : LOGIANA_NTSC
//170328tu  001 throw : 
//170326u   001 :new for VR_LOC_DET_OP
//170323r   001 :retruct ORGAN
//170320m   002 :start ORGOLE
//170320m   001 :mv to CQMAX10 
//151220su      :mod sound ck 192 -> 144MHz
//               1st
//

module AUDIO_OSC_TOP(
      input     CK48M_i     //27
    , input     XPSW_i      //123
    , output    XLED_R_o   //120
    , output    XLED_G_o   //122
    , output    XLED_B_o   //121
    // CN1
    , inout     P62
    , inout     P61
    , inout     P60
    , inout     P59
    , inout     P58
    , inout     P57
    , inout     P56
    , inout     P55
    , inout     P52
    , inout     P50
    , inout     P48
    , inout     P47
    , inout     P46
    , inout     P45
    , inout     P44
    , inout     P43
    , inout     P41
    , inout     P39
    , inout     P38
    // CN2
    , inout     P124
    , inout     P127
    , inout     P130
    , inout     P131
    , inout     P132
    , inout     P134
    , inout     P135
    , inout     P140
    , inout     P141
//    , inout     P3 //analog AD pin
    , inout     P6
    , inout     P7
    , inout     P8
    , inout     P10
    , inout     P11
    , inout     P12
    , inout     P13
    , inout     P14
    , inout     P17

) ;
    function integer log2;
        input integer value ;
    begin
        value = value-1;
        for (log2=0; value>0; log2=log2+1)
            value = value>>1;
    end endfunction
    parameter C_FCK = 48_000_000 ;


    // start
    wire            XARST           ;
    wire            CK196M          ;
    wire            CK              ;
    assign CK = CK48M_i ;
    PLL u_PLL(
              .areset       ( 1'b0          )
            , .inclk0       ( CK48M_i       )
            , .c0           ( CK196M        )
            , .locked       ( XARST         )
    ) ;

    wire    LED_MISO_i    ;
    wire    LED_MOSI_o    ;
    wire    LED_MOSI_OE_o ;
    wire    LED_SS_o      ;
    wire    LED_SCLK_o    ;
    wire    VRLOC_PATN_P_o;
    wire    VRLOC_PATN_N_o;
    wire    VRLOC_DAT_i   ;
    wire    DAC_P_o       ;
    wire    DAC_N_o       ;
    wire    T_EN_WAVE_CTR_o  ;
    AUDIO_OSC #(
        .C_FCK  ( C_FCK )
    ) AUDIO_OSC (
          .CK_i             ( CK            )
        , .XARST_i          ( XARST         )
        , .EN_CK_i          ( 1'b1          )
        , .LED_MISO_i       ( LED_MISO_i    ) 
        , .LED_MOSI_o       ( LED_MOSI_o    )
        , .LED_MOSI_OE_o    ( LED_MOSI_OE_o )
        , .LED_SS_o         ( LED_SS_o      )
        , .LED_SCLK_o       ( LED_SCLK_o    )
        , .VRLOC_PATN_P_o   ( VRLOC_PATN_P_o)
        , .VRLOC_PATN_N_o   ( VRLOC_PATN_N_o)
        , .VRLOC_DAT_i      ( VRLOC_DAT_i   )
        , .DAC_P_o          ( DAC_P_o       )
        , .DAC_N_o          ( DAC_N_o       )
        , .T_EN_WAVE_CTR_o  ( T_EN_WAVE_CTR_o  )
    ) ;                       
    assign P124 = ( LED_MOSI_OE_o ) ? LED_MOSI_o : 1'bZ ; //DIO
//    assign P124 = LED_MOSI_o ;
    assign LED_MISO_i = P124 ;  //DIO
    assign P127 = LED_SCLK_o ;  //CLK
    assign P130 = LED_SS_o ;    //STB

    assign P38 = VRLOC_PATN_P_o ;
    assign VRLOC_DAT_i = P39 ;
    assign P41 = VRLOC_PATN_N_o ;

    assign P17 = DAC_P_o ;
    assign P14 = DAC_N_o ;
    assign P13 = DAC_P_o ;

    assign XLED_R_o = ~ 1'b0 ;
    assign XLED_G_o = ~ 1'b0 ;
    assign XLED_B_o = ~ 1'b0 ;
endmodule //AUDIO_OSC_TOP
