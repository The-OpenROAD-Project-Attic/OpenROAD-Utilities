CC		=   gcc
CPPC	=   g++
LD      =   ld
OPTFLAG = 	-g -ggdb -m64 -O3 -fPIC -DNDEBUG
# OPTFLAG = 	-g -ggdb -m64 -O3 -fPIC -DNDEBUG -ffast-math -Dcimg_display=1 
WFLAG 	= 	-W -Wall -Wextra -Wunreachable-code 
WSTRICT =	-Werror -Wundef -Wpointer-arith 

INCLUDE = 	-I$(CURDIR) -I$(HASHROOT)/include \
			-I$(LEFROOT)/include -I$(DEFROOT)/include \
  	  -I$(OPENSTAROOT)/include -I$(OPENSTASRCROOT)

CFLAG   =   -std=c11   $(OPTFLAG)  
CPPFLAG =   -std=c++14 $(OPTFLAG)

#Get Only the Internal Structure of SRCDIR Recursively
SRCDIR	= 	$(CURDIR)
STRUCT	=   $(shell find $(SRCDIR) -type d)

#Get All Files inside the STRUCTURE Variable
ALLSRCs =   $(addsuffix /*,$(STRUCT))
ALLSRCs := 	$(wildcard $(ALLSRCs))

#Filter Only Specific Files                                
CFILES  		= 	$(filter %.c,$(ALLSRCs))
CPPFILES		= 	$(filter %.cpp,$(ALLSRCs))
HFILES 			= 	$(filter %.h,$(ALLSRCs))
COBJ			= 	$(subst $(SRCDIR),$(CURDIR),$(CFILES:%.c=%.o))
CPPOBJ			= 	$(subst $(SRCDIR),$(CURDIR),$(CPPFILES:%.cpp=%.o))
OBJFILES		= 	$(COBJ) $(CPPOBJ)

DEPENDS			=   $(HFILES)

HASHROOT 		= ../module/sparsehash/install-sp/
LEFROOT 		= ../module/lef/5.8-p027
DEFROOT 		= ../module/def/5.8-p027

DEFLIB         	= -L$(DEFROOT)/lib -ldef -ldefzlib -lcdef -lcdefzlib
LEFLIB         	= -L$(LEFROOT)/lib -llef -llefzlib -lclef -lclefzlib

OPENSTALIB 		= $(OPENSTAROOT)/lib/libliberty.a \
					$(OPENSTAROOT)/lib/libutil.a \
					$(OPENSTAROOT)/lib/libsearch.a \
					$(OPENSTAROOT)/lib/libdcalc.a \
					$(OPENSTAROOT)/lib/libgraph.a \
					$(OPENSTAROOT)/lib/libnetwork.a \
					$(OPENSTAROOT)/lib/libparasitics.a \
					$(OPENSTAROOT)/lib/libsdc.a \
					$(OPENSTAROOT)/lib/libsdf.a \
					$(OPENSTAROOT)/lib/libverilog.a

OPENSTAROOT 	= ../module/OpenSTA/install-sp/
OPENSTASRCROOT 	= ../module/OpenSTA/

### RULES ###############
%.o:		%.c 	$(DEPENDS)
	@echo " "
	@echo "  Building... $@"
	$(CPPC) $(CPPFLAG) $(IFLUTE) -c -o $@ $< 

%.o:		%.cpp 	$(DEPENDS)
	@touch main.cpp
	@echo " "
	@echo "  Building... $@"
	$(CPPC) $(CPPFLAG) $(INCLUDE) -c -o $@ $< 

defgenerator: $(OBJFILES) $(OPENSTASRCROOT)/app/StaApp_wrap.o \
	$(OPENSTASRCROOT)/app/StaMain.o \
	$(OPENSTASRCROOT)/app/TclInitVar.o
	@echo " "
	@echo "  Linking... with LEF/DEF modules..."
	@echo " "

	$(CPPC) -o $@                               \
	$(CPPFLAG) 					    			\
	$^ 											\
	-Wl,--start-group ${LEFLIB} ${DEFLIB} ${OPENSTALIB} -Wl,--end-group \
	-lgomp -lpthread -lm -ldl -l:./libtcl8.5.so -lz \
	-static-libstdc++	
	@echo " "
	@echo "  Linking is completed !!"
	@echo "- Compiling defgenerater is done."
	@echo " "
	@echo "GNU GCC/G++ compiler has been used."
	@gcc --version
	@echo " "

clean : 
	@echo "Delete: OBJs"
	@rm -rvf $(OBJFILES) 
	@echo "Delete: binary"
	@rm -rvf $(CURDIR)/defgenerater
