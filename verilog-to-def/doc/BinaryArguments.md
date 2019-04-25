# Usage
    $ defgenerator -lef tech.lef -lef macro.lef ... -def out.def -verilog netlist.v -lib ff.lib -lib aoi.lib ... -dieAreaInMicron 0 0 200 300 -defDbu 2000 -siteName CoreSite -design usb_phy [-pinLocation pinList.pins]
* __-lef__ : *.lef Location (Multiple lef files supported. Technology LEF must be ahead of other LEFs.)
* __-def__ : Output *.def Location.
* __-verilog__ : Gate-level Verilog *.v Location.
* __-lib__ : *.lib Location (Required due to OpenSTA).
* __-dieAreaInMicron__ : Specify Rectangular Die Area followed by four number. lx ly ux uy
* __-defDbu__ : Specify the Database Units for DEF. 2000 is recommended.
* __-siteName__ : Specify the Row Name in *.lef.
* __-design__ : Specify the Top Module in *.v.
* __-pinLocation__ : Specify pin locations. If it is not specified, set all coordinates as (0, 0, 2). Example of *.pins files are in [test/pins/pinList.pins](/verilog-to-def/test/pins/pinList.pins). Simple *.pins generation script is in [/test/pins/pinGenerate.py](/verilog-to-def/test/pins/pinGenerate.py)


