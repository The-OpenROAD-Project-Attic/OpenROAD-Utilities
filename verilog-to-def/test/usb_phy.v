/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : L-2016.03-SP4-1
// Date      : Tue Apr  9 16:04:10 2019
/////////////////////////////////////////////////////////////


module usb_tx_phy ( clk, rst, fs_ce, phy_mode, txdp, txdn, txoe, DataOut_i_7_, 
        DataOut_i_6_, DataOut_i_5_, DataOut_i_4_, DataOut_i_3_, DataOut_i_2_, 
        DataOut_i_1_, DataOut_i_0_, TxValid_i, TxReady_o );
  input clk, rst, fs_ce, phy_mode, DataOut_i_7_, DataOut_i_6_, DataOut_i_5_,
         DataOut_i_4_, DataOut_i_3_, DataOut_i_2_, DataOut_i_1_, DataOut_i_0_,
         TxValid_i;
  output txdp, txdn, txoe, TxReady_o;
  wire   tx_ready_d, N18, ld_data, tx_ip, tx_ip_sync, data_done, bit_cnt_2_,
         bit_cnt_1_, bit_cnt_0_, hold_reg_d_7_, hold_reg_d_6_, hold_reg_d_5_,
         hold_reg_d_4_, hold_reg_d_3_, hold_reg_d_2_, hold_reg_d_1_,
         hold_reg_d_0_, sd_raw_o, N87, N88, sft_done, sft_done_r, hold_reg_7_,
         hold_reg_6_, hold_reg_5_, hold_reg_4_, hold_reg_3_, hold_reg_2_,
         hold_reg_1_, hold_reg_0_, one_cnt_2_, one_cnt_1_, one_cnt_0_, sd_bs_o,
         sd_nrzi_o, txoe_r1, append_eop_sync2, append_eop, append_eop_sync1,
         append_eop_sync3, append_eop_sync4, txoe_r2, state_2_, state_1_,
         state_0_, n115, n116, n117, n118, n119, n120, n121, n122, n123, n124,
         n125, n126, n127, n128, n129, n130, n131, n132, n133, n134, n135,
         n136, n137, n138, n139, n140, n141, n142, n143, n144, n145, n146, n1,
         n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44,
         n45, n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56, n57, n58,
         n59, n60, n61, n62, n63, n64, n65, n66, n67, n68, n69, n70, n71, n72,
         n73, n74, n75, n76, n77, n78, n79, n80, n81, n82, n83, n84, n85, n86,
         n87, n88, n89, n90, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100,
         n101, n102, n103, n104, n105;

  ms00f80 state_reg_0_ ( .d(n146), .ck(clk), .o(state_0_) );
  ms00f80 append_eop_reg ( .d(n133), .ck(clk), .o(append_eop) );
  ms00f80 append_eop_sync1_reg ( .d(n124), .ck(clk), .o(append_eop_sync1) );
  ms00f80 append_eop_sync2_reg ( .d(n125), .ck(clk), .o(append_eop_sync2) );
  ms00f80 append_eop_sync3_reg ( .d(n126), .ck(clk), .o(append_eop_sync3) );
  ms00f80 tx_ip_reg ( .d(n135), .ck(clk), .o(tx_ip) );
  ms00f80 data_done_reg ( .d(n134), .ck(clk), .o(data_done) );
  ms00f80 tx_ip_sync_reg ( .d(n122), .ck(clk), .o(tx_ip_sync) );
  ms00f80 txoe_r1_reg ( .d(n128), .ck(clk), .o(txoe_r1) );
  ms00f80 txoe_r2_reg ( .d(n129), .ck(clk), .o(txoe_r2) );
  ms00f80 txoe_reg ( .d(n130), .ck(clk), .o(txoe) );
  ms00f80 bit_cnt_reg_0_ ( .d(n119), .ck(clk), .o(bit_cnt_0_) );
  ms00f80 bit_cnt_reg_1_ ( .d(n120), .ck(clk), .o(bit_cnt_1_) );
  ms00f80 bit_cnt_reg_2_ ( .d(n118), .ck(clk), .o(bit_cnt_2_) );
  ms00f80 sd_bs_o_reg ( .d(n123), .ck(clk), .o(sd_bs_o) );
  ms00f80 sd_nrzi_o_reg ( .d(n121), .ck(clk), .o(sd_nrzi_o) );
  ms00f80 txdn_reg ( .d(n132), .ck(clk), .o(txdn) );
  ms00f80 txdp_reg ( .d(n131), .ck(clk), .o(txdp) );
  ms00f80 one_cnt_reg_0_ ( .d(n117), .ck(clk), .o(one_cnt_0_) );
  ms00f80 one_cnt_reg_1_ ( .d(n116), .ck(clk), .o(one_cnt_1_) );
  ms00f80 one_cnt_reg_2_ ( .d(n115), .ck(clk), .o(one_cnt_2_) );
  ms00f80 sft_done_reg ( .d(N88), .ck(clk), .o(sft_done) );
  ms00f80 sft_done_r_reg ( .d(sft_done), .ck(clk), .o(sft_done_r) );
  ms00f80 state_reg_2_ ( .d(n144), .ck(clk), .o(state_2_) );
  ms00f80 state_reg_1_ ( .d(n145), .ck(clk), .o(state_1_) );
  ms00f80 TxReady_o_reg ( .d(N18), .ck(clk), .o(TxReady_o) );
  ms00f80 ld_data_reg ( .d(tx_ready_d), .ck(clk), .o(ld_data) );
  ms00f80 hold_reg_reg_0_ ( .d(n143), .ck(clk), .o(hold_reg_0_) );
  ms00f80 hold_reg_d_reg_0_ ( .d(hold_reg_0_), .ck(clk), .o(hold_reg_d_0_) );
  ms00f80 hold_reg_reg_1_ ( .d(n142), .ck(clk), .o(hold_reg_1_) );
  ms00f80 hold_reg_d_reg_1_ ( .d(hold_reg_1_), .ck(clk), .o(hold_reg_d_1_) );
  ms00f80 hold_reg_reg_2_ ( .d(n141), .ck(clk), .o(hold_reg_2_) );
  ms00f80 hold_reg_d_reg_2_ ( .d(hold_reg_2_), .ck(clk), .o(hold_reg_d_2_) );
  ms00f80 hold_reg_reg_3_ ( .d(n140), .ck(clk), .o(hold_reg_3_) );
  ms00f80 hold_reg_d_reg_3_ ( .d(hold_reg_3_), .ck(clk), .o(hold_reg_d_3_) );
  ms00f80 hold_reg_reg_4_ ( .d(n139), .ck(clk), .o(hold_reg_4_) );
  ms00f80 hold_reg_d_reg_4_ ( .d(hold_reg_4_), .ck(clk), .o(hold_reg_d_4_) );
  ms00f80 hold_reg_reg_5_ ( .d(n138), .ck(clk), .o(hold_reg_5_) );
  ms00f80 hold_reg_d_reg_5_ ( .d(hold_reg_5_), .ck(clk), .o(hold_reg_d_5_) );
  ms00f80 hold_reg_reg_6_ ( .d(n137), .ck(clk), .o(hold_reg_6_) );
  ms00f80 hold_reg_d_reg_6_ ( .d(hold_reg_6_), .ck(clk), .o(hold_reg_d_6_) );
  ms00f80 hold_reg_reg_7_ ( .d(n136), .ck(clk), .o(hold_reg_7_) );
  ms00f80 hold_reg_d_reg_7_ ( .d(hold_reg_7_), .ck(clk), .o(hold_reg_d_7_) );
  ms00f80 sd_raw_o_reg ( .d(N87), .ck(clk), .o(sd_raw_o) );
  ms00f80 append_eop_sync4_reg ( .d(n127), .ck(clk), .o(append_eop_sync4) );
  na02s02 U3 ( .a(rst), .b(n77), .o(n93) );
  na02f01 U4 ( .a(rst), .b(fs_ce), .o(n76) );
  in01s01 U5 ( .a(n102), .o(n1) );
  in01s01 U6 ( .a(n1), .o(n2) );
  no02f01 U7 ( .a(n48), .b(ld_data), .o(n45) );
  in01s01 U8 ( .a(one_cnt_1_), .o(n100) );
  in01s01 U9 ( .a(one_cnt_2_), .o(n103) );
  no03s01 U10 ( .a(n100), .b(n103), .c(one_cnt_0_), .o(n72) );
  in01s01 U11 ( .a(bit_cnt_1_), .o(n87) );
  in01s01 U12 ( .a(bit_cnt_2_), .o(n90) );
  in01s01 U13 ( .a(bit_cnt_0_), .o(n8) );
  no02s01 U14 ( .a(n90), .b(n8), .o(n11) );
  in01s01 U15 ( .a(n11), .o(n6) );
  no03s01 U16 ( .a(n72), .b(n87), .c(n6), .o(N88) );
  no02s01 U17 ( .a(state_2_), .b(state_1_), .o(n20) );
  na02s01 U18 ( .a(state_0_), .b(n20), .o(n18) );
  in01s01 U19 ( .a(state_0_), .o(n26) );
  na02s01 U20 ( .a(state_1_), .b(n26), .o(n19) );
  in01s01 U21 ( .a(n19), .o(n54) );
  na02s01 U22 ( .a(n54), .b(data_done), .o(n4) );
  in01s01 U23 ( .a(sft_done_r), .o(n3) );
  na02s01 U24 ( .a(n3), .b(sft_done), .o(n52) );
  ao12s01 U25 ( .b(n18), .c(n4), .a(n52), .o(tx_ready_d) );
  na03s01 U26 ( .a(rst), .b(TxValid_i), .c(tx_ready_d), .o(n5) );
  in01s01 U27 ( .a(n5), .o(N18) );
  in01s01 U28 ( .a(tx_ip_sync), .o(n92) );
  ao22s01 U29 ( .a(bit_cnt_2_), .b(hold_reg_d_6_), .c(hold_reg_d_2_), .d(n90), 
        .o(n9) );
  na02s01 U30 ( .a(n90), .b(bit_cnt_0_), .o(n10) );
  oa22s01 U31 ( .a(hold_reg_d_7_), .b(n6), .c(hold_reg_d_3_), .d(n10), .o(n7)
         );
  ao12s01 U32 ( .b(n9), .c(n8), .a(n7), .o(n15) );
  ao22s01 U33 ( .a(bit_cnt_2_), .b(hold_reg_d_4_), .c(hold_reg_d_0_), .d(n90), 
        .o(n13) );
  in01s01 U34 ( .a(n10), .o(n88) );
  ao22s01 U35 ( .a(n88), .b(hold_reg_d_1_), .c(n11), .d(hold_reg_d_5_), .o(n12) );
  oa12s01 U36 ( .b(bit_cnt_0_), .c(n13), .a(n12), .o(n14) );
  ao22s01 U37 ( .a(bit_cnt_1_), .b(n15), .c(n14), .d(n87), .o(n16) );
  no02s01 U38 ( .a(n92), .b(n16), .o(N87) );
  in01s01 U39 ( .a(state_2_), .o(n32) );
  in01s01 U40 ( .a(fs_ce), .o(n77) );
  in01s01 U41 ( .a(n52), .o(n17) );
  ao12s01 U42 ( .b(n19), .c(n18), .a(n17), .o(n25) );
  in01s01 U43 ( .a(append_eop_sync3), .o(n67) );
  na02s01 U44 ( .a(state_1_), .b(n67), .o(n23) );
  in01s01 U45 ( .a(TxValid_i), .o(n35) );
  ao22s01 U46 ( .a(state_2_), .b(append_eop_sync3), .c(n20), .d(n35), .o(n22)
         );
  oa12s01 U47 ( .b(state_0_), .c(data_done), .a(state_1_), .o(n21) );
  ao22s01 U48 ( .a(state_0_), .b(n23), .c(n22), .d(n21), .o(n24) );
  oa12s01 U49 ( .b(n25), .c(n24), .a(rst), .o(n31) );
  oa12s01 U50 ( .b(n32), .c(n93), .a(n31), .o(n28) );
  ao12s01 U51 ( .b(rst), .c(n26), .a(n28), .o(n34) );
  ao12s01 U52 ( .b(n26), .c(n28), .a(n34), .o(n146) );
  no02s01 U53 ( .a(n28), .b(n26), .o(n30) );
  in01s01 U54 ( .a(rst), .o(n73) );
  no02s01 U55 ( .a(state_2_), .b(n73), .o(n27) );
  oa22s01 U56 ( .a(n28), .b(n27), .c(state_1_), .d(n30), .o(n29) );
  ao12s01 U57 ( .b(state_1_), .c(n30), .a(n29), .o(n145) );
  na04s01 U58 ( .a(state_0_), .b(rst), .c(state_1_), .d(n31), .o(n33) );
  ao22s01 U59 ( .a(state_2_), .b(n34), .c(n33), .d(n32), .o(n144) );
  no04s01 U60 ( .a(state_2_), .b(state_0_), .c(state_1_), .d(n35), .o(n48) );
  in01s01 U61 ( .a(n48), .o(n46) );
  na02s01 U62 ( .a(n46), .b(ld_data), .o(n36) );
  in01s01 U63 ( .a(n36), .o(n44) );
  ao22s01 U64 ( .a(n45), .b(hold_reg_0_), .c(n44), .d(DataOut_i_0_), .o(n37)
         );
  in01s01 U65 ( .a(n37), .o(n143) );
  ao22s01 U66 ( .a(n45), .b(hold_reg_1_), .c(n44), .d(DataOut_i_1_), .o(n38)
         );
  in01s01 U67 ( .a(n38), .o(n142) );
  ao22s01 U68 ( .a(n45), .b(hold_reg_2_), .c(n44), .d(DataOut_i_2_), .o(n39)
         );
  in01s01 U69 ( .a(n39), .o(n141) );
  ao22s01 U70 ( .a(n45), .b(hold_reg_3_), .c(n44), .d(DataOut_i_3_), .o(n40)
         );
  in01s01 U71 ( .a(n40), .o(n140) );
  ao22s01 U72 ( .a(n45), .b(hold_reg_4_), .c(n44), .d(DataOut_i_4_), .o(n41)
         );
  in01s01 U73 ( .a(n41), .o(n139) );
  ao22s01 U74 ( .a(n45), .b(hold_reg_5_), .c(n44), .d(DataOut_i_5_), .o(n42)
         );
  in01s01 U75 ( .a(n42), .o(n138) );
  ao22s01 U76 ( .a(n45), .b(hold_reg_6_), .c(n44), .d(DataOut_i_6_), .o(n43)
         );
  in01s01 U77 ( .a(n43), .o(n137) );
  ao22s01 U78 ( .a(hold_reg_7_), .b(n45), .c(n44), .d(DataOut_i_7_), .o(n47)
         );
  na02s01 U79 ( .a(n47), .b(n46), .o(n136) );
  ao12s01 U80 ( .b(tx_ip), .c(n67), .a(n48), .o(n49) );
  no02s01 U81 ( .a(n49), .b(n73), .o(n135) );
  in01s01 U82 ( .a(data_done), .o(n51) );
  na02s01 U83 ( .a(rst), .b(TxValid_i), .o(n50) );
  ao12s01 U84 ( .b(tx_ip), .c(n51), .a(n50), .o(n134) );
  no02s01 U85 ( .a(data_done), .b(n52), .o(n53) );
  in01s01 U86 ( .a(append_eop_sync2), .o(n69) );
  ao22s01 U87 ( .a(n54), .b(n53), .c(append_eop), .d(n69), .o(n55) );
  no02s01 U88 ( .a(n55), .b(n73), .o(n133) );
  in01s01 U89 ( .a(sd_nrzi_o), .o(n78) );
  ao12s01 U90 ( .b(phy_mode), .c(n78), .a(append_eop_sync3), .o(n59) );
  in01s01 U91 ( .a(n76), .o(n57) );
  na02s01 U92 ( .a(append_eop_sync3), .b(phy_mode), .o(n56) );
  na02s01 U93 ( .a(n57), .b(n56), .o(n61) );
  in01s01 U94 ( .a(txdn), .o(n58) );
  oa22s01 U95 ( .a(n59), .b(n61), .c(n93), .d(n58), .o(n132) );
  ao12s01 U96 ( .b(txdp), .c(n77), .a(n73), .o(n60) );
  oa12s01 U97 ( .b(n78), .c(n61), .a(n60), .o(n131) );
  no02s01 U98 ( .a(txoe_r1), .b(txoe_r2), .o(n62) );
  ao22s01 U99 ( .a(txoe), .b(n77), .c(n62), .d(fs_ce), .o(n63) );
  na02s01 U100 ( .a(n63), .b(rst), .o(n130) );
  in01s01 U101 ( .a(txoe_r2), .o(n64) );
  in01s01 U102 ( .a(txoe_r1), .o(n65) );
  oa22s01 U103 ( .a(n93), .b(n64), .c(n76), .d(n65), .o(n129) );
  oa22s01 U104 ( .a(n93), .b(n65), .c(n76), .d(n92), .o(n128) );
  in01s01 U105 ( .a(append_eop_sync4), .o(n66) );
  oa22s01 U106 ( .a(n67), .b(n76), .c(n93), .d(n66), .o(n127) );
  oa12s01 U107 ( .b(n77), .c(n66), .a(rst), .o(n68) );
  oa22s01 U108 ( .a(n68), .b(n67), .c(n76), .d(n69), .o(n126) );
  in01s01 U109 ( .a(append_eop_sync1), .o(n71) );
  oa22s01 U110 ( .a(n93), .b(n69), .c(n76), .d(n71), .o(n125) );
  in01s01 U111 ( .a(append_eop), .o(n70) );
  oa22s01 U112 ( .a(n93), .b(n71), .c(n76), .d(n70), .o(n124) );
  in01s01 U113 ( .a(sd_bs_o), .o(n74) );
  no04s01 U114 ( .a(n77), .b(n73), .c(n92), .d(n72), .o(n102) );
  na02s01 U115 ( .a(n2), .b(sd_raw_o), .o(n96) );
  oa12s01 U116 ( .b(n93), .c(n74), .a(n96), .o(n123) );
  in01s01 U117 ( .a(tx_ip), .o(n75) );
  oa22s01 U118 ( .a(n93), .b(n92), .c(n76), .d(n75), .o(n122) );
  no02s01 U119 ( .a(n77), .b(sd_bs_o), .o(n79) );
  in01s01 U120 ( .a(n79), .o(n80) );
  ao22s01 U121 ( .a(sd_nrzi_o), .b(n80), .c(n79), .d(n78), .o(n81) );
  na04s01 U122 ( .a(rst), .b(tx_ip_sync), .c(txoe_r1), .d(n81), .o(n121) );
  na02s01 U123 ( .a(rst), .b(tx_ip_sync), .o(n85) );
  ao12s01 U124 ( .b(n2), .c(bit_cnt_0_), .a(n85), .o(n86) );
  in01s01 U125 ( .a(n86), .o(n83) );
  na02s01 U126 ( .a(n2), .b(bit_cnt_0_), .o(n82) );
  ao22s01 U127 ( .a(bit_cnt_1_), .b(n83), .c(n82), .d(n87), .o(n120) );
  na02s01 U128 ( .a(bit_cnt_0_), .b(n1), .o(n84) );
  oa22s01 U129 ( .a(bit_cnt_0_), .b(n1), .c(n85), .d(n84), .o(n119) );
  ao12s01 U130 ( .b(n2), .c(n87), .a(n86), .o(n91) );
  na02s01 U131 ( .a(n88), .b(bit_cnt_1_), .o(n89) );
  oa22s01 U132 ( .a(n91), .b(n90), .c(n1), .d(n89), .o(n118) );
  in01s01 U133 ( .a(n93), .o(n95) );
  in01s01 U134 ( .a(one_cnt_0_), .o(n94) );
  oa22s01 U135 ( .a(one_cnt_0_), .b(n96), .c(n93), .d(n92), .o(n99) );
  in01s01 U136 ( .a(n99), .o(n98) );
  ao12s01 U137 ( .b(n95), .c(n94), .a(n98), .o(n117) );
  in01s01 U138 ( .a(n96), .o(n101) );
  na02s01 U139 ( .a(one_cnt_0_), .b(n101), .o(n97) );
  ao22s01 U140 ( .a(one_cnt_1_), .b(n98), .c(n97), .d(n100), .o(n116) );
  ao12s01 U141 ( .b(n101), .c(n100), .a(n99), .o(n105) );
  na04s01 U142 ( .a(one_cnt_1_), .b(one_cnt_0_), .c(n2), .d(sd_raw_o), .o(n104) );
  ao22s01 U143 ( .a(one_cnt_2_), .b(n105), .c(n104), .d(n103), .o(n115) );
