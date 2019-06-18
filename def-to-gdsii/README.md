# Magic VLSI layout tool DEF-to-GDSII flow
___
### **Introduction:**

  This is an instruction of DEF-to-GDS conversion flow with [Magic VLSI layout tool](http://opencircuitdesign.com/magic/), the goal is to convert placed and/or routed DEF files into GDSII files which could be used for tape-out. 
___
### **Steps to implement this flow:**

  Get Magic downloaded and installed. You could follow the instructions on the [website of OCD(Open Circuit Design)](http://opencircuitdesign.com/magic/).

- Downloading:

 Stable Distribution (Magic 8.2) Source:
In 2019, Version 8.2 has finally been declared stable enough to supplant version 8.1 as the new stable (and only) distribution. 
  The git system has been changed to a more normal git format, with new development being done in repository branches.
[Download here](http://opencircuitdesign.com/magic/archive/magic-8.2.119.tgz)

- System Requirements:

  These comments were helpfully provided by Jason Schonberg, January 2010. Although specifically for Ubuntu Linux, they provide a good summary of the packages required on all systems. 
  Different distributions of Linux may or may not come with all of the following packages, and missing ones will need to be installed.
Updated October 2018. 
  The reference to BLT has long been deprecated since most BLT functions were absorbed into the Tk distribution. 
  Added the package dependency for the Cairo graphics package (for magic-8.2).

  In order to compile Magic on a vanilla installation of Ubuntu, the following additional packages are needed (at a minimum):

**M4 preprocessor**
```
$ sudo apt-get install m4
```
**tcsh shell**
```
$ sudo apt-get install tcsh
```
**Xlib.h**
```
$ sudo apt-get install libx11-dev
```
  If you wish to have the Tcl/Tk wrapper around magic (recommended) you will need to install the Tcl/Tk libraries. Version 8.5 or higher is highly recommended.

**Tcl/Tk**
```
$ sudo apt-get install tcl-dev tk-dev
```
  The best graphics for Magic is the OpenGL interface ("magic -d OGL"), but since that is problematic for off-screen rendering on many systems, a good alternative is the Cairo graphics interface ("magic -d XR"). This is optional, but if you want to use it, you need the Cairo library development package:

**Cairo**
```
$ sudo apt-get install libcairo2-dev
```
  For the non-Tcl/Tk version only: The readline source makes reference to the `tputs` function which is provided by the ncurses library. Although the ncurses library is installed in Ubuntu, the include files to build against it are not, so the development version is required.

**ncurses**
```
$ sudo apt-get install libncurses-dev
```
- Installation:

  Compiling and Installing Magic From Source:
While it is true that most people want to install and run an executable "out-of-the-box," without worrying about compiling, it is also true that EDA tools are complicated, require a lot of care and maintenance, and usually work best when compiled from the original source code. 
  The developers go to great lengths to make sure that the source code will compile on various systems without trouble.
  In the current stable (8.1) and development (8.2) distributions, compile and install instructions can be found in the INSTALL file in the top-level directory of the source distribution.

  In releases prior to 7.4, see the file README.Tcl in the source distribution for complete instructions on compiling the Tcl/Tk-based version of magic.
	[Installation instructions](http://opencircuitdesign.com/magic/install.html).

___
### **Prepare technology file**
  With at least sections of the following, for more details please read the [manual](http://opencircuitdesign.com/magic/techref/maint2.html), as well there are several examples of technology files you could find on Magic website [link](http://opencircuitdesign.com/magic/tech.html):

- **Tech:**
  Magic stores the technology of a cell in the cell's file on disk. When reading a cell back in to Magic from disk, the cell's technology must match the name of the current technology, which appears as a single word in the tech section of the technology file.

- **Planes:**
  The planes section of the technology file specifies how many planes will be used to store tiles in a given technology, and gives each plane a name. Each line in this section defines a plane by giving a comma-separated list of the names by which it is known.

- **Types:**
  The types section identifies the technology-specific tile types used by Magic. 

- **Contact:**
  The contact section lets Magic know which types are contacts, and the planes 
and component types to which they are connected.

- **Styles:**
  Magic can be run on several different types of graphical displays. Although it would have been possible to incorporate display-specific information into the technology file, a different technology file would have been required for each display type. Instead, the technology file gives one or more display-independent styles for each type that is to be displayed, and uses a per-display-type styles file to map to colors and stipplings specific to the display being used.

- **cifinput:**
  In addition to writing CIF, Magic can also read in CIF files using the cif read file command. The cifinput section of the technology file describes how to convert from CIF mask layers to Magic tile types. In addition, it provides information to the Calma reader to allow it to read in Calma GDS II Stream format files. The cifinput section is very similar to the cifoutput section.

- **cifoutput:**
  The layers stored by Magic do not always correspond to physical mask layers. For example, there is no physical layer corresponding to (the scmos technology file layer) ntransistor; instead, the actual circuit must be built up by overlapping poly and diffusion over pwell. When writing CIF (Caltech Intermediate Form) or Calma GDS-II files, Magic generates the actual geometries that will appear on the masks used to fabricate the circuit. The cifoutput section of the technology file describes how to generate mask layers from Magic's abstract layers.

- **Extract:**
  The extract section of a technology file contains the parameters used by Magic's circuit extractor. Each line in this section begins with a keyword that determines the interpretation of the remainder of the line.

- **Lef:**
  This section defines a mapping between magic layers and layers that may be found in LEF and DEF format files. Without the section, magic cannot read a LEF or DEF file. The LEF and DEF layer declarations are usually simple and straightforward (as they typically define metal layers only), so often it will suffice to insert a plain vanilla lef section into a technology file if one is missing. 
___

### **Prepare TCL file:**
  It reads in DEF, tech LEF, macro LEF, standard cell GDSII, specify topcell, output GDSII file name. 

Example of DEF-to-GDSII conversion script, **_be sure to be saved with “tcl” extension_**:
```
###############################
    box 0 0 0 0
    drc off
    snap int
    lef read <$tech_LEF_path>
    gds readonly true
    gds rescale false
    gds <$GDSII_path>
    def read <$DEF_file_name>
    load <$topcell_name_of_DEF>
    select top cell
    expand
    gds write <$output_GDSII_filename>
    quit -noprompt
###############################
```

  Get it run with batch-mode command:

```magic -dnull -noconsole -T <$techfile> <$run_script>```
- “-dnull -noconsole” to run script in batch mode.
- “-T <$techfile>“ is to specify the technology file name (without extension “.tech)
- “<$run_script>” is a TCL script which includes all commands for magic to run.
___

### **Pitfalls & Troubleshootings:**

- Cannot find standard cell GDSII in PDK folders.

  - Solution: Normally these GDSII files are named with extension “gds2” instead of “gds”.

- Technology file setup incomplete.

  - Solution:  Please follow the rules, essential sections and syntax on the website. With at least sections from aforementioned items in “Steps to implement this flow - section 2”.

- Wrong order of “gds read” and “def read” 

  - Solution:  Place “gds read” before “def read” in order not to merge all standard cells into top level of GDSII.

- Read all corners LEFs and GDSIIs

  - Solution:  Only all VT GDSII files should be read in and tech LEF.

___
### **Testing result:**

#### **06.06.2019**

- Successfully convert 65nm node DEF to GDSII generated by:

  - Cadence Design System Inc. Innovus Digital Implementation Platform.
DARPA OpenROAD Cadre flow. (with 9T/12T, LVT, HVT, and RVT cell libraries and GDSII).

- Output GDSII could be loaded with industry-leading commercial GDSII viewers: 

  - Cadence Design System Inc. PVS K2 QuickView. (Version: PVS 16.1)
 Mentor Graphics Calibre Workbench. (Version: Calibre 2016.1_31.21)


___
### **Acknowledgement:**

- Thanks so much for Tim Edward's efforts on supporting this task.
