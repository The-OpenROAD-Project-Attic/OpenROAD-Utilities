# Verilog to DEF translator with OpenSTA Engine
The DEF-translator is required for executing Floorplanner and Placement tools. It takes a gate-level netlist and generates flattened DEF file.

## Install on a bare-metal machine
### Pre-requisite
* GCC compiler and libstdc++ static library >= 5.4.0
* tcl (for OpenSTA) >= 8.4
* Recommended OS: Centos6, Centos7 or Ubuntu 16.04

### How to clone and compile the repository:
    $ git clone --recursive https://github.com/abk-openroad/OpenROAD-Utilities.git
    $ cd verilog-to-def
    $ make clean
    $ make

### Example usages for DEF translator 
    $ make test

The output file will be located in *test/usb_phy_generated.def*

### Manuals
* [def-translator's arguments](/verilog-to-def/doc/BinaryArguments.md)

### Verified/supported Technologies
* [ASAP 7](http://asap.asu.edu/asap/)
* TSMC16 7.5T/9T
* CMP28
* [FreePDK 45](http://vlsicad.ucsd.edu/A2A/)
    
### License
* BSD-3-clause License [[link](/verilog-to-def/LICENSE)]

### 3rd Party Module List
* [OpenSTA](https://github.com/abk-openroad/OpenSTA)
* LEF/DEF Parser (Modified by mgwoo)

### Author
* Mingyu Woo
