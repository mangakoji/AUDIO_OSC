===================
### AUDIO_SIN_WAVE_OSC

audio frequency sin wave oscrator
set by potention meter
can view set frequency on TM1638 LED & KEY Boad Driver

the frequency range is 16~2042Hz

## Description 
FPGA

code is complete, but doc is not over.
if you interst this project, show sources! ;-)

maybe discript docs.


show block chart 
chart/chart.bdf on Quartus

This project is 7SEG LED & KEY driver used TM1638
I test on aitendo board follow 
http://www.aitendo.com/product/12887

driver module name is 
~/FPGA/RTL/TM1638_LED_KEY_DRV/TM1638_LED_KEY_DRV.v



1. set system clock speed on C_FCK, as Hz

2. if you show binary code , input BIN_DAT_i/32
3. if you want direct 7seg drive, connect DIRECT7SEG[0:7]_i

    
```verilogHDL:sample


```

include TB_~~~
you can simple RTL behaver sim on this same code.

.TOP(demo) module
~/FPGA/RTL/TM1638_LED_KEY_DRV_TOP.v is a demo top module including target TM1638_LED_KEY_DRV().
the Demo is a ... funny clock. MSB digit 16 in 1 minuts.


    
```text:
pin_connection

Boadr : FPGA
VCC - CQ_MAX10-JB F1(poli Fuse)+5Vside
GND - CQ_MAX10-FB GND pin
STB - SS_o(P130)
CLK - SCLK_o(P127)
DIO-MISO_i(P124)
```
 

TM1638_LED_KEY_DRV


*.
~/K-7SEG8D1638-SKETTCH/*
is a board test code use arduino. wrote by aitendo.
character code is broken , I corrected.
BOMUTF16 is not match arudion.


## Log
2017-05-26fr adj potentiometer sabilizer LPF cuttoff f 58Hz->0.9Hz

## Features



## Demo
show 
https://www.youtube.com/watch?v=MgKUHE3Mb0w






## Requirement
writen in VerilogHDL.


#platform: CQ MAX10-FB (Altera MAX10:10M08SAE144C8)
 but may be can use any FPGA/ASIC




## Usage
  clone and compile on Altera QuartusII 
  I compiled on v16.1 web



## Help:  http://mangakoji.hatenablog.com/



## Licence:
----------
Copyright &copy; @manga_koji 2017-04-16su
Distributed under the [MIT License][mit].
[MIT]: http://www.opensource.org/licenses/mit-license.php

As a possibility, SUBREG_TIM_DIV part is conflict any one's PAT.
I dosen't study PAT.
But even if nobody held PAT, I don'd claim PAT.
and you can use this for known example.


enjoy!
