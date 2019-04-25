#!/bin/bash
src/defgenerator -lef test/ispd_13/contest.lef \
  -lib test/ispd_13/contest.lib \
  -verilog test/usb_phy.v \
  -siteName CoreSite \
  -design usb_phy \
  -defDbu 2000 \
  -dieAreaInMicron 0 0 199.88 300.96 \
  -pinLocation test/pins/pinList.pins \
  -def test/usb_phy_generated.def