endmodule


module usb_rx_phy ( clk, rst, fs_ce, rxd, rxdp, rxdn, RxValid_o, RxActive_o, 
        RxError_o, DataIn_o_7_, DataIn_o_6_, DataIn_o_5_, DataIn_o_4_, 
        DataIn_o_3_, DataIn_o_2_, DataIn_o_1_, DataIn_o_0_, RxEn_i, 
        LineState_1_, LineState_0_ );
  input clk, rst, rxd, rxdp, rxdn, RxEn_i;
  output fs_ce, RxValid_o, RxActive_o, RxError_o, DataIn_o_7_, DataIn_o_6_,
         DataIn_o_5_, DataIn_o_4_, DataIn_o_3_, DataIn_o_2_, DataIn_o_1_,
         DataIn_o_0_, LineState_1_, LineState_0_;
  wire   sync_err, bit_stuff_err, byte_err, rx_en, N20, rxd_s0, rxd_s1, rxd_s,
         rxdp_s0, N26, rxdp_s_r, N27, rxdp_s, rxdn_s0, N28, rxdn_s_r, N29,
         rxdn_s, se0, se0_s, rxd_r, dpll_state_1_, dpll_state_0_, N31, N32,
         fs_ce_d, fs_ce_r1, fs_ce_r2, fs_state_2_, fs_state_1_, fs_state_0_,
         rx_valid_r, sd_r, sd_nrzi, shift_en, one_cnt_2_, one_cnt_1_,
         one_cnt_0_, N136, bit_cnt_2_, bit_cnt_1_, bit_cnt_0_, rx_valid1, N165,
         se0_r, N166, n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, n109,
         n110, n111, n112, n113, n114, n115, n116, n117, n118, n119, n120,
         n121, n122, n123, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12,
         n23, n24, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34, n35, n36,
         n37, n38, n39, n40, n41, n42, n43, n44, n45, n46, n47, n48, n49, n50,
         n51, n52, n53, n54, n55, n56, n57, n58, n59, n60, n61, n62, n63, n64,
         n65, n66, n67, n68, n69, n70, n71, n72, n73, n74, n75, n76, n77, n78,
         n79, n80, n81, n82, n83, n84, n85, n86, n87, n88, n89, n90, n91, n92,
         n93, n94, n95, n96, n97, n98, n99, n100;

  ms00f80 rx_en_reg ( .d(RxEn_i), .ck(clk), .o(rx_en) );
  ms00f80 rxd_s0_reg ( .d(rxd), .ck(clk), .o(rxd_s0) );
  ms00f80 rxd_s1_reg ( .d(rxd_s0), .ck(clk), .o(rxd_s1) );
  ms00f80 rxd_s_reg ( .d(n123), .ck(clk), .o(rxd_s) );
  ms00f80 rxdp_s0_reg ( .d(rxdp), .ck(clk), .o(rxdp_s0) );
  ms00f80 rxdp_s1_reg ( .d(rxdp_s0), .ck(clk), .o(LineState_0_) );
  ms00f80 rxdp_s_r_reg ( .d(N26), .ck(clk), .o(rxdp_s_r) );
  ms00f80 rxdp_s_reg ( .d(N27), .ck(clk), .o(rxdp_s) );
  ms00f80 rxdn_s0_reg ( .d(rxdn), .ck(clk), .o(rxdn_s0) );
  ms00f80 rxdn_s1_reg ( .d(rxdn_s0), .ck(clk), .o(LineState_1_) );
  ms00f80 rxdn_s_r_reg ( .d(N28), .ck(clk), .o(rxdn_s_r) );
  ms00f80 rxdn_s_reg ( .d(N29), .ck(clk), .o(rxdn_s) );
  ms00f80 rxd_r_reg ( .d(rxd_s), .ck(clk), .o(rxd_r) );
  ms00f80 dpll_state_reg_0_ ( .d(N31), .ck(clk), .o(dpll_state_0_) );
  ms00f80 dpll_state_reg_1_ ( .d(N32), .ck(clk), .o(dpll_state_1_) );
  ms00f80 fs_ce_r2_reg ( .d(fs_ce_r1), .ck(clk), .o(fs_ce_r2) );
  ms00f80 fs_ce_reg ( .d(fs_ce_r2), .ck(clk), .o(fs_ce) );
  ms00f80 se0_s_reg ( .d(n22), .ck(clk), .o(se0_s) );
  ms00f80 sd_r_reg ( .d(n21), .ck(clk), .o(sd_r) );
  ms00f80 rx_valid_reg ( .d(N165), .ck(clk), .o(RxValid_o) );
  ms00f80 rx_valid_r_reg ( .d(n122), .ck(clk), .o(rx_valid_r) );
  ms00f80 rx_active_reg ( .d(n121), .ck(clk), .o(RxActive_o) );
  ms00f80 fs_state_reg_0_ ( .d(n120), .ck(clk), .o(fs_state_0_) );
  ms00f80 fs_state_reg_1_ ( .d(n119), .ck(clk), .o(fs_state_1_) );
  ms00f80 fs_state_reg_2_ ( .d(n118), .ck(clk), .o(fs_state_2_) );
  ms00f80 sync_err_reg ( .d(N20), .ck(clk), .o(sync_err) );
  ms00f80 shift_en_reg ( .d(n117), .ck(clk), .o(shift_en) );
  ms00f80 sd_nrzi_reg ( .d(n116), .ck(clk), .o(sd_nrzi) );
  ms00f80 one_cnt_reg_0_ ( .d(n115), .ck(clk), .o(one_cnt_0_) );
  ms00f80 one_cnt_reg_1_ ( .d(n114), .ck(clk), .o(one_cnt_1_) );
  ms00f80 one_cnt_reg_2_ ( .d(n113), .ck(clk), .o(one_cnt_2_) );
  ms00f80 bit_stuff_err_reg ( .d(N136), .ck(clk), .o(bit_stuff_err) );
  ms00f80 hold_reg_reg_7_ ( .d(n20), .ck(clk), .o(DataIn_o_7_) );
  ms00f80 hold_reg_reg_6_ ( .d(n19), .ck(clk), .o(DataIn_o_6_) );
  ms00f80 hold_reg_reg_5_ ( .d(n18), .ck(clk), .o(DataIn_o_5_) );
  ms00f80 hold_reg_reg_4_ ( .d(n17), .ck(clk), .o(DataIn_o_4_) );
  ms00f80 hold_reg_reg_3_ ( .d(n16), .ck(clk), .o(DataIn_o_3_) );
  ms00f80 hold_reg_reg_2_ ( .d(n15), .ck(clk), .o(DataIn_o_2_) );
  ms00f80 hold_reg_reg_1_ ( .d(n14), .ck(clk), .o(DataIn_o_1_) );
  ms00f80 hold_reg_reg_0_ ( .d(n13), .ck(clk), .o(DataIn_o_0_) );
  ms00f80 bit_cnt_reg_0_ ( .d(n111), .ck(clk), .o(bit_cnt_0_) );
  ms00f80 bit_cnt_reg_1_ ( .d(n112), .ck(clk), .o(bit_cnt_1_) );
  ms00f80 bit_cnt_reg_2_ ( .d(n110), .ck(clk), .o(bit_cnt_2_) );
  ms00f80 rx_valid1_reg ( .d(n109), .ck(clk), .o(rx_valid1) );
  ms00f80 se0_r_reg ( .d(se0), .ck(clk), .o(se0_r) );
  ms00f80 byte_err_reg ( .d(N166), .ck(clk), .o(byte_err) );
  ms00f80 fs_ce_r1_reg ( .d(fs_ce_d), .ck(clk), .o(fs_ce_r1) );
  na02s02 U3 ( .a(n83), .b(shift_en), .o(n94) );
  na04s03 U4 ( .a(fs_ce), .b(n99), .c(n100), .d(n25), .o(n40) );
  in01s01 U5 ( .a(one_cnt_0_), .o(n60) );
  no03s01 U6 ( .a(sync_err), .b(bit_stuff_err), .c(byte_err), .o(n1) );
  in01s01 U7 ( .a(n1), .o(RxError_o) );
  no02s01 U8 ( .a(rxdn_s), .b(rxdp_s), .o(se0) );
  in01s01 U9 ( .a(rxdp_s), .o(n39) );
  in01s01 U10 ( .a(fs_state_2_), .o(n51) );
  in01s01 U11 ( .a(fs_state_1_), .o(n47) );
  ao22s01 U12 ( .a(rx_en), .b(n39), .c(n51), .d(n47), .o(n5) );
  in01s01 U13 ( .a(rx_en), .o(n42) );
  no02s01 U14 ( .a(rxdn_s), .b(n42), .o(n2) );
  oa12s01 U15 ( .b(fs_state_1_), .c(n2), .a(fs_state_0_), .o(n4) );
  in01s01 U16 ( .a(fs_state_0_), .o(n43) );
  no02s01 U17 ( .a(n2), .b(n43), .o(n3) );
  ao22s01 U18 ( .a(n5), .b(n4), .c(n3), .d(n51), .o(n6) );
  in01s01 U19 ( .a(se0_s), .o(n99) );
  in01s01 U20 ( .a(se0), .o(n100) );
  in01s01 U21 ( .a(RxActive_o), .o(n25) );
  no02s01 U22 ( .a(n6), .b(n40), .o(N20) );
  na02s01 U23 ( .a(rxdp_s0), .b(LineState_0_), .o(n7) );
  in01s01 U24 ( .a(n7), .o(N26) );
  no02s01 U25 ( .a(rxdp_s_r), .b(N26), .o(n8) );
  in01s01 U26 ( .a(n8), .o(N27) );
  na02s01 U27 ( .a(rxdn_s0), .b(LineState_1_), .o(n9) );
  in01s01 U28 ( .a(n9), .o(N28) );
  no02s01 U29 ( .a(rxdn_s_r), .b(N28), .o(n10) );
  in01s01 U30 ( .a(n10), .o(N29) );
  in01s01 U31 ( .a(one_cnt_1_), .o(n65) );
  in01s01 U32 ( .a(one_cnt_2_), .o(n11) );
  no03s01 U33 ( .a(one_cnt_0_), .b(n65), .c(n11), .o(n23) );
  na04s01 U34 ( .a(sd_nrzi), .b(fs_ce), .c(n23), .d(RxActive_o), .o(n12) );
  no02s01 U35 ( .a(se0), .b(n12), .o(N136) );
  in01s01 U36 ( .a(fs_ce), .o(n98) );
  no02s01 U37 ( .a(n23), .b(n98), .o(n83) );
  in01s01 U38 ( .a(n83), .o(n81) );
  in01s01 U39 ( .a(rx_valid1), .o(n24) );
  no02s01 U40 ( .a(n81), .b(n24), .o(N165) );
  no02s01 U41 ( .a(bit_cnt_2_), .b(bit_cnt_1_), .o(n26) );
  no04s01 U42 ( .a(se0_r), .b(n26), .c(n25), .d(n100), .o(N166) );
  in01s01 U43 ( .a(dpll_state_0_), .o(n27) );
  no02s01 U44 ( .a(dpll_state_1_), .b(n27), .o(fs_ce_d) );
  oa12s01 U45 ( .b(rxd_s), .c(rxd_r), .a(rx_en), .o(n28) );
  ao12s01 U46 ( .b(rxd_s), .c(rxd_r), .a(n28), .o(n29) );
  no02s01 U47 ( .a(dpll_state_0_), .b(n29), .o(n31) );
  ao12s01 U48 ( .b(n29), .c(fs_ce_d), .a(n31), .o(n30) );
  na02s01 U49 ( .a(rst), .b(n30), .o(N31) );
  ao12s01 U50 ( .b(dpll_state_1_), .c(n31), .a(fs_ce_d), .o(n32) );
  in01s01 U51 ( .a(rst), .o(n85) );
  no02s01 U52 ( .a(n32), .b(n85), .o(N32) );
  in01s01 U53 ( .a(rxd_s1), .o(n34) );
  in01s01 U54 ( .a(rxd_s), .o(n97) );
  oa12s01 U55 ( .b(rxd_s), .c(rxd_s1), .a(rxd_s0), .o(n33) );
  oa12s01 U56 ( .b(n34), .c(n97), .a(n33), .o(n123) );
  ao12s01 U57 ( .b(rx_valid_r), .c(n98), .a(RxValid_o), .o(n35) );
  in01s01 U58 ( .a(n35), .o(n122) );
  oa12s01 U59 ( .b(fs_state_1_), .c(rx_en), .a(n39), .o(n36) );
  no04s01 U60 ( .a(n36), .b(n43), .c(n51), .d(n40), .o(n54) );
  na02s01 U61 ( .a(se0), .b(rx_valid_r), .o(n37) );
  ao22s01 U62 ( .a(rx_en), .b(n54), .c(RxActive_o), .d(n37), .o(n38) );
  no02s01 U63 ( .a(n38), .b(n85), .o(n121) );
  na02s01 U64 ( .a(rst), .b(n40), .o(n44) );
  na04s01 U65 ( .a(rst), .b(rx_en), .c(n43), .d(n39), .o(n41) );
  oa22s01 U66 ( .a(n43), .b(n44), .c(n40), .d(n41), .o(n120) );
  na02s01 U67 ( .a(n44), .b(n41), .o(n46) );
  in01s01 U68 ( .a(n46), .o(n45) );
  no04s01 U69 ( .a(rxdn_s), .b(n43), .c(n85), .d(n42), .o(n48) );
  na02s01 U70 ( .a(n48), .b(n44), .o(n49) );
  oa22s01 U71 ( .a(n47), .b(n45), .c(n49), .d(fs_state_1_), .o(n119) );
  ao12s01 U72 ( .b(n48), .c(n47), .a(n46), .o(n53) );
  in01s01 U73 ( .a(n49), .o(n50) );
  na02s01 U74 ( .a(fs_state_1_), .b(n50), .o(n52) );
  ao22s01 U75 ( .a(fs_state_2_), .b(n53), .c(n52), .d(n51), .o(n118) );
  no02s01 U76 ( .a(RxActive_o), .b(n54), .o(n55) );
  in01s01 U77 ( .a(shift_en), .o(n70) );
  ao22s01 U78 ( .a(fs_ce), .b(n55), .c(n70), .d(n98), .o(n117) );
  in01s01 U79 ( .a(sd_r), .o(n96) );
  ao22s01 U80 ( .a(rxd_s), .b(n96), .c(sd_r), .d(n97), .o(n56) );
  ao22s01 U81 ( .a(fs_ce), .b(n56), .c(sd_nrzi), .d(n98), .o(n57) );
  ao12s01 U82 ( .b(RxActive_o), .c(n57), .a(n85), .o(n116) );
  no02s01 U83 ( .a(n94), .b(n85), .o(n75) );
  na02s01 U84 ( .a(sd_nrzi), .b(n75), .o(n63) );
  na03s01 U85 ( .a(shift_en), .b(rst), .c(n98), .o(n58) );
  oa12s01 U86 ( .b(one_cnt_0_), .c(n63), .a(n58), .o(n64) );
  in01s01 U87 ( .a(n64), .o(n62) );
  no02s01 U88 ( .a(one_cnt_0_), .b(n58), .o(n59) );
  no02s01 U89 ( .a(n62), .b(n59), .o(n115) );
  no02s01 U90 ( .a(n63), .b(n60), .o(n67) );
  in01s01 U91 ( .a(n67), .o(n61) );
  ao22s01 U92 ( .a(one_cnt_1_), .b(n62), .c(n61), .d(n65), .o(n114) );
  in01s01 U93 ( .a(n63), .o(n66) );
  ao12s01 U94 ( .b(n66), .c(n65), .a(n64), .o(n69) );
  ao12s01 U95 ( .b(n67), .c(one_cnt_1_), .a(one_cnt_2_), .o(n68) );
  ao12s01 U96 ( .b(one_cnt_2_), .c(n69), .a(n68), .o(n113) );
  no02s01 U97 ( .a(n70), .b(n85), .o(n71) );
  in01s01 U98 ( .a(bit_cnt_0_), .o(n78) );
  ao22s01 U99 ( .a(n81), .b(n71), .c(n78), .d(n75), .o(n73) );
  in01s01 U100 ( .a(bit_cnt_1_), .o(n79) );
  na02s01 U101 ( .a(n75), .b(n79), .o(n72) );
  oa22s01 U102 ( .a(n73), .b(n79), .c(n72), .d(n78), .o(n112) );
  ao12s01 U103 ( .b(n81), .c(n78), .a(n73), .o(n111) );
  in01s01 U104 ( .a(n73), .o(n74) );
  ao12s01 U105 ( .b(n75), .c(n79), .a(n74), .o(n77) );
  na03s01 U106 ( .a(n75), .b(bit_cnt_1_), .c(bit_cnt_0_), .o(n76) );
  in01s01 U107 ( .a(bit_cnt_2_), .o(n80) );
  ao22s01 U108 ( .a(bit_cnt_2_), .b(n77), .c(n76), .d(n80), .o(n110) );
  no03s01 U109 ( .a(n80), .b(n79), .c(n78), .o(n82) );
  ao22s01 U110 ( .a(n83), .b(n82), .c(rx_valid1), .d(n81), .o(n84) );
  no02s01 U111 ( .a(n85), .b(n84), .o(n109) );
  in01s01 U112 ( .a(n94), .o(n93) );
  oa22s01 U113 ( .a(n94), .b(DataIn_o_1_), .c(DataIn_o_0_), .d(n93), .o(n86)
         );
  in01s01 U114 ( .a(n86), .o(n13) );
  oa22s01 U115 ( .a(n94), .b(DataIn_o_2_), .c(DataIn_o_1_), .d(n93), .o(n87)
         );
  in01s01 U116 ( .a(n87), .o(n14) );
  oa22s01 U117 ( .a(n94), .b(DataIn_o_3_), .c(DataIn_o_2_), .d(n93), .o(n88)
         );
  in01s01 U118 ( .a(n88), .o(n15) );
  oa22s01 U119 ( .a(n94), .b(DataIn_o_4_), .c(DataIn_o_3_), .d(n93), .o(n89)
         );
  in01s01 U120 ( .a(n89), .o(n16) );
  oa22s01 U121 ( .a(n94), .b(DataIn_o_5_), .c(DataIn_o_4_), .d(n93), .o(n90)
         );
  in01s01 U122 ( .a(n90), .o(n17) );
  oa22s01 U123 ( .a(n94), .b(DataIn_o_6_), .c(DataIn_o_5_), .d(n93), .o(n91)
         );
  in01s01 U124 ( .a(n91), .o(n18) );
  oa22s01 U125 ( .a(n94), .b(DataIn_o_7_), .c(DataIn_o_6_), .d(n93), .o(n92)
         );
  in01s01 U126 ( .a(n92), .o(n19) );
  oa22s01 U127 ( .a(n94), .b(sd_nrzi), .c(DataIn_o_7_), .d(n93), .o(n95) );
  in01s01 U128 ( .a(n95), .o(n20) );
  ao22s01 U129 ( .a(fs_ce), .b(n97), .c(n96), .d(n98), .o(n21) );
  ao22s01 U130 ( .a(fs_ce), .b(n100), .c(n99), .d(n98), .o(n22) );
