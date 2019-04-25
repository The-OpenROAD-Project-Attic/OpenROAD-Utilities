### Configuration File Fields Introduction
Here, the configuration file fields are introduced in the below.  

| Fields | Description | Example  |
| :------ | :----------- | :--------: |
| CELL_NAME | Standard cell name  | AND2X1 |
| SPICEMODEL_FILE | Model Card file path  | ./Free45PDK/gpdk45nm.pm |
| SPICE_NETLIST | CDL SPICE netlist path  | ./Free45PDK/cells.sp |
| LIB_FILE | Cell library file  | ./Free45PDK/gscl45nm.lib |
| RESULT_DIR | SPICE Simulation result path  | ./work/result |
| INPUT_PIN | Input pin of standard cell  | A |
| OUTPUT_PIN | Output pin of standard cell | Y |
| POWER_PIN | Name of power pin  | vdd |
| GROUND_PIN | Name of ground pin | gnd |
| INPUT_SLEW | Slew index range in library | 0 4 |
| CLOAD | Fanout capacitance value (start end increment) | 0 2 1 |
| FANOUT | Instantiate the number of fanout logic | 4 |
| INPUT_PIN_LIST_FILE | Input pin value assignment of standard cell | ./INPUT_ASSIGNMENT |
| CORNER | Corner defined in OpenSTA  | wst/bst |
| unitR | Resistance value per unit length; Resistnace unit is depends on the library (default: 1) | 0.03 |
| unitC | Capacitance value per unit length; Capcitance unit is depends on the library (default: 1) | 0.05 |
| PATH_WIRE_LENGTH | Interconnect Length (um) (default: 1) | 0.5 |

### Example
RESULT_DIR = ./work/result/

INPUT_PIN = A

OUTPUT_PIN = Y

POWER_PIN = vdd

GROUND_PIN = gnd

INPUT_SLEW = 0 3

CLOAD = 0 1 1

FANOUT = 1

INPUT_PIN_LIST_FILE = ./INPUT_ASSIGNMENT

SPICE_DIR = ./work/spice_dump

CORNER = wst

SPICEMODEL_FILE = ../Free45PDK/gpdk45nm.m

LIB_FILE = ../Free45PDK/gscl45nm.lib

SPICE_NETLIST = ../Free45PDK/cells.sp

CELL_NAME = AND2X1

unitR = 0.3 

unitC = 0.5  

PATH_WIRE_LENGTH = 2  