endmodule


module usb_phy ( clk, rst, phy_tx_mode, usb_rst, txdp, txdn, txoe, rxd, rxdp, 
        rxdn, DataOut_i_7_, DataOut_i_6_, DataOut_i_5_, DataOut_i_4_, 
        DataOut_i_3_, DataOut_i_2_, DataOut_i_1_, DataOut_i_0_, TxValid_i, 
        TxReady_o, RxValid_o, RxActive_o, RxError_o, DataIn_o_7_, DataIn_o_6_, 
        DataIn_o_5_, DataIn_o_4_, DataIn_o_3_, DataIn_o_2_, DataIn_o_1_, 
        DataIn_o_0_, LineState_o_1_, LineState_o_0_ );
  input clk, rst, phy_tx_mode, rxd, rxdp, rxdn, DataOut_i_7_, DataOut_i_6_,
         DataOut_i_5_, DataOut_i_4_, DataOut_i_3_, DataOut_i_2_, DataOut_i_1_,
         DataOut_i_0_, TxValid_i;
  output usb_rst, txdp, txdn, txoe, TxReady_o, RxValid_o, RxActive_o,
         RxError_o, DataIn_o_7_, DataIn_o_6_, DataIn_o_5_, DataIn_o_4_,
         DataIn_o_3_, DataIn_o_2_, DataIn_o_1_, DataIn_o_0_, LineState_o_1_,
         LineState_o_0_;
  wire   fs_ce, rst_cnt_4_, rst_cnt_3_, rst_cnt_2_, rst_cnt_1_, rst_cnt_0_,
         N26, n7, n8, n9, n10, n11, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44,
         n45, n46, n47;

  usb_tx_phy i_tx_phy ( .clk(clk), .rst(rst), .fs_ce(fs_ce), .phy_mode(
        phy_tx_mode), .txdp(txdp), .txdn(txdn), .txoe(txoe), .DataOut_i_7_(
        DataOut_i_7_), .DataOut_i_6_(DataOut_i_6_), .DataOut_i_5_(DataOut_i_5_), .DataOut_i_4_(DataOut_i_4_), .DataOut_i_3_(DataOut_i_3_), .DataOut_i_2_(
        DataOut_i_2_), .DataOut_i_1_(DataOut_i_1_), .DataOut_i_0_(DataOut_i_0_), .TxValid_i(TxValid_i), .TxReady_o(TxReady_o) );
  usb_rx_phy i_rx_phy ( .clk(clk), .rst(rst), .fs_ce(fs_ce), .rxd(rxd), .rxdp(
        rxdp), .rxdn(rxdn), .RxValid_o(RxValid_o), .RxActive_o(RxActive_o), 
        .RxError_o(RxError_o), .DataIn_o_7_(DataIn_o_7_), .DataIn_o_6_(
        DataIn_o_6_), .DataIn_o_5_(DataIn_o_5_), .DataIn_o_4_(DataIn_o_4_), 
        .DataIn_o_3_(DataIn_o_3_), .DataIn_o_2_(DataIn_o_2_), .DataIn_o_1_(
        DataIn_o_1_), .DataIn_o_0_(DataIn_o_0_), .RxEn_i(txoe), .LineState_1_(
        LineState_o_1_), .LineState_0_(LineState_o_0_) );
  ms00f80 usb_rst_reg ( .d(N26), .ck(clk), .o(usb_rst) );
  ms00f80 rst_cnt_reg_0_ ( .d(n11), .ck(clk), .o(rst_cnt_0_) );
  ms00f80 rst_cnt_reg_4_ ( .d(n10), .ck(clk), .o(rst_cnt_4_) );
  ms00f80 rst_cnt_reg_3_ ( .d(n9), .ck(clk), .o(rst_cnt_3_) );
  ms00f80 rst_cnt_reg_2_ ( .d(n8), .ck(clk), .o(rst_cnt_2_) );
  ms00f80 rst_cnt_reg_1_ ( .d(n7), .ck(clk), .o(rst_cnt_1_) );
  in01s01 U32 ( .a(rst_cnt_3_), .o(n36) );
  na03s01 U33 ( .a(rst_cnt_2_), .b(rst_cnt_1_), .c(rst_cnt_0_), .o(n35) );
  in01s01 U34 ( .a(rst_cnt_4_), .o(n42) );
  no03s01 U35 ( .a(n36), .b(n35), .c(n42), .o(N26) );
  in01s01 U36 ( .a(rst), .o(n25) );
  no03s01 U37 ( .a(LineState_o_0_), .b(LineState_o_1_), .c(n25), .o(n24) );
  in01s01 U38 ( .a(usb_rst), .o(n23) );
  na03s01 U39 ( .a(n24), .b(fs_ce), .c(n23), .o(n46) );
  no02s01 U40 ( .a(rst_cnt_0_), .b(n46), .o(n26) );
  in01s01 U41 ( .a(n46), .o(n34) );
  no04s01 U42 ( .a(LineState_o_1_), .b(LineState_o_0_), .c(n34), .d(n25), .o(
        n44) );
  no02s01 U43 ( .a(n26), .b(n44), .o(n31) );
  in01s01 U44 ( .a(rst_cnt_1_), .o(n27) );
  na02s01 U45 ( .a(n27), .b(n34), .o(n28) );
  in01s01 U46 ( .a(rst_cnt_0_), .o(n45) );
  oa22s01 U47 ( .a(n31), .b(n27), .c(n28), .d(n45), .o(n7) );
  na03s01 U48 ( .a(n34), .b(rst_cnt_1_), .c(rst_cnt_0_), .o(n33) );
  in01s01 U49 ( .a(rst_cnt_2_), .o(n32) );
  in01s01 U50 ( .a(n28), .o(n29) );
  no02s01 U51 ( .a(n32), .b(n29), .o(n30) );
  ao22s01 U52 ( .a(n33), .b(n32), .c(n31), .d(n30), .o(n8) );
  ao12s01 U53 ( .b(n34), .c(n35), .a(n44), .o(n41) );
  na02s01 U54 ( .a(n36), .b(n34), .o(n38) );
  oa22s01 U55 ( .a(n41), .b(n36), .c(n38), .d(n35), .o(n9) );
  no03s01 U56 ( .a(n46), .b(n36), .c(n35), .o(n37) );
  in01s01 U57 ( .a(n37), .o(n43) );
  in01s01 U58 ( .a(n38), .o(n39) );
  no02s01 U59 ( .a(n42), .b(n39), .o(n40) );
  ao22s01 U60 ( .a(n43), .b(n42), .c(n41), .d(n40), .o(n10) );
  in01s01 U61 ( .a(n44), .o(n47) );
  ao22s01 U62 ( .a(rst_cnt_0_), .b(n47), .c(n46), .d(n45), .o(n11) );
endmodule

